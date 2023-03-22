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
}

void BlackBoxModel::updateValue()
{
    if (!handle)
        return;
    auto type = handle->type(m_value.toStdString());
    switch (type) {
    case ciparser::Message::Int16:
        setMaxVal(32768);
        setMinVal(-32768);
        break;
    case ciparser::Message::Uint16:
        setMaxVal(65536);
        setMinVal(0);
        break;
    case ciparser::Message::Int8:
        setMaxVal(128);
        setMinVal(-128);
        break;
    case ciparser::Message::Uint8:
        setMaxVal(256);
        setMinVal(0);
        break;
    case ciparser::Message::Bit:
        setMaxVal(1);
        setMinVal(0);
        break;
    }
    updateValues();
    emit valueChanged();
}

void BlackBoxModel::updateValues()
{
    beginResetModel();
    values = &handle->value(
            m_value.toStdString(), currPosition + padSize * m_step);
    endResetModel();
}

void BlackBoxModel::setPosition(size_t newPos)
{
    if (!handle || newPos == currPosition)
        return;
    if (padSize * m_step > handle->end()) {
        newPos = 0;
    } else if (newPos < handle->begin()) {
        newPos = handle->begin();
    } else if (newPos + padSize * m_step > handle->end()) {
        newPos = handle->end() - padSize * m_step;
    }
    currPosition = newPos;
    if (!m_value.isNull()) {
        updateValues();
    }
    emit positionChanged();
}

void BlackBoxModel::setStep(int value)
{
    if (m_step != value) {
        m_step = value;
        if (handle) {
            if (padSize * m_step > handle->end())
                setPosition(0);
        }
        if (!m_value.isNull())
            updateValues();
        emit stepChanged();
    }
}

QObject* BlackBoxModel::finder() const
{
    if (!handle)
        return nullptr;
    return new CanNamesFinder(handle->getContext());
}

bool BlackBoxModel::contains(const QString& value) const
{
    if (!handle)
        return false;
    return handle->contains(value.toStdString());
}

QString BlackBoxModel::positionToString(int position)
{
    ciparser::BBTime time(position);
    auto result = QString(QStringLiteral("%1:%2:%3"))
                          .arg((int)time.hour, 2, 10, QLatin1Char('0'))
                          .arg((int)time.minutes, 2, 10, QLatin1Char('0'))
                          .arg((int)time.seconds, 2, 10, QLatin1Char('0'));
    return result;
}

int BlackBoxModel::rowCount(const QModelIndex&) const
{
    return padSize;
}

QVariant BlackBoxModel::data(const QModelIndex& index, int role) const
{
    if (!values || !handle)
        return QVariant();
    int idx = index.row();
    int nextIdx = idx == padSize - 1 ? idx : idx + 1;

    switch (role) {
    case Qt::DisplayRole:
        return (*values)[currPosition + idx * m_step];
    case NextValue:
        return (*values)[currPosition + nextIdx * m_step];
    }
    return QVariant();
}

QHash<int, QByteArray> BlackBoxModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "display";
    roles[NextValue] = "nextValue";

    return roles;
}

BBVIEWER_END_NS
