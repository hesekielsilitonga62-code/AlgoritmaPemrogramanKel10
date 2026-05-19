#include "statsscreen.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QScrollArea>
#include <QFrame>
#include <QTime>
#include <cstdlib>

StatsScreen::StatsScreen(QWidget* parent) : QWidget(parent) {
    buildUi();
    applyStyle();
    connect(&AppState::instance(), &AppState::statsChanged, this, &StatsScreen::refresh);
    connect(&AppState::instance(), &AppState::timerTick,    this, &StatsScreen::refresh);
}

void StatsScreen::buildUi() {
    auto* root = new QVBoxLayout(this);
    root->setContentsMargins(0,0,0,0); root->setSpacing(0);

    // Status bar
    auto* sb = new QWidget(this); sb->setObjectName("statusBar"); sb->setFixedHeight(44);
    auto* sbL = new QHBoxLayout(sb); sbL->setContentsMargins(20,0,20,0);
    auto* sbTime = new QLabel(QTime::currentTime().toString("HH:mm"), sb); sbTime->setObjectName("statusTime");
    auto* sbMid  = new QLabel("Statistik", sb); sbMid->setObjectName("labelMuted");
    sbL->addWidget(sbTime); sbL->addStretch(); sbL->addWidget(sbMid); sbL->addStretch();
    sbL->addWidget(new QLabel("📶 🔋", sb));
    root->addWidget(sb);

    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    auto* inner = new QWidget();
    auto* cl = new QVBoxLayout(inner);
    cl->setContentsMargins(16,16,16,24); cl->setSpacing(14);
    scroll->setWidget(inner);
    root->addWidget(scroll, 1);

    auto& t = AppState::instance().theme;

    // Big stat cards
    auto makeBigCard = [&](const QString& icon, QLabel*& valLbl, const QString& lbl) -> QFrame* {
        auto* card = new QFrame(inner); card->setObjectName("statCardBig");
        auto* lay = new QVBoxLayout(card); lay->setContentsMargins(18,18,18,18); lay->setSpacing(6);
        auto* iconW = new QLabel(icon, card); iconW->setObjectName("statCardIcon");
        valLbl = new QLabel("0", card); valLbl->setObjectName("statCardVal");
        auto* lbLbl = new QLabel(lbl, card); lbLbl->setObjectName("statCardLbl");
        lay->addWidget(iconW); lay->addWidget(valLbl); lay->addWidget(lbLbl);
        return card;
    };

    // Row 1 — 2 cards
    auto* row1 = new QHBoxLayout(); row1->setSpacing(12);
    row1->addWidget(makeBigCard("🕐", lblTotalHours, "Total Jam Belajar"));
    row1->addWidget(makeBigCard("🍅", lblSessions,   "Total Sesi Pomodoro"));
    auto* rw1W = new QWidget(inner); rw1W->setLayout(row1);
    cl->addWidget(rw1W);

    auto* row2 = new QHBoxLayout(); row2->setSpacing(12);
    row2->addWidget(makeBigCard("📋", lblTasks,   "Total Tugas"));
    row2->addWidget(makeBigCard("✅", lblDone,    "Tugas Selesai"));
    auto* rw2W = new QWidget(inner); rw2W->setLayout(row2);
    cl->addWidget(rw2W);

    auto* row3 = new QHBoxLayout(); row3->setSpacing(12);
    row3->addWidget(makeBigCard("🔥", lblStreak,   "Streak Hari Ini"));
    row3->addWidget(makeBigCard("⏱",  lblAvgDaily, "Rata-rata Harian"));
    auto* rw3W = new QWidget(inner); rw3W->setLayout(row3);
    cl->addWidget(rw3W);

    // Weekly chart
    auto* chartCard = new QFrame(inner); chartCard->setObjectName("weeklyChartCard");
    auto* chartLay  = new QVBoxLayout(chartCard); chartLay->setContentsMargins(18,16,18,16); chartLay->setSpacing(12);
    auto* chartTitle = new QLabel("📈 Aktivitas 7 Hari Terakhir", chartCard); chartTitle->setObjectName("chartTitle");
    chartLay->addWidget(chartTitle);

    auto* barArea = new QWidget(chartCard);
    auto* barLay  = new QHBoxLayout(barArea);
    barLay->setContentsMargins(0,0,0,0); barLay->setSpacing(6);
    barLay->setAlignment(Qt::AlignBottom);

    QStringList days = {"Sen","Sel","Rab","Kam","Jum","Sab","Min"};
    // Dummy data untuk 7 hari
    QList<int> data = {45,90,30,120,60,0,75};
    int maxVal = *std::max_element(data.begin(), data.end());
    if (maxVal == 0) maxVal = 1;

    for (int i = 0; i < 7; i++) {
        auto* col = new QWidget(barArea);
        auto* cLay = new QVBoxLayout(col);
        cLay->setContentsMargins(0,0,0,0); cLay->setSpacing(4);
        cLay->setAlignment(Qt::AlignBottom | Qt::AlignHCenter);

        auto* bar = new QWidget(col); bar->setObjectName("weekBar");
        int barH = (int)((double)data[i] / maxVal * 100) + 4;
        bar->setFixedHeight(barH);
        bar->setStyleSheet(QString("background:%1; border-radius:4px;").arg(t.accent));
        barWidgets.append(bar);

        auto* lbl = new QLabel(days[i], col);
        lbl->setObjectName("labelMutedSmall");
        lbl->setAlignment(Qt::AlignCenter);
        barLabels.append(lbl);

        cLay->addWidget(bar);
        cLay->addWidget(lbl);
        barLay->addWidget(col, 1);
    }

    barArea->setFixedHeight(130);
    chartLay->addWidget(barArea);
    cl->addWidget(chartCard);

    // Top tasks section
    auto* taskTitle = new QLabel("🏆 Mata Kuliah Terbanyak", inner);
    taskTitle->setObjectName("sectionTitle");
    cl->addWidget(taskTitle);

    listContainer = new QWidget(inner);
    auto* lcLay = new QVBoxLayout(listContainer);
    lcLay->setContentsMargins(0,0,0,0); lcLay->setSpacing(8);

    // Placeholder rows
    QStringList subjects = {"Algoritma Pemrograman", "Matematika Diskrit", "Basis Data", "Jaringan Komputer"};
    QList<int> pcts = {75, 60, 45, 30};
    for (int i = 0; i < subjects.size(); i++) {
        auto* row = new QFrame(listContainer); row->setObjectName("subjectRow");
        auto* rLay = new QHBoxLayout(row); rLay->setContentsMargins(14,12,14,12); rLay->setSpacing(10);
        auto* lbNum = new QLabel(QString::number(i+1), row); lbNum->setObjectName("rankNum");
        lbNum->setFixedWidth(24); lbNum->setAlignment(Qt::AlignCenter);
        auto* lbName = new QLabel(subjects[i], row); lbName->setObjectName("subjectName");
        auto* lbPct  = new QLabel(QString("%1%").arg(pcts[i]), row); lbPct->setObjectName("subjectPct");
        rLay->addWidget(lbNum); rLay->addWidget(lbName, 1); rLay->addWidget(lbPct);
        lcLay->addWidget(row);
    }
    cl->addWidget(listContainer);
    cl->addStretch();

    refresh();
}

