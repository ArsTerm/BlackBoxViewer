#pragma once

#include "blackboxviewer_global.h"
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
        return context.position() - 100;
    }

    void setPosition(size_t newPos)
    {
        qDebug() << "Set position:" << newPos;
        if (newPos + 100 != context.position()) {
            updatePosition(newPos);
        }
    }

private:
    QUrl sourceFile;
    QFile sourceFileObj;
    ciparser::Context context;
    int values[100];

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
