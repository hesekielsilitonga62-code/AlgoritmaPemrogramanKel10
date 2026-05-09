import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

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

    // ── Komponen kartu statistik kecil ──────────────────────────────────────
    component StatCard : Rectangle {
        property string label: ""
        property string nilai: ""
        property string ikon: ""
        property string warnaIkon: window.accentColor

        height: 90
        color: "#0a2a43"
        radius: 14
        border.color: "#163e5f"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                width: 48; height: 48; radius: 12
                color: Qt.rgba(255/255, 204/255, 0/255, 0.12)
                Text {
                    anchors.centerIn: parent
                    text: ikon; font.pixelSize: 24
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
                    color: window.textMuted; font.pixelSize: 12
                }
            }
        }
    }

    // ── Komponen progress bar ────────────────────────────────────────────────
    component ProgressRow : Column {
        property string label: ""
        property int persen: 0
        property string warnaBar: window.accentColor

        spacing: 6
        Layout.fillWidth: true

        RowLayout {
            width: parent.width
            Text { text: parent.parent.label; color: window.textPrimary; font.pixelSize: 13; Layout.fillWidth: true }
            Text { text: parent.parent.persen + "%"; color: window.accentColor; font.pixelSize: 13; font.bold: true }
        }

        Rectangle {
            width: parent.width; height: 8; radius: 4; color: window.borderColor
            Rectangle {
                width: parent.parent.persen > 0 ? parent.width * (parent.parent.persen / 100) : 0
                height: 8; radius: 4; color: parent.parent.warnaBar
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
        }
    }

    // ─── LAYOUT ──────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 20

        // HEADER
        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                width: 120; height: 38; radius: 10; color: window.borderColor
                Text { text: "◀ " + lang.mainMenu; color: window.textPrimary; font.bold: true; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: pageLoader.sourceComponent = mainComponent
                    onPressed:  parent.opacity = 0.7
                    onReleased: parent.opacity = 1.0
                }
            }

            Item { Layout.fillWidth: true }

            Column {
                spacing: 2
                Text { text: lang.statistik; color: window.textPrimary; font.pixelSize: 28; font.bold: true; horizontalAlignment: Text.AlignRight }
                Text { text: lang.ringkasanAktivitas; color: window.textMuted; font.pixelSize: 13; horizontalAlignment: Text.AlignRight }

            }
        }

        // ── BARIS 1: 4 kartu ringkasan ──────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 4; columnSpacing: 14; rowSpacing: 14
            StatCard { Layout.fillWidth: true; ikon: "⏱️"; label: lang.totalWaktuBelajar;    nilai: formatWaktu(globalSeconds) }
            StatCard { Layout.fillWidth: true; ikon: "🍅"; label: lang.sesiPomodoroSelesai;  nilai: globalSessionsCompleted + " / " + globalTargetSessions }
            StatCard { Layout.fillWidth: true; ikon: "✅"; label: lang.tugasSelesaiLabel;    nilai: hitungTugasSelesai() + " " + lang.tugas.toLowerCase() }
            StatCard { Layout.fillWidth: true; ikon: "👥"; label: lang.temanDitambahkan;     nilai: myFriendsModel.count + " " + lang.orang }
        }

        // ── BARIS 2: Progress + Daftar Tugas ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // Panel kiri: Progress
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.42
                color: window.bgSecondary; radius: 14; border.color: window.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 18

                    Text {
                        text: + lang.progressHariIni;
                        color: window.textPrimary; font.pixelSize: 15; font.bold: true
                    }

                    // Progress Pomodoro
                    ProgressRow {
                        Layout.fillWidth: true
                        label: lang.targetSesiHarian
                        persen: persenSesi()
                        warnaBar: "#2ecc71"
                    }

                    // Progress Tugas
                    ProgressRow {
                        Layout.fillWidth: true
                        label: lang.penyelesaianTugas
                        persen: persenTugas()
                        warnaBar: "#ffcc00"
                    }

                    // Waktu fokus vs total
                    ProgressRow {
                        Layout.fillWidth: true
                        label: lang.waktuFokusPomodoro
                        persen: globalSeconds > 0
                                ? Math.min(Math.round((globalSecondsFocused / globalSeconds) * 100), 100)
                                : 0
                        warnaBar: "#3498db"
                    }

                    Item { Layout.fillHeight: true }

                    // Motivasi kecil di bawah
                    Rectangle {
                        Layout.fillWidth: true; height: 50
                        color: Qt.rgba(255/255, 204/255, 0/255, 0.08)
                        radius: 10; border.color: Qt.rgba(255/255, 204/255, 0/255, 0.2)

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 20
                            text: globalSeconds < 1800 ? lang.motivasiAwal
                                    : globalSeconds < 7200 ? lang.motivasiTengah
                                    : lang.motivasiAkhir
                            color: "#ffcc00"; font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Panel kanan: Daftar tugas
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: window.bgSecondary; radius: 14; border.color: window.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "📋 " + lang.daftarTugas; color: window.textPrimary; font.pixelSize: 15; font.bold: true; Layout.fillWidth: true }
                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: Qt.rgba(255/255, 204/255, 0/255, 0.15)
                            Text {
                                anchors.centerIn: parent
                                text: globalTaskModel.count
                                color: window.accentColor; font.bold: true; font.pixelSize: 13
                            }
                        }
                    }

                    // Jika tidak ada tugas
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: globalTaskModel.count === 0
                        Column {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "📭"; font.pixelSize: 36; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: lang.belumAdaTugas; color: window.textMuted; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: globalTaskModel
                        spacing: 8; clip: true
                        visible: globalTaskModel.count > 0

                        delegate: Rectangle {
                            width: ListView.view.width; height: 56
                            radius: 10
                            color: model.isDone ? Qt.rgba(46/255, 204/255, 113/255, 0.1)
                                                : window.bgCard
                            border.color: model.isDone ? "#2ecc71" : "#163e5f"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 10

                                // Status dot
                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: model.isDone ? "#2ecc71" : "#f39c12"
                                }

                                Column {
                                    spacing: 2; Layout.fillWidth: true
                                    Text {
                                        text: model.title
                                        color: model.isDone ? window.textMuted : window.textPrimary
                                        font.pixelSize: 14; font.bold: !model.isDone
                                        font.strikeout: model.isDone
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: "Deadline: " + model.deadline
                                        color: window.textMuted; font.pixelSize: 11
                                    }
                                }

                                Text {
                                    text: model.isDone ? "✅ " + lang.selesai : "⏳ " + lang.pending
                                    color: model.isDone ? "#2ecc71" : "#f39c12"
                                    font.pixelSize: 11; font.bold: true
                                }
                            }
                        }
                    }

                    // Summary bawah
                    Rectangle {
                        Layout.fillWidth: true; height: 36
                        color: "#051624"; radius: 8
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10
                            Text { text: "✅ " + hitungTugasSelesai() + " " + lang.selesai; color: "#2ecc71"; font.pixelSize: 12; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Text { text: "⏳ " + hitungTugasPending() + " " + lang.pending; color: "#f39c12"; font.pixelSize: 12; font.bold: true }
                        }
                    }
                }
            }
        }
    }
}
