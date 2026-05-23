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
    component MenuButton : Rectangle {
        property string label: ""
        property string icon: ""
        property string sublabel: ""
        property string iconSource: ""
        property var clickAction: null

        width: 260; height: 80; radius: 16
        color: hoverArea.containsMouse
               ? Qt.rgba(255/255, 204/255, 0/255, 0.10)
               : window.bgSecondary
        border.color: hoverArea.containsMouse ? window.accentColor : window.borderColor
        border.width: hoverArea.containsMouse ? 1.5 : 1
        scale: hoverArea.pressed ? 0.94 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 12

            Rectangle {
                width: 44; height: 44; radius: 12
                color: hoverArea.containsMouse
                       ? Qt.rgba(255/255, 204/255, 0/255, 0.18)
                       : Qt.rgba(255/255, 204/255, 0/255, 0.08)
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: icon; font.pixelSize: 22
                    visible: iconSource === ""
                }
                Image {
                    anchors.fill: parent; anchors.margins: 8
                    source: iconSource
                    visible: iconSource !== ""
                }
            }

            Column {
                spacing: 3; Layout.fillWidth: true
                Text {
                    text: label
                    color: window.textPrimary; font.pixelSize: 13; font.bold: true
                }
                Text {
                    text: sublabel
                    color: window.textMuted; font.pixelSize: 10
                    elide: Text.ElideRight; width: parent.width
                    visible: sublabel !== ""
                }
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (clickAction) clickAction() }
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

    // --- 3. LAYOUT UTAMA: kiri = grid menu, kanan = widget panel ---
    Item {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

    // ── PANEL KANAN: 4 Widget ─────────────────────────────────────────────
    Item {
        id: rightPanel
        anchors {
            top: parent.top; bottom: parent.bottom
            right: parent.right
            rightMargin: 32
        }
        width: 320

        // ─── 1. JAM + GREETING ─────────────────────────────────────────
        Rectangle {
            id: clockWidget
            anchors { top: parent.top; topMargin: 16; left: parent.left; right: parent.right }
            height: 88
            color: window.bgSecondary; radius: 14; border.color: window.borderColor; border.width: 1

            property string greeting: ""
            property string timeStr:  ""
            property string dateStr:  ""

            function refresh() {
                var d = new Date()
                var h = d.getHours()
                var m = d.getMinutes()
                var s = d.getSeconds()
                timeStr = Qt.formatTime(d, "hh:mm:ss")
                dateStr = Qt.formatDate(d, "dddd, d MMMM yyyy")
                if (h >= 4  && h < 11) greeting = lang.selamatPagi + ", " + window.namaUser + "! ☀️"
                else if (h >= 11 && h < 15) greeting = lang.selamatSiang + ", " + window.namaUser + "! 🌤️"
                else if (h >= 15 && h < 18) greeting = lang.selamatSore + ", " + window.namaUser + "! 🌇"
                else greeting = lang.selamatMalam +  ", " + window.namaUser + "! 🌙"
            }

            Timer { interval: 1000; repeat: true; running: true; onTriggered: clockWidget.refresh() }
            Component.onCompleted: clockWidget.refresh()

            Column {
                anchors.centerIn: parent; spacing: 2
                Text {
                    text: clockWidget.timeStr
                    color: window.accentColor; font.pixelSize: 28; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "monospace"
                }
                Text {
                    text: clockWidget.dateStr
                    color: window.textMuted; font.pixelSize: 11
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: clockWidget.greeting
                    color: window.textPrimary; font.pixelSize: 12; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // ─── 2. MOOD TRACKER ───────────────────────────────────────────
        Rectangle {
            id: moodWidget
            anchors { top: clockWidget.bottom; topMargin: 10; left: parent.left; right: parent.right }
            height: moodExpanded ? 160 : 80
            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            color: window.bgSecondary; radius: 14; border.color: window.borderColor; border.width: 1
            clip: true

            property bool moodExpanded: false
            property int  todayMood: -1  // -1 = belum pilih
            // Simpan riwayat 7 hari: array of {day, mood}
            property var moodHistory: []

            readonly property var moods: [
                { emoji: "😴", label: lang.moodNgantuk,  color: "#8a9fb1" },
                { emoji: "😐", label: lang.moodBiasa,    color: "#4a90d9" },
                { emoji: "🙂", label: lang.moodLumayan,  color: "#4ecca3" },
                { emoji: "😊", label: lang.moodBaik,     color: "#ffcc00" },
                { emoji: "🔥", label: lang.moodSemangat, color: "#ff6b35" },
            ]

            Column {
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                spacing: 8

                // Header row
                Item {
                    width: parent.width; height: 24
                    Text {
                        text: "😊  " + lang.moodHariIni
                        color: window.accentColor; font.pixelSize: 12; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: moodWidget.moodExpanded ? "▲" : "▼"
                        color: window.textMuted; font.pixelSize: 11
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: moodWidget.moodExpanded = !moodWidget.moodExpanded }
                }

                // Mood yang sudah dipilih atau teks placeholder
                Row {
                    spacing: 6
                    Text {
                        text: moodWidget.todayMood >= 0 ? moodWidget.moods[moodWidget.todayMood].emoji : "—"
                        font.pixelSize: 22
                    }
                    Text {
                        text: moodWidget.todayMood >= 0
                              ? moodWidget.moods[moodWidget.todayMood].label
                              : lang.belumDipilih
                        color: moodWidget.todayMood >= 0
                               ? moodWidget.moods[moodWidget.todayMood].color
                               : window.textMuted
                        font.pixelSize: 13; font.bold: moodWidget.todayMood >= 0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Pilih mood (muncul saat expanded)
                Row {
                    spacing: 8
                    visible: moodWidget.moodExpanded
                    Repeater {
                        model: moodWidget.moods
                        delegate: Rectangle {
                            width: 44; height: 44; radius: 22
                            color: moodWidget.todayMood === index
                                   ? Qt.rgba(1,1,1,0.18) : window.bgCard
                            border.color: moodWidget.todayMood === index ? modelData.color : window.borderColor
                            border.width: moodWidget.todayMood === index ? 2 : 1
                            scale: moodArea.pressed ? 0.88 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Text { anchors.centerIn: parent; text: modelData.emoji; font.pixelSize: 22 }
                            MouseArea {
                                id: moodArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    moodWidget.todayMood = index
                                    moodWidget.moodExpanded = false
                                }
                            }
                        }
                    }
                }

                // Riwayat mood 7 hari (titik warna)
                Row {
                    spacing: 4
                    visible: moodWidget.moodExpanded
                    Text { text: lang.tujuhHari; color: window.textMuted; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                    Repeater {
                        model: 7
                        delegate: Rectangle {
                            width: 10; height: 10; radius: 5
                            color: index < moodWidget.moodHistory.length
                                   ? moodWidget.moods[moodWidget.moodHistory[index]].color
                                   : window.borderColor
                            ToolTip.visible: histDot.containsMouse
                            ToolTip.text: index < moodWidget.moodHistory.length
                                          ? moodWidget.moods[moodWidget.moodHistory[index]].label : "—"
                            MouseArea { id: histDot; anchors.fill: parent; hoverEnabled: true }
                        }
                    }
                }
            }
        }

        // ─── 3. COUNTDOWN DEADLINE ─────────────────────────────────────
        Rectangle {
            id: countdownWidget
            anchors { top: moodWidget.bottom; topMargin: 10; left: parent.left; right: parent.right }
            height: 90
            color: window.bgSecondary; radius: 14; border.color: window.borderColor; border.width: 1

            property string taskTitle: lang.belumAdaTugas
            property string countdownStr: "—"
            property bool   urgent: false

            function findNearest() {
                var now = Date.now()
                var nearest = null
                var nearestTs = Infinity
                for (var i = 0; i < globalTaskModel.count; i++) {
                    var t = globalTaskModel.get(i)
                    if (!t.isDone && t.deadlineTimestamp > now && t.deadlineTimestamp < nearestTs) {
                        nearest   = t
                        nearestTs = t.deadlineTimestamp
                    }
                }
                if (!nearest) { taskTitle = lang.semuaTugasSelesai; countdownStr = ""; urgent = false; return }
                taskTitle = nearest.title
                var sisa = nearestTs - now
                urgent = sisa < 3600000  // < 1 jam
                var totalSec = Math.floor(sisa / 1000)
                var d = Math.floor(totalSec / 86400)
                var h = Math.floor((totalSec % 86400) / 3600)
                var m = Math.floor((totalSec % 3600)  / 60)
                var s = totalSec % 60
                if (d > 0) countdownStr = d + lang.hari + " " + h + lang.jam + " " + m + lang.menit
                else       countdownStr = Qt.formatTime(new Date(0,0,0,h,m,s), "hh:mm:ss")
            }

            Timer { interval: 1000; repeat: true; running: true; onTriggered: countdownWidget.findNearest() }
            Component.onCompleted: countdownWidget.findNearest()

            Column {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 14 }
                spacing: 4
                Text {
                    text: "⏳  " + lang.tugasTerdekat
                    color: window.accentColor; font.pixelSize: 11; font.bold: true
                }
                Text {
                    text: countdownWidget.taskTitle
                    color: window.textPrimary; font.pixelSize: 13; font.bold: true
                }
                Text {
                    text: countdownWidget.countdownStr
                    color: countdownWidget.urgent ? "#ff4444" : "#4ecca3"
                    font.pixelSize: countdownWidget.countdownStr.length > 0 ? 20 : 13
                    font.bold: true; font.family: "monospace"
                }
            }
        }

        // ─── 4. ANIMASI LO-FI (BINTANG + PARTIKEL) ────────────────────
        Rectangle {
            id: lofiWidget
            anchors { top: countdownWidget.bottom; topMargin: 10; left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 16 }
            color: window.bgDeep; radius: 14; border.color: window.borderColor; border.width: 1
            clip: true

            // Label kecil
            Text {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 10 }
                text: "✨  Study Vibes"
                color: window.accentColor; font.pixelSize: 11; font.bold: true
                opacity: 0.8
            }

            // Bintang-bintang berkedip
            Repeater {
                model: 28
                delegate: Rectangle {
                    property real rndX: Math.random()
                    property real rndY: Math.random()
                    property real rndSize: 1.5 + Math.random() * 3
                    property real rndDelay: Math.random() * 3000
                    property real rndDur: 1500 + Math.random() * 2500

                    x: rndX * lofiWidget.width
                    y: 30 + rndY * (lofiWidget.height - 60)
                    width: rndSize; height: rndSize; radius: rndSize / 2
                    color: window.accentColor

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation   { duration: parent.rndDelay }
                        NumberAnimation  { from: 0.1; to: 0.9; duration: parent.rndDur; easing.type: Easing.InOutSine }
                        NumberAnimation  { from: 0.9; to: 0.1; duration: parent.rndDur; easing.type: Easing.InOutSine }
                    }
                }
            }

            // Partikel hujan (garis vertikal kecil jatuh)
            Repeater {
                model: 18
                delegate: Item {
                    property real rndX:   Math.random() * lofiWidget.width
                    property real rndDur: 2800 + Math.random() * 3000
                    property real rndH:   6 + Math.random() * 10
                    property real rndDelay: Math.random() * 4000

                    x: rndX; y: 30
                    width: 1; height: lofiWidget.height

                    Rectangle {
                        id: raindrop
                        x: 0; width: 1; height: parent.rndH
                        radius: 1
                        color: Qt.rgba(1, 1, 1, 0.12)
                        y: -20

                        SequentialAnimation on y {
                            loops: Animation.Infinite
                            PauseAnimation { duration: parent.parent.rndDelay }
                            NumberAnimation { from: -20; to: lofiWidget.height; duration: parent.parent.rndDur; easing.type: Easing.Linear }
                        }
                    }
                }
            }

            // Teks study quote kecil di tengah bawah
            Text {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 12 }
                text: "📚  " + lang.fokusSubAktif
                color: window.textMuted; font.pixelSize: 10; font.italic: true
                opacity: 0.7
            }
        }
    }

    // --- GRID MENU (sekarang di tengah-kiri area) ---
    Grid {
        id: menuGrid
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -rightPanel.width / 2
        columns: 2
        spacing: 12
        z: 5

        MenuButton {
            label: lang.tugas; icon: "✍"; sublabel: lang.sublabelTugas
            clickAction: function() { pageStack.push(inputTugasComponent) }
        }
        MenuButton {
            label: lang.timer; icon: "⏱"; sublabel: lang.sublabelTimer
            clickAction: function() { pageStack.push(timerComponent) }
        }
        MenuButton {
            label: lang.studyRoom; icon: "🏠"; sublabel: lang.sublabelRoom
            clickAction: function() { pageStack.push(studyRoomComponent) }
        }
        MenuButton {
            label: lang.statistik; icon: "📊"; sublabel: lang.sublabelStatistik
            clickAction: function() { pageStack.push(statistikComponent) }
        }
        MenuButton {
            label: lang.teman; icon: "👥"; sublabel: lang.sublabelTeman
            clickAction: function() { pageStack.push(temanComponent) }
        }
        MenuButton {
            label: lang.pengaturan; icon: "⚙"; sublabel: lang.sublabelSetting
            clickAction: function() { pageStack.push(settingsComponent) }
        }
        MenuButton {
            label: lang.keluarAkun; icon: "⏻"; sublabel: lang.sublabelKeluar
            clickAction: function() { logoutConfirmPopup.open() }
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
                                var t = globalTaskModel.get(i)
                                tasks.push({
                                    "title":             t.title,
                                    "deadline":          t.deadline,
                                    "deadlineTimestamp": t.deadlineTimestamp,
                                    "isDone":            t.isDone
                                })
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
                            pageStack.replace(null, loginComponent)
                            isLoginView = true
                        }
                    }
                }
            }
        }
    }
}
