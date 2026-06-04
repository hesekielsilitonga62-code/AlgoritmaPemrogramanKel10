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
    Q_INVOKABLE bool resetPassword(QString username, QString oldPassword, QString newPassword);

    // ── User Profile & Data ─────────────────────────────────────────────────
    Q_INVOKABLE void saveUserData(const QString &username,
                                  const QString &namaUser,
                                  const QString &statusUser,
                                  int            selectedAvatar,
                                  int            sessionsCompleted,
                                  int            secondsFocused,
                                  const QVariantList &tasks);

    Q_INVOKABLE QVariantMap loadUserData(const QString &username);

    // ── Crop & Save ─────────────────────────────────────────────────────────
    // Memotong gambar di path `sourcePath` dengan koordinat (x, y, w, h)
    // dalam skala gambar asli, lalu menyimpannya ke file temp.
    // Mengembalikan path file hasil crop (sebagai "file:///...") atau "" jika gagal.
    Q_INVOKABLE QString cropAndSave(const QString &sourcePath,
                                    int x, int y, int w, int h);

private:
    QSettings m_settings;

    QString readPassword(const QString &username) const;
    void    writePassword(const QString &username, const QString &password);
};

#endif // AUTHMANAGER_H
