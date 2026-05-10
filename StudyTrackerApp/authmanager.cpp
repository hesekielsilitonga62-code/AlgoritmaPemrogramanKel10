#include "authmanager.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

// QSettings akan menyimpan data di lokasi standar OS:
//   Windows : HKEY_CURRENT_USER\Software\StudyTracker\StudyTrackerApp
//   Linux   : ~/.config/StudyTracker/StudyTrackerApp.ini
//   macOS   : ~/Library/Preferences/com.StudyTracker.StudyTrackerApp.plist
AuthManager::AuthManager(QObject *parent)
    : QObject(parent),
    m_settings("StudyTracker", "StudyTrackerApp")
{
    // Seed akun admin hanya jika belum pernah terdaftar sebelumnya
    if (!checkUserExists("admin")) {
        writePassword("admin", "1234");
        qDebug() << "[AuthManager] Akun admin di-seed untuk pertama kali.";
    }
    qDebug() << "[AuthManager] QSettings path:" << m_settings.fileName();
}

// ─── Helpers privat ────────────────────────────────────────────────────────

QString AuthManager::readPassword(const QString &username) const
{
    return m_settings.value("Users/credentials/" + username, QString()).toString();
}

void AuthManager::writePassword(const QString &username, const QString &password)
{
    m_settings.setValue("Users/credentials/" + username, password);
    m_settings.sync();
}

// ─── Auth API ──────────────────────────────────────────────────────────────

bool AuthManager::login(QString username, QString password)
{
    if (checkUserExists(username) && readPassword(username) == password) {
        qDebug() << "[AuthManager] Login berhasil untuk:" << username;
        return true;
    }
    qDebug() << "[AuthManager] Login gagal untuk:" << username;
    return false;
}

bool AuthManager::registerUser(QString username, QString password)
{
    if (username.isEmpty() || password.isEmpty() || checkUserExists(username)) {
        qDebug() << "[AuthManager] Registrasi gagal.";
        return false;
    }
    writePassword(username, password);

    // Inisialisasi profil kosong untuk user baru
    QString prefix = "Users/data/" + username + "/";
    m_settings.setValue(prefix + "namaUser",          username);
    m_settings.setValue(prefix + "statusUser",        "Semangat Belajar! 💪");
    m_settings.setValue(prefix + "selectedAvatar",    0);
    m_settings.setValue(prefix + "sessionsCompleted", 0);
    m_settings.setValue(prefix + "secondsFocused",    0);
    m_settings.setValue(prefix + "tasks",             QString("[]")); // JSON array kosong
    m_settings.sync();

    qDebug() << "[AuthManager] User baru terdaftar:" << username;
    return true;
}

bool AuthManager::checkUserExists(QString username)
{
    return m_settings.contains("Users/credentials/" + username);
}

bool AuthManager::resetPassword(QString username, QString oldPassword, QString newPassword) {
    if (!checkUserExists(username)) return false;
    if (readPassword(username) != oldPassword) return false; // verifikasi dulu
    writePassword(username, newPassword);
    return true;
}

// ─── User Data API ─────────────────────────────────────────────────────────

void AuthManager::saveUserData(const QString     &username,
                               const QString     &namaUser,
                               const QString     &statusUser,
                               int                selectedAvatar,
                               int                sessionsCompleted,
                               int                secondsFocused,
                               const QVariantList &tasks)
{
    if (!checkUserExists(username)) {
        qDebug() << "[AuthManager] saveUserData gagal - user tidak ditemukan:" << username;
        return;
    }

    QString prefix = "Users/data/" + username + "/";
    m_settings.setValue(prefix + "namaUser",          namaUser);
    m_settings.setValue(prefix + "statusUser",        statusUser);
    m_settings.setValue(prefix + "selectedAvatar",    selectedAvatar);
    m_settings.setValue(prefix + "sessionsCompleted", sessionsCompleted);
    m_settings.setValue(prefix + "secondsFocused",    secondsFocused);

    // Simpan tasks sebagai JSON string
    // tasks dari QML adalah QVariantList berisi QVariantMap
    QJsonArray jsonArray;
    for (const QVariant &taskVariant : tasks) {
        QVariantMap taskMap = taskVariant.toMap();
        jsonArray.append(QJsonObject::fromVariantMap(taskMap));
    }
    QJsonDocument doc(jsonArray);
    m_settings.setValue(prefix + "tasks", QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    m_settings.sync();

    qDebug() << "[AuthManager] Data user" << username << "disimpan."
             << "Tasks:" << jsonArray.size();
}

QVariantMap AuthManager::loadUserData(const QString &username)
{
    QVariantMap result;

    if (!checkUserExists(username)) {
        qDebug() << "[AuthManager] loadUserData gagal - user tidak ditemukan:" << username;
        return result; // return map kosong
    }

    QString prefix = "Users/data/" + username + "/";

    result["namaUser"]          = m_settings.value(prefix + "namaUser",          username).toString();
    result["statusUser"]        = m_settings.value(prefix + "statusUser",        "Semangat Belajar! 💪").toString();
    result["selectedAvatar"]    = m_settings.value(prefix + "selectedAvatar",    0).toInt();
    result["sessionsCompleted"] = m_settings.value(prefix + "sessionsCompleted", 0).toInt();
    result["secondsFocused"]    = m_settings.value(prefix + "secondsFocused",    0).toInt();

    // Parse tasks dari JSON string kembali ke QVariantList
    QString tasksJson = m_settings.value(prefix + "tasks", QString("[]")).toString();
    QJsonDocument doc = QJsonDocument::fromJson(tasksJson.toUtf8());
    QVariantList taskList;
    if (doc.isArray()) {
        for (const QJsonValue &val : doc.array()) {
            taskList.append(val.toObject().toVariantMap());
        }
    }
    result["tasks"] = taskList;

    qDebug() << "[AuthManager] Data user" << username << "dimuat."
             << "Tasks:" << taskList.size();
    return result;
}