#include "cannamesfinder.h"
#include <Context/context.h>
#include <QDebug>

BBVIEWER_BEGIN_NS

CanNamesFinder::CanNamesFinder(ciparser::Context const& c, QObject* parent)
    : QAbstractListModel{parent}
{
    for (auto const& [name, _] : c.getIds()) {
        fullNames.push_back(name);
    }
    currNames = fullNames;
}

BBVIEWER_END_NS

int bbviewer::CanNamesFinder::rowCount(const QModelIndex&) const
{
    return currNames.size();
}

QVariant
bbviewer::CanNamesFinder::data(const QModelIndex& index, int role) const
{
    int idx = index.row();

    switch (role) {
    case Qt::DisplayRole:
        return QString::fromStdString(currNames[idx]);
    }
    return QVariant();
}

void bbviewer::CanNamesFinder::addSymbol(char s)
{
    currTemplate.push_back(s);
    currNames.clear();
    filterTemplateData();
}

void bbviewer::CanNamesFinder::removeSymbol()
{
    currTemplate.pop_back();
    currNames.clear();
    filterTemplateData();
}

void bbviewer::CanNamesFinder::setTemplate(const QString& t)
{
    currTemplate = t.toStdString();
    currNames.clear();
    filterTemplateData();
}

// To-do Оптимизировать алгоритм для addSymbol
void bbviewer::CanNamesFinder::filterTemplateData()
{
    beginResetModel();

    for (size_t i = 0; i < fullNames.size(); i++) {
        auto& str = fullNames[i];
        bool find = true;
        auto cmpSize = std::min(str.size(), currTemplate.size());

        for (size_t j = 0; j < cmpSize; j++) {
            if (str[j] != currTemplate[j]) {
                find = false;
            }
        }

        if (find) {
            currNames.push_back(str);
        }
    }

    endResetModel();
}
