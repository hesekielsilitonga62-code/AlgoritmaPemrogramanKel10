#pragma once
#include <QString>

// ═══════════════════════════════════════════════
//  STUDY TRACKER — Qt Stylesheet & Color System
//  Kelompok 10
// ═══════════════════════════════════════════════

namespace ST {

// ── Warna tema default (dark) ──────────────────
struct Theme {
    QString bgPrimary   = "#001b2e";
    QString bgSecondary = "#0a2a43";
    QString bgCard      = "#051624";
    QString bgDeep      = "#020f1a";
    QString accent      = "#ffcc00";
    QString accentDim   = "rgba(255,204,0,40)";
    QString border      = "#163e5f";
    QString textPrimary = "#ffffff";
    QString textMuted   = "#8a9fb1";
    QString green       = "#05d605";
    QString red         = "#ff5555";
};

// ── Temas tersedia ─────────────────────────────
inline Theme defaultTheme() { return Theme{}; }

inline Theme blackTheme() {
    Theme t;
    t.bgPrimary="#0a0a0a"; t.bgSecondary="#141414"; t.bgCard="#050505"; t.bgDeep="#000000";
    t.accent="#ffffff"; t.border="#2a2a2a"; t.textMuted="#666666";
    return t;
}
inline Theme whiteTheme() {
    Theme t;
    t.bgPrimary="#f0f4f8"; t.bgSecondary="#ffffff"; t.bgCard="#e8edf2"; t.bgDeep="#d8e0e8";
    t.accent="#1565c0"; t.border="#cfd8dc"; t.textPrimary="#1a1a2e"; t.textMuted="#546e7a";
    return t;
}
inline Theme pinkTheme() {
    Theme t;
    t.bgPrimary="#1a0a12"; t.bgSecondary="#2d1020"; t.bgCard="#120709"; t.bgDeep="#0a0408";
    t.accent="#ff6eb4"; t.border="#4a1a30"; t.textPrimary="#ffe0f0"; t.textMuted="#c27a9a";
    return t;
}
inline Theme lautTheme() {
    Theme t;
    t.bgPrimary="#0a1f3d"; t.bgSecondary="#112d54"; t.bgCard="#071529"; t.bgDeep="#040e1c";
    t.accent="#38bdf8"; t.border="#1e4a7a"; t.textPrimary="#dbeafe"; t.textMuted="#7aadcc";
    return t;
}
inline Theme ademTheme() {
    Theme t;
    t.bgPrimary="#061a10"; t.bgSecondary="#0e2e1c"; t.bgCard="#040f09"; t.bgDeep="#020a05";
    t.accent="#4ecca3"; t.border="#1a4a2e"; t.textPrimary="#d0f5e8"; t.textMuted="#6aab88";
    return t;
}
inline Theme vintageTheme() {
    Theme t;
    t.bgPrimary="#1c1208"; t.bgSecondary="#2e1f0e"; t.bgCard="#120c04"; t.bgDeep="#0a0700";
    t.accent="#d4a24c"; t.border="#4a3010"; t.textPrimary="#f5e6c8"; t.textMuted="#9c7a4a";
    return t;
}

// ── Global stylesheet dinamis ─────────────────
inline QString buildStyleSheet(const Theme& t) {
    return QString(R"(
QWidget {
    font-family: "Segoe UI", "Roboto", sans-serif;
    font-size: 14px;
    color: %1;
    background-color: transparent;
}
QScrollArea, QScrollArea > QWidget > QWidget {
    background-color: transparent;
    border: none;
}
QScrollBar:vertical {
    background: transparent;
    width: 4px;
    margin: 0;
}
QScrollBar::handle:vertical {
    background: %7;
    border-radius: 2px;
    min-height: 30px;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }

/* ── Input fields ── */
QLineEdit {
    background-color: %3;
    border: 1.5px solid %7;
    border-radius: 14px;
    padding: 8px 14px;
    color: %1;
    font-size: 14px;
    selection-background-color: %5;
}
QLineEdit:focus {
    border-color: %5;
    background-color: %2;
}
QLineEdit::placeholder { color: %8; }

/* ── Buttons ── */
QPushButton {
    border-radius: 14px;
    padding: 10px 18px;
    font-size: 14px;
    font-weight: bold;
    border: none;
    cursor: pointer;
}
QPushButton#btnMain {
    background: qlineargradient(x1:0,y1:0,x2:1,y2:0, stop:0 %5, stop:1 %9);
    color: %4;
    font-size: 15px;
    font-weight: 900;
    border-radius: 14px;
    min-height: 52px;
}
QPushButton#btnMain:pressed { background: %5; }

QPushButton#btnPomStart {
    background-color: %5;
    color: %4;
    border-radius: 22px;
    font-size: 13px;
    font-weight: bold;
    min-height: 44px;
}
QPushButton#btnPomStop, QPushButton#btnPomSkip {
    background-color: %3;
    color: %1;
    border: 1px solid %7;
    border-radius: 22px;
    font-size: 13px;
    min-height: 44px;
}
QPushButton#btnAddTask {
    background-color: %5;
    color: %4;
    border-radius: 14px;
    font-size: 13px;
    font-weight: bold;
    padding: 8px 16px;
}
QPushButton#btnDanger {
    background-color: rgba(255,85,85,25);
    border: 1.5px solid rgba(255,85,85,76);
    color: #ff7070;
    border-radius: 14px;
    font-size: 15px;
    font-weight: bold;
    min-height: 50px;
}
QPushButton#btnDanger:pressed { background-color: rgba(255,85,85,50); }
QPushButton#btnSave {
    background-color: %5;
    color: %4;
    border-radius: 12px;
    font-size: 14px;
    font-weight: bold;
    min-height: 46px;
}
QPushButton#btnCancel {
    background-color: %2;
    color: %8;
    border: 1px solid %7;
    border-radius: 12px;
    font-size: 14px;
    min-height: 46px;
}
QPushButton#btnTimerStart {
    background-color: %5;
    color: %4;
    border-radius: 24px;
    font-size: 14px;
    font-weight: bold;
    min-height: 48px;
}
QPushButton#btnTimerStop, QPushButton#btnTimerSkip {
    background-color: %2;
    color: %1;
    border: 1px solid %7;
    border-radius: 24px;
    font-size: 14px;
    min-height: 48px;
}
QPushButton#btnLogout {
    background-color: rgba(255,85,85,25);
    border: 1.5px solid rgba(255,85,85,76);
    color: #ff7070;
    border-radius: 12px;
    font-size: 14px;
    font-weight: bold;
    min-height: 48px;
}

