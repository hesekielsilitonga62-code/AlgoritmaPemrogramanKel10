#pragma once
#include <QWidget>
#include <QLabel>
#include <QPushButton>
#include <QScrollArea>
#include <QVBoxLayout>
#include "appstate.h"

class HomeScreen : public QWidget {
    Q_OBJECT
public:
    explicit HomeScreen(QWidget* parent = nullptr);
    void refresh();
    void applyStyle();

signals:
    void timerStartRequested();
    void timerStopRequested();
    void timerSkipRequested();
    void navigateTo(const QString& screen);

private:
    QLabel*  lblName;
    QLabel*  lblStatus;
    QLabel*  lblAvatar;
    QLabel*  lblSessions;
    QLabel*  lblFocus;
    QLabel*  lblTasks;
    QLabel*  lblDone;
    QLabel*  lblPomDisplay;
    QLabel*  lblPomBadge;
    QLabel*  lblPomSessions;
    QLabel*  lblQuoteText;
    QLabel*  lblQuoteAuthor;
    QLabel*  lblStatusTime;
    QWidget* taskPreviewContainer;
    QVBoxLayout* taskPreviewLayout;

    // Streak dots
    QList<QLabel*> streakDots;
    QLabel* lblStreakCount;

    void buildUi();
    void updatePomadoroDisplay();
    void updateTaskPreview();
    void updateStreak();
    QString formatStudyTime(int secs);
};
