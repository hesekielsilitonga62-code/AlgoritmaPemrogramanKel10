#pragma once
#include <QWidget>
#include <QLabel>
#include <QLineEdit>
#include <QDialog>
#include <QListWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QTimer>
#include "appstate.h"

class ChatDialog : public QDialog {
    Q_OBJECT
public:
    explicit ChatDialog(const Friend& fr, QWidget* parent = nullptr);

private:
    QListWidget*  msgList;
    QLineEdit*    edtInput;
    const Friend& fr;

    void sendMessage(const QString& msg);
    void addBubble(const QString& text, bool isMe, const QString& sender = "");
    QString getAutoReply(const QString& msg);
    void applyStyle();
};

class FriendScreen : public QWidget {
    Q_OBJECT
public:
    explicit FriendScreen(QWidget* parent = nullptr);
    void refresh();
    void applyStyle();

private:
    QLineEdit*   edtSearch;
    QWidget*     onlineContainer;
    QWidget*     offlineContainer;
    QVBoxLayout* onlineLay;
    QVBoxLayout* offlineLay;

    void buildUi();
    void renderFriends(const QString& search = "");
    void openChat(const QString& name);
};
