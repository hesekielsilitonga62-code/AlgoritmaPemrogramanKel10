#include "loginscreen.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFrame>
#include <QPainter>
#include <QTimer>

LoginScreen::LoginScreen(QWidget* parent) : QWidget(parent) {
    // Akun default untuk demo
    userDb["admin"]  = "admin123";
    userDb["user"]   = "user123";
    userDb["kelompok10"] = "kelompok10";
    buildUi();
    applyStyle();
}

void LoginScreen::buildUi() {
    auto* root = new QVBoxLayout(this);
    root->setContentsMargins(24, 40, 24, 40);
    root->setSpacing(0);

    // ── Logo ──
    auto* logoArea = new QWidget(this);
    auto* logoLay  = new QVBoxLayout(logoArea);
    logoLay->setAlignment(Qt::AlignHCenter);
    logoLay->setSpacing(6);

    auto* lbEmoji = new QLabel("", logoArea);
    lbEmoji->setAlignment(Qt::AlignCenter);
    lbEmoji->setStyleSheet("font-size:52px;");

    auto* lbTitle = new QLabel("Study Tracker", logoArea);
    lbTitle->setAlignment(Qt::AlignCenter);
    lbTitle->setObjectName("loginTitle");

    auto* lbSub2 = new QLabel("Kelompok 10 — Algoritma Pemrograman", logoArea);
    lbSub2->setAlignment(Qt::AlignCenter);
    lbSub2->setObjectName("loginSubtitle");

    logoLay->addWidget(lbEmoji);
    logoLay->addWidget(lbTitle);
    logoLay->addWidget(lbSub2);

    root->addWidget(logoArea);
    root->addSpacing(28);

    // ── Card ──
    auto* card = new QFrame(this);
    card->setObjectName("loginCard");
    auto* cardLay = new QVBoxLayout(card);
    cardLay->setContentsMargins(24, 28, 24, 24);
    cardLay->setSpacing(0);

    // Card header
    auto* headArea = new QWidget(card);
    auto* headLay  = new QVBoxLayout(headArea);
    headLay->setAlignment(Qt::AlignHCenter);
    headLay->setSpacing(4);

    lblEmoji = new QLabel("", headArea);
    lblEmoji->setAlignment(Qt::AlignCenter);
    lblEmoji->setStyleSheet("font-size:36px;");

    lblHeading = new QLabel("Selamat Datang!", headArea);
    lblHeading->setAlignment(Qt::AlignCenter);
    lblHeading->setObjectName("cardHeading");

    lblSub = new QLabel("Masuk ke akunmu", headArea);
    lblSub->setAlignment(Qt::AlignCenter);
    lblSub->setObjectName("labelMuted");

    headLay->addWidget(lblEmoji);
    headLay->addWidget(lblHeading);
    headLay->addWidget(lblSub);
    cardLay->addWidget(headArea);
    cardLay->addSpacing(20);

    // Error box
    lblError = new QLabel(card);
    lblError->setObjectName("errorBox");
    lblError->setWordWrap(true);
    lblError->setVisible(false);
    cardLay->addWidget(lblError);
    cardLay->addSpacing(4);

    // Username
    auto* lbUser = new QLabel("Username", card);
    lbUser->setObjectName("fieldLabel");
    cardLay->addWidget(lbUser);
    cardLay->addSpacing(6);

    edtUser = new QLineEdit(card);
    edtUser->setPlaceholderText("username / email");
    edtUser->setFixedHeight(52);
    cardLay->addWidget(edtUser);
    cardLay->addSpacing(14);

    // Password
    auto* lbPass = new QLabel("Kata Sandi", card);
    lbPass->setObjectName("fieldLabelGreen");
    cardLay->addWidget(lbPass);
    cardLay->addSpacing(6);

    auto* passRow = new QHBoxLayout();
    passRow->setSpacing(0);
    edtPass = new QLineEdit(card);
    edtPass->setPlaceholderText("••••••••");
    edtPass->setEchoMode(QLineEdit::Password);
    edtPass->setFixedHeight(52);
    btnTogglePass = new QPushButton("👁️", card);
    btnTogglePass->setFixedSize(52,52);
    btnTogglePass->setObjectName("btnEye");
    connect(btnTogglePass, &QPushButton::clicked, this, &LoginScreen::togglePassword);
    passRow->addWidget(edtPass, 1);
    passRow->addWidget(btnTogglePass);
    cardLay->addLayout(passRow);
    cardLay->addSpacing(12);

    // Confirm password (register mode)
    confirmRow = new QWidget(card);
    auto* crLay = new QVBoxLayout(confirmRow);
    crLay->setContentsMargins(0,0,0,0); crLay->setSpacing(6);
    auto* lbConfirm = new QLabel("Konfirmasi Kata Sandi", confirmRow);
    lbConfirm->setObjectName("fieldLabelGreen");
    edtPassConfirm = new QLineEdit(confirmRow);
    edtPassConfirm->setPlaceholderText("ulangi password");
    edtPassConfirm->setEchoMode(QLineEdit::Password);
    edtPassConfirm->setFixedHeight(52);
    crLay->addWidget(lbConfirm);
    crLay->addWidget(edtPassConfirm);
    cardLay->addWidget(confirmRow);
    confirmRow->setVisible(false);
    cardLay->addSpacing(8);

    // Main button
    btnMain = new QPushButton("Masuk", card);
    btnMain->setObjectName("btnMain");
    btnMain->setFixedHeight(52);
    connect(btnMain, &QPushButton::clicked, this, [this](){
        isRegisterMode ? handleRegister() : handleLogin();
    });
    cardLay->addWidget(btnMain);
    cardLay->addSpacing(16);

    // Footer switch
    auto* footRow = new QHBoxLayout();
    footRow->setAlignment(Qt::AlignHCenter);
    footRow->setSpacing(8);
    auto* lbForgot = new QLabel("Lupa kata sandi?", card);
    lbForgot->setObjectName("labelMuted");
    auto* lbDot = new QLabel("·", card);
    lbDot->setObjectName("labelMuted");
    btnSwitch = new QPushButton("Daftar", card);
    btnSwitch->setObjectName("btnSwitch");
    btnSwitch->setFlat(true);
    connect(btnSwitch, &QPushButton::clicked, this, &LoginScreen::switchMode);
    footRow->addWidget(lbForgot);
    footRow->addWidget(lbDot);
    footRow->addWidget(btnSwitch);
    cardLay->addLayout(footRow);

    root->addWidget(card);
    root->addStretch();

    // Enter keys
    connect(edtUser, &QLineEdit::returnPressed, edtPass, static_cast<void(QLineEdit::*)()>(&QLineEdit::setFocus));
    connect(edtPass, &QLineEdit::returnPressed, this, [this](){
        isRegisterMode ? handleRegister() : handleLogin();
    });
}

