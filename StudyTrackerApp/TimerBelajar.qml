import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: timerPage
    anchors.fill: parent
    color: window.bgPrimary

    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    function updateClosestTask() {
        if (typeof globalTaskModel === "undefined" || globalTaskModel.count === 0)
            return lang.belumAdaTugas

        var closest = null
        for (var i = 0; i < globalTaskModel.count; i++) {
            var task = globalTaskModel.get(i)
            if (!task.isDone) {
                if (closest === null || task.deadlineTimestamp < closest.deadlineTimestamp) {
                    closest = task
                }
            }
        }

        if (closest === null) return lang.semuaTugasSelesai
        return closest.title + "\n📅 " + closest.deadline
    }

    function handleStart() {
        if (!window.globalTimerRunning && window.globalCurrentTimerValue === 0) {
            let h = parseInt(hIn.text) || 0
            let m = parseInt(mIn.text) || 0
            let s = parseInt(sIn.text) || 0
            let total = (h * 3600) + (m * 60) + s
            window.globalCurrentTimerValue = total
        }
        if (window.globalCurrentTimerValue > 0) window.globalTimerRunning = true
    }

        function handleStop() {
            window.globalTimerRunning = false
        }

        function handleSkip() {
            window.globalTimerRunning = false
            window.globalCurrentTimerValue = 0
            window.globalSessionsCompleted++
        }

    // --- MAIN LAYOUT ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 10

        // 1. HEADER (Dibersihkan agar tidak double)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            Text {
                text: lang.timer
                color: window.textPrimary
                font.pixelSize: 28; font.bold: true
            }
            Item { Layout.fillWidth: true } // Spacer
        }

        // 2. CONTENT AREA (Timer & Statistik)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 40

            // SISI KIRI: TIMER & TUGAS
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 20

                // Lingkaran Timer
                Rectangle {
                    width: 320; height: 320
                    Layout.preferredWidth: 320; Layout.preferredHeight: 320
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: "#00ffcc"
                        border.width: 10

                        SequentialAnimation on scale {
                            running: window.globalTimerRunning; loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 1.03; duration: 1000; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.03; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: window.formatTime(window.globalCurrentTimerValue)
                        color: window.textPrimary
                        font.pixelSize: 56; font.bold: true
                    }
                }

                // Controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    TextField { id: hIn; placeholderText: lang.jam[0].toUpperCase(); width: 45; color: window.textPrimary; horizontalAlignment: TextInput.AlignHCenter
                        background: Rectangle { color: window.bgSecondary; radius: 5 }
                        onTextChanged: {
                                if (!isRunning) {
                                    currentTimerValue = (parseInt(hIn.text||0)*3600) +
                                                       (parseInt(mIn.text||0)*60) +
                                                       parseInt(sIn.text||0)
                                }
                            }
                    }
                    TextField { id: mIn; placeholderText: lang.menit[0].toUpperCase(); width: 45; color: window.textPrimary; horizontalAlignment: TextInput.AlignHCenter
                        background: Rectangle { color: window.bgSecondary; radius: 5 }
                        onTextChanged: {
                                if (!isRunning) {
                                    currentTimerValue = (parseInt(hIn.text||0)*3600) +
                                                       (parseInt(mIn.text||0)*60) +
                                                       parseInt(sIn.text||0)
                                }
                            }
                    }
                    TextField { id: sIn; placeholderText: lang.detik[0].toUpperCase(); width: 45; color: window.textPrimary; horizontalAlignment: TextInput.AlignHCenter
                        background: Rectangle { color: window.bgSecondary; radius: 5 }
                        onTextChanged: {
                                if (!isRunning) {
                                    currentTimerValue = (parseInt(hIn.text||0)*3600) +
                                                       (parseInt(mIn.text||0)*60) +
                                                       parseInt(sIn.text||0)
                                }
                            }
                    }

                    Button { text: lang.mulaiSesi;  onClicked: handleStart() }
                    Button { text: lang.stopTimer;  onClicked: handleStop()  }
                    Button { text: lang.skipTimer;  onClicked: handleSkip()  }
                    }

                // Tugas Terdekat (Dinaikkan posisinya)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Text { text: lang.tugasTerdekat; color: window.textMuted; font.pixelSize: 13 }
                    Button {
                        id: taskBtn
                        Layout.fillWidth: true; Layout.preferredHeight: 45
                        text: (globalTaskModel.count >= 0) ? updateClosestTask() : ""
                        onClicked: {
                            pageLoader.source = "InputTugas.qml"
                        }
                        background: Rectangle { color: "#2d3436"; radius: 8 }
                        contentItem: Text { text: taskBtn.text; color: window.textPrimary; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // SISI KANAN: STATISTIK
            ColumnLayout {
                Layout.preferredWidth: 320
                spacing: 15

                // ── Kartu Pengingat Istirahat (dari Settings Pomodoro) ──────────
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 12
                    color: window.bgSecondary; border.color: window.accentColor; border.width: 1

                    // Animasi border berkedip saat timer jalan menandakan "segera istirahat"
                    SequentialAnimation on border.width {
                        running: window.globalTimerRunning
                        loops: Animation.Infinite
                        NumberAnimation { from: 1; to: 2.5; duration: 900 }
                        NumberAnimation { from: 2.5; to: 1; duration: 900 }
                    }

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10

                        // Ikon tomat berputar pelan saat timer jalan
                        Text {
                            text: "🍅"
                            font.pixelSize: 30

                            RotationAnimation on rotation {
                                running: window.globalTimerRunning
                                loops: Animation.Infinite
                                from: -8; to: 8; duration: 1200
                                easing.type: Easing.InOutSine
                            }
                            // Reset ke posisi normal saat berhenti
                            onVisibleChanged: if (!window.globalTimerRunning) rotation = 0
                        }

                        Column {
                            spacing: 4; Layout.fillWidth: true

                            Text { text: lang.waktuIstirahat;  color: window.textMuted; font.pixelSize: 11 }
                            Text { text: window.pomodoroIstirahat + " " + lang.menit; color: window.accentColor; font.pixelSize: 24; font.bold: true }
                            Text { text: window.pomodoroFokus + " " + lang.menit + " · " + window.pomodoroIstirahat + " " + lang.menit; color: Qt.lighter(window.borderColor, 1.5); font.pixelSize: 10 }
                        }
                }

                    // Tooltip kecil di pojok kanan atas
                    Rectangle {
                        anchors.top: parent.top; anchors.right: parent.right
                        anchors.margins: 6
                        width: settingsBadge.implicitWidth + 10; height: 16; radius: 8
                        color: Qt.rgba(255/255,204/255,0/255,0.15)
                        border.color: window.accentColor; border.width: 1
                        Text {
                            id: settingsBadge
                            anchors.centerIn: parent
                            text: lang.dariSettings
                            color: window.accentColor; font.pixelSize: 8; font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: pageLoader.sourceComponent = settingsComponent
                        }
                    }
                }

                // Kotak-kotak info
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 12; color: window.textPrimary
                    Column { anchors.centerIn: parent;
                        Text { text: lang.targetSesiHarian; font.pixelSize: 12; color: "#666"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: window.globalSessionsCompleted + " / " + window.globalTargetSessions; font.pixelSize: 28; font.bold: true; color: "black" }
                    }
                }

                TextField {
                    id: targetInput
                        // 1. Ambil nilai awal dari global
                        text: window.globalTargetSessions.toString()
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: window.textPrimary

                        // Memberi batasan hanya angka
                        validator: IntValidator { bottom: 1; top: 99 }

                        background: Rectangle { color: window.bgSecondary; radius: 8 }

                        // 2. Simpan ke global setiap kali teks berubah
                        onTextChanged: {
                            let val = parseInt(text)
                            if (!isNaN(val)) {
                                window.globalTargetSessions = val
                            }
                        }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 12; color: window.textPrimary
                    Column { anchors.centerIn: parent;
                        Text { text: lang.totalFokus; font.pixelSize: 12; color: "#666"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: Math.floor(window.globalSecondsFocused/3600)+lang.jam[0] + " "+Math.floor((window.globalSecondsFocused%3600)/60)+"m"; font.pixelSize: 24; font.bold: true; color: "black" }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 100; radius: 12; color: window.textPrimary
                    RowLayout {
                        anchors.centerIn: parent; spacing: 10

                        Text {
                            id: fireEmoji
                            text: "🔥"
                            font.pixelSize: 32
                            // Animasi membesar-mengecil saat timer jalan
                            scale: window.globalTimerRunning ? 1.0 : 0.8
                            opacity: window.globalTimerRunning ? 1.0 : 0.3

                            Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

                            // Menambahkan animasi denyut (pulsing) jika sedang fokus
                            SequentialAnimation on scale {
                                running: window.globalTimerRunning
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 1.0; to: 1.2; duration: 800; easing.type: Easing.InOutBack }
                                        NumberAnimation { from: 1.2; to: 1.0; duration: 800; easing.type: Easing.InOutBack }
                            }
                        }

                        Column {
                            Text {
                                text: window.globalTimerRunning ? lang.fokusAktif : lang.mulaiSesi
                                font.bold: true
                                color: window.globalTimerRunning ? "#e67e22" : "black"
                            }
                            Text {
                                text: window.globalTimerRunning ? lang.fokusSubAktif : lang.fokusSubIdle
                                color: window.globalTimerRunning ? "green" : "#95a5a6"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }

        // 3. FOOTER (Tombol Kembali)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            Button {
                anchors.centerIn: parent
                onClicked: pageLoader.sourceComponent = mainComponent
                contentItem: Text { text: lang.kembaliKeMenu; color: "black"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                background: Rectangle { implicitWidth: 200; implicitHeight: 40; color: window.accentColor; radius: 20 }
            }
        }
    }

    Component.onCompleted: {
        // Jalankan sekali saat awal
        taskBtn.text = updateClosestTask()

        // Jalankan setiap kali ada data di model yang berubah (tambah, hapus, atau centang selesai)
        globalTaskModel.dataChanged.connect(function() {
            taskBtn.text = updateClosestTask()
        })
        globalTaskModel.rowsInserted.connect(function() {
            taskBtn.text = updateClosestTask()
        })
        globalTaskModel.rowsRemoved.connect(function() {
            taskBtn.text = updateClosestTask()
        })
    }
}