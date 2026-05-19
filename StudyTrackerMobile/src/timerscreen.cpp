#include "timerscreen.h"
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QScrollArea>
#include <QFrame>
#include <QTime>
#include <algorithm>

// ── TimerRing ──────────────────────────────────
TimerRing::TimerRing(QWidget* parent) : QWidget(parent) {
    setFixedSize(260, 260);
}
void TimerRing::setProgress(double p, bool r) {
    progress = p; running = r; update();
}
void TimerRing::paintEvent(QPaintEvent*) {
    auto& t = AppState::instance().theme;
    QPainter p(this);
    p.setRenderHint(QPainter::Antialiasing);

    QRectF outer(6, 6, 248, 248);

    // Background circle
    p.setBrush(QColor(t.bgCard));
    p.setPen(QColor(t.border));
    p.drawEllipse(outer);

    // Outer dim ring
    p.setBrush(Qt::NoBrush);
    QPen dimPen(QColor(t.accent));
    dimPen.setWidth(18); dimPen.setCapStyle(Qt::RoundCap);
    QColor dimColor(t.accent); dimColor.setAlpha(40);
    dimPen.setColor(dimColor);
    p.setPen(dimPen);
    p.drawEllipse(QRectF(18,18,224,224));

    // Progress arc
    if (progress > 0.001) {
        QPen progPen(QColor(t.accent));
        progPen.setWidth(18); progPen.setCapStyle(Qt::RoundCap);
        p.setPen(progPen);
        // Qt arc: 0 = right, positive = counter-clockwise, in 1/16 degrees
        int startAngle = 90 * 16;
        int spanAngle  = -(int)(progress * 360 * 16);
        p.drawArc(QRectF(18,18,224,224), startAngle, spanAngle);
    }

    // Inner circle
    p.setBrush(QColor(t.bgSecondary));
    p.setPen(QColor(t.border));
    p.drawEllipse(QRectF(26, 26, 208, 208));
}

// ── TimerScreen ────────────────────────────────
TimerScreen::TimerScreen(QWidget* parent) : QWidget(parent) {
    buildUi();
    applyStyle();

    ticker = new QTimer(this);
    ticker->setInterval(1000);
    connect(ticker, &QTimer::timeout, this, &TimerScreen::tick);
}

