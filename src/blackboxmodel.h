#pragma once

#include "blackboxviewer_global.h"
#include <Context/context.h>
#include <QAbstractListModel>
#include <QUrl>

BBVIEWER_BEGIN_NS

class BlackBoxModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
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

private:
    QUrl sourceFile;
    ciparser::Context context;
    int values[100];

    void updateContext();
    ciparser::Context getCanInitData();

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

signals:
    void sourceChanged();
};

BBVIEWER_END_NS
