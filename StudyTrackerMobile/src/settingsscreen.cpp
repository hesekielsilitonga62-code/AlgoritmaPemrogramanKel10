#include "settingsscreen.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QScrollArea>
#include <QFrame>
#include <QTime>
#include <QInputDialog>

SettingsScreen::SettingsScreen(QWidget* parent) : QWidget(parent) {
    buildUi();
    applyStyle();
}

void SettingsScreen::buildUi() {
    auto* root = new QVBoxLayout(this);
    root->setContentsMargins(0,0,0,0); root->setSpacing(0);

    // Status bar
    auto* sb = new QWidget(this); sb->setObjectName("statusBar"); sb->setFixedHeight(44);
    auto* sbL = new QHBoxLayout(sb); sbL->setContentsMargins(20,0,20,0);
    auto* sbTime = new QLabel(QTime::currentTime().toString("HH:mm"), sb);
    sbTime->setObjectName("statusTime");
    auto* sbMid = new QLabel("Setelan", sb); sbMid->setObjectName("labelMuted");
    sbL->addWidget(sbTime); sbL->addStretch();
    sbL->addWidget(sbMid); sbL->addStretch();
    sbL->addWidget(new QLabel("📶 🔋", sb));
    root->addWidget(sb);

    // Scroll area
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    auto* inner = new QWidget();
    auto* cl = new QVBoxLayout(inner);
    cl->setContentsMargins(16,16,16,24); cl->setSpacing(12);
    scroll->setWidget(inner);
    root->addWidget(scroll, 1);

    // ── Profile card ──
    auto* profCard = new QFrame(inner); profCard->setObjectName("settingsCard");
    auto* profLay  = new QHBoxLayout(profCard);
    profLay->setContentsMargins(20,20,20,20); profLay->setSpacing(16);

    lblAvatar = new QLabel("😀", profCard);
    lblAvatar->setObjectName("profileAvatar");
    lblAvatar->setFixedSize(64,64);
    lblAvatar->setAlignment(Qt::AlignCenter);

    auto* infoW = new QWidget(profCard);
    auto* infoL = new QVBoxLayout(infoW);
    infoL->setContentsMargins(0,0,0,0); infoL->setSpacing(4);
    lblName   = new QLabel("Pengguna", infoW); lblName->setObjectName("profileName");
    lblStatus = new QLabel("Pelajar semangat!", infoW); lblStatus->setObjectName("labelMuted");
    auto* btnEdit = new QPushButton("✏️ Edit Profil", infoW);
    btnEdit->setObjectName("btnEditProfile");
    connect(btnEdit, &QPushButton::clicked, this, [this](){
        bool ok;
        QString newName = QInputDialog::getText(this, "Edit Nama",
            "Nama baru:", QLineEdit::Normal,
            AppState::instance().currentUser, &ok);
        if (ok && !newName.isEmpty()) {
            AppState::instance().currentUser = newName;
            refresh();
        }
    });
    infoL->addWidget(lblName);
    infoL->addWidget(lblStatus);
    infoL->addWidget(btnEdit);

    profLay->addWidget(lblAvatar);
    profLay->addWidget(infoW, 1);
    cl->addWidget(profCard);

    // ── Notifikasi ──
    auto* notifCard = new QFrame(inner); notifCard->setObjectName("settingsCard");
    auto* notifLay  = new QVBoxLayout(notifCard);
    notifLay->setContentsMargins(0,0,0,0); notifLay->setSpacing(0);

    auto* notifTitle = new QLabel("🔔 Notifikasi", notifCard);
    notifTitle->setObjectName("sectionTitle");
    notifTitle->setStyleSheet("padding: 12px 16px 8px;");
    notifLay->addWidget(notifTitle);

    auto makeToggleRow = [&](const QString& label, const QString& sub, QPushButton*& btn) {
        auto* row = new QWidget(notifCard); row->setObjectName("toggleRow");
        auto* rLay = new QHBoxLayout(row); rLay->setContentsMargins(16,14,16,14);
        auto* infoW2 = new QWidget(row);
        auto* iL = new QVBoxLayout(infoW2); iL->setContentsMargins(0,0,0,0); iL->setSpacing(2);
        auto* lbLabel = new QLabel(label, infoW2); lbLabel->setObjectName("toggleLabel");
        auto* lbSub   = new QLabel(sub,   infoW2); lbSub->setObjectName("labelMuted");
        iL->addWidget(lbLabel); iL->addWidget(lbSub);
        btn = new QPushButton(row);
        btn->setObjectName("toggleSwitch");
        btn->setFixedSize(48, 28);
        btn->setCheckable(true);
        rLay->addWidget(infoW2, 1);
        rLay->addWidget(btn);
        notifLay->addWidget(row);

        auto* sep = new QFrame(notifCard);
        sep->setObjectName("divider");
        sep->setFixedHeight(1);
        notifLay->addWidget(sep);
    };

    makeToggleRow("Notif Tugas",   "Pengingat deadline tugas",  btnNotifTugas);
    makeToggleRow("Notif Belajar", "Pomodoro selesai / break",  btnNotifBelajar);
    makeToggleRow("Notif Teman",   "Pesan dari teman",          btnNotifTeman);

    auto& app = AppState::instance();
    btnNotifTugas->setChecked(app.notifTugas);
    btnNotifBelajar->setChecked(app.notifBelajar);
    btnNotifTeman->setChecked(app.notifTeman);

    connect(btnNotifTugas,   &QPushButton::toggled, [](bool v){ AppState::instance().notifTugas   = v; });
    connect(btnNotifBelajar, &QPushButton::toggled, [](bool v){ AppState::instance().notifBelajar = v; });
    connect(btnNotifTeman,   &QPushButton::toggled, [](bool v){ AppState::instance().notifTeman   = v; });

    cl->addWidget(notifCard);

    // ── Tema ──
    auto* themeCard = new QFrame(inner); themeCard->setObjectName("settingsCard");
    auto* themeLay  = new QVBoxLayout(themeCard);
    themeLay->setContentsMargins(0,0,0,0); themeLay->setSpacing(0);

    auto* themeTitle = new QLabel("🎨 Tema", themeCard);
    themeTitle->setObjectName("sectionTitle");
    themeTitle->setStyleSheet("padding: 12px 16px 8px;");
    themeLay->addWidget(themeTitle);

    auto* themeGrid = new QWidget(themeCard);
    auto* tgLay = new QHBoxLayout(themeGrid);
    tgLay->setContentsMargins(16,14,16,14); tgLay->setSpacing(10);
    tgLay->setAlignment(Qt::AlignLeft);

    struct ThemeDef { QString name; QString bg; QString accent; QString label; };
    QList<ThemeDef> themes = {
        {"default", "#001b2e", "#ffcc00", "Default"},
        {"black",   "#0a0a0a", "#ffffff", "Hitam"},
        {"white",   "#f0f4f8", "#1565c0", "Putih"},
        {"pink",    "#1a0a12", "#ff6eb4", "Pink"},
        {"laut",    "#0a1f3d", "#38bdf8", "Laut"},
        {"adem",    "#061a10", "#4ecca3", "Adem"},
        {"vintage", "#1c1208", "#d4a24c", "Vintage"},
    };

    for (auto& td : themes) {
        auto* btn = new QPushButton(td.label, themeCard);
        btn->setFixedSize(70, 50);
        btn->setObjectName("themeBtn");
        QString nm = td.name;
        QString bg = td.bg, ac = td.accent;
        btn->setStyleSheet(QString(
            "QPushButton { background:%1; color:%2; border-radius:10px;"
            " border:2px solid transparent; font-size:9px; font-weight:800; }"
            "QPushButton:checked { border:3px solid white; }")
            .arg(bg, ac));
        btn->setCheckable(true);
        btn->setChecked(AppState::instance().themeName == nm);
        connect(btn, &QPushButton::clicked, this, [this, nm](){
            AppState::instance().applyTheme(nm);
            applyStyle();
            refresh();
            emit themeChanged();
        });
        tgLay->addWidget(btn);
        themeBtns.append(btn);
    }

    themeLay->addWidget(themeGrid);
    cl->addWidget(themeCard);

    // ── Tentang ──
    auto* aboutCard = new QFrame(inner); aboutCard->setObjectName("settingsCard");
    auto* aboutLay  = new QVBoxLayout(aboutCard);
    aboutLay->setContentsMargins(16,16,16,16); aboutLay->setSpacing(8);
    auto* aboutTitle = new QLabel("📖 Tentang Aplikasi", aboutCard); aboutTitle->setObjectName("sectionTitle");
    auto* aboutDesc  = new QLabel(
        "Study Tracker v1.0\n"
        "Kelompok 10 — Algoritma Pemrograman\n"
        "Dibangun dengan C++ & Qt Framework\n"
        "Terinspirasi dari Yeolpumta / YPT Study App",
        aboutCard);
    aboutDesc->setObjectName("labelMuted");
    aboutDesc->setWordWrap(true);
    aboutLay->addWidget(aboutTitle);
    aboutLay->addWidget(aboutDesc);
    cl->addWidget(aboutCard);

    // ── Logout ──
    auto* btnLogout = new QPushButton("🚪 Keluar / Logout", inner);
    btnLogout->setObjectName("btnLogout");
    btnLogout->setFixedHeight(50);
    connect(btnLogout, &QPushButton::clicked, this, &SettingsScreen::logoutRequested);
    cl->addWidget(btnLogout);

    cl->addStretch();
}