void TimerScreen::buildUi() {
    auto* root = new QVBoxLayout(this);
    root->setContentsMargins(0,0,0,0); root->setSpacing(0);

    // Status bar
    auto* sb = new QWidget(this); sb->setObjectName("statusBar"); sb->setFixedHeight(44);
    auto* sbL = new QHBoxLayout(sb); sbL->setContentsMargins(20,0,20,0);
    lblStatusTime = new QLabel(QTime::currentTime().toString("HH:mm"), sb); lblStatusTime->setObjectName("statusTime");
    auto* sbMid = new QLabel("Timer Belajar", sb); sbMid->setObjectName("labelMuted");
    sbL->addWidget(lblStatusTime); sbL->addStretch(); sbL->addWidget(sbMid); sbL->addStretch();
    sbL->addWidget(new QLabel("📶 🔋", sb));
    root->addWidget(sb);

    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    auto* inner = new QWidget();
    auto* cl = new QVBoxLayout(inner);
    cl->setContentsMargins(20,20,20,20); cl->setSpacing(20);
    scroll->setWidget(inner);
    root->addWidget(scroll, 1);

    // Timer ring + center
    auto* ringWrap = new QWidget(inner);
    ringWrap->setObjectName("ringWrap");
    auto* rwLay = new QHBoxLayout(ringWrap);
    rwLay->setAlignment(Qt::AlignHCenter);
    ring = new TimerRing(ringWrap);

    // Overlay layout on ring
    auto* centerW = new QWidget(ring);
    centerW->setGeometry(0, 0, 260, 260);
    auto* cenLay = new QVBoxLayout(centerW);
    cenLay->setAlignment(Qt::AlignCenter); cenLay->setSpacing(4);

    lblBadge = new QLabel("SIAP", ring);
    lblBadge->setObjectName("timerBadge");
    lblBadge->setAlignment(Qt::AlignCenter);
    lblBadge->setFixedWidth(90);

    lblTime = new QLabel("00:00", ring);
    lblTime->setObjectName("timerTimeBig");
    lblTime->setAlignment(Qt::AlignCenter);

    lblSessions = new QLabel("Sesi: 0 / 4", ring);
    lblSessions->setObjectName("labelMutedSmall");
    lblSessions->setAlignment(Qt::AlignCenter);

    cenLay->addWidget(lblBadge, 0, Qt::AlignHCenter);
    cenLay->addWidget(lblTime);
    cenLay->addWidget(lblSessions, 0, Qt::AlignHCenter);

    rwLay->addWidget(ring);
    cl->addWidget(ringWrap);

    // Time input row
    auto* inputRow = new QHBoxLayout();
    inputRow->setAlignment(Qt::AlignHCenter);
    inputRow->setSpacing(10);

    auto makeBox = [&](const QString& unit, QSpinBox*& sp) {
        auto* box = new QFrame(inner); box->setObjectName("timeInputBox");
        auto* bl = new QVBoxLayout(box); bl->setContentsMargins(8,8,8,6); bl->setSpacing(2);
        sp = new QSpinBox(box);
        sp->setRange(1, 99); sp->setFixedSize(68, 36);
        sp->setButtonSymbols(QAbstractSpinBox::UpDownArrows);
        auto* u = new QLabel(unit, box); u->setObjectName("labelMutedSmall"); u->setAlignment(Qt::AlignCenter);
        bl->addWidget(sp); bl->addWidget(u);
        return box;
    };
    QSpinBox* dummy;
    inputRow->addWidget(makeBox("FOKUS (mnt)", spFocus));
    auto* sep = new QLabel(":", inner); sep->setObjectName("timeSep"); sep->setAlignment(Qt::AlignCenter);
    inputRow->addWidget(sep);
    inputRow->addWidget(makeBox("ISTIRAHAT (mnt)", spBreak));

    auto& app = AppState::instance();
    spFocus->setValue(app.focusMinutes);
    spBreak->setValue(app.breakMinutes);
    connect(spFocus, QOverload<int>::of(&QSpinBox::valueChanged), [](int v){
        AppState::instance().focusMinutes = v;
    });
    connect(spBreak, QOverload<int>::of(&QSpinBox::valueChanged), [](int v){
        AppState::instance().breakMinutes = v;
    });

    auto* inputW = new QWidget(inner);
    inputW->setLayout(inputRow);
    cl->addWidget(inputW);

    // Controls
    auto* ctrlRow = new QHBoxLayout();
    ctrlRow->setSpacing(10);
    auto* btnStart = new QPushButton("▶ Mulai", inner); btnStart->setObjectName("btnTimerStart");
    auto* btnStop  = new QPushButton("■ Stop",  inner); btnStop->setObjectName("btnTimerStop");
    auto* btnSkip  = new QPushButton("⏭ Skip",  inner); btnSkip->setObjectName("btnTimerSkip");
    connect(btnStart, &QPushButton::clicked, this, &TimerScreen::start);
    connect(btnStop,  &QPushButton::clicked, this, &TimerScreen::stop);
    connect(btnSkip,  &QPushButton::clicked, this, &TimerScreen::skip);
    ctrlRow->addWidget(btnStart, 3); ctrlRow->addWidget(btnStop, 2); ctrlRow->addWidget(btnSkip, 2);
    auto* ctrlW = new QWidget(inner); ctrlW->setLayout(ctrlRow);
    cl->addWidget(ctrlW);

    // Stats
    auto* statsRow = new QHBoxLayout(); statsRow->setSpacing(10);
    auto makeStatBox = [&](const QString& lbl, QLabel*& valLbl) -> QWidget* {
        auto* sb2 = new QFrame(inner); sb2->setObjectName("timerStatBox");
        auto* sl = new QVBoxLayout(sb2); sl->setContentsMargins(10,12,10,10); sl->setSpacing(2);
        valLbl = new QLabel("0", sb2); valLbl->setObjectName("timerStatVal"); valLbl->setAlignment(Qt::AlignCenter);
        auto* ll = new QLabel(lbl, sb2); ll->setObjectName("labelMutedSmall"); ll->setAlignment(Qt::AlignCenter);
        sl->addWidget(valLbl); sl->addWidget(ll);
        return sb2;
    };
    statsRow->addWidget(makeStatBox("Total Fokus", lbTotalFocus));
    statsRow->addWidget(makeStatBox("Sesi Hari Ini", lbSessions));
    statsRow->addWidget(makeStatBox("Terlama", lbLongest));
    auto* statsW = new QWidget(inner); statsW->setLayout(statsRow);
    cl->addWidget(statsW);

    // Closest task
    auto* ctCard = new QFrame(inner); ctCard->setObjectName("closestTaskCard");
    auto* ctLay = new QHBoxLayout(ctCard); ctLay->setContentsMargins(20,12,14,12); ctLay->setSpacing(10);
    auto* ctInfo = new QWidget(ctCard);
    auto* ctIL = new QVBoxLayout(ctInfo); ctIL->setContentsMargins(0,0,0,0); ctIL->setSpacing(2);
    auto* ctLbl = new QLabel("📌 TUGAS TERDEKAT", ctCard); ctLbl->setObjectName("closestLbl");
    lblClosestTask = new QLabel("Tidak ada tugas", ctCard); lblClosestTask->setObjectName("closestName");
    ctIL->addWidget(ctLbl); ctIL->addWidget(lblClosestTask);
    ctLay->addWidget(ctInfo, 1);
    cl->addWidget(ctCard);

    cl->addStretch();

    updateUI();
}