/* ── ComboBox ── */
QComboBox {
    background-color: %3;
    border: 1px solid %7;
    border-radius: 10px;
    padding: 6px 10px;
    color: %1;
    font-size: 13px;
    font-weight: bold;
    min-width: 100px;
}
QComboBox::drop-down { border: none; width: 20px; }
QComboBox QAbstractItemView {
    background-color: %2;
    border: 1px solid %7;
    selection-background-color: %5;
    color: %1;
}

/* ── Labels ── */
QLabel { background: transparent; }
QLabel#labelAccent { color: %5; font-weight: bold; }
QLabel#labelMuted  { color: %8; font-size: 12px; }

/* ── Spin box (timer inputs) ── */
QSpinBox {
    background-color: %2;
    border: 1px solid %7;
    border-radius: 10px;
    padding: 4px 8px;
    color: %1;
    font-size: 20px;
    font-weight: bold;
}
QSpinBox::up-button, QSpinBox::down-button {
    width: 20px; height: 16px;
    background: %7;
    border-radius: 4px;
}
)")
    .arg(t.textPrimary)   // %1 text-primary
    .arg(t.bgSecondary)   // %2 bg-secondary
    .arg(t.bgCard)        // %3 bg-card
    .arg(t.bgDeep)        // %4 bg-deep
    .arg(t.accent)        // %5 accent
    .arg("")              // %6 unused
    .arg(t.border)        // %7 border
    .arg(t.textMuted)     // %8 text-muted
    .arg(t.green);        // %9 green
}

} // namespace ST
