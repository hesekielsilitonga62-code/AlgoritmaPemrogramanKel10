import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    signal logoutRequested()

    // --- 1. DEFINISI KOMPONEN (WAJIB DI LUAR GRID/FLOW) ---
    component MenuButton : Column {
        property string label: ""
        property string icon: ""
        property string iconSource: ""
        property var clickAction: null
        property bool isLoggedIn: true

        width: 80
        spacing: 8

        Rectangle {
            id: iconRect
            width: 75; height: 75
            radius: 37.5
            color: mouseArea.pressed ? window.borderColor : window.bgSecondary
            border.color: window.accentColor
            border.width: 2
            anchors.horizontalCenter: parent.horizontalCenter
            scale: mouseArea.pressed ? 0.9 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: icon
                font.pixelSize: 30
                color: window.accentColor
                visible: iconSource === ""
            }

            Image {
                    anchors.fill: parent
                    anchors.margins: 15
                    source: iconSource
                    visible: iconSource !== "" // Muncul kalau ada sumber gambarnya
                }


            MouseArea {
                id : mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (clickAction) clickAction()
                    else console.log("Klik: " + label)
                }
            }

        }
        Text {
            text: label
            color: window.textPrimary
            font.pixelSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // --- 2. HEADER & DRAWER ---
    Item {
        id: header
        width: parent.width; height: 80; z: 10
        anchors.top: parent.top

        Button {
            text: "☰"; anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 20
            onClicked: taskDrawer.open()
            background: Rectangle { color: "transparent" }
            contentItem: Text { text: "☰"; color: window.textPrimary; font.pixelSize: 30 }
        }
    }

    // --- 3. MENU UTAMA (GUNAKAN GRID SAJA AGAR RAPI) ---
    Grid {
        id: menuGrid
        anchors.centerIn: parent
        columns: 3
        spacing: 30
        z: 5

        MenuButton {
            label: lang.tugas
            icon: "✍"
            clickAction: function() {
                // Mengubah source loader menjadi file InputTugas.qml
                pageLoader.source = "InputTugas.qml"
            }
        }

        MenuButton {
                    label: lang.timer
                    icon: "⏱" // Kamu bisa tetap pakai ikon teks atau modifikasi komponennya
                    clickAction: function() {
                        console.log("Membuka halaman Timer Belajar...")
                        pageLoader.source = "TimerBelajar.qml"
                    }
                }

        MenuButton {
                    label: lang.studyRoom
                    icon: "🏠"
                    clickAction: function() {
                        console.log("Membuka halaman Study Room...")
                        pageLoader.source = "StudyRoomPage.qml"
                    }
                }

        MenuButton {
            label: lang.statistik; icon: "📊"
            clickAction: function() {
                pageLoader.sourceComponent = statistikComponent
            }
        }

        MenuButton {
            label: lang.teman
            icon: "👥"
            clickAction: function() {
                console.log("Mencoba membuka halaman teman...")
                pageLoader.source = "TemanPage.qml";
            }
        }

        MenuButton {
            label: lang.pengaturan; icon: "⚙"
            clickAction: function() {
                pageLoader.sourceComponent = settingsComponent
            }
        }

        // Tombol Logout dengan Aksi Khusus
        MenuButton {
            label: lang.keluarAkun
            icon: "⏻"
            clickAction: function() {
                logoutConfirmPopup.open()
            }
        }
    }

    // ── Popup Konfirmasi Logout ───────────────────────────────────────────────
    Popup {
        id: logoutConfirmPopup
        anchors.centerIn: parent
        width: 320; height: 190
        modal: true; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: window.bgSecondary; radius: 16
            border.color: window.accentColor; border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; spacing: 14

            Text {
                text: "⏻  " + lang.keluarKonfirm
                color: window.accentColor; font.pixelSize: 17; font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: lang.sesiBelajarDihentikan
                color: window.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 12

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: cancelLogoutArea.pressed ? Qt.darker(window.borderColor, 1.2) : window.borderColor
                    Text { anchors.centerIn: parent; text: lang.tidak; color: window.textPrimary; font.bold: true; font.pixelSize: 13 }
                    MouseArea {
                        id: cancelLogoutArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: logoutConfirmPopup.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: confirmLogoutArea.pressed ? "#cc9900" : window.accentColor
                    Text { anchors.centerIn: parent; text: lang.yaLogout; color: window.bgPrimary; font.bold: true; font.pixelSize: 13 }
                    MouseArea {
                        id: confirmLogoutArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // 1. Kumpulkan tasks dari model
                            var tasks = []
                            for (var i = 0; i < globalTaskModel.count; i++) {
                                tasks.push(globalTaskModel.get(i))
                            }

                            // 2. Simpan data user yang sedang login
                            backend.saveUserData(
                                window.currentUser,
                                window.namaUser,
                                window.statusUser,
                                window.selectedAvatar,
                                window.globalSessionsCompleted,
                                window.globalSecondsFocused,
                                tasks
                            )

                            // 3. Reset semua state window agar bersih
                            window.resetWindowState()

                            // 4. Kembali ke halaman login
                            logoutConfirmPopup.close()
                            pageLoader.sourceComponent = loginComponent
                            isLoginView = true
                        }
                    }
                }
            }
        }
    }
}