void SettingsScreen::refresh() {
    auto& app = AppState::instance();
    lblName->setText(app.currentUser.isEmpty() ? "Pengguna" : app.currentUser);
    lblAvatar->setText(app.currentAvatar);
    setToggle(btnNotifTugas,   app.notifTugas);
    setToggle(btnNotifBelajar, app.notifBelajar);
    setToggle(btnNotifTeman,   app.notifTeman);
}

void SettingsScreen::setToggle(QPushButton* btn, bool on) {
    auto& t = AppState::instance().theme;
    btn->setChecked(on);
    btn->setText(on ? "ON" : "OFF");
    btn->setStyleSheet(on
        ? QString("background:%1; color:%2; border-radius:14px; font-size:10px; font-weight:800; border:none;")
            .arg(t.accent, t.bgDeep)
        : QString("background:%1; color:%2; border-radius:14px; font-size:10px; font-weight:800; border:1px solid %3;")
            .arg(t.bgCard, t.textMuted, t.border));
}

void SettingsScreen::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        SettingsScreen { background:%1; }
        QWidget#statusBar  { background:%1; border-bottom:1px solid %2; }
        QLabel#statusTime  { font-family:'Courier New'; font-size:13px; font-weight:700; color:%3; }
        QLabel#labelMuted  { font-size:12px; color:%7; }
        QFrame#settingsCard { background:%4; border:1px solid %2; border-radius:18px; }
        QLabel#profileName  { font-size:18px; font-weight:800; color:%3; }
        QLabel#profileAvatar {
            background:rgba(255,204,0,38); border:2px solid rgba(255,204,0,89);
            border-radius:32px; font-size:34px;
        }
        QPushButton#btnEditProfile {
            background:transparent; border:none; color:%5;
            font-size:12px; font-weight:700; text-align:left; padding:0;
        }
        QLabel#sectionTitle  { font-size:13px; font-weight:800; color:%5; }
        QWidget#toggleRow    { border-bottom:1px solid %2; }
        QLabel#toggleLabel   { font-size:14px; font-weight:700; color:%3; }
        QFrame#divider       { background:%2; }
        QPushButton#btnLogout {
            background:rgba(255,85,85,25); border:1.5px solid rgba(255,85,85,76);
            color:#ff7070; border-radius:14px; font-size:15px; font-weight:bold;
        }
        QPushButton#btnLogout:pressed { background:rgba(255,85,85,50); }
    )").arg(t.bgPrimary, t.border, t.textPrimary, t.bgSecondary,
            t.accent, t.green, t.textMuted));

    refresh();
}
