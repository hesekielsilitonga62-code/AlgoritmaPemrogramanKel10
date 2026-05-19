#include "mainwindow.h"
#include "styles.h"
#include <QVBoxLayout>
#include <QWidget>
#include <QApplication>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    setWindowTitle("Study Tracker — Kelompok 10");
    // Mobile-like window size
    setFixedSize(390, 844);

    buildUi();
    applyGlobalStyle();
}

void MainWindow::buildUi() {
    // ── Root central widget ──
    auto* central = new QWidget(this);
    setCentralWidget(central);
    auto* rootLay = new QVBoxLayout(central);
    rootLay->setContentsMargins(0,0,0,0);
    rootLay->setSpacing(0);

    // ── Root stack: Login  <->  Main App ──
    rootStack = new QStackedWidget(central);
    rootLay->addWidget(rootStack);

    // ── Login screen ──
    loginScreen = new LoginScreen();
    rootStack->addWidget(loginScreen);
    connect(loginScreen, &LoginScreen::loginSuccess,
            this, &MainWindow::onLoginSuccess);

    // ── Main app container ──
    mainContainer = new QWidget();
    auto* mainLay = new QVBoxLayout(mainContainer);
    mainLay->setContentsMargins(0,0,0,0);
    mainLay->setSpacing(0);

    // Notification banner (overlay di atas)
    notifBanner = new NotificationBanner(mainContainer);
    notifBanner->setGeometry(0, 0, 390, 72);
    notifBanner->raise();

    // Stacked screens (tanpa nav)
    stackedScreens = new QStackedWidget(mainContainer);

    homeScreen     = new HomeScreen();
    taskScreen     = new TaskScreen();
    timerScreen    = new TimerScreen();
    statsScreen    = new StatsScreen();
    friendScreen   = new FriendScreen();
    settingsScreen = new SettingsScreen();

    stackedScreens->addWidget(homeScreen);     // index 0
    stackedScreens->addWidget(taskScreen);     // index 1
    stackedScreens->addWidget(timerScreen);    // index 2
    stackedScreens->addWidget(statsScreen);    // index 3
    stackedScreens->addWidget(friendScreen);   // index 4
    stackedScreens->addWidget(settingsScreen); // index 5

    mainLay->addWidget(stackedScreens, 1);

    // Navigation bar (bottom)
    navBar = new NavigationBar(mainContainer);
    mainLay->addWidget(navBar);

    rootStack->addWidget(mainContainer);

    // ── Connections ──
    connect(navBar, &NavigationBar::screenRequested,
            this, &MainWindow::navigateTo);

    connect(homeScreen, &HomeScreen::navigateTo,
            this, &MainWindow::navigateTo);
    connect(homeScreen, &HomeScreen::timerStartRequested,
            this, &MainWindow::onTimerStart);
    connect(homeScreen, &HomeScreen::timerStopRequested,
            this, &MainWindow::onTimerStop);
    connect(homeScreen, &HomeScreen::timerSkipRequested,
            this, &MainWindow::onTimerSkip);

    connect(timerScreen, &TimerScreen::notifyRequested,
            notifBanner, &NotificationBanner::push);
    connect(timerScreen, &TimerScreen::sessionCompleted,
            this, [this](int /*s*/){ homeScreen->refresh(); });

    connect(settingsScreen, &SettingsScreen::logoutRequested,
            this, &MainWindow::onLogout);
    connect(settingsScreen, &SettingsScreen::themeChanged,
            this, &MainWindow::onThemeChanged);

    // Show login first
    rootStack->setCurrentIndex(0);
}

void MainWindow::onLoginSuccess(const QString& username, const QString& avatar) {
    Q_UNUSED(avatar)
    AppState::instance().currentUser   = username;
    AppState::instance().currentAvatar = "😀";
    AppState::instance().isLoggedIn    = true;

    // Streak: tandai hari ini
    AppState::instance().streakDays[6] = true;
    AppState::instance().streakCount   = 1;

    rootStack->setCurrentIndex(1); // tampilkan main app
    navigateTo("main");
    refreshAllScreens();
}

void MainWindow::onLogout() {
    AppState::instance().isLoggedIn    = false;
    AppState::instance().timerRunning  = false;
    AppState::instance().timerRemaining= 0;
    loginScreen->reset();
    rootStack->setCurrentIndex(0);
}

void MainWindow::navigateTo(const QString& screen) {
    int idx = 0;
    if      (screen == "main")     idx = 0;
    else if (screen == "tasks")    idx = 1;
    else if (screen == "timer")    idx = 2;
    else if (screen == "stats")    idx = 3;
    else if (screen == "friends")  idx = 4;
    else if (screen == "settings") idx = 5;

    stackedScreens->setCurrentIndex(idx);
    navBar->setActive(screen);

    // Refresh layar yang dituju
    if (screen == "main")     homeScreen->refresh();
    if (screen == "tasks")    taskScreen->refresh();
    if (screen == "timer")    timerScreen->refresh();
    if (screen == "stats")    statsScreen->refresh();
    if (screen == "friends")  friendScreen->refresh();
    if (screen == "settings") settingsScreen->refresh();
}

void MainWindow::onThemeChanged() {
    applyGlobalStyle();
    homeScreen->applyStyle();
    taskScreen->applyStyle();
    timerScreen->applyStyle();
    statsScreen->applyStyle();
    friendScreen->applyStyle();
    settingsScreen->applyStyle();
    navBar->applyStyle();
}

void MainWindow::onTimerStart() {
    timerScreen->start();
    homeScreen->refresh();
}
void MainWindow::onTimerStop() {
    timerScreen->stop();
    homeScreen->refresh();
}
void MainWindow::onTimerSkip() {
    timerScreen->skip();
    homeScreen->refresh();
}

void MainWindow::applyGlobalStyle() {
    auto& t = AppState::instance().theme;
    qApp->setStyleSheet(ST::buildStyleSheet(t));
    // Override window background
    setStyleSheet(QString("QMainWindow { background:%1; }").arg(t.bgPrimary));
}

void MainWindow::refreshAllScreens() {
    homeScreen->refresh();
    taskScreen->refresh();
    timerScreen->refresh();
    statsScreen->refresh();
    friendScreen->refresh();
    settingsScreen->refresh();
}
