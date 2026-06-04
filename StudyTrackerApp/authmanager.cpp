#include "authmanager.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject> 
#include <QPixmap>
#include <QImage>
#include <QDir>
#include <QStandardPaths>
#include <QUrl>

AuthManager::AuthManager(QObject *parent)
    : QObject(parent),
    m_settings("StudyTracker", "StudyTrackerApp")
{
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

    QString prefix = "Users/data/" + username + "/";
    m_settings.setValue(prefix + "namaUser",          username);
    m_settings.setValue(prefix + "statusUser",        "Semangat Belajar! 💪");
    m_settings.setValue(prefix + "selectedAvatar",    0);
    m_settings.setValue(prefix + "sessionsCompleted", 0);
    m_settings.setValue(prefix + "secondsFocused",    0);
    m_settings.setValue(prefix + "tasks",             QString("[]"));
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
    if (readPassword(username) != oldPassword) return false;
    writePassword(username, newPassword);
    return true;
}

// ─── Crop & Save ───────────────────────────────────────────────────────────

QString AuthManager::cropAndSave(const QString &sourcePath,
                                 int x, int y, int w, int h)
{
    // sourcePath dari QML bisa berupa "file:///C:/..." — konversi ke path lokal
    QString localPath = QUrl(sourcePath).toLocalFile();
    if (localPath.isEmpty()) localPath = sourcePath; // fallback

    QImage original(localPath);
    if (original.isNull()) {
        qDebug() << "[cropAndSave] Gagal load gambar:" << localPath;
        return "";
    }

    // Skala: gambar ditampilkan 200x200 di QML dengan PreserveAspectCrop
    // Kita perlu tahu skala antara gambar asli dan ukuran display 200x200
    double scaleX = (double)original.width()  / 200.0;
    double scaleY = (double)original.height() / 200.0;

    // Pakai skala yang lebih kecil (sama dengan PreserveAspectCrop)
    double scale = qMax(scaleX, scaleY);

    // Hitung ukuran gambar setelah di-scale ke 200x200
    int scaledW = (int)(original.width()  / scale);
    int scaledH = (int)(original.height() / scale);

    // Offset awal (gambar di-center dalam 200x200 oleh PreserveAspectCrop)
    int centerOffX = (200 - scaledW) / 2;
    int centerOffY = (200 - scaledH) / 2;

    // Koordinat crop dalam gambar asli
    // x/y dari QML adalah offset display (sudah dalam unit pixel 200x200)
    int cropX = (int)((-x - centerOffX) * scale);
    int cropY = (int)((-y - centerOffY) * scale);
    int cropW = (int)(w * scale);
    int cropH = (int)(h * scale);

    // Clamp agar tidak keluar batas gambar
    cropX = qMax(0, qMin(cropX, original.width()  - 1));
    cropY = qMax(0, qMin(cropY, original.height() - 1));
    cropW = qMin(cropW, original.width()  - cropX);
    cropH = qMin(cropH, original.height() - cropY);

    if (cropW <= 0 || cropH <= 0) {
        qDebug() << "[cropAndSave] Area crop tidak valid:" << cropX << cropY << cropW << cropH;
        return "";
    }

    // Crop dan resize ke 200x200
    QImage cropped = original.copy(cropX, cropY, cropW, cropH)
                         .scaled(200, 200, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    // Simpan ke folder temp
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                      + "/StudyTrackerApp";
    QDir().mkpath(tempDir);
    QString outPath = tempDir + "/avatar_crop.png";

    if (!cropped.save(outPath, "PNG")) {
        qDebug() << "[cropAndSave] Gagal menyimpan hasil crop ke:" << outPath;
        return "";
    }

    qDebug() << "[cropAndSave] Berhasil crop ke:" << outPath;
    // Kembalikan sebagai file URL agar QML bisa langsung pakai sebagai Image.source
    return QUrl::fromLocalFile(outPath).toString();
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

    QJsonArray jsonArray;
    for (const QVariant &taskVariant : tasks) {
        QVariantMap taskMap = taskVariant.toMap();
        jsonArray.append(QJsonObject::fromVariantMap(taskMap));
    }
    QJsonDocument doc(jsonArray);
    m_settings.setValue(prefix + "tasks", QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    m_settings.sync();

    qDebug() << "[AuthManager] Data user" << username << "disimpan. Tasks:" << jsonArray.size();
}

QVariantMap AuthManager::loadUserData(const QString &username)
{
    QVariantMap result;

    if (!checkUserExists(username)) {
        qDebug() << "[AuthManager] loadUserData gagal - user tidak ditemukan:" << username;
        return result;
    }

    QString prefix = "Users/data/" + username + "/";

    result["namaUser"]          = m_settings.value(prefix + "namaUser",          username).toString();
    result["statusUser"]        = m_settings.value(prefix + "statusUser",        "Semangat Belajar! 💪").toString();
    result["selectedAvatar"]    = m_settings.value(prefix + "selectedAvatar",    0).toInt();
    result["sessionsCompleted"] = m_settings.value(prefix + "sessionsCompleted", 0).toInt();
    result["secondsFocused"]    = m_settings.value(prefix + "secondsFocused",    0).toInt();

    QString tasksJson = m_settings.value(prefix + "tasks", QString("[]")).toString();
    QJsonDocument doc = QJsonDocument::fromJson(tasksJson.toUtf8());
    QVariantList taskList;
    if (doc.isArray()) {
        for (const QJsonValue &val : doc.array()) {
            taskList.append(val.toObject().toVariantMap());
        }
    }
    result["tasks"] = taskList;

    qDebug() << "[AuthManager] Data user" << username << "dimuat. Tasks:" << taskList.size();
    return result;
}
