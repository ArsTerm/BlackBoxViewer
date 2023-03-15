#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <blackboxmodel.h>

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
            "BBViewer", 1, 0, "CanNamesFinder", "Created by BBModel");

    QUrl component("qrc:/qml/main.qml");
    QQmlComponent comp(&engine, component);

    QFile file("C:\\Projects\\BBtest.bin");

    file.open(QFile::ReadWrite);
    file.resize(0);

    ciparser::BBFrame frame;

    uint8_t val = 0;

    frame.id = 84;
    frame.time = ciparser::BBTime();

    for (int i = 0; i < 65; i++) {
        for (int j = 0; j < 8; j++) {
            frame.data.byte[j] = val;
        }
        file.write((char*)&frame, sizeof(frame));
        frame.id = 85;
        file.write((char*)&frame, sizeof(frame));
        frame.id = 84;
        frame.time = ciparser::BBTime(frame.time, 3);
        val += 10;
    }

    file.close();

    auto win = comp.create();

    qDebug() << "Window:" << win;

    return app.exec();
}
