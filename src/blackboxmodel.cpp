#include "blackboxmodel.h"
#include <Parser/caninitparser.h>
#include <QDebug>
#include <QFile>
#include <Visitor/caninitvisitor.h>
#include <cassert>

BBVIEWER_BEGIN_NS

ContextPool BlackBoxModel::cpool;

BlackBoxModel::BlackBoxModel()
{
}

void BlackBoxModel::updateContext()
{
    beginResetModel();
    if (handle) {
        cpool.free(handle);
    }
    handle = cpool.get(
            sourceFile.toLocalFile(), QStringLiteral(CANINIT_TEST_PATH));
    endResetModel();

    emit sourceChanged();
    setPosition(handle->begin());
    //    sourceFileObj.close();
    //    sourceFileObj.setFileName(sourceFile.toLocalFile());

    //    if (!sourceFileObj.open(QFile::ReadOnly)) {
    //        assert(false);
    //    }

    //    auto data = (ciparser::BBFrame*)sourceFileObj.map(0,
    //    sourceFileObj.size());

    //    context.setData(data, sourceFileObj.size() / sizeof(*data));

    //    collectData();
}

ciparser::Context BlackBoxModel::getCanInitData()
{
    QFile file(QStringLiteral(CANINIT_TEST_PATH));

    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        assert(false);
    }
    auto data = (char*)file.map(0, file.size());

    ciparser::CanInitParser parser(
            std::make_unique<ciparser::CanInitLexer>(data, file.size()));

    ciparser::CanInitVisitor visitor;

    visitor.visit(parser.parse());

    return ciparser::Context(nullptr, 0, visitor.get_ids());
}

void BlackBoxModel::updatePosition(size_t newPos)
{
    //    qDebug() << "Update postion:" << context.position() << newPos;

    //    context.reset();

    //    while (context.position() != newPos)
    //        context.incTick();

    //    beginResetModel();
    //    collectData();
    //    endResetModel();

    emit positionChanged();
}

void BlackBoxModel::collectData()
{
    //    auto value = context.handle("I_Can");
    //    values.reset();

    //    values.insert(context.position(), *value);

    //    for (int i = 0; i < padSize; i++) {
    //        if (context.incTick()) {
    //            values.insert(context.position(), *value);
    //        }
    //    }
}

int BlackBoxModel::rowCount(const QModelIndex& parent) const
{
    return padSize;
}

QVariant BlackBoxModel::data(const QModelIndex& index, int role) const
{
    if (!values || !handle)
        return QVariant();
    int idx = index.row();

    switch (role) {
    case Qt::DisplayRole:
        return (*values)[currPosition + idx];
    }
    return QVariant();
}

BBVIEWER_END_NS