void LoginScreen::handleLogin() {
    QString user = edtUser->text().trimmed();
    QString pass = edtPass->text();
    if (user.isEmpty() || pass.isEmpty()) {
        showError("Username dan password tidak boleh kosong");
        return;
    }
    if (!userDb.contains(user) || userDb[user] != pass) {
        showError("Username atau password salah");
        return;
    }
    showError("Berhasil masuk! Selamat datang " + user, true);
    auto& app = AppState::instance();
    app.currentUser = user;
    app.currentAvatar = "😀";
    app.isLoggedIn = true;
    QTimer::singleShot(600, this, [this, user](){
        emit loginSuccess(user, "😀");
    });
}

void LoginScreen::handleRegister() {
    QString user = edtUser->text().trimmed();
    QString pass = edtPass->text();
    QString conf = edtPassConfirm->text();
    if (user.isEmpty() || pass.isEmpty()) {
        showError("Username dan password tidak boleh kosong");
        return;
    }
    if (pass != conf) {
        showError("Konfirmasi password tidak cocok");
        return;
    }
    if (pass.length() < 6) {
        showError("Password minimal 6 karakter");
        return;
    }
    if (userDb.contains(user)) {
        showError("Username sudah digunakan");
        return;
    }
    userDb[user] = pass;
    showError("Akun berhasil dibuat! Silakan masuk.", true);
    QTimer::singleShot(800, this, [this](){
        isRegisterMode = false;
        applyModeUi();
    });
}