void TimerScreen::start() {
    auto& app = AppState::instance();
    if (!app.timerRunning) {
        if (app.timerRemaining == 0) {
            app.timerRemaining = app.focusMinutes * 60;
            app.timerTotal     = app.timerRemaining;
        }
        app.timerRunning = true;
        ticker->start();
        updateUI();
    }
}

void TimerScreen::stop() {
    auto& app = AppState::instance();
    app.timerRunning   = false;
    app.timerRemaining = 0;
    app.timerTotal     = 0;
    ticker->stop();
    ring->setProgress(0, false);
    updateUI();
    emit app.timerTick();
}

void TimerScreen::skip() {
    auto& app = AppState::instance();
    app.timerRunning   = false;
    app.timerRemaining = 0;
    app.timerTotal     = 0;
    app.isBreak        = !app.isBreak;
    ticker->stop();
    ring->setProgress(0, false);
    updateUI();
    emit app.timerTick();
}

void TimerScreen::tick() {
    auto& app = AppState::instance();
    if (!app.timerRunning) return;

    if (app.timerRemaining > 0) {
        app.timerRemaining--;
        if (!app.isBreak) app.totalStudySecs++;
    }

    double prog = app.timerTotal > 0
        ? 1.0 - (double)app.timerRemaining / app.timerTotal
        : 0;
    ring->setProgress(prog, true);
    updateUI();
    emit app.timerTick();

    if (app.timerRemaining == 0) {
        app.timerRunning = false;
        ticker->stop();
        if (!app.isBreak) {
            app.sessions++;
            emit sessionCompleted(app.sessions);
            emit notifyRequested("🎉", "Sesi Selesai!", QString("Sesi %1 selesai! Waktunya istirahat.").arg(app.sessions));
            app.isBreak = true;
            app.timerRemaining = app.breakMinutes * 60;
        } else {
            emit notifyRequested("📚", "Istirahat Selesai!", "Waktunya belajar lagi! 💪");
            app.isBreak = false;
            app.timerRemaining = app.focusMinutes * 60;
        }
        app.timerTotal = app.timerRemaining;
    }
}

