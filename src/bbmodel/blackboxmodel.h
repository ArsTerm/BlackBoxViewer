#pragma once

#include "blackboxviewer_global.h"
#include "cannamesfinder.h"
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
    Q_PROPERTY(int step READ step WRITE setStep NOTIFY stepChanged)
    Q_PROPERTY(int maxVal READ maxVal WRITE setMaxVal NOTIFY maxValChanged)
public:
    enum Roles { NextValue = Qt::UserRole + 1 };

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

    int step() const
    {
        return m_step;
    }

    void setStep(int value);

    int maxVal() const
    {
        return m_maxVal;
    }

    void setMaxVal(int maxVal)
    {
        if (m_maxVal != maxVal) {
            m_maxVal = maxVal;
            emit maxValChanged();
        }
    }

    Q_INVOKABLE QObject* finder() const;
    Q_INVOKABLE bool contains(QString const& value) const;

private:
    QUrl sourceFile;
    QFile sourceFileObj;
    size_t currPosition = -1;
    QString m_value;
    ContextHandle* handle = nullptr;
    ciparser::ValuesArray const* values = nullptr;
    int m_step = 1;
    int m_maxVal = 128;
    static constexpr size_t padSize = 100;
    static ContextPool cpool;

    void updateContext();
    void updateValue();
    void updateValues();

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void sourceChanged();
    void positionChanged();
    void valueChanged();
    void stepChanged();
    void maxValChanged();
};

BBVIEWER_END_NS
