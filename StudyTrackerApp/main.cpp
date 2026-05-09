#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "authmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    AuthManager auth;
    QQmlApplicationEngine engine;

    // Daftarkan backend SEBELUM load
    engine.rootContext()->setContextProperty("backend", &auth);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Load hanya SEKALI
    engine.loadFromModule("StudyTrackerApp", "Main");

    return app.exec();
}
