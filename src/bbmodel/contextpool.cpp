#include "contextpool.h"
#include <Parser/caninitparser.h>
#include <Parser/parsenode.h>
#include <QDebug>
#include <Visitor/caninitvisitor.h>
#include <Visitor/nodes/astnode.h>

#include <compiler.h>

BBVIEWER_BEGIN_NS

ContextHandle::ContextHandle(QString const& bbName, QString const& ciName)
    : bbFile(bbName), ciFile(ciName), refCount(1)
{
    if (!bbFile.open(QFile::ReadOnly)) {
        assert(false);
    }
    if (!ciFile.open(QFile::ReadOnly)) {
        assert(false);
    }

    auto data = (char*)ciFile.map(0, ciFile.size());

    ciparser::CanInitParser parser(
            std::make_unique<ciparser::CanInitLexer>(data, ciFile.size()));

    ciparser::CanInitVisitor visitor;

    auto parseNode = parser.parse();
    auto astNode = visitor.visit(parseNode);

    cicompiler::Compiler compiler;
    compiler.parseSet(visitor.get_ids(), "mycompile.json");

    auto bbdata = (ciparser::BBFrame*)bbFile.map(0, bbFile.size());

    new (&context) ciparser::Context(
            bbdata, bbFile.size() / sizeof(*bbdata), visitor.get_ids());

    delete parseNode;
    delete astNode;
}

bool ContextHandle::contains(const std::string& value)
{
    return !context.handle(value).isNull();
}

const ciparser::ValuesArray&
ContextHandle::value(const std::string& name, size_t position)
{
    auto& val = data[name];

    if (val.endPosition < position) {
        if (val.endPosition != context.position()) {
            val.array.reset();
            context.reset();
        }
        auto handle = context.handle(name);
        val.array.insert(context.position(), *handle);
        while (context.position() != position) {
            if (context.incTick()) {
                val.array.insert(context.position(), *handle);
            }
        }
        val.endPosition = context.position();
    }

    return val.array;
}

ciparser::Message::Type ContextHandle::type(const std::string& name)
{
    auto handle = context.handle(name);
    return handle.type();
}

ContextHandle* ContextPool::get(QString const& bbName, QString const& ciName)
{
    auto it = std::find_if(
            handles.begin(),
            handles.end(),
            [&bbName, &ciName](auto const& handle) {
                return handle->equal(bbName, ciName);
            });
    if (it == handles.end()) {
        handles.emplace_back(new ContextHandle(bbName, ciName));
        return handles[handles.size() - 1];
    }
    (*it)->ref();
    return *it;
}

void ContextPool::free(ContextHandle const* h)
{
    auto it = std::find(handles.begin(), handles.end(), h);
    if (it != handles.end()) {
        if ((*it)->deref()) {
            delete *it;
            handles.erase(it);
        }
    }
}

BBVIEWER_END_NS
