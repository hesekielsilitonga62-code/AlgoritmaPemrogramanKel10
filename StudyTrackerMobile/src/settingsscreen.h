#pragma once
#include <QWidget>
#include <QLabel>
#include <QPushButton>
#include "appstate.h"

class SettingsScreen : public QWidget {
    Q_OBJECT
public:
    explicit SettingsScreen(QWidget* parent = nullptr);
    void refresh();
    void applyStyle();

signals:
    void logoutRequested();
    void themeChanged();

private:
    QLabel*      lblAvatar;
    QLabel*      lblName;
    QLabel*      lblStatus;
    QPushButton* btnNotifTugas;
    QPushButton* btnNotifBelajar;
    QPushButton* btnNotifTeman;
    QList<QPushButton*> themeBtns;

    void buildUi();
    void setToggle(QPushButton* btn, bool on);
    void applyThemeDots();
};
