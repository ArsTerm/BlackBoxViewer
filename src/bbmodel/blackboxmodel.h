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
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
public:
    BlackBoxModel();

    void setSource(QUrl const& source)
    {
        if (sourceFile != source) {
            sourceFile = source;
            updateContext();
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

    void setPosition(size_t newPos);

    ~BlackBoxModel() override
    {
        if (handle) {
            cpool.free(handle);
        }
    }

    QString const& value() const
    {
        return m_value;
    }

    void setValue(QString const& val)
    {
        if (val != m_value) {
            m_value = val;
            updateValue();
        }
    }

    Q_INVOKABLE bool contains(QString const& value) const;

private:
    QUrl sourceFile;
    QFile sourceFileObj;
    size_t currPosition = 0;
    QString m_value;
    ContextHandle* handle = nullptr;
    ciparser::ValuesArray const* values = nullptr;
    static constexpr size_t padSize = 100;
    static ContextPool cpool;

    void updateContext();
    void updateValue();

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

signals:
    void sourceChanged();
    void positionChanged();
    void valueChanged();
};

BBVIEWER_END_NS
