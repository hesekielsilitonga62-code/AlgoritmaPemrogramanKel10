#pragma once
#include <QWidget>
#include <QLabel>
#include <QPushButton>
#include <QTimer>
#include <QPropertyAnimation>
#include "appstate.h"

class NotificationBanner : public QWidget {
    Q_OBJECT
public:
    explicit NotificationBanner(QWidget* parent = nullptr);
    void push(const QString& icon, const QString& title, const QString& body);

private slots:
    void hideBanner();

private:
    QLabel*  lblIcon;
    QLabel*  lblTitle;
    QLabel*  lblBody;
    QPushButton* btnClose;
    QTimer*  autoHide;
    void applyStyle();
};
