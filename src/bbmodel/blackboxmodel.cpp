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
    beginResetModel();
    values = &handle->value(m_value.toStdString(), currPosition + padSize);
    endResetModel();
    emit valueChanged();
}

void BlackBoxModel::setPosition(size_t newPos)
{
    if (!handle)
        return;
    qDebug() << "Set position:" << newPos;
    if (newPos < handle->begin()) {
        newPos = handle->begin();
    } else if (newPos + padSize > handle->end()) {
        newPos = handle->end() - padSize;
    }
    currPosition = newPos;
    if (!m_value.isNull()) {
        beginResetModel();
        values = &handle->value(m_value.toStdString(), newPos + padSize);
        endResetModel();
    }
    emit positionChanged();
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
        return (*values)[currPosition + idx];
    }
    return QVariant();
}

BBVIEWER_END_NS
