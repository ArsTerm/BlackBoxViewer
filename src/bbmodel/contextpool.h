#pragma once

#include "blackboxviewer_global.h"
#include <Context/context.h>
#include <Context/types/valuesarray.h>
#include <QFile>
#include <unordered_map>

BBVIEWER_BEGIN_NS

class ContextHandle {
    friend class ContextPool;

public:
    ContextHandle(QString const& bbName, QString const& ciName);

    bool equal(QString const& bbName, QString const& ciName) const
    {
        return bbFile.fileName() == bbName && ciFile.fileName() == ciName;
    }

    friend bool operator==(ContextHandle const& l, ContextHandle const& r)
    {
        return l.equal(r.bbFile.fileName(), r.ciFile.fileName());
    }

    size_t begin() const
    {
        return context.beginTime().toTicks();
    }

    size_t end() const
    {
        return context.endTime().toTicks();
    }

    bool contains(std::string const& value);

    ciparser::ValuesArray const&
    value(std::string const& name, size_t position);

    ciparser::Context const& getContext() const
    {
        return context;
    }

private:
    struct Data {
        size_t endPosition = 0;
        ciparser::ValuesArray array;
    };
    std::unordered_map<std::string, Data> data;
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
