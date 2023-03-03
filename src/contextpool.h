#pragma once

#include "blackboxviewer_global.h"
#include <Context/context.h>
#include <QFile>

BBVIEWER_BEGIN_NS

class ContextHandle {
    friend class ContextPool;

public:
    ContextHandle(QString const& bbName, QString const& ciName);

    ciparser::Context& get();

    bool equal(QString const& bbName, QString const& ciName) const
    {
        return bbFile.fileName() == bbName && ciFile.fileName() == ciName;
    }

    friend bool operator==(ContextHandle const& l, ContextHandle const& r)
    {
        return l.equal(r.bbFile.fileName(), r.ciFile.fileName());
    }

private:
    ciparser::Context context;
    QFile bbFile;
    QFile ciFile;
    size_t refCount;

    void ref()
    {
        refCount++;
    }

    bool deref()
    {
        return --refCount == 0;
    }
};

class ContextPool {
public:
    ContextHandle* get(QString const& bbName, QString const& ciName);
    void free(ContextHandle const* c);

private:
    std::vector<ContextHandle*> handles;
};

BBVIEWER_END_NS
