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
    qDebug() << "Set position:" << newPos;
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

bool BlackBoxModel::contains(const QString& value) const
{
    if (!handle)
        return false;
    return handle->contains(value.toStdString());
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

    switch (role) {
    case Qt::DisplayRole:
        return (*values)[currPosition + idx * m_step];
    }
    return QVariant();
}

BBVIEWER_END_NS
