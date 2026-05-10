import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import StudyTrackerApp

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    // ── Sync dua arah dengan window (global) ─────────────────────────────────
    property string namaUser:       window.namaUser
    property string statusUser:     window.statusUser
    property int    selectedAvatar: window.selectedAvatar

    onNamaUserChanged:        window.namaUser       = namaUser
    onStatusUserChanged:      window.statusUser     = statusUser
    onSelectedAvatarChanged:  window.selectedAvatar = selectedAvatar

    property bool notifBelajar: window.notifBelajar
    property bool notifTugas:   window.notifTugas
    property bool notifTeman:   window.notifTeman
    property bool soundEnabled: window.soundEnabled

    onNotifBelajarChanged: window.notifBelajar = notifBelajar
    onNotifTugasChanged:   window.notifTugas   = notifTugas
    onNotifTemanChanged:   window.notifTeman   = notifTeman
    onSoundEnabledChanged: window.soundEnabled = soundEnabled

    property int pomodoroFokus:    window.pomodoroFokus
    property int pomodoroIstirahat: window.pomodoroIstirahat
    property int targetSesiHarian: window.globalTargetSessions

    onPomodoroFokusChanged:     window.pomodoroFokus         = pomodoroFokus
    onPomodoroIstirahatChanged: window.pomodoroIstirahat     = pomodoroIstirahat
    onTargetSesiHarianChanged:  window.globalTargetSessions  = targetSesiHarian

    property string selectedTheme:    window.appTheme
    property string selectedLanguage: window.selectedLanguage

    onSelectedThemeChanged:    window.appTheme           = selectedTheme
    onSelectedLanguageChanged: window.selectedLanguage   = selectedLanguage

    // ── Avatar list (sama dengan Main.qml) ───────────────────────────────────
    readonly property var avatarList: window.avatarList

    // ── Pop-up Notifikasi ─────────────────────────────────────────────────────
    Rectangle {
        id: notifPopup
        width: 320; height: 60; radius: 14
        color: window.bgSecondary; border.color: window.accentColor; border.width: 1.5
        z: 999; anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 16
        visible: false; opacity: 0

        property string notifText: ""

        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 10
            Text { text: "🔔"; font.pixelSize: 20 }
            Text { text: notifPopup.notifText; color: window.textPrimary; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
            Rectangle {
                width: 20; height: 20; radius: 10; color: window.borderColor
                Text { anchors.centerIn: parent; text: "✕"; color: window.textMuted; font.pixelSize: 10 }
                MouseArea { anchors.fill: parent; onClicked: hideNotifAnim.start() }
            }
        }

        NumberAnimation { id: showNotifAnim; target: notifPopup; property: "opacity"; from: 0; to: 1; duration: 300 }
        NumberAnimation { id: hideNotifAnim; target: notifPopup; property: "opacity"; from: 1; to: 0; duration: 300; onFinished: notifPopup.visible = false }
        Timer { id: autoHideNotif; interval: 3000; onTriggered: hideNotifAnim.start() }
    }

    function showNotif(text) {
        notifPopup.notifText = text; notifPopup.visible = true; notifPopup.opacity = 0
        showNotifAnim.start(); autoHideNotif.restart()
    }

    // ── Komponen reusable ─────────────────────────────────────────────────────
    component SectionTitle : Text {
        property string judul: ""
        text: judul; color: window.accentColor; font.pixelSize: 13; font.bold: true
        font.letterSpacing: 1.2; topPadding: 8
    }

    component ToggleRow : Rectangle {
        property string label: ""; property string sublabel: ""
        property bool   checked: false; property var onToggle: null
        height: sublabel !== "" ? 62 : 52; color: "transparent"
        Rectangle { anchors.fill: parent; color: window.bgSecondary; radius: 12; border.color: window.borderColor }
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12
            Column {
                spacing: 3; Layout.fillWidth: true
                Text { text: parent.parent.parent.label;    color: window.textPrimary; font.pixelSize: 14; font.bold: true }
                Text { text: parent.parent.parent.sublabel; color: window.textMuted;   font.pixelSize: 12; visible: parent.parent.parent.sublabel !== "" }
            }
            Rectangle {
                width: 48; height: 26; radius: 13
                color: parent.parent.checked ? window.accentColor : window.borderColor
                Behavior on color { ColorAnimation { duration: 200 } }
                Rectangle {
                    width: 20; height: 20; radius: 10; color: window.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.parent.parent.checked ? parent.width - width - 3 : 3
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: if (parent.parent.parent.onToggle) parent.parent.parent.onToggle()
                }
            }
        }
    }

    component StepperRow : Rectangle {
        property string label: ""; property string sublabel: ""; property int nilai: 0
        property int minVal: 1; property int maxVal: 120; property string satuan: ""
        property var onMinus: null; property var onPlus: null
        height: 62; color: "transparent"
        Rectangle { anchors.fill: parent; color: window.bgSecondary; radius: 12; border.color: window.borderColor }
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12
            Column {
                spacing: 3; Layout.fillWidth: true
                Text { text: parent.parent.parent.label;    color: window.textPrimary; font.pixelSize: 14; font.bold: true }
                Text { text: parent.parent.parent.sublabel; color: window.textMuted;   font.pixelSize: 12; visible: parent.parent.parent.sublabel !== "" }
            }
            RowLayout {
                spacing: 8
                Rectangle {
                    width: 32; height: 32; radius: 8; color: minusArea.pressed ? window.borderColor : window.bgCard; border.color: window.borderColor
                    Text { anchors.centerIn: parent; text: "−"; color: window.textPrimary; font.pixelSize: 18; font.bold: true }
                    MouseArea { id: minusArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (parent.parent.parent.parent.onMinus) parent.parent.parent.parent.onMinus() }
                }
                Text { text: parent.parent.parent.nilai + " " + parent.parent.parent.satuan; color: window.accentColor; font.pixelSize: 15; font.bold: true; horizontalAlignment: Text.AlignHCenter; Layout.minimumWidth: 60 }
                Rectangle {
                    width: 32; height: 32; radius: 8; color: plusArea.pressed ? window.borderColor : window.bgCard; border.color: window.borderColor
                    Text { anchors.centerIn: parent; text: "+"; color: window.textPrimary; font.pixelSize: 18; font.bold: true }
                    MouseArea { id: plusArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (parent.parent.parent.parent.onPlus) parent.parent.parent.parent.onPlus() }
                }
            }
        }
    }

    // ── Layout Utama ──────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent; anchors.margins: 0; spacing: 0

        // ── Sidebar ───────────────────────────────────────────────────────────
        Rectangle {
            width: 220; Layout.fillHeight: true; color: window.bgDeep

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 6

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 10; color: window.borderColor
                    Text { text: "◀ " + lang.mainMenu; color: window.textPrimary; font.bold: true; anchors.centerIn: parent }
                    MouseArea {
                        anchors.fill: parent; onClicked: pageLoader.sourceComponent = mainComponent
                        onPressed: parent.opacity = 0.7; onReleased: parent.opacity = 1.0
                    }
                }

                Text { text: lang.pengaturan; color: window.textMuted; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2; topPadding: 16 }

                Repeater {
                    model: [
                        { icon: "👤", label: lang.profil,              id: "profil"   },
                        { icon: "🔔", label: lang.notifikasi,      id: "notif"    },
                        { icon: "🍅", label: lang.pomodoroLabel,                   id: "pomodoro" },
                        { icon: "🎨", label: lang.tampilan + " & " + lang.bahasa,  id: "tampilan" },
                        { icon: "🔒", label: lang.akunKeamanan,                    id: "akun"     },
                        { icon: "ℹ️", label: lang.tentangAplikasi,                 id: "tentang"  },
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 44; radius: 10
                        color: settingStack.currentId === modelData.id
                               ? Qt.rgba(255/255, 204/255, 0/255, 0.12) : "transparent"
                        border.color: settingStack.currentId === modelData.id ? window.accentColor : "transparent"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 10
                            Text { text: modelData.icon; font.pixelSize: 18 }
                            Text { text: modelData.label; color: window.textPrimary; font.pixelSize: 13; font.bold: settingStack.currentId === modelData.id; Layout.fillWidth: true }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingStack.currentId = modelData.id }
                    }
                }

                Item { Layout.fillHeight: true }
                Text { text: "Tudu v0.1"; color: window.textMuted; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter; bottomPadding: 8 }
            }
        }

        Rectangle { width: 1; Layout.fillHeight: true; color: window.borderColor }

        // ── Konten Setting ────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true

            QtObject { id: settingStack; property string currentId: "profil" }

            // ── PROFIL ────────────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 14
                visible: settingStack.currentId === "profil"

                SectionTitle { judul: lang.profilPengguna }

                Rectangle {
                    Layout.fillWidth: true; height: 100
                    color: window.bgSecondary; radius: 14; border.color: window.borderColor
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 20
                        Rectangle {
                            width: 64; height: 64; radius: 32; color: window.borderColor
                            border.color: window.accentColor; border.width: 2
                            Text { anchors.centerIn: parent; text: root.avatarList[root.selectedAvatar]; font.pixelSize: 32 }
                        }
                        Column {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: window.namaUser;   color: window.textPrimary; font.pixelSize: 18; font.bold: true }
                            Text { text: window.statusUser; color: window.textMuted;   font.pixelSize: 13 }
                        }
                    }
                }

                SectionTitle { judul: lang.pilihAvatar }

                Rectangle {
                    Layout.fillWidth: true; height: 220
                    color: window.bgSecondary; radius: 12; border.color: window.borderColor; clip: true
                    ScrollView {
                        anchors.fill: parent; anchors.margins: 8; contentWidth: availableWidth
                        Flow {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: root.avatarList
                                delegate: Rectangle {
                                    width: 50; height: 50; radius: 10
                                    color: root.selectedAvatar === index ? Qt.rgba(255/255,204/255,0/255,0.18) : window.bgCard
                                    border.color: root.selectedAvatar === index ? window.accentColor : window.borderColor
                                    border.width: root.selectedAvatar === index ? 2 : 1
                                    Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 28 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedAvatar = index }
                                }
                            }
                        }
                    }
                }

                SectionTitle { judul: lang.namaTampilan }
                Rectangle {
                    Layout.fillWidth: true; height: 52; color: window.bgSecondary; radius: 12; border.color: window.borderColor
                    TextField {
                        anchors.fill: parent; anchors.margins: 4; text: window.namaUser
                        color: window.textPrimary; font.pixelSize: 14; padding: 12; placeholderText: lang.namaKamu
                        background: Rectangle { color: "transparent" }
                        onTextChanged: { root.namaUser = text; window.namaUser = text }
                    }
                }

                SectionTitle { judul: lang.statusLabel }
                Rectangle {
                    Layout.fillWidth: true; height: 52; color: window.bgSecondary; radius: 12; border.color: window.borderColor
                    TextField {
                        anchors.fill: parent; anchors.margins: 4; text: window.statusUser
                        color: window.textPrimary; font.pixelSize: 14; padding: 12; placeholderText: "Status kamu..."
                        background: Rectangle { color: "transparent" }
                        onTextChanged: { root.statusUser = text; window.statusUser = text }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // ── NOTIFIKASI ────────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 12
                visible: settingStack.currentId === "notif"

                SectionTitle { judul: lang.notifikasi }
                ToggleRow {
                    Layout.fillWidth: true
                    label: lang.pengingatBelajar
                    sublabel: lang.pengingatBelajarSub
                    checked: root.notifBelajar
                    onToggle: function() {
                        root.notifBelajar = !root.notifBelajar
                        root.showNotif(root.notifBelajar ? "🍅 " + lang.pengingatBelajar + " diaktifkan!" : "🔕 " + lang.pengingatBelajar + " dinonaktifkan")
                    }
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: lang.pengingatTugas
                    sublabel: lang.pengingatTugasSub
                    checked: root.notifTugas
                    onToggle: function() {
                        root.notifTugas = !root.notifTugas
                        root.showNotif(root.notifTugas ? "📋 " + lang.pengingatTugas + " diaktifkan!" : "🔕 " + lang.pengingatTugas + " dinonaktifkan")
                    }
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: lang.notifTeman
                    sublabel: lang.notifTemanSub
                    checked: root.notifTeman
                    onToggle: function() {
                        root.notifTeman = !root.notifTeman
                        root.showNotif(root.notifTeman ? "👥 " + lang.notifTeman + " diaktifkan!" : "🔕 " + lang.notifTeman + " dinonaktifkan")
                    }
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: lang.suara
                    sublabel: lang.suaraSub
                    checked: root.soundEnabled
                    onToggle: function() {
                        root.soundEnabled = !root.soundEnabled
                        root.showNotif(root.soundEnabled ? "🔊 " + lang.suara + " diaktifkan!" : "🔇 " + lang.suara + " dinonaktifkan")
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 56; color: Qt.rgba(255/255, 204/255, 0/255, 0.05); radius: 12; border.color: Qt.rgba(255/255, 204/255, 0/255, 0.15)
                    Text { anchors.centerIn: parent; width: parent.width - 24; text: "💡 Toggle notif untuk melihat pratinjau pop-up di atas layar"; color: window.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
                }
                Item { Layout.fillHeight: true }
            }

            // ── POMODORO ──────────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 12
                visible: settingStack.currentId === "pomodoro"

                SectionTitle { judul: lang.pomodoroLabel }
                StepperRow {
                    Layout.fillWidth: true
                    label: lang.waktuFokus
                    sublabel: lang.waktuFokusSub
                    nilai: root.pomodoroFokus; minVal: 5; maxVal: 90; satuan: lang.menit
                    onMinus: function() { if (root.pomodoroFokus > 5)  root.pomodoroFokus -= 5 }
                    onPlus:  function() { if (root.pomodoroFokus < 90) root.pomodoroFokus += 5 }
                }
                StepperRow {
                    Layout.fillWidth: true
                    label: lang.waktuIstirahat
                    sublabel: lang.waktuIstirahatSub
                    nilai: root.pomodoroIstirahat; minVal: 1; maxVal: 30; satuan: lang.menit
                    onMinus: function() { if (root.pomodoroIstirahat > 1)  root.pomodoroIstirahat-- }
                    onPlus:  function() { if (root.pomodoroIstirahat < 30) root.pomodoroIstirahat++ }
                }
                StepperRow {
                    Layout.fillWidth: true
                    label: lang.targetSesiHarian
                    sublabel: lang.targetSesiHarianSub
                    nilai: root.targetSesiHarian; minVal: 1; maxVal: 20; satuan: lang.sesi
                    onMinus: function() { if (root.targetSesiHarian > 1)  root.targetSesiHarian-- }
                    onPlus:  function() { if (root.targetSesiHarian < 20) root.targetSesiHarian++ }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 60
                    color: Qt.rgba(255/255, 204/255, 0/255, 0.07); radius: 12
                    border.color: Qt.rgba(255/255, 204/255, 0/255, 0.2)
                    Text {
                        anchors.centerIn: parent; width: parent.width - 24
                        text: "💡 " + lang.totalFokusStat
                              .replace("{menit}", root.pomodoroFokus * root.targetSesiHarian)
                              .replace("{jam}",   Math.floor(root.pomodoroFokus * root.targetSesiHarian / 60))
                              .replace("{sisa}",  root.pomodoroFokus * root.targetSesiHarian % 60)
                        color: window.accentColor; font.pixelSize: 13
                        wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    }
                }
                Item { Layout.fillHeight: true }
            }

            // ══════════════════════════════════════════════════════════════════
            // ── TAMPILAN & BAHASA ─────────────────────────────────────────────
            // ══════════════════════════════════════════════════════════════════
            // ── TAMPILAN & BAHASA ─────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 14
                visible: settingStack.currentId === "tampilan"

                SectionTitle { judul: "🎨  " + lang.temaWarna }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    Repeater {
                        model: [
                            { key: "gelap",   label: "Gelap",   emoji: "🌙", bg2: "#0a2a43", accent: "#ffcc00" },
                            { key: "hitam",   label: "Hitam",   emoji: "⬛", bg2: "#141414", accent: "#ffffff" },
                            { key: "putih",   label: "Putih",   emoji: "☀️", bg2: "#dde4eb", accent: "#1565c0" },
                            { key: "pink",    label: "Pink",    emoji: "🌸", bg2: "#2d1020", accent: "#ff6eb4" },
                            { key: "laut",    label: "Laut",    emoji: "🌊", bg2: "#112d54", accent: "#38bdf8" },
                            { key: "adem",    label: "Adem",    emoji: "🌿", bg2: "#0e2e1c", accent: "#4ecca3" },
                            { key: "vintage", label: "Vintage", emoji: "🍂", bg2: "#2e1f0e", accent: "#d4a24c" },
                        ]
                        delegate: Rectangle {
                            width: Math.floor((parent.width - 60) / 3)
                            height: 90; radius: 14
                            color: modelData.bg2
                            border.color: window.appTheme === modelData.key ? modelData.accent : Qt.rgba(1,1,1,0.1)
                            border.width: window.appTheme === modelData.key ? 2.5 : 1
                            scale: window.appTheme === modelData.key ? 1.03 : 1.0
                            Behavior on scale { NumberAnimation { duration: 180 } }
                            Rectangle { width: parent.width; height: 4; radius: 2; anchors.top: parent.top; color: modelData.accent; opacity: 0.9 }
                            Column {
                                anchors.centerIn: parent; spacing: 6
                                Rectangle {
                                    width: 38; height: 38; radius: 19; color: modelData.accent
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: window.appTheme === modelData.key ? "✓" : modelData.emoji
                                        font.pixelSize: window.appTheme === modelData.key ? 18 : 16
                                        color: window.appTheme === modelData.key ? "#222" : "white"
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: modelData.label; color: "white"; font.pixelSize: 11
                                    font.bold: window.appTheme === modelData.key
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            Rectangle {
                                visible: window.appTheme === modelData.key
                                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 5
                                width: 44; height: 16; radius: 8; color: modelData.accent
                                Text { anchors.centerIn: parent; text: lang.aktif; font.pixelSize: 8; font.bold: true; color: "#222" }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { window.appTheme = modelData.key; root.selectedTheme = modelData.key; root.showNotif(lang.temaDiterapkan) }
                            }
                        }
                    }
                }

                SectionTitle { judul: "🌐  " + lang.bahasa }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: lang.langList
                        delegate: Rectangle {
                            width: Math.floor((parent.width - 24) / 4)
                            height: 70; radius: 12
                            color: window.selectedLanguage === modelData.key ? Qt.rgba(255/255,204/255,0/255,0.12) : window.bgSecondary
                            border.color: window.selectedLanguage === modelData.key ? window.accentColor : window.borderColor
                            border.width: window.selectedLanguage === modelData.key ? 2 : 1
                            scale: window.selectedLanguage === modelData.key ? 1.04 : 1.0
                            Behavior on scale { NumberAnimation { duration: 160 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Column {
                                anchors.centerIn: parent; spacing: 5
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.flag; font.pixelSize: 24 }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    color: window.selectedLanguage === modelData.key ? window.accentColor : window.textPrimary
                                    font.pixelSize: 11; font.bold: window.selectedLanguage === modelData.key
                                }
                            }
                            Rectangle {
                                visible: window.selectedLanguage === modelData.key
                                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 4
                                width: 18; height: 18; radius: 9; color: window.accentColor
                                Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 10; font.bold: true; color: "#222" }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { window.selectedLanguage = modelData.key; root.showNotif(lang.bahasaBerlaku) }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 46
                    color: Qt.rgba(255/255, 204/255, 0/255, 0.05); radius: 12; border.color: window.borderColor
                    Text {
                        anchors.centerIn: parent; width: parent.width - 24
                        text: "💡 " + lang.infoLanguage
                        color: window.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // ── AKUN & KEAMANAN ───────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 12
                visible: settingStack.currentId === "akun"

                SectionTitle { judul: lang.akunKeamanan }

                Rectangle {
                    Layout.fillWidth: true; height: gantiPassCol.implicitHeight + 40
                    color: window.bgSecondary; radius: 14; border.color: window.borderColor
                    Column {
                        id: gantiPassCol
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                        spacing: 10
                        Text { text: "🔑 " + lang.gantiPassword; color: window.textPrimary; font.pixelSize: 14; font.bold: true }
                        TextField {
                            id: passLama; width: parent.width
                            placeholderText: lang.passwordLama; echoMode: TextInput.Password
                            color: window.textPrimary; font.pixelSize: 13; padding: 10
                            background: Rectangle {
                                color: window.bgCard; radius: 8
                                border.color: passLamaError.visible ? "#ff4444" : window.borderColor
                                border.width: passLamaError.visible ? 1.5 : 1
                            }
                            onTextChanged: passLamaError.visible = false
                        }
                        // Pesan error password lama salah
                        Text {
                            id: passLamaError
                            visible: false
                            text: "❌ Password lama salah!"
                            color: "#ff4444"; font.pixelSize: 12
                        }
                        TextField {
                            id: passBaru; width: parent.width
                            placeholderText: lang.passwordBaru; echoMode: TextInput.Password
                            color: window.textPrimary; font.pixelSize: 13; padding: 10
                            background: Rectangle { color: window.bgCard; radius: 8; border.color: window.borderColor }
                        }
                        Rectangle {
                            width: parent.width; height: 40; radius: 8
                            color: simpanPassArea.pressed ? "#cc9900" : window.accentColor
                            Text { anchors.centerIn: parent; text: lang.simpanPassword; color: "#001b2e"; font.bold: true; font.pixelSize: 13 }
                            MouseArea {
                                id: simpanPassArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (passLama.text.trim() === "" || passBaru.text.trim() === "") return
                                    // Validasi password lama dulu
                                    if (!backend.login(window.currentUser, passLama.text.trim())) {
                                        passLamaError.visible = true
                                        return
                                    }
                                    passLamaError.visible = false
                                    backend.resetPassword(window.currentUser, passLama.text.trim(), passBaru.text.trim())
                                    passLama.text = ""; passBaru.text = ""
                                    gantiPassInfo.visible = true
                                    gantiPassTimer.restart()
                                    root.showNotif(lang.passwordBerhasil)
                                }
                            }
                        }
                        Text {
                            id: gantiPassInfo; visible: false
                            text: lang.passwordBerhasil; color: "#2ecc71"; font.pixelSize: 12
                            Timer { id: gantiPassTimer; interval: 3000; onTriggered: gantiPassInfo.visible = false }
                        }
                    }
                }

                // ── Reset Data ────────────────────────────────────────────────
                SectionTitle { judul: "⚠️  " + lang.resetSemuaData }

                Rectangle {
                    Layout.fillWidth: true; height: 72
                    color: Qt.rgba(255/255, 68/255, 68/255, 0.08); radius: 14; border.color: Qt.rgba(255/255, 68/255, 68/255, 0.3)
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12
                        Column {
                            spacing: 3; Layout.fillWidth: true
                            Text { text: lang.resetSemuaData; color: "#ff4444"; font.pixelSize: 14; font.bold: true }
                            Text { text: lang.dataResetWarning; color: window.textMuted; font.pixelSize: 12 }
                        }
                        Rectangle {
                            width: 80; height: 34; radius: 8; color: resetArea.pressed ? "#cc2222" : "#ff4444"
                            Text { anchors.centerIn: parent; text: lang.yaReset; color: "white"; font.bold: true; font.pixelSize: 13 }
                            MouseArea { id: resetArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: resetConfirmPopup.open() }
                        }
                    }
                }

                // ── Keluar Akun ───────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; height: 52; color: window.bgSecondary; radius: 14; border.color: window.borderColor
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 16
                        Text { text: "⏻  " + lang.keluarAkun; color: window.textPrimary; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingsLogoutPopup.open() }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // ── TENTANG ───────────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 16
                visible: settingStack.currentId === "tentang"

                    Item { Layout.fillHeight: true }

                    Column {
                        Layout.alignment: Qt.AlignHCenter; spacing: 12
                        Rectangle {
                            width: 80; height: 80; radius: 20; color: window.bgSecondary; border.color: window.accentColor; border.width: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text { anchors.centerIn: parent; text: "📚"; font.pixelSize: 38 }
                        }
                        Text { text: "Study Tracker"; color: window.textPrimary; font.pixelSize: 26; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Versi 0.1.0"; color: window.textMuted; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: lang.tentangDeskripsi; color: window.textMuted; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; wrapMode: Text.WordWrap; width: 380 }
                    }

                    Rectangle { Layout.alignment: Qt.AlignHCenter; width: 380; height: 1; color: window.borderColor }

                    Column {
                        Layout.alignment: Qt.AlignHCenter; spacing: 8
                        Repeater {
                            model: [
                                { k: "Framework", v: "Qt 6 / QML"      },
                                { k: "Backend",   v: "C++ / Qt Quick"   },
                                { k: "Database",  v: "In-Memory (QMap)" },
                            ]
                            delegate: RowLayout {
                                width: 380; spacing: 0
                                Text { text: modelData.k; color: window.textMuted;   font.pixelSize: 13; Layout.preferredWidth: 140 }
                                Text { text: modelData.v; color: window.textPrimary; font.pixelSize: 13; font.bold: true }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

            // ── Popup Konfirmasi Reset ────────────────────────────────────────
            Popup {
                id: resetConfirmPopup; anchors.centerIn: parent; width: 340; height: 200
                modal: true; focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                background: Rectangle { color: window.bgSecondary; radius: 16; border.color: "#ff4444"; border.width: 2 }
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: "⚠️  " + lang.resetKonfirmasi; color: "#ff4444"; font.pixelSize: 16; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: lang.dataResetWarning; color: window.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        Rectangle {
                            Layout.fillWidth: true; height: 40; radius: 8; color: cancelResetArea.pressed ? "#1a3a5c" : "#163e5f"
                            Text { anchors.centerIn: parent; text: lang.tidak; color: window.textPrimary; font.bold: true; font.pixelSize: 13 }
                            MouseArea { id: cancelResetArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: resetConfirmPopup.close() }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 40; radius: 8; color: confirmResetArea.pressed ? "#cc2222" : "#ff4444"
                            Text { anchors.centerIn: parent; text: lang.yaReset; color: "white"; font.bold: true; font.pixelSize: 13 }
                            MouseArea {
                                id: confirmResetArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Reset semua data
                                    globalTaskModel.clear()
                                    myFriendsModel.clear()
                                    studyRoomFriendsModel.clear()
                                    chatHistories = ({})
                                    window.globalSeconds = 0
                                    window.globalSessionsCompleted = 0
                                    window.globalSecondsFocused = 0
                                    window.globalTimerRunning = false
                                    window.globalCurrentTimerValue = 0
                                    // Reset profil pengguna ke default
                                    window.namaUser       = "Pengguna"
                                    window.statusUser     = "Semangat Belajar! 💪"
                                    window.selectedAvatar = 0
                                    root.namaUser         = "Pengguna"
                                    root.statusUser       = "Semangat Belajar! 💪"
                                    root.selectedAvatar   = 0
                                    resetConfirmPopup.close()
                                    root.showNotif(lang.dataResetBerhasil)
                                }
                            }
                        }
                    }
                }
            }

            // ── Popup Konfirmasi Logout ───────────────────────────────────────
            Popup {
                id: settingsLogoutPopup; anchors.centerIn: parent; width: 320; height: 190
                modal: true; focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                background: Rectangle { color: window.bgSecondary; radius: 16; border.color: window.accentColor; border.width: 2 }
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: "⏻  " + lang.keluarKonfirm; color: window.accentColor; font.pixelSize: 17; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: lang.sesiBelajarDihentikan; color: window.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        Rectangle {
                            Layout.fillWidth: true; height: 40; radius: 8; color: settCancelArea.pressed ? "#1a3a5c" : "#163e5f"
                            Text { anchors.centerIn: parent; text: lang.tidak; color: window.textPrimary; font.bold: true; font.pixelSize: 13 }
                            MouseArea { id: settCancelArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingsLogoutPopup.close() }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 40; radius: 8; color: settConfirmArea.pressed ? "#cc9900" : window.accentColor
                            Text { anchors.centerIn: parent; text: lang.yaLogout; color: "#001b2e"; font.bold: true; font.pixelSize: 13 }
                            MouseArea {
                                id: settConfirmArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settingsLogoutPopup.close()
                                    pageLoader.sourceComponent = loginComponent
                                    isLoginView = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}