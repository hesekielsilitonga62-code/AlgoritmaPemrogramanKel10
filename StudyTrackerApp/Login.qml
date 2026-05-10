import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ════════════════════════════════════════════════════════════════════════
// Login.qml — Halaman Login & Registrasi (Redesign)
// Card mengikuti warna tema aktif (accentColor, bgCard, dll)
// Field username & password dipisah jadi bubble sendiri-sendiri
// ════════════════════════════════════════════════════════════════════════

Rectangle {
    id: loginRoot
    anchors.fill: parent
    color: "transparent"

    // ── Signal ke Main.qml ───────────────────────────────────────────────
    signal loginSuccess()

    // ── State internal ───────────────────────────────────────────────────
    property string errorMessage:  ""
    property bool   showError:     false
    property bool   isSuccess:     false
    property int    loginAttempts: 0
    property bool   isLoginView:   window.isLoginView

    Connections {
        target: window
        function onIsLoginViewChanged() { loginRoot.isLoginView = window.isLoginView }
    }

    // ── Dekorasi kiri ─────────────────────────────────────────────────────
    Column {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 60; spacing: 28
        visible: parent.width > 800

        Text { text: "📚"; font.pixelSize: 52 }
        Text {
            text: "Study\nTracker"
            font.pixelSize: 42; font.bold: true
            color: window.textPrimary; lineHeight: 1.15
        }
        Text {
            text: lang.dekorasiSlogan
            color: window.textMuted; font.pixelSize: 15; lineHeight: 1.5
        }
        Column { spacing: 14; topPadding: 10
            Repeater {
                model: [lang.dekorasi1, lang.dekorasi2, lang.dekorasi3, lang.dekorasi4]
                Text { text: modelData; color: window.textMuted; font.pixelSize: 13 }
            }
        }
    }

    // ── Dekorasi kanan ────────────────────────────────────────────────────
    Column {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 60; spacing: 20
        visible: parent.width > 900

        Repeater {
            model: [lang.dekorasi5, lang.dekorasi6, lang.dekorasi7]
            Rectangle {
                width: 230; height: 56; radius: 14
                color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.06)
                border.color: window.borderColor; border.width: 1
                Text { anchors.centerIn: parent; text: modelData; color: window.textMuted; font.pixelSize: 12 }
            }
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // KARTU LOGIN TENGAH
    // ═════════════════════════════════════════════════════════════════════
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.88, 430)
        height: loginColumn.implicitHeight + 56
        radius: 28

        // Warna card ikut tema
        color: window.bgSecondary

        // Border accent tipis
        border.color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.45)
        border.width: 1.5

        // Glow lembut di belakang card
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 24; height: parent.height + 24
            radius: parent.radius + 12
            color: "transparent"
            border.color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.10)
            border.width: 8
            z: -1
        }

        // Strip aksen di atas card
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 4
            radius: 4
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.0) }
                GradientStop { position: 0.3; color: window.accentColor }
                GradientStop { position: 0.7; color: window.accentColor }
                GradientStop { position: 1.0; color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.0) }
            }
        }

        ColumnLayout {
            id: loginColumn
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 36 }
            anchors.topMargin: 32
            spacing: 14

            // ── Avatar / ikon ──────────────────────────────────────────────
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 62; height: 62; radius: 31
                color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.15)
                border.color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.5)
                border.width: 2
                Text {
                    anchors.centerIn: parent
                    text: loginRoot.isLoginView ? "👋" : "✨"
                    font.pixelSize: 28
                }
            }

            // ── Judul ──────────────────────────────────────────────────────
            Text {
                text: loginRoot.isLoginView ? lang.selamatDatang : lang.buatAkunBaru
                font.pixelSize: 22; font.bold: true
                color: window.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: loginRoot.isLoginView ? lang.masukKeApp : lang.daftarkanAkun
                color: window.textMuted; font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
                bottomPadding: 4
            }

            // ── Notifikasi error / sukses ──────────────────────────────────
            Rectangle {
                visible: loginRoot.showError
                Layout.fillWidth: true
                height: visible ? notifRow.implicitHeight + 16 : 0
                radius: 10
                color: loginRoot.isSuccess
                    ? Qt.rgba(0.18, 0.78, 0.44, 0.15)
                    : Qt.rgba(1, 0.27, 0.27, 0.13)
                border.color: loginRoot.isSuccess ? "#2ecc71" : "#ff5555"
                border.width: 1

                RowLayout {
                    id: notifRow
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 12 }
                    spacing: 8
                    Text { text: loginRoot.isSuccess ? "✅" : "⚠️"; font.pixelSize: 14 }
                    Text {
                        text: loginRoot.errorMessage
                        color: loginRoot.isSuccess ? "#2ecc71" : "#ff7070"
                        font.pixelSize: 12; wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        visible: !loginRoot.isSuccess && !backend.checkUserExists(userField.text) && userField.text !== "" && loginRoot.isLoginView
                        width: visible ? daftarLink.implicitWidth + 16 : 0; height: 26; radius: 6
                        color: window.accentColor
                        Text { id: daftarLink; anchors.centerIn: parent; text: "Daftar →"; color: window.bgDeep; font.pixelSize: 11; font.bold: true }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { loginRoot.isLoginView = false; window.isLoginView = false; loginRoot.showError = false }
                        }
                    }
                    Rectangle {
                        visible: !loginRoot.isSuccess && loginRoot.loginAttempts >= 3 && loginRoot.isLoginView
                        width: visible ? resetLink.implicitWidth + 16 : 0; height: 26; radius: 6
                        color: "#ff5555"
                        Text { id: resetLink; anchors.centerIn: parent; text: "Reset →"; color: "#fff"; font.pixelSize: 11; font.bold: true }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: resetPopup.open() }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // FIELD USERNAME — bubble sendiri dengan label + ikon
            // ══════════════════════════════════════════════════════════════
            Column {
                Layout.fillWidth: true; spacing: 6

                // Label kecil di atas
                Row {
                    spacing: 5; leftPadding: 4
                    Text { text: "👤"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: lang.emailUsername
                        color: window.accentColor; font.pixelSize: 11; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Bubble field username
                Rectangle {
                    width: parent.width; height: 50; radius: 14
                    color: userField.activeFocus
                        ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.10)
                        : window.bgCard
                    border.color: userField.activeFocus
                        ? window.accentColor
                        : Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.30)
                    border.width: userField.activeFocus ? 2 : 1.5

                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    Behavior on color        { ColorAnimation { duration: 180 } }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left; anchors.leftMargin: 14
                        text: "✉️"; font.pixelSize: 16
                    }

                    TextField {
                        id: userField
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: 42; anchors.rightMargin: 12
                        placeholderText: "username / email"
                        color: window.textPrimary
                        placeholderTextColor: window.textMuted
                        font.pixelSize: 13
                        background: Rectangle { color: "transparent" }
                        Keys.onReturnPressed: passField.forceActiveFocus()
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // FIELD PASSWORD — bubble terpisah, warna hijau agar beda jelas
            // ══════════════════════════════════════════════════════════════
            Column {
                Layout.fillWidth: true; spacing: 6

                // Label kecil di atas
                Row {
                    spacing: 5; leftPadding: 4
                    Text { text: "🔒"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: lang.kataSandi
                        color: "#05d605"; font.pixelSize: 11; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Bubble field password — border hijau agar beda dari username
                Rectangle {
                    width: parent.width; height: 50; radius: 14
                    color: passField.activeFocus
                        ? Qt.rgba(0.02, 0.84, 0.02, 0.09)
                        : window.bgCard
                    border.color: passField.activeFocus
                        ? "#05d605"
                        : Qt.rgba(0.02, 0.84, 0.02, 0.35)
                    border.width: passField.activeFocus ? 2 : 1.5

                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    Behavior on color        { ColorAnimation { duration: 180 } }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left; anchors.leftMargin: 14
                        text: "🔑"; font.pixelSize: 16
                    }

                    TextField {
                        id: passField
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: 42; anchors.rightMargin: showPassBtn.width + 16
                        placeholderText: "••••••••"
                        echoMode: passField.passVisible ? TextInput.Normal : TextInput.Password
                        color: window.textPrimary
                        placeholderTextColor: window.textMuted
                        font.pixelSize: 13
                        background: Rectangle { color: "transparent" }
                        Keys.onReturnPressed: loginBtn.doLogin()
                        property bool passVisible: false
                    }

                    // Tombol show / hide password
                    Rectangle {
                        id: showPassBtn
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right; anchors.rightMargin: 10
                        width: 30; height: 30; radius: 8
                        color: showPassArea.pressed ? Qt.rgba(0.02, 0.84, 0.02, 0.20) : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            anchors.centerIn: parent
                            text: passField.passVisible ? "🙈" : "👁️"
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: showPassArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: passField.passVisible = !passField.passVisible
                        }
                    }
                }
            }

            // ── Tombol utama ───────────────────────────────────────────────
            Rectangle {
                id: loginBtn
                Layout.fillWidth: true; Layout.topMargin: 6; height: 52; radius: 14

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: loginBtnArea.pressed
                            ? Qt.darker(window.accentColor, 1.2)
                            : window.accentColor
                    }
                    GradientStop {
                        position: 1.0
                        color: loginBtnArea.pressed ? "#00aa00" : "#05d605"
                    }
                }

                // Shine tipis di atas
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: parent.height / 2; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                Text {
                    anchors.centerIn: parent
                    text: loginRoot.isLoginView ? lang.masuk : lang.daftarSekarang
                    color: window.bgDeep; font.bold: true; font.pixelSize: 15
                    font.letterSpacing: 0.5
                }

                function doLogin() {
                    if (loginRoot.isLoginView) {
                        if (userField.text.trim() === "" || passField.text === "") {
                            loginRoot.errorMessage = lang.isiUsernamePassword
                            loginRoot.isSuccess    = false
                            loginRoot.showError    = true
                            return
                        }
                        if (!backend.checkUserExists(userField.text.trim())) {
                            loginRoot.errorMessage = lang.akunBelumTerdaftar1 + userField.text.trim() + lang.akunBelumTerdaftar2
                            loginRoot.isSuccess    = false
                            loginRoot.showError    = true
                            return
                        }
                        if (backend.login(userField.text.trim(), passField.text)) {
                            var u    = userField.text.trim()
                            var data = backend.loadUserData(u)
                            window.currentUser             = u
                            window.namaUser                = data.namaUser
                            window.statusUser              = data.statusUser
                            window.selectedAvatar          = data.selectedAvatar
                            window.globalSessionsCompleted = data.sessionsCompleted
                            window.globalSecondsFocused    = data.secondsFocused
                            globalTaskModel.clear()
                            for (var i = 0; i < data.tasks.length; i++) globalTaskModel.append(data.tasks[i])
                            loginRoot.loginAttempts = 0
                            loginRoot.showError     = false
                            loginRoot.loginSuccess()
                        } else {
                            loginRoot.loginAttempts++
                            loginRoot.isSuccess  = false
                            loginRoot.showError  = true
                            loginRoot.errorMessage = loginRoot.loginAttempts >= 3
                                ? loginRoot.loginAttempts + lang.passwordSalahNKali
                                : lang.passwordSalah + " (" + loginRoot.loginAttempts + "/3)"
                        }
                    } else {
                        if (backend.registerUser(userField.text.trim(), passField.text)) {
                            loginRoot.isLoginView  = true
                            window.isLoginView     = true
                            loginRoot.isSuccess    = true
                            loginRoot.showError    = true
                            loginRoot.errorMessage = lang.pendaftaranBerhasil
                            passField.text         = ""
                        } else {
                            loginRoot.isSuccess    = false
                            loginRoot.showError    = true
                            loginRoot.errorMessage = lang.gagalDaftar
                        }
                    }
                }

                MouseArea {
                    id: loginBtnArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: loginBtn.doLogin()
                }
            }

            // ── Link bawah ──────────────────────────────────────────────────
            Row {
                Layout.alignment: Qt.AlignHCenter; spacing: 10; bottomPadding: 8
                Text {
                    text: loginRoot.isLoginView ? lang.lupaKataSandi : lang.kembali
                    color: window.textMuted; font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (loginRoot.isLoginView) resetPopup.open()
                            else { loginRoot.isLoginView = true; window.isLoginView = true }
                        }
                    }
                }
                Text { text: "·"; color: window.borderColor }
                Text {
                    text: loginRoot.isLoginView ? lang.daftar : lang.sudahPunyaAkun
                    color: "#05d605"; font.pixelSize: 12; font.bold: true
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            loginRoot.isLoginView = !loginRoot.isLoginView
                            window.isLoginView    = loginRoot.isLoginView
                            loginRoot.showError   = false
                        }
                    }
                }
            }

            // ── Popup Reset Password ───────────────────────────────────────
            Popup {
                id: resetPopup
                anchors.centerIn: Overlay.overlay
                width: 340; height: 300; modal: true
                focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                background: Rectangle {
                    color: window.bgSecondary; radius: 20
                    border.color: window.accentColor; border.width: 1.5
                    // strip di atas
                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 4; radius: 4; color: window.accentColor; opacity: 0.7
                    }
                }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 22; spacing: 12

                    Text {
                        text: lang.gantiPassword
                        color: window.textPrimary; font.bold: true; font.pixelSize: 15
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: lang.resetPasswordUntuk + (userField.text.trim() !== "" ? userField.text.trim() : "—")
                        color: window.accentColor; font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Field password lama
                    Rectangle {
                        Layout.fillWidth: true; height: 46; radius: 12
                        color: window.bgCard
                        border.color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.35)
                        border.width: 1.5
                        Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12; text: "🔑"; font.pixelSize: 14 }
                        TextField {
                            id: oldPassField
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                            anchors.leftMargin: 36; anchors.rightMargin: 10
                            placeholderText: lang.passwordLama
                            echoMode: TextInput.Password; font.pixelSize: 13
                            color: window.textPrimary; placeholderTextColor: window.textMuted
                            background: Rectangle { color: "transparent" }
                        }
                    }

                    // Field password baru
                    Rectangle {
                        Layout.fillWidth: true; height: 46; radius: 12
                        color: window.bgCard
                        border.color: Qt.rgba(0.02, 0.84, 0.02, 0.35)
                        border.width: 1.5
                        Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12; text: "🆕"; font.pixelSize: 14 }
                        TextField {
                            id: newPassField
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                            anchors.leftMargin: 36; anchors.rightMargin: 10
                            placeholderText: lang.masukkanPasswordBaru
                            echoMode: TextInput.Password; font.pixelSize: 13
                            color: window.textPrimary; placeholderTextColor: window.textMuted
                            background: Rectangle { color: "transparent" }
                        }
                    }

                    Text {
                        id: resetError; text: ""; color: "#ff6b6b"; font.pixelSize: 11
                        Layout.fillWidth: true; wrapMode: Text.Wrap
                        visible: text !== ""; horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 44; radius: 12
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: saveArea.pressed ? Qt.darker(window.accentColor, 1.2) : window.accentColor }
                            GradientStop { position: 1.0; color: saveArea.pressed ? "#00aa00" : "#05d605" }
                        }
                        Text { anchors.centerIn: parent; text: lang.simpanPassword; color: window.bgDeep; font.bold: true; font.pixelSize: 13 }
                        MouseArea {
                            id: saveArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var u = userField.text.trim()
                                if (u === "") { resetError.text = lang.isiUsernameDulu; return }
                                if (oldPassField.text === "" || newPassField.text === "") { resetError.text = lang.isiUsernamePassword; return }
                                if (!backend.login(u, oldPassField.text)) { resetError.text = lang.passwordLamaSalah; return }
                                if (backend.resetPassword(u, oldPassField.text, newPassField.text)) {
                                    loginRoot.isSuccess    = true
                                    loginRoot.showError    = true
                                    loginRoot.errorMessage = lang.passwordBerhasil
                                    loginRoot.loginAttempts = 0
                                    oldPassField.text = ""; newPassField.text = ""; resetError.text = ""
                                    resetPopup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
