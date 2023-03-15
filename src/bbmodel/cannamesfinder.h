#ifndef CANNAMESFINDER_H
#define CANNAMESFINDER_H

#include "blackboxviewer_global.h"
#include <QAbstractListModel>

namespace ciparser {
class Context;
}

BBVIEWER_BEGIN_NS

class CanNamesFinder : public QAbstractListModel {
    Q_OBJECT
public:
    explicit CanNamesFinder(
            ciparser::Context const& c, QObject* parent = nullptr);

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

    Q_INVOKABLE void addSymbol(char s);
    Q_INVOKABLE void removeSymbol();
    Q_INVOKABLE void setTemplate(QString const& t);

private:
    std::string currTemplate;
    std::vector<std::string> currNames;
    std::vector<std::string> fullNames;

    void filterTemplateData();
};

BBVIEWER_END_NS

#endif // CANNAMESFINDER_H
