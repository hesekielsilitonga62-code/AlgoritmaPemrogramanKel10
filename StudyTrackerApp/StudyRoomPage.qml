import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: studyRoomRoot
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    property var finalRankings: []

    function formatWaktu(detikTotal) {
        let jam   = Math.floor(detikTotal / 3600).toString().padStart(2, '0')
        let menit = Math.floor((detikTotal % 3600) / 60).toString().padStart(2, '0')
        let detik = (detikTotal % 60).toString().padStart(2, '0')
        return jam + ":" + menit + ":" + detik
    }

    function getIconByStatus(statusText, isMe) {
        if (isMe) return "✍️"
        let text = statusText ? statusText.toLowerCase() : ""
        if (text.includes("belajar") || text.includes("membaca")) return "📚"
        if (text.includes("menulis") || text.includes("tugas") || text.includes("laprak")) return "📝"
        if (text.includes("ngoding")) return "💻"
        if (text.includes("game") || text.includes("bermain")) return "🎮"
        if (text.includes("istirahat")) return "☕"
        if (text.includes("musik")) return "🎸"
        if (text.includes("melukis")) return "🎨"
        if (text.includes("olahraga")) return "👟"
        return "📖"
    }

    // ── Init hanya jika studyRoomFriendsModel belum diisi ───────────────────
    // Dengan begitu waktu NPC tidak reset saat user balik ke main menu lalu masuk lagi
    function initRoom() {
        if (studyRoomFriendsModel.count > 0) {
            // Sudah ada data, tidak perlu init ulang — waktu tetap lanjut
            updateRankings()
            return
        }
        // Pertama kali masuk: isi dari myFriendsModel yang online, max 9
        let count = 0
        for (let i = 0; i < myFriendsModel.count && count < 9; i++) {
            let f = myFriendsModel.get(i)
            if (f.isOnline) {
                studyRoomFriendsModel.append({
                    "userName":     f.name,
                    "status":       f.status,
                    "studySeconds": Math.floor(Math.random() * 7200) + 300,
                    "isMe":         false
                })
                count++
            }
        }
        updateRankings()
    }

    // ── Setiap detik globalStudyTimer trigger: update waktu NPC ─────────────
    Connections {
        target: globalStudyTimer
        function onTriggered() {
            for (let i = 0; i < studyRoomFriendsModel.count; i++) {
                if (Math.random() < 0.7) {
                    studyRoomFriendsModel.setProperty(
                        i, "studySeconds",
                        studyRoomFriendsModel.get(i).studySeconds + 1
                    )
                }
            }
            updateRankings()
        }
    }

    function updateRankings() {
        let temp = []
        temp.push({ "userName": lang.kamu, "totalSeconds": globalSeconds, "isMe": true, "status": "" })
        for (let i = 0; i < studyRoomFriendsModel.count; i++) {
            let f = studyRoomFriendsModel.get(i)
            temp.push({
                "userName":     f.userName,
                "totalSeconds": f.studySeconds,
                "isMe":         false,
                "status":       f.status
            })
        }
        temp.sort((a, b) => b.totalSeconds - a.totalSeconds)
        finalRankings = temp
    }

    Component.onCompleted: {
        initRoom()
        isStudying = true
    }

    // ─── UI ─────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // HEADER
        Rectangle {
            width: 100; height: 35; radius: 10; color: window.borderColor
            Text { text: "◀ " + lang.kembali; color: window.textPrimary; anchors.centerIn: parent; font.bold: true }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    isStudying = false
                    pageLoader.sourceComponent = mainComponent
                }
            }
        }

        // DAFTAR TUGAS (hanya yang belum selesai)
        ListView {
            id: miniTaskList
            Layout.fillWidth: true

            // Hitung jumlah tugas yang belum selesai
            property int pendingCount: {
                let n = 0
                for (let i = 0; i < globalTaskModel.count; i++)
                    if (!globalTaskModel.get(i).isDone) n++
                return n
            }

            Layout.preferredHeight: pendingCount === 0 ? 40 : Math.min(contentHeight, 120)
            model: globalTaskModel
            spacing: 6; clip: true

            Text {
                text: lang.belumAdaTugas
                color: window.textMuted; font.pixelSize: 14
                anchors.centerIn: parent
                visible: miniTaskList.pendingCount === 0
            }

            delegate: Rectangle {
                width: miniTaskList.width
                // Kalau sudah selesai: height 0 + spacing 0 → tidak makan tempat
                height: model.isDone ? 0 : 36
                visible: !model.isDone
                color: window.bgSecondary; radius: 8
                clip: true
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Text { text: model.title; color: window.textPrimary; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: model.deadline; color: window.accentColor; font.pixelSize: 10 }
                }
            }
        }

        // TIMER SESI
        Rectangle {
            Layout.fillWidth: true; height: 90
            color: window.bgSecondary; radius: 15; border.color: window.borderColor; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 4
                Text {
                    text: lang.waktuBelajarSesi
                    color: window.textMuted; font.pixelSize: 11; font.letterSpacing: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: formatWaktu(globalSeconds)
                    color: window.textMuted; font.pixelSize: 38; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // GRID TEMAN
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: window.bgSecondary; radius: 15; border.color: window.borderColor

            Text {
                text: lang.temanDiRoom + " (" + studyRoomFriendsModel.count + " " + lang.online + ")"
                color: window.textMuted; font.pixelSize: 9
                anchors { top: parent.top; left: parent.left; margins: 12 }
            }

            GridLayout {
                anchors.fill: parent; anchors.margins: 20; anchors.topMargin: 30
                columns: 5; columnSpacing: 10; rowSpacing: 15

                // Slot "Kamu" selalu tampil di posisi pertama
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 4
                    Rectangle {
                        width: 48; height: 48; radius: 24; color: window.accentColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { anchors.centerIn: parent; text: "✍️"; font.pixelSize: 22 }
                    }
                    Text { text: lang.kamu; color: window.accentColor; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: formatWaktu(globalSeconds); color: window.accentColor; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }

                // Slot NPC dari studyRoomFriendsModel (max 9)
                Repeater {
                    model: studyRoomFriendsModel
                    delegate: Column {
                        Layout.alignment: Qt.AlignHCenter; spacing: 4
                        Rectangle {
                            width: 48; height: 48; radius: 24; color: window.borderColor
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text { anchors.centerIn: parent; text: getIconByStatus(model.status, false); font.pixelSize: 22 }
                        }
                        Text { text: model.userName; color: window.textPrimary; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: formatWaktu(model.studySeconds); color: window.accentColor; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }
        }

        // PODIUM TOP 3
        Rectangle {
            Layout.fillWidth: true; height: 160
            color: window.bgSecondary; radius: 15; border.color: window.borderColor

            Text {
                text: "🏆 " + lang.peringkatSesi
                color: window.textMuted; font.pixelSize: 11
                anchors { top: parent.top; left: parent.left; margins: 12 }
            }

            // Urutan visual: 2 - 1 - 3 (tengah lebih tinggi)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                spacing: 30

                Repeater {
                    model: [1, 0, 2]   // index ke finalRankings
                    delegate: Column {
                        spacing: 4
                        // Tinggi kolom podium berbeda: juara 1 lebih tinggi
                        bottomPadding: modelData === 0 ? 0 : (modelData === 1 ? 10 : 20)

                        // ── NAMA di atas ──
                        Text {
                            text: finalRankings.length > modelData
                                  ? finalRankings[modelData].userName : "-"
                            color: modelData === 0 ? window.accentColor : window.textPrimary
                            font.pixelSize: 12
                            font.bold: finalRankings.length > modelData && finalRankings[modelData].isMe
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // ── WAKTU di bawah nama ──
                        Text {
                            text: finalRankings.length > modelData
                                  ? formatWaktu(finalRankings[modelData].totalSeconds) : ""
                            color: window.textMuted; font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // ── LINGKARAN ANGKA ──
                        Rectangle {
                            width: modelData === 0 ? 60 : 46
                            height: width; radius: width / 2
                            color: modelData === 0 ? window.accentColor
                                 : modelData === 1 ? "#c0c0c0" : "#cd7f32"
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                text: modelData + 1
                                font.bold: true
                                font.pixelSize: modelData === 0 ? 22 : 16
                                anchors.centerIn: parent
                                color: "#222"
                            }
                        }
                    }
                }
            }
        }
    }
}
