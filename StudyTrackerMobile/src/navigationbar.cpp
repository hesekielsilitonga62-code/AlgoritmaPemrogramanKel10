#include "navigationbar.h"
#include "appstate.h"
#include <QHBoxLayout>

NavigationBar::NavigationBar(QWidget* parent) : QWidget(parent) {
    setFixedHeight(68);
    auto* layout = new QHBoxLayout(this);
    layout->setContentsMargins(8, 0, 8, 0);
    layout->setSpacing(0);

    struct Def { QString screen, icon, label; };
    QList<Def> defs = {
        {"main",     "🏠", "Home"},
        {"tasks",    "📋", "Tugas"},
        {"timer",    "⏱",  "Timer"},
        {"stats",    "📊", "Statistik"},
        {"friends",  "👥", "Teman"},
        {"settings", "⚙️", "Setelan"},
    };

    for (auto& d : defs) {
        auto* btn = makeNavBtn(d.icon, d.label);
        btn->setProperty("screen", d.screen);
        connect(btn, &QPushButton::clicked, this, [this, d](){
            emit screenRequested(d.screen);
        });
        layout->addWidget(btn, 1);
        items.append({btn, d.icon, d.label});
    }
    applyStyle();
}

QPushButton* NavigationBar::makeNavBtn(const QString& icon, const QString& label) {
    auto* btn = new QPushButton(this);
    btn->setText(icon + "\n" + label);
    btn->setCheckable(true);
    btn->setFlat(true);
    return btn;
}

void NavigationBar::setActive(const QString& screen) {
    activeScreen = screen;
    for (auto& item : items) {
        bool active = (item.btn->property("screen").toString() == screen);
        item.btn->setChecked(active);
    }
    applyStyle();
}

void NavigationBar::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        NavigationBar {
            background-color: %1;
            border-top: 1px solid %2;
        }
        QPushButton {
            background: transparent;
            border: none;
            border-radius: 12px;
            color: %3;
            font-size: 10px;
            font-weight: bold;
            padding: 6px 2px;
        }
        QPushButton:checked {
            color: %4;
            background-color: rgba(255,204,0,20);
        }
        QPushButton:pressed {
            background-color: rgba(255,204,0,30);
        }
    )").arg(t.bgSecondary, t.border, t.textMuted, t.accent));
}
