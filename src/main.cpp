#include <QApplication>
#include <QFont>
#include "mainwindow.h"

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);

    // Font default
    QFont font("Segoe UI", 10);
    app.setFont(font);

    MainWindow win;
    win.show();

    return app.exec();
}
