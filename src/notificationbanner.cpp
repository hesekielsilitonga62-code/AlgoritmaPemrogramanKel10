#include "notificationbanner.h"
#include <QHBoxLayout>
#include <QVBoxLayout>

NotificationBanner::NotificationBanner(QWidget* parent)
    : QWidget(parent)
{
    setFixedHeight(72);
    setAttribute(Qt::WA_TransparentForMouseEvents, false);

    auto* outer = new QHBoxLayout(this);
    outer->setContentsMargins(12, 8, 12, 8);

    // Inner card
    auto* inner = new QWidget(this);
    inner->setObjectName("notifInner");
    auto* row = new QHBoxLayout(inner);
    row->setContentsMargins(12, 8, 10, 8);
    row->setSpacing(12);

    lblIcon = new QLabel("🔔", inner);
    lblIcon->setFixedSize(40, 40);
    lblIcon->setAlignment(Qt::AlignCenter);
    lblIcon->setStyleSheet("font-size:20px; border-radius:20px;");

    auto* texts = new QWidget(inner);
    auto* vl = new QVBoxLayout(texts);
    vl->setContentsMargins(0,0,0,0); vl->setSpacing(2);

    lblTitle = new QLabel("Notifikasi", texts);
    lblTitle->setObjectName("notifTitle");
    lblBody  = new QLabel("Pesan", texts);
    lblBody->setObjectName("notifBody");
    vl->addWidget(lblTitle);
    vl->addWidget(lblBody);

    btnClose = new QPushButton("✕", inner);
    btnClose->setFixedSize(28,28);
    btnClose->setObjectName("btnNotifClose");
    connect(btnClose, &QPushButton::clicked, this, &NotificationBanner::hideBanner);

    row->addWidget(lblIcon);
    row->addWidget(texts, 1);
    row->addWidget(btnClose);

    outer->addWidget(inner);

    autoHide = new QTimer(this);
    autoHide->setSingleShot(true);
    connect(autoHide, &QTimer::timeout, this, &NotificationBanner::hideBanner);

    applyStyle();
    hide();
}

void NotificationBanner::push(const QString& icon, const QString& title, const QString& body) {
    lblIcon->setText(icon);
    lblTitle->setText(title);
    lblBody->setText(body);
    show(); raise();
    autoHide->start(4500);
}

void NotificationBanner::hideBanner() {
    hide();
}

void NotificationBanner::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        #notifInner {
            background-color: %1;
            border: 2px solid %2;
            border-radius: 16px;
        }
        QLabel#notifTitle { font-size:13px; font-weight:800; color:%3; }
        QLabel#notifBody  { font-size:11px; color:%4; }
        QPushButton#btnNotifClose {
            background:transparent; border:none; color:%4;
            font-size:14px; border-radius:14px;
        }
        QPushButton#btnNotifClose:hover { color:%3; }
    )").arg(t.bgSecondary, t.accent, t.textPrimary, t.textMuted));
}