void StatsScreen::refresh() {
    auto& app = AppState::instance();
    int h = app.totalStudySecs / 3600;
    int m = (app.totalStudySecs % 3600) / 60;
    lblTotalHours->setText(h > 0 ? QString("%1j %2m").arg(h).arg(m) : QString("%1m").arg(m));
    lblSessions->setText(QString::number(app.sessions));
    lblTasks->setText(QString::number(app.tasksTotal()));
    lblDone->setText(QString::number(app.tasksDone()));
    lblStreak->setText(QString("%1 hari").arg(app.streakCount));
    int avg = app.sessions > 0 ? (app.totalStudySecs / app.sessions / 60) : 0;
    lblAvgDaily->setText(QString("%1m").arg(avg));
}

void StatsScreen::updateWeeklyBar() {}

void StatsScreen::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        StatsScreen { background:%1; }
        QWidget#statusBar { background:%1; border-bottom:1px solid %2; }
        QLabel#statusTime { font-family:'Courier New'; font-size:13px; font-weight:700; color:%3; }
        QLabel#labelMuted { font-size:12px; color:%7; }
        QLabel#labelMutedSmall { font-size:10px; color:%7; }
        QFrame#statCardBig { background:%4; border:1px solid %2; border-radius:18px; border-left:5px solid %5; }
        QLabel#statCardIcon { font-size:24px; }
        QLabel#statCardVal  { font-family:'Courier New'; font-size:28px; font-weight:700; color:%3; }
        QLabel#statCardLbl  { font-size:12px; color:%7; }
        QFrame#weeklyChartCard { background:%4; border:1px solid %2; border-radius:18px; }
        QLabel#chartTitle { font-size:13px; font-weight:800; color:%5; }
        QLabel#sectionTitle { font-size:13px; font-weight:800; color:%7; }
        QFrame#subjectRow { background:%4; border:1px solid %2; border-radius:12px; }
        QLabel#rankNum    { font-size:14px; font-weight:700; color:%5; }
        QLabel#subjectName{ font-size:13px; font-weight:700; color:%3; }
        QLabel#subjectPct { font-size:12px; color:%7; }
    )").arg(t.bgPrimary, t.border, t.textPrimary, t.bgSecondary,
            t.accent, t.green, t.textMuted));
}