void LoginScreen::switchMode() {
    isRegisterMode = !isRegisterMode;
    applyModeUi();
    lblError->setVisible(false);
    edtUser->clear(); edtPass->clear(); edtPassConfirm->clear();
}

void LoginScreen::applyModeUi() {
    if (isRegisterMode) {
        lblEmoji->setText("");
        lblHeading->setText("Buat Akun Baru");
        lblSub->setText("Daftar gratis, mulai belajar!");
        btnMain->setText("Daftar");
        btnSwitch->setText("Sudah punya akun? Masuk");
        confirmRow->setVisible(true);
    } else {
        lblEmoji->setText("");
        lblHeading->setText("Selamat Datang!");
        lblSub->setText("Masuk ke akunmu");
        btnMain->setText("Masuk");
        btnSwitch->setText("Daftar");
        confirmRow->setVisible(false);
    }
}

void LoginScreen::togglePassword() {
    bool hidden = edtPass->echoMode() == QLineEdit::Password;
    edtPass->setEchoMode(hidden ? QLineEdit::Normal : QLineEdit::Password);
    btnTogglePass->setText(hidden ? "" : "👁️");
}

void LoginScreen::showError(const QString& msg, bool success) {
    lblError->setText(msg);
    lblError->setVisible(true);
    auto& t = AppState::instance().theme;
    if (success)
        lblError->setStyleSheet(QString("background:rgba(5,214,5,30);border:1px solid %1;border-radius:10px;padding:10px 12px;font-size:12px;color:%1;").arg(t.green));
    else
        lblError->setStyleSheet(QString("background:rgba(255,85,85,30);border:1px solid %1;border-radius:10px;padding:10px 12px;font-size:12px;color:#ff7070;").arg(t.red));
}

void LoginScreen::reset() {
    edtUser->clear(); edtPass->clear(); edtPassConfirm->clear();
    lblError->setVisible(false);
    isRegisterMode = false;
    applyModeUi();
}

void LoginScreen::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        LoginScreen {
            background: qlineargradient(x1:0,y1:0,x2:0.4,y2:1,
                stop:0 %1, stop:0.6 %2, stop:1 %3);
        }
        QFrame#loginCard {
            background-color: %3;
            border: 1.5px solid %4;
            border-radius: 28px;
        }
        QLabel#loginTitle {
            font-size: 28px; font-weight: 900;
            color: %5; letter-spacing: -0.5px;
        }
        QLabel#loginSubtitle { font-size: 13px; color: %6; }
        QLabel#cardHeading   { font-size: 18px; font-weight: 900; color: %5; }
        QLabel#labelMuted    { font-size: 12px; color: %6; }
        QLabel#fieldLabel    { font-size: 11px; font-weight: 700; color: %7; padding-left:4px; }
        QLabel#fieldLabelGreen { font-size: 11px; font-weight: 700; color: %8; padding-left:4px; }
        QPushButton#btnSwitch {
            background: transparent; border: none;
            color: %8; font-size: 12px; font-weight: 700;
        }
        QPushButton#btnEye {
            background: transparent; border: none;
            border-radius: 14px; font-size: 16px; color: %6;
        }
        QPushButton#btnEye:hover { color: %5; }
    )").arg(t.bgDeep, t.bgPrimary, t.bgSecondary,
            t.accentDim.replace("rgba","rgba"),
            t.textPrimary, t.textMuted,
            t.accent, t.green));
}
