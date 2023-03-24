#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <blackboxmodel.h>
#include <cannamesfinder.h>

using namespace bbviewer;

int main(int argc, char* argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    Q_INIT_RESOURCE(qmltypes);

    QQmlApplicationEngine engine;

    engine.addImportPath(":/qml");

    QDir dir(":/qml");

    qDebug() << "Dir entry:" << dir.entryList();

    qRegisterMetaType<size_t>("size_t");

    qmlRegisterType<BlackBoxModel>("BBViewer", 1, 0, "BBModel");
    qmlRegisterUncreatableType<CanNamesFinder>(
            "BBViewer",
            1,
            0,
            "CanNamesFinder",
            QStringLiteral("Created by BBModel"));

    QUrl component(QStringLiteral("qrc:/qml/main.qml"));
    QQmlComponent comp(&engine, component);

    comp.create();

    return app.exec();
}