void TimerScreen::updateUI() {
    auto& app = AppState::instance();
    auto& t   = app.theme;
    int mins = app.timerRemaining / 60;
    int secs = app.timerRemaining % 60;
    QString timeStr = QString("%1:%2").arg(mins,2,10,QChar('0')).arg(secs,2,10,QChar('0'));
    lblTime->setText(timeStr);
    lblSessions->setText(QString("Sesi: %1 / 4").arg(app.sessions));

    if (app.timerRunning) {
        lblBadge->setText(app.isBreak ? "ISTIRAHAT" : "BERJALAN");
        lblBadge->setStyleSheet(QString("font-size:9px;font-weight:800;padding:2px 10px;border-radius:10px;background:rgba(5,214,5,38);color:%1;border:1px solid rgba(5,214,5,89);").arg(t.green));
        lblTime->setStyleSheet(QString("font-family:'Courier New';font-size:46px;font-weight:700;color:%1;letter-spacing:2px;").arg(t.accent));
    } else {
        lblBadge->setText(app.isBreak ? "BREAK" : "SIAP");
        lblBadge->setStyleSheet(QString("font-size:9px;font-weight:800;padding:2px 10px;border-radius:10px;background:%1;color:%2;border:1px solid %3;").arg(t.bgCard, t.textMuted, t.border));
        lblTime->setStyleSheet("font-family:'Courier New';font-size:46px;font-weight:700;letter-spacing:2px;");
    }

    // Update stats
    int h = app.totalStudySecs / 3600;
    int m = (app.totalStudySecs % 3600) / 60;
    lbTotalFocus->setText(h > 0 ? QString("%1j %2m").arg(h).arg(m) : QString("%1m").arg(m));
    if (lbSessions) lbSessions->setText(QString::number(app.sessions));
    lbLongest->setText(QString("%1m").arg(app.focusMinutes));

    updateClosestTask();
    lblStatusTime->setText(QTime::currentTime().toString("HH:mm"));
}

void TimerScreen::updateClosestTask() {
    auto& app = AppState::instance();
    Task* closest = nullptr;
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    for (auto& task : app.tasks) {
        if (task.isDone || task.deadlineTs == 0) continue;
        if (!closest || task.deadlineTs < closest->deadlineTs)
            closest = &task;
    }
    if (closest)
        lblClosestTask->setText(closest->title + " · " + closest->deadline);
    else
        lblClosestTask->setText("Tidak ada tugas mendatang");
}

void TimerScreen::refresh() { updateUI(); }

void TimerScreen::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        TimerScreen { background:%1; }
        QWidget#statusBar { background:%1; border-bottom:1px solid %2; }
        QLabel#statusTime { font-family:'Courier New'; font-size:13px; font-weight:700; color:%3; }
        QLabel#timerTimeBig { font-family:'Courier New'; font-size:46px; font-weight:700; color:%3; letter-spacing:2px; }
        QLabel#labelMutedSmall { font-size:10px; color:%7; }
        QLabel#labelMuted { font-size:12px; color:%7; }
        QFrame#timeInputBox { background:%4; border:1px solid %2; border-radius:12px; min-width:80px; }
        QLabel#timeSep { font-size:20px; font-weight:700; color:%7; }
        QFrame#timerStatBox { background:%4; border:1px solid %2; border-radius:14px; }
        QLabel#timerStatVal { font-family:'Courier New'; font-size:18px; font-weight:700; color:%5; }
        QFrame#closestTaskCard { background:%4; border:1px solid %2; border-radius:14px; border-left:4px solid %5; }
        QLabel#closestLbl  { font-size:10px; font-weight:800; color:%5; text-transform:uppercase; }
        QLabel#closestName { font-size:13px; font-weight:700; color:%3; }
    )").arg(t.bgPrimary, t.border, t.textPrimary, t.bgSecondary,
            t.accent, t.green, t.textMuted));
}
