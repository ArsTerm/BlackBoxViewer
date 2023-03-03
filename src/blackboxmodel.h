#pragma once

#include "blackboxviewer_global.h"
#include "contextpool.h"
#include <Context/context.h>
#include <QAbstractListModel>
#include <QDebug>
#include <QFile>
#include <QUrl>

BBVIEWER_BEGIN_NS

class BlackBoxModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(size_t position READ position WRITE setPosition NOTIFY
                       positionChanged)
public:
    BlackBoxModel();

    void setSource(QUrl const& source)
    {
        if (sourceFile != source) {
            sourceFile = source;
            updateContext();
            emit sourceChanged();
        }
    }

    QUrl const& source() const
    {
        return sourceFile;
    }

    size_t position() const
    {
        return currPosition;
    }

    void setPosition(size_t newPos)
    {
        qDebug() << "Set position:" << newPos;
        if (newPos < handle->begin()) {
            newPos = handle->begin();
        }
        currPosition = newPos;
        beginResetModel();
        values = &handle->value("I91_frn", newPos + padSize);
        endResetModel();
        emit positionChanged();
    }

    ~BlackBoxModel() override
    {
        if (handle) {
            cpool.free(handle);
        }
    }

private:
    QUrl sourceFile;
    QFile sourceFileObj;
    size_t currPosition = 0;
    ContextHandle* handle = nullptr;
    ciparser::ValuesArray const* values = nullptr;
    static constexpr size_t padSize = 100;
    static ContextPool cpool;

    void updateContext();
    ciparser::Context getCanInitData();
    void updatePosition(size_t newPos);
    void collectData();

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

signals:
    void sourceChanged();
    void positionChanged();
};

BBVIEWER_END_NS
