#pragma once
#include <QWidget>
#include <QLineEdit>
#include <QPushButton>
#include <QLabel>
#include <QStackedWidget>
#include "appstate.h"

class LoginScreen : public QWidget {
    Q_OBJECT
public:
    explicit LoginScreen(QWidget* parent = nullptr);
    void applyStyle();
    void reset();

signals:
    void loginSuccess(const QString& username, const QString& avatar);

private slots:
    void handleLogin();
    void handleRegister();
    void switchMode();
    void togglePassword();

private:
    bool isRegisterMode = false;

    QLabel*      lblEmoji;
    QLabel*      lblHeading;
    QLabel*      lblSub;
    QLineEdit*   edtUser;
    QLineEdit*   edtPass;
    QLineEdit*   edtPassConfirm;
    QPushButton* btnTogglePass;
    QLabel*      lblError;
    QPushButton* btnMain;
    QPushButton* btnSwitch;
    QWidget*     confirmRow;

    // Simple user store (in-memory, simulasi)
    QMap<QString,QString> userDb;

    void showError(const QString& msg, bool success=false);
    void buildUi();
    void applyModeUi();
};
