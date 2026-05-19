#pragma once
#include <QWidget>
#include <QPushButton>
#include <QMap>

class NavigationBar : public QWidget {
    Q_OBJECT
public:
    explicit NavigationBar(QWidget* parent = nullptr);
    void setActive(const QString& screen);
    void applyStyle();

signals:
    void screenRequested(const QString& screen);

private:
    struct NavItem { QPushButton* btn; QString icon; QString label; };
    QList<NavItem> items;
    QString activeScreen;

    QPushButton* makeNavBtn(const QString& icon, const QString& label);
};
