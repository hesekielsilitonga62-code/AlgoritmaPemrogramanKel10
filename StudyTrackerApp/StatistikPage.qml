import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    // ── Warna semantik — ikut tema secara otomatis ───────────────────────────
    // "sukses" → sedikit lebih terang dari accentColor, dipakai untuk done/selesai
    // "warning" → dipakai untuk pending
    readonly property color colorDone:    Qt.rgba(
        window.accentColor.r * 0.55 + 0.18,
        window.accentColor.g * 0.55 + 0.45,
        window.accentColor.b * 0.55 + 0.18, 1)   // hijau tonik adaptif
    readonly property color colorPending: Qt.rgba(
        window.accentColor.r * 0.9  + 0.10,
        window.accentColor.g * 0.55,
        window.accentColor.b * 0.10, 1)           // oranye adaptif

    // Versi "done" yang benar-benar ngikut tema: pakai accentColor + sedikit green shift
    // Untuk tema yg accentColor terang (putih/biru) → done tetap terlihat beda
    readonly property color accentSoft: Qt.rgba(
        window.accentColor.r,
        window.accentColor.g,
        window.accentColor.b, 0.12)

    readonly property color accentBorder: Qt.rgba(
        window.accentColor.r,
        window.accentColor.g,
        window.accentColor.b, 0.35)

    // Progress bar: pakai 3 nuansa dari accentColor agar ikut tema
    readonly property color barColor1: window.accentColor                         // sesi
    readonly property color barColor2: Qt.lighter(window.accentColor, 1.35)       // tugas
    readonly property color barColor3: Qt.rgba(                                   // fokus
        window.accentColor.r * 0.4 + 0.1,
        window.accentColor.g * 0.4 + 0.3,
        window.accentColor.b * 0.4 + 0.6, 1)

    // ── Helpers ──────────────────────────────────────────────────────────────
    function formatWaktu(detik) {
        let j = Math.floor(detik / 3600).toString().padStart(2, '0')
        let m = Math.floor((detik % 3600) / 60).toString().padStart(2, '0')
        let s = (detik % 60).toString().padStart(2, '0')
        return j + ":" + m + ":" + s
    }
    function hitungTugasSelesai() {
        let n = 0
        for (let i = 0; i < globalTaskModel.count; i++)
            if (globalTaskModel.get(i).isDone) n++
        return n
    }
    function hitungTugasPending() {
        let n = 0
        for (let i = 0; i < globalTaskModel.count; i++)
            if (!globalTaskModel.get(i).isDone) n++
        return n
    }
    function persenTugas() {
        if (globalTaskModel.count === 0) return 0
        return Math.round((hitungTugasSelesai() / globalTaskModel.count) * 100)
    }
    function persenSesi() {
        if (globalTargetSessions === 0) return 0
        return Math.min(Math.round((globalSessionsCompleted / globalTargetSessions) * 100), 100)
    }

    // ── Kartu statistik kecil ────────────────────────────────────────────────
    component StatCard : Rectangle {
        property string label: ""
        property string nilai: ""
        property string ikon:  ""

        height: 90
        color:  window.bgSecondary
        radius: 14
        border.color: window.borderColor
        border.width: 1

        // Stripe aksen kiri
        Rectangle {
            width: 4; height: parent.height - 24; radius: 2
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            color: window.accentColor; opacity: 0.7
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            anchors.leftMargin: 22
            spacing: 14

            // Ikon bulat dengan latar aksen transparan
            Rectangle {
                width: 46; height: 46; radius: 12
                color: root.accentSoft
                border.color: root.accentBorder; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: ikon; font.pixelSize: 22
                }
            }

            Column {
                spacing: 4
                Text {
                    text: nilai
                    color: window.textPrimary; font.pixelSize: 22; font.bold: true
                }
                Text {
                    text: label
                    color: window.textMuted; font.pixelSize: 11
                }
            }
        }
    }

    // ── Progress bar row ─────────────────────────────────────────────────────
    component ProgressRow : Column {
        property string label:    ""
        property int    persen:   0
        property color  warnaBar: window.accentColor
        property string subLabel: ""

        spacing: 6
        Layout.fillWidth: true

        RowLayout {
            width: parent.width
            Text {
                text: parent.parent.label
                color: window.textPrimary; font.pixelSize: 13
                Layout.fillWidth: true
            }
            // Badge persen
            Rectangle {
                width: persenBadge.implicitWidth + 10; height: 20; radius: 10
                color: Qt.rgba(parent.parent.warnaBar.r,
                               parent.parent.warnaBar.g,
                               parent.parent.warnaBar.b, 0.15)
                border.color: Qt.rgba(parent.parent.warnaBar.r,
                                      parent.parent.warnaBar.g,
                                      parent.parent.warnaBar.b, 0.4)
                border.width: 1
                Text {
                    id: persenBadge
                    anchors.centerIn: parent
                    text: parent.parent.parent.persen + "%"
                    color: parent.parent.parent.warnaBar
                    font.pixelSize: 11; font.bold: true
                }
            }
        }

        // Track bar
        Rectangle {
            width: parent.width; height: 8; radius: 4
            color: window.borderColor

            // Fill bar
            Rectangle {
                width: parent.parent.persen > 0
                       ? parent.width * (parent.parent.persen / 100) : 0
                height: 8; radius: 4
                color: parent.parent.warnaBar

                Behavior on width {
                    NumberAnimation { duration: 700; easing.type: Easing.OutCubic }
                }

                // Kilap di ujung kanan fill
                Rectangle {
                    width: 8; height: 8; radius: 4
                    anchors.right: parent.right
                    color: Qt.lighter(parent.parent.parent.warnaBar, 1.5)
                    visible: parent.parent.parent.persen > 3
                    opacity: 0.7
                }
            }
        }
    }

    // ─── LAYOUT UTAMA ────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 20

        // ── HEADER ───────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            // Tombol kembali bergaya sama dengan TimerBelajar
            Rectangle {
                id: backBtn
                width: backRow.implicitWidth + 24; height: 36; radius: 18
                color: backArea.pressed
                       ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.22)
                       : backArea.containsMouse
                         ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.10)
                         : window.bgSecondary
                border.color: backArea.containsMouse ? window.accentColor : window.borderColor
                border.width:  backArea.containsMouse ? 1.5 : 1

                Behavior on color        { ColorAnimation { duration: 160 } }
                Behavior on border.color { ColorAnimation { duration: 160 } }

                Row {
                    id: backRow
                    anchors.centerIn: parent; spacing: 7
                    Text {
                        text: "←"
                        color: backArea.containsMouse ? window.accentColor : window.textMuted
                        font.pixelSize: 15; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 160 } }
                    }
                    Text {
                        text: lang.mainMenu
                        color: backArea.containsMouse ? window.accentColor : window.textMuted
                        font.pixelSize: 13; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 160 } }
                    }
                }
                MouseArea {
                    id: backArea; anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                    onClicked: pageLoader.sourceComponent = mainComponent
                }
            }

            Item { Layout.fillWidth: true }

            // Judul kanan
            Column {
                spacing: 2
                Text {
                    text: lang.statistik
                    color: window.textPrimary; font.pixelSize: 28; font.bold: true
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right
                }
                Text {
                    text: lang.ringkasanAktivitas
                    color: window.textMuted; font.pixelSize: 13
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right
                }
            }
        }

        // ── BARIS 1: 4 kartu ringkasan ───────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 4; columnSpacing: 14; rowSpacing: 14

            StatCard { Layout.fillWidth: true; ikon: "⏱️"; label: lang.totalWaktuBelajar;   nilai: formatWaktu(globalSeconds) }
            StatCard { Layout.fillWidth: true; ikon: "🍅"; label: lang.sesiPomodoroSelesai; nilai: globalSessionsCompleted + " / " + globalTargetSessions }
            StatCard { Layout.fillWidth: true; ikon: "✅"; label: lang.tugasSelesaiLabel;   nilai: hitungTugasSelesai() + " " + lang.tugas.toLowerCase() }
            StatCard { Layout.fillWidth: true; ikon: "👥"; label: lang.temanDitambahkan;    nilai: myFriendsModel.count + " " + lang.orang }
        }

        // ── BARIS 2: Progress + Daftar Tugas ─────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // ── Panel kiri: Progress ─────────────────────────────────────────
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.42
                color: window.bgSecondary; radius: 14
                border.color: window.borderColor; border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // Judul
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Rectangle {
                            width: 4; height: 18; radius: 2
                            color: window.accentColor
                        }
                        Text {
                            text: lang.progressHariIni
                            color: window.textPrimary; font.pixelSize: 15; font.bold: true
                        }
                    }

                    // Progress Sesi Pomodoro
                    ProgressRow {
                        Layout.fillWidth: true
                        label:    lang.targetSesiHarian
                        persen:   persenSesi()
                        warnaBar: root.barColor1
                    }

                    // Progress Tugas
                    ProgressRow {
                        Layout.fillWidth: true
                        label:    lang.penyelesaianTugas
                        persen:   persenTugas()
                        warnaBar: root.barColor2
                    }

                    // Waktu fokus
                    ProgressRow {
                        Layout.fillWidth: true
                        label:    lang.waktuFokusPomodoro
                        persen:   globalSeconds > 0
                                  ? Math.min(Math.round((globalSecondsFocused / globalSeconds) * 100), 100)
                                  : 0
                        warnaBar: root.barColor3
                    }

                    Item { Layout.fillHeight: true }

                    // Kartu motivasi — warna ikut tema
                    Rectangle {
                        Layout.fillWidth: true; height: 54; radius: 12
                        color: root.accentSoft
                        border.color: root.accentBorder; border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 10
                            Text {
                                text: globalSeconds < 1800 ? "🌱"
                                    : globalSeconds < 7200 ? "🔥" : "🏆"
                                font.pixelSize: 20
                            }
                            Text {
                                text: globalSeconds < 1800 ? lang.motivasiAwal
                                    : globalSeconds < 7200 ? lang.motivasiTengah
                                    : lang.motivasiAkhir
                                color: window.accentColor; font.pixelSize: 11
                                wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            // ── Panel kanan: Daftar tugas ────────────────────────────────────
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: window.bgSecondary; radius: 14
                border.color: window.borderColor; border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    // Header daftar tugas
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8

                        Rectangle {
                            width: 4; height: 18; radius: 2
                            color: window.accentColor
                        }
                        Text {
                            text: "📋 " + lang.daftarTugas
                            color: window.textPrimary; font.pixelSize: 15; font.bold: true
                            Layout.fillWidth: true
                        }
                        // Badge jumlah total
                        Rectangle {
                            width: totalBadge.implicitWidth + 12; height: 24; radius: 12
                            color: root.accentSoft
                            border.color: root.accentBorder; border.width: 1
                            Text {
                                id: totalBadge
                                anchors.centerIn: parent
                                text: globalTaskModel.count
                                color: window.accentColor; font.bold: true; font.pixelSize: 12
                            }
                        }
                    }

                    // Kosong
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: globalTaskModel.count === 0
                        Column {
                            anchors.centerIn: parent; spacing: 10
                            Text {
                                text: "📭"; font.pixelSize: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 0.5
                            }
                            Text {
                                text: lang.belumAdaTugas
                                color: window.textMuted; font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // List tugas
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: globalTaskModel
                        spacing: 8; clip: true
                        visible: globalTaskModel.count > 0

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            width: ListView.view.width; height: 56
                            radius: 10

                            // Warna latar — done pakai tint accentColor tipis, pending pakai bgCard
                            color: model.isDone
                                   ? Qt.rgba(window.accentColor.r,
                                             window.accentColor.g,
                                             window.accentColor.b, 0.08)
                                   : window.bgCard

                            border.color: model.isDone
                                          ? Qt.rgba(window.accentColor.r,
                                                    window.accentColor.g,
                                                    window.accentColor.b, 0.35)
                                          : window.borderColor
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 10

                                // Dot status ikut accentColor (done) atau textMuted (pending)
                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: model.isDone
                                           ? window.accentColor
                                           : window.textMuted
                                    opacity: model.isDone ? 1.0 : 0.6
                                }

                                Column {
                                    spacing: 2; Layout.fillWidth: true
                                    Text {
                                        text: model.title
                                        color: model.isDone ? window.textMuted : window.textPrimary
                                        font.pixelSize: 14; font.bold: !model.isDone
                                        font.strikeout: model.isDone
                                        elide: Text.ElideRight; width: parent.width
                                        opacity: model.isDone ? 0.6 : 1.0
                                    }
                                    Text {
                                        text: "Deadline: " + model.deadline
                                        color: window.textMuted; font.pixelSize: 11
                                    }
                                }

                                // Badge status
                                Rectangle {
                                    width: statusBadge.implicitWidth + 12; height: 22; radius: 11
                                    color: model.isDone
                                           ? Qt.rgba(window.accentColor.r,
                                                     window.accentColor.g,
                                                     window.accentColor.b, 0.18)
                                           : Qt.rgba(window.textMuted.r,
                                                     window.textMuted.g,
                                                     window.textMuted.b, 0.15)
                                    border.color: model.isDone
                                                  ? Qt.rgba(window.accentColor.r,
                                                            window.accentColor.g,
                                                            window.accentColor.b, 0.5)
                                                  : window.borderColor
                                    border.width: 1
                                    Text {
                                        id: statusBadge
                                        anchors.centerIn: parent
                                        text: model.isDone
                                              ? "✓ " + lang.selesai
                                              : "· " + lang.pending
                                        color: model.isDone ? window.accentColor : window.textMuted
                                        font.pixelSize: 10; font.bold: true
                                    }
                                }
                            }
                        }
                    }

                    // Summary bar bawah — ikut bgCard + border tema
                    Rectangle {
                        Layout.fillWidth: true; height: 38
                        color: window.bgCard; radius: 10
                        border.color: window.borderColor; border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 0

                            // Selesai
                            Row {
                                spacing: 6
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: window.accentColor; opacity: 0.9
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: hitungTugasSelesai() + " " + lang.selesai
                                    color: window.accentColor
                                    font.pixelSize: 12; font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Pending
                            Row {
                                spacing: 6
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: window.textMuted; opacity: 0.7
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: hitungTugasPending() + " " + lang.pending
                                    color: window.textMuted
                                    font.pixelSize: 12; font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
