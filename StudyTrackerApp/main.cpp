#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSslConfiguration>  
#include "authmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QSslConfiguration::setDefaultConfiguration(QSslConfiguration::defaultConfiguration());

    AuthManager auth;
    QQmlApplicationEngine engine;

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
