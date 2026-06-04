import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Dialogs
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
    property string customAvatarPath: window.customAvatarPath
    onCustomAvatarPathChanged: window.customAvatarPath = customAvatarPath

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

    FileDialog {
        id: avatarFilePicker
        title: lang.uploadFotoProfil
        nameFilters: [lang.filterGambar]
        onAccepted: {
            cropPopup.imagePath = selectedFile
            cropPopup.offsetX   = 0
            cropPopup.offsetY   = 0
            cropPopup.open()
        }
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
                        anchors.fill: parent; onClicked: pageStack.pop()
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
            ScrollView {
                id: profilScrollView
                anchors.fill: parent
                visible: settingStack.currentId === "profil"
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    id: profilContent
                    width: profilScrollView.availableWidth - 64
                    x: 32
                    y: 32
                    spacing: 14

                    SectionTitle { judul: lang.profilPengguna }

                    Rectangle {
                        Layout.fillWidth: true; height: 100
                        color: window.bgSecondary; radius: 14; border.color: window.borderColor
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 20; spacing: 20
                            Item {
                                width: 88; height: 88

                                // ── Foto/emoji avatar — terpotong lingkaran sempurna ──
                                Rectangle {
                                    anchors.fill: parent   // 88×88
                                    radius: width / 2      // bentuk lingkaran
                                    color: window.bgSecondary
                                    clip: true             // potong semua child sesuai radius lingkaran
                                    z: 1

                                    // Layer foto — hanya muncul kalau ada customAvatarPath
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        clip: true          // clip kedua untuk pastikan lingkaran
                                        color: "transparent"
                                        visible: root.customAvatarPath !== ""

                                        Image {
                                            anchors.fill: parent
                                            source: root.customAvatarPath !== "" ? root.customAvatarPath : ""
                                            fillMode: Image.PreserveAspectCrop
                                            // offset sudah 0 karena hasil cropAndSave sudah persegi
                                        }
                                    }

                                    // Layer emoji — muncul kalau tidak ada foto
                                    Text {
                                        anchors.centerIn: parent
                                        text: (root.selectedAvatar >= 0 && root.selectedAvatar < root.avatarList.length)
                                              ? root.avatarList[root.selectedAvatar] : "📷"
                                        font.pixelSize: 38
                                        visible: root.customAvatarPath === ""
                                    }
                                }

                                // ── Border PNG berputar di atas ──
                                Image {
                                    id: settProfileBorderPng
                                    anchors.centerIn: parent
                                    width: 88; height: 88
                                    source: (window.selectedBorder >= 1 && window.selectedBorder <= 3)
                                            ? (window.borderAssets[window.selectedBorder] ?? "") : ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: (window.selectedBorder >= 1 && window.selectedBorder <= 3)
                                    z: 2
                                    RotationAnimator {
                                        target: settProfileBorderPng; from: 0; to: 360
                                        duration: 5000; loops: Animation.Infinite
                                        running: settProfileBorderPng.visible
                                    }
                                }

                                // ── Border gradasi Canvas (id 4-49) ──
                                Canvas {
                                    id: profileBorderCanvas
                                    anchors.centerIn: parent
                                    width: 88; height: 88
                                    z: 2
                                    visible: window.selectedBorder >= 4

                                    property real angle: 0
                                    NumberAnimation on angle {
                                        from: 0; to: Math.PI * 2
                                        duration: window.selectedBorder >= 4 ? window.borderDefs[window.selectedBorder].dur : 2000
                                        loops: Animation.Infinite
                                        running: profileBorderCanvas.visible
                                    }
                                    onAngleChanged: requestPaint()
                                    onVisibleChanged: requestPaint()
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        var idx = window.selectedBorder
                                        if (idx < 4 || idx >= window.borderDefs.length) return
                                        var def = window.borderDefs[idx]
                                        var cx = width / 2, cy = height / 2
                                        var x1 = cx + Math.cos(angle) * cx
                                        var y1 = cy + Math.sin(angle) * cy
                                        var x2 = cx + Math.cos(angle + Math.PI) * cx
                                        var y2 = cy + Math.sin(angle + Math.PI) * cy
                                        var grad = ctx.createLinearGradient(x1, y1, x2, y2)
                                        grad.addColorStop(0, def.c1)
                                        grad.addColorStop(1, def.c2)
                                        ctx.strokeStyle = grad
                                        ctx.lineWidth = def.lw
                                        ctx.beginPath()
                                        ctx.arc(cx, cy, cx - def.lw / 2 - 1, 0, Math.PI * 2)
                                        ctx.stroke()
                                    }
                                }

                                // ── Ring default (border 0) ──
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 88; height: 88; radius: 44
                                    color: "transparent"
                                    border.color: window.selectedBorder === 0 ? window.accentColor : "transparent"
                                    border.width: 2
                                    z: 2
                                }
                            }

                        Column {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: window.namaUser;   color: window.textPrimary; font.pixelSize: 18; font.bold: true }
                            Text { text: window.statusUser; color: window.textMuted;   font.pixelSize: 13 }
                        }
                    }
                }

                SectionTitle { judul: lang.namaTampilan }
                Rectangle {
                    Layout.fillWidth: true; height: 52; color: window.bgSecondary; radius: 12; border.color: window.borderColor
                    TextField {
                        anchors.fill: parent; anchors.margins: 4;
                        color: window.textPrimary; font.pixelSize: 14; padding: 12; placeholderText: lang.namaKamu
                        background: Rectangle { color: "transparent" }
                        Component.onCompleted: text = window.namaUser
                        onTextChanged: { root.namaUser = text; window.namaUser = text }
                    }
                }

                SectionTitle { judul: lang.statusLabel }
                Rectangle {
                    Layout.fillWidth: true; height: 52; color: window.bgSecondary; radius: 12; border.color: window.borderColor
                    TextField {
                        anchors.fill: parent; anchors.margins: 4;
                        color: window.textPrimary; font.pixelSize: 14; padding: 12; placeholderText: "Status kamu..."
                        background: Rectangle { color: "transparent" }
                        Component.onCompleted: text = window.statusUser
                        onTextChanged: { root.statusUser = text; window.statusUser = text }
                    }
                }

                SectionTitle { judul: lang.pilihAvatar }

                Rectangle {
                    Layout.fillWidth: true; height: 60
                    color: uploadArea.containsMouse
                           ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.12)
                           : window.bgSecondary
                    radius: 12; border.color: root.customAvatarPath !== "" ? "#2ecc71" : window.accentColor; border.width: 1.5

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 12
                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: root.customAvatarPath !== "" ? Qt.rgba(46/255,204/255,113/255,0.15) : Qt.rgba(255/255,204/255,0/255,0.1)
                            Text { anchors.centerIn: parent; text: root.customAvatarPath !== "" ? "✓" : "🖼️"; font.pixelSize: 18 }
                        }
                        Column {
                            spacing: 2; Layout.fillWidth: true
                            Text {
                                text: root.customAvatarPath !== "" ? lang.fotoBerhasilDipilih : lang.uploadFotoProfil
                                color: root.customAvatarPath !== "" ? "#2ecc71" : window.textPrimary
                                font.pixelSize: 13; font.bold: true
                            }
                            Text {
                                text: root.customAvatarPath !== ""
                                      ? root.customAvatarPath.toString().replace(/.*[\/\\]/, "").substring(0, 30) + "..."
                                      : lang.klikUntukPilih
                                color: window.textMuted; font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: clearArea.pressed ? "#cc2222" : "#ff4444"
                            visible: root.customAvatarPath !== ""
                            z: 20
                            Text { anchors.centerIn: parent; text: "✕"; color: "white"; font.pixelSize: 11; font.bold: true }
                            MouseArea {
                                id: clearArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                propagateComposedEvents: false
                                onClicked: function(mouse) {
                                    mouse.accepted = true
                                    root.customAvatarPath   = ""
                                    window.customAvatarPath = ""
                                    root.selectedAvatar     = 0
                                    window.selectedAvatar   = 0
                                }
                            }
                        }
                    }
                    MouseArea {
                        id: uploadArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; z: 1
                        onClicked: function(mouse) {
                            if (root.customAvatarPath === "") avatarFilePicker.open()
                        }
                    }
                }

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
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.selectedAvatar = index
                                            root.customAvatarPath = ""
                                            window.customAvatarPath = ""
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SectionTitle { judul: "✨  " + lang.profil + " Border" }

                // ── Border names (indeks 0-49) ─────────────────────────────
                readonly property var borderNames: [
                    "Default",     "Kawaii",       "Galaxy PNG",  "Rainbow PNG",
                    "Pelangi",     "Api",          "Laut",        "Galaxy",
                    "Sakura",      "Neon Hijau",   "Magma",       "Es Biru",
                    "Emas",        "Hutan",        "Anggur",      "Flamingo",
                    "Toska",       "Matahari",     "Midnite",     "Neon Ungu",
                    "Merah Bara",  "Emerald",      "Oranye",      "Biru Peter",
                    "Lavender",    "Hijau Segar",  "Sunset",      "Langit",
                    "Neon Merah",  "Menta",        "Magenta",     "Gelap Royal",
                    "Peach",       "Pastel Ungu",  "Persik",      "Lemon Mint",
                    "Matrix",      "Candy",        "Cyber",       "Soft Biru",
                    "Krim",        "Lilac",        "Rose",        "Seafoam",
                    "Dusk",        "Flamingo 2",   "Portal",      "Neon Volt",
                    "Bunga",       "Neon Cyan",
                ]

                Rectangle {
                    Layout.fillWidth: true; height: 160
                    color: window.bgSecondary; radius: 12; border.color: window.borderColor; clip: true

                    ScrollView {
                        anchors.fill: parent; anchors.margins: 10
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        contentWidth: borderRow.implicitWidth
                        contentHeight: availableHeight

                        Row {
                            id: borderRow
                            spacing: 10
                            height: parent.height

                            // ── Border 0: Default ────────────────────────────
                            Column {
                                spacing: 4; anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: 56; height: 56; radius: 28
                                    color: window.bgCard
                                    border.color: window.selectedBorder === 0 ? window.accentColor : window.borderColor
                                    border.width: window.selectedBorder === 0 ? 3 : 1
                                    scale: window.selectedBorder === 0 ? 1.1 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                    Text { anchors.centerIn: parent; text: window.selectedBorder === 0 ? "✓" : "○"; color: window.accentColor; font.pixelSize: 20; font.bold: true }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { window.selectedBorder = 0; root.showNotif("Border 'Default' " + lang.aktif + " ✨") } }
                                }
                                Text { text: "Default"; color: window.selectedBorder === 0 ? window.accentColor : window.textMuted; font.pixelSize: 9; anchors.horizontalCenter: parent.horizontalCenter }
                            }

                            // ── Border 1-3: PNG (Kawaii, Galaxy, Rainbow) ────
                            Repeater {
                                model: [
                                    { id: 1, label: "Kawaii",   asset: "qrc:/StudyTrackerApp/borders/kawaii.png" },
                                    { id: 2, label: "Galaxy",   asset: "qrc:/StudyTrackerApp/borders/galaxy.png" },
                                    { id: 3, label: "Rainbow",  asset: "qrc:/StudyTrackerApp/borders/rainbow.png" },
                                ]
                                delegate: Column {
                                    spacing: 4; anchors.verticalCenter: parent.verticalCenter
                                    Rectangle {
                                        width: 56; height: 56; radius: 28; color: window.bgCard; clip: true
                                        border.color: window.selectedBorder === modelData.id ? window.accentColor : window.borderColor
                                        border.width: window.selectedBorder === modelData.id ? 3 : 1
                                        scale: window.selectedBorder === modelData.id ? 1.1 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 150 } }
                                        Image {
                                            id: pngImg
                                            anchors.fill: parent; source: modelData.asset
                                            fillMode: Image.PreserveAspectCrop
                                            RotationAnimator {
                                                target: pngImg; from: 0; to: 360; duration: 4000
                                                loops: Animation.Infinite
                                                running: window.selectedBorder === modelData.id
                                            }
                                        }
                                        Text {
                                            anchors.centerIn: parent; z: 1
                                            text: window.selectedBorder === modelData.id ? "✓" : ""
                                            color: "white"; font.pixelSize: 16; font.bold: true
                                            style: Text.Outline; styleColor: "#000"
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { window.selectedBorder = modelData.id; root.showNotif("Border '" + modelData.label + "' " + lang.aktif + " ✨") }
                                        }
                                    }
                                    Text { text: modelData.label; color: window.selectedBorder === modelData.id ? window.accentColor : window.textMuted; font.pixelSize: 9; anchors.horizontalCenter: parent.horizontalCenter }
                                }
                            }

                            // ── Border 4-49: Gradasi Canvas ──────────────────
                            Repeater {
                                model: 46   // id 4..49
                                delegate: Column {
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    property int bid: index + 4
                                    property var bdef: window.borderDefs[bid]

                                    Rectangle {
                                        id: gradBtnRect
                                        width: 56; height: 56; radius: 28
                                        color: window.bgCard
                                        border.color: "transparent"; border.width: 0
                                        scale: window.selectedBorder === bid ? 1.1 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 150 } }

                                        Canvas {
                                            id: gradBtnCanvas
                                            anchors.fill: parent
                                            property real angle: 0
                                            NumberAnimation on angle {
                                                from: 0; to: Math.PI * 2
                                                duration: bdef ? bdef.dur : 2000
                                                loops: Animation.Infinite; running: true
                                            }
                                            onAngleChanged: requestPaint()
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                if (!bdef) return
                                                var cx = width / 2, cy = height / 2
                                                var lw = window.selectedBorder === bid ? (bdef.lw + 1) : bdef.lw
                                                var x1 = cx + Math.cos(angle) * cx
                                                var y1 = cy + Math.sin(angle) * cy
                                                var x2 = cx + Math.cos(angle + Math.PI) * cx
                                                var y2 = cy + Math.sin(angle + Math.PI) * cy
                                                var grad = ctx.createLinearGradient(x1, y1, x2, y2)
                                                grad.addColorStop(0, bdef.c1)
                                                grad.addColorStop(1, bdef.c2)
                                                ctx.strokeStyle = grad
                                                ctx.lineWidth = lw
                                                ctx.beginPath()
                                                ctx.arc(cx, cy, cx - lw / 2 - 1, 0, Math.PI * 2)
                                                ctx.stroke()
                                            }
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            text: window.selectedBorder === bid ? "✓" : ""
                                            color: bdef ? bdef.c1 : "white"; font.pixelSize: 16; font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                window.selectedBorder = bid
                                                root.showNotif("Border '" + profilContent.borderNames[bid] + "' " + lang.aktif + " ✨")
                                            }
                                        }
                                    }
                                    Text {
                                        text: profilContent.borderNames[bid] ?? ("Border " + bid)
                                        color: window.selectedBorder === bid ? window.accentColor : window.textMuted
                                        font.pixelSize: 9; anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                Item { height: 32 }
                }
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
            ScrollView {
                anchors.fill: parent
                visible: settingStack.currentId === "tampilan"
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width - 64
                x: 32; y: 32
                spacing: 14

                SectionTitle { judul: "🎨  " + lang.temaWarna }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    Repeater {
                        model: [
                            // ── Tema Gelap ───────────────────────────────────
                            { key: "gelap",        label: "Gelap",        emoji: "🌙", bg2: "#0a2a43", accent: "#ffcc00" },
                            { key: "hitam",        label: "Hitam",        emoji: "⬛", bg2: "#141414", accent: "#ffffff" },
                            { key: "gelap_merah",  label: "Darah",        emoji: "🩸", bg2: "#2a0a0a", accent: "#ff3333" },
                            { key: "gelap_ungu",   label: "Dracula",      emoji: "🧛", bg2: "#1e1433", accent: "#bd93f9" },
                            { key: "gelap_hijau",  label: "Matrix",       emoji: "💻", bg2: "#0a1a0a", accent: "#00ff41" },
                            { key: "gelap_biru",   label: "Midnight",     emoji: "🌃", bg2: "#0d1b2a", accent: "#4fc3f7" },
                            { key: "gelap_oranye", label: "Lava",         emoji: "🌋", bg2: "#1a0d00", accent: "#ff6d00" },
                            { key: "gelap_toska",  label: "Abyss",        emoji: "🌊", bg2: "#001a1a", accent: "#00e5cc" },
                            { key: "gelap_kuning", label: "Neon Night",   emoji: "🟡", bg2: "#111100", accent: "#ffe600" },
                            { key: "gelap_silver", label: "Steel",        emoji: "⚙️", bg2: "#0e1117", accent: "#b0bec5" },
                            // ── Tema Terang ──────────────────────────────────
                            { key: "putih",        label: "Putih",        emoji: "☀️",  bg2: "#dde4eb", accent: "#1565c0" },
                            { key: "krem",         label: "Krem",         emoji: "🍦",  bg2: "#f5efe0", accent: "#8d5524" },
                            { key: "pastel_pink",  label: "Kawaii",       emoji: "🎀",  bg2: "#ffe0ec", accent: "#e91e8c" },
                            { key: "pastel_biru",  label: "Baby Blue",    emoji: "🫧",  bg2: "#daeaf7", accent: "#1976d2" },
                            { key: "pastel_hijau", label: "Mint Fresh",   emoji: "🍃",  bg2: "#d8f3dc", accent: "#2d6a4f" },
                            { key: "pastel_ungu",  label: "Lavender",     emoji: "💜",  bg2: "#ede7f6", accent: "#6a1b9a" },
                            { key: "pastel_kuning",label: "Sunny",        emoji: "🌞",  bg2: "#fff9c4", accent: "#f57f17" },
                            { key: "pastel_peach", label: "Peach",        emoji: "🍑",  bg2: "#ffe8d6", accent: "#bf5700" },
                            { key: "nordic",       label: "Nordic",       emoji: "❄️",  bg2: "#e8edf2", accent: "#2e7d8c" },
                            { key: "paper",        label: "Paper",        emoji: "📄",  bg2: "#f4f1ea", accent: "#5d4037" },
                            // ── Tema Warna Solid ─────────────────────────────
                            { key: "pink",         label: "Pink",         emoji: "🌸", bg2: "#2d1020", accent: "#ff6eb4" },
                            { key: "merah",        label: "Ruby",         emoji: "❤️", bg2: "#2a0808", accent: "#f44336" },
                            { key: "oranye",       label: "Oranye",       emoji: "🍊", bg2: "#1a0d00", accent: "#ff9800" },
                            { key: "kuning",       label: "Kuning",       emoji: "🌟", bg2: "#1a1600", accent: "#fdd835" },
                            { key: "hijau",        label: "Hijau",        emoji: "🍀", bg2: "#091a09", accent: "#4caf50" },
                            { key: "toska",        label: "Toska",        emoji: "🦚", bg2: "#001a18", accent: "#26a69a" },
                            { key: "laut",         label: "Laut",         emoji: "🌊", bg2: "#112d54", accent: "#38bdf8" },
                            { key: "biru",         label: "Biru",         emoji: "💙", bg2: "#0a1a40", accent: "#2196f3" },
                            { key: "ungu",         label: "Ungu",         emoji: "🔮", bg2: "#150a2a", accent: "#9c27b0" },
                            { key: "coklat",       label: "Coklat",       emoji: "🍫", bg2: "#1c100a", accent: "#795548" },
                            // ── Tema Alam ────────────────────────────────────
                            { key: "adem",         label: "Adem",         emoji: "🌿", bg2: "#0e2e1c", accent: "#4ecca3" },
                            { key: "hutan",        label: "Hutan",        emoji: "🌲", bg2: "#0a1f0a", accent: "#8bc34a" },
                            { key: "gurun",        label: "Gurun",        emoji: "🏜️", bg2: "#2a1e0a", accent: "#ffb300" },
                            { key: "salju",        label: "Salju",        emoji: "☃️", bg2: "#d0dde8", accent: "#0288d1" },
                            { key: "pantai",       label: "Pantai",       emoji: "🏖️", bg2: "#0d2a36", accent: "#00bcd4" },
                            { key: "aurora",       label: "Aurora",       emoji: "🌌", bg2: "#061020", accent: "#00e5ff" },
                            { key: "musim_gugur",  label: "Gugur",        emoji: "🍁", bg2: "#1a0e00", accent: "#ff8f00" },
                            { key: "musim_semi",   label: "Semi",         emoji: "🌸", bg2: "#1a1000", accent: "#f48fb1" },
                            { key: "volcano",      label: "Vulkanik",     emoji: "🌋", bg2: "#1a0500", accent: "#ff5722" },
                            { key: "bambu",        label: "Bambu",        emoji: "🎍", bg2: "#111a08", accent: "#aed581" },
                            // ── Tema Makanan & Minuman ───────────────────────
                            { key: "kopi",         label: "Kopi",         emoji: "☕", bg2: "#1c1008", accent: "#d7a86e" },
                            { key: "matcha",       label: "Matcha",       emoji: "🍵", bg2: "#0e1a0a", accent: "#69b578" },
                            { key: "boba",         label: "Boba",         emoji: "🧋", bg2: "#1a1020", accent: "#cc99ff" },
                            { key: "stroberi",     label: "Stroberi",     emoji: "🍓", bg2: "#1a0810", accent: "#f06292" },
                            { key: "blueberry",    label: "Blueberry",    emoji: "🫐", bg2: "#0a0a1a", accent: "#7986cb" },
                            { key: "vanilla",      label: "Vanilla",      emoji: "🍨", bg2: "#e8dfc8", accent: "#795548" },
                            { key: "coklat_susu",  label: "Choco Milk",   emoji: "🍫", bg2: "#1e140a", accent: "#bcaaa4" },
                            { key: "nasi",         label: "Nasi Goreng",  emoji: "🍳", bg2: "#1a1000", accent: "#ffcc80" },
                            { key: "teh_tarik",    label: "Teh Tarik",    emoji: "🧃", bg2: "#1a0e08", accent: "#ffa726" },
                            { key: "es_krim",      label: "Es Krim",      emoji: "🍦", bg2: "#ffe8f0", accent: "#e91e8c" },
                            // ── Tema Pop Culture ─────────────────────────────
                            { key: "vintage",      label: "Vintage",      emoji: "🍂", bg2: "#2e1f0e", accent: "#d4a24c" },
                            { key: "retro",        label: "Retro 80s",    emoji: "📺", bg2: "#0a001a", accent: "#ff00ff" },
                            { key: "vaporwave",    label: "Vaporwave",    emoji: "🌴", bg2: "#1a0028", accent: "#ff71ce" },
                            { key: "cyberpunk",    label: "Cyberpunk",    emoji: "🤖", bg2: "#0a0014", accent: "#ffe600" },
                            { key: "lofi",         label: "Lo-fi",        emoji: "🎵", bg2: "#1a1428", accent: "#b39ddb" },
                            { key: "cottagecore",  label: "Cottagecore",  emoji: "🌾", bg2: "#e8dcc8", accent: "#5d4e37" },
                            { key: "dark_academia",label: "Dark Academia", emoji: "📚", bg2: "#1e1810", accent: "#c8a96e" },
                            { key: "y2k",          label: "Y2K",          emoji: "💿", bg2: "#0a1428", accent: "#00ffff" },
                            { key: "pastel_goth",  label: "Pastel Goth",  emoji: "🖤", bg2: "#1a0a1a", accent: "#cc99ff" },
                            { key: "skater",       label: "Skater",       emoji: "🛹", bg2: "#0f0f0f", accent: "#ff4500" },
                            // ── Tema Angkasa & Sci-fi ────────────────────────
                            { key: "galaxy",       label: "Galaxy",       emoji: "🌌", bg2: "#050520", accent: "#7c4dff" },
                            { key: "nebula",       label: "Nebula",       emoji: "✨", bg2: "#0d0520", accent: "#e040fb" },
                            { key: "cosmos",       label: "Cosmos",       emoji: "🪐", bg2: "#060a1e", accent: "#40c4ff" },
                            { key: "mars",         label: "Mars",         emoji: "🔴", bg2: "#1a0a05", accent: "#ff6e40" },
                            { key: "bulan",        label: "Bulan",        emoji: "🌕", bg2: "#0e0e14", accent: "#eeeeee" },
                            { key: "bima_sakti",   label: "Bima Sakti",   emoji: "🌠", bg2: "#040418", accent: "#82b1ff" },
                            { key: "blackhole",    label: "Black Hole",   emoji: "🕳️", bg2: "#000005", accent: "#ea80fc" },
                            { key: "neon_space",   label: "Neon Space",   emoji: "🚀", bg2: "#080018", accent: "#69ff47" },
                            { key: "asteroid",     label: "Asteroid",     emoji: "☄️", bg2: "#0a0808", accent: "#ff6d00" },
                            { key: "saturn",       label: "Saturnus",     emoji: "🪐", bg2: "#0d1020", accent: "#ffca28" },
                            // ── Tema Seni & Estetika ─────────────────────────
                            { key: "monokrom",     label: "Monokrom",     emoji: "🎭", bg2: "#1a1a1a", accent: "#aaaaaa" },
                            { key: "sepia",        label: "Sepia",        emoji: "📷", bg2: "#2a1e10", accent: "#c8a96e" },
                            { key: "neon",         label: "Neon",         emoji: "💡", bg2: "#050505", accent: "#39ff14" },
                            { key: "glassmorphism",label: "Glassmorphic", emoji: "🔷", bg2: "#1a2240", accent: "#90caf9" },
                            { key: "bauhaus",      label: "Bauhaus",      emoji: "🟥", bg2: "#f5f0e8", accent: "#e53935" },
                            { key: "memphis",      label: "Memphis",      emoji: "🔶", bg2: "#fafafa", accent: "#ff6f00" },
                            { key: "brutalist",    label: "Brutalist",    emoji: "🏗️", bg2: "#e8e0d0", accent: "#212121" },
                            { key: "grunge",       label: "Grunge",       emoji: "🎸", bg2: "#1a1008", accent: "#9e9d24" },
                            { key: "watercolor",   label: "Watercolor",   emoji: "🎨", bg2: "#e8f4f8", accent: "#0277bd" },
                            { key: "noir",         label: "Noir",         emoji: "🕵️", bg2: "#0a0a0a", accent: "#c8b8a2" },
                            // ── Tema Budaya ──────────────────────────────────
                            { key: "sakura",       label: "Sakura",       emoji: "🌸", bg2: "#1a0a14", accent: "#f48fb1" },
                            { key: "samurai",      label: "Samurai",      emoji: "⚔️", bg2: "#0a0a00", accent: "#c62828" },
                            { key: "batik",        label: "Batik",        emoji: "🪱", bg2: "#1a0e00", accent: "#ff8f00" },
                            { key: "melayu",       label: "Melayu",       emoji: "🏝️", bg2: "#0a1a14", accent: "#4db6ac" },
                            { key: "india",        label: "India",        emoji: "🕌", bg2: "#1a0a00", accent: "#ff9800" },
                            { key: "nordic2",      label: "Viking",       emoji: "🪓", bg2: "#0e1820", accent: "#78909c" },
                            { key: "aztec",        label: "Aztec",        emoji: "🌞", bg2: "#1a0e00", accent: "#ffca28" },
                            { key: "mediterania",  label: "Mediterania",  emoji: "🫒", bg2: "#0a1814", accent: "#26a69a" },
                            { key: "amazon",       label: "Amazon",       emoji: "🐍", bg2: "#0a1a08", accent: "#66bb6a" },
                            { key: "arctic",       label: "Arktik",       emoji: "🐻‍❄️", bg2: "#0a1428", accent: "#b3e5fc" },
                            // ── Tema Bonus ───────────────────────────────────
                            { key: "neon_pink",    label: "Neon Pink",    emoji: "💗", bg2: "#1a001a", accent: "#ff4dd2" },
                            { key: "emerald",      label: "Emerald",      emoji: "💚", bg2: "#001a0e", accent: "#00e676" },
                            { key: "amber",        label: "Amber",        emoji: "🟠", bg2: "#1a0e00", accent: "#ffab40" },
                            { key: "indigo",       label: "Indigo",       emoji: "🫐", bg2: "#0a0a28", accent: "#536dfe" },
                            { key: "rose_gold",    label: "Rose Gold",    emoji: "🌹", bg2: "#200a10", accent: "#f48fb1" },
                            { key: "obsidian",     label: "Obsidian",     emoji: "🖤", bg2: "#08080c", accent: "#607d8b" },
                            { key: "senja",        label: "Senja",        emoji: "🌇", bg2: "#1a0d10", accent: "#ff7043" },
                            { key: "pagi",         label: "Pagi",         emoji: "🌅", bg2: "#ffe0b0", accent: "#e65100" },
                            { key: "neon_biru",    label: "Neon Biru",    emoji: "🔵", bg2: "#000a18", accent: "#00b0ff" },
                            { key: "pistachio",    label: "Pistachio",    emoji: "🌰", bg2: "#0e1a08", accent: "#c5e1a5" },
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

                Item { height: 32 }
            }
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
                            text: lang.passwordLamaSalah
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
                                    window.customAvatarPath = ""
                                    root.customAvatarPath   = ""
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
                                    var tasks = []
                                    for (var i = 0; i < globalTaskModel.count; i++) {
                                        var t = globalTaskModel.get(i)
                                        tasks.push({
                                            "title": t.title, "deadline": t.deadline,
                                            "deadlineTimestamp": t.deadlineTimestamp, "isDone": t.isDone
                                        })
                                    }
                                    backend.saveUserData(
                                        window.currentUser, window.namaUser, window.statusUser,
                                        window.selectedAvatar, window.globalSessionsCompleted,
                                        window.globalSecondsFocused, tasks
                                    )
                                    pageStack.replace(null, loginComponent)
                                    isLoginView = true
                                }
                            }
                        }
                    }
                }
            }
        }

    Popup {
        id: cropPopup
        anchors.centerIn: parent; width: 340; height: 440
        modal: true; focus: true
        closePolicy: Popup.CloseOnEscape

        property string imagePath: ""
        property real offsetX: 0
        property real offsetY: 0

        background: Rectangle { color: window.bgSecondary; radius: 16; border.color: window.accentColor; border.width: 2 }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 14

            Text { text: "✂️  " + lang.aturPosisiFoto; color: window.textPrimary; font.pixelSize: 15; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: lang.geserFoto; color: window.textMuted; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }

            Rectangle {
                width: 200; height: 200; radius: 100; clip: true
                border.color: window.accentColor; border.width: 2
                color: window.bgCard
                Layout.alignment: Qt.AlignHCenter

                // Gunakan Item sebagai clipping container - Image di dalamnya tidak bisa keluar
                Item {
                    id: cropContainer
                    anchors.fill: parent
                    clip: true

                    Image {
                        id: cropImage
                        source: cropPopup.imagePath
                        // Render lebih besar dari container supaya bisa digeser
                        width: 200; height: 200
                        fillMode: Image.PreserveAspectCrop
                        // Clamp offset supaya gambar tidak bisa keluar lingkaran
                        x: Math.max(-(implicitWidth - 200), Math.min(0, cropPopup.offsetX))
                        y: Math.max(-(implicitHeight - 200), Math.min(0, cropPopup.offsetY))
                    }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.OpenHandCursor
                    property real startX: 0; property real startY: 0
                    property real startOffX: 0; property real startOffY: 0
                    onPressed: { startX = mouseX; startY = mouseY; startOffX = cropPopup.offsetX; startOffY = cropPopup.offsetY }
                    onPositionChanged: {
                        cropPopup.offsetX = startOffX + (mouseX - startX)
                        cropPopup.offsetY = startOffY + (mouseY - startY)
                    }
                }
            }

            Text { text: lang.petunjukGeser; color: window.textMuted; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8; color: window.borderColor
                    Text { anchors.centerIn: parent; text: lang.batalFoto; color: window.textPrimary; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cropPopup.close() }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8; color: window.accentColor
                    Text { anchors.centerIn: parent; text: lang.simpanFoto; color: "#001b2e"; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.customAvatarPath   = cropPopup.imagePath
                            window.customAvatarPath = cropPopup.imagePath
                            window.avatarOffsetX    = cropPopup.offsetX
                            window.avatarOffsetY    = cropPopup.offsetY
                            root.selectedAvatar     = -1
                            window.selectedAvatar   = -1
                            cropPopup.close()
                        }
                        }
                    }
                }
            }
        }
    }
}
