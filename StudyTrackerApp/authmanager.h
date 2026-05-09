#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QSettings>
#include <QString>
#include <QVariant>

class AuthManager : public QObject
{
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);

    // ── Auth ────────────────────────────────────────────────────────────────
    Q_INVOKABLE bool login(QString username, QString password);
    Q_INVOKABLE bool registerUser(QString username, QString password);
    Q_INVOKABLE bool checkUserExists(QString username);
    Q_INVOKABLE bool resetPassword(QString username, QString newPassword);

    // ── User Profile & Data ─────────────────────────────────────────────────
    // Dipanggil dari QML saat logout / pindah halaman
    // tasks: QVariantList berisi QVariantMap per task (dari globalTaskModel)
    Q_INVOKABLE void saveUserData(const QString &username,
                                  const QString &namaUser,
                                  const QString &statusUser,
                                  int            selectedAvatar,
                                  int            sessionsCompleted,
                                  int            secondsFocused,
                                  const QVariantList &tasks);

    // Mengembalikan semua data user sebagai QVariantMap ke QML
    // QML bisa akses: result.namaUser, result.tasks, dsb.
    Q_INVOKABLE QVariantMap loadUserData(const QString &username);

private:
    QSettings m_settings;

    QString readPassword(const QString &username) const;
    void    writePassword(const QString &username, const QString &password);
};

#endif // AUTHMANAGER_H