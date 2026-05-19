#pragma once
#include <QMainWindow>
#include <QStackedWidget>
#include <QTimer>
#include "loginscreen.h"
#include "homescreen.h"
#include "taskscreen.h"
#include "timerscreen.h"
#include "statsscreen.h"
#include "friendscreen.h"
#include "settingsscreen.h"
#include "navigationbar.h"
#include "notificationbanner.h"
#include "appstate.h"

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override = default;

private slots:
    void onLoginSuccess(const QString& username, const QString& avatar);
    void onLogout();
    void navigateTo(const QString& screen);
    void onThemeChanged();
    void onTimerStart();
    void onTimerStop();
    void onTimerSkip();

private:
    // Screens
    LoginScreen*    loginScreen;
    HomeScreen*     homeScreen;
    TaskScreen*     taskScreen;
    TimerScreen*    timerScreen;
    StatsScreen*    statsScreen;
    FriendScreen*   friendScreen;
    SettingsScreen* settingsScreen;

    // Layout widgets
    QWidget*        mainContainer;   // holds nav + stacked
    QStackedWidget* stackedScreens;
    NavigationBar*  navBar;
    NotificationBanner* notifBanner;

    // Root stacked (login vs main)
    QStackedWidget* rootStack;

    void buildUi();
    void applyGlobalStyle();
    void refreshAllScreens();
};
