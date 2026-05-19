#pragma once
#include <QWidget>
#include <QLabel>
#include <QPushButton>
#include <QLineEdit>
#include <QDialog>
#include <QVBoxLayout>
#include <QDateTimeEdit>
#include <QCheckBox>
#include "appstate.h"

class TaskDialog : public QDialog {
    Q_OBJECT
public:
    explicit TaskDialog(QWidget* parent = nullptr, const Task* edit = nullptr);
    Task getTask() const;

private:
    QLineEdit*      edtTitle;
    QLineEdit*      edtMatkul;
    QDateTimeEdit*  dtDeadline;
    QCheckBox*      chkNoDeadline;
    int             priority = 1;
    QPushButton*    btnHigh;
    QPushButton*    btnMed;
    QPushButton*    btnLow;

    void selectPriority(int p);
    void applyStyle();
};

class TaskScreen : public QWidget {
    Q_OBJECT
public:
    explicit TaskScreen(QWidget* parent = nullptr);
    void refresh();
    void applyStyle();

private:
    QLabel*      lblCount;
    QWidget*     listContainer;
    QVBoxLayout* listLayout;

    void buildUi();
    void openAddTask();
    void renderTasks();
    void toggleDone(int taskId);
    void deleteTask(int taskId);
    void editTask(int taskId);
};
