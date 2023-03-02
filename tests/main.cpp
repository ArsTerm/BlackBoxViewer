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

    QQmlApplicationEngine engine;

    qRegisterMetaType<size_t>("size_t");

    qmlRegisterType<BlackBoxModel>("BBViewer", 1, 0, "BBModel");

    QUrl component("qrc:/qml/main.qml");
    QQmlComponent comp(&engine, component);

    QFile file("BBtest.bin");

    file.open(QFile::ReadWrite);

    ciparser::BBFrame frame;

    uint8_t val = 0;

    frame.id = 83;
    frame.time = ciparser::BBTime();

    for (int i = 0; i < 65; i++) {
        for (int j = 0; j < 8; j++) {
            frame.data.byte[j] = val;
        }
        file.write((char*)&frame, sizeof(frame));
        frame.time = ciparser::BBTime(frame.time, 1);
        val++;
    }

    file.close();

    auto win = comp.create();

    qDebug() << "Window:" << win;

    return app.exec();
}
