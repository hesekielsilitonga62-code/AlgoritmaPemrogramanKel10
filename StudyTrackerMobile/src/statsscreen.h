#pragma once
#include <QWidget>
#include <QLabel>
#include "appstate.h"

class StatsScreen : public QWidget {
    Q_OBJECT
public:
    explicit StatsScreen(QWidget* parent=nullptr);
    void refresh();
    void applyStyle();
private:
    QLabel* lblTotalHours;
    QLabel* lblSessions;
    QLabel* lblTasks;
    QLabel* lblDone;
    QLabel* lblStreak;
    QLabel* lblAvgDaily;
    // Weekly bar
    QList<QWidget*> barWidgets;
    QList<QLabel*>  barLabels;

    QWidget* listContainer;
    void buildUi();
    void updateWeeklyBar();
};
