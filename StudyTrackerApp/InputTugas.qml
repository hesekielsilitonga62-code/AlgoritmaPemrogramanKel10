import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {
    id: inputTugasPage
    anchors.fill: parent
    color: window.bgPrimary

    property int editingIndex: -1

    // Tombol Kembali
    Button {
        id: backBtn
        text: "‹ " + lang.kembali
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
        z: 10
        onClicked: pageLoader.sourceComponent = mainComponent
        background: Rectangle { color: "transparent" }
        contentItem: Text { text: backBtn.text; color: window.accentColor; font.pixelSize: 18; font.bold: true }
    }

    // Kontainer Utama menggunakan Item agar anchors berfungsi
    Item {
        id: inputPage
        // Tambahkan baris ini agar dia bisa menerima kiriman model dari Main.qml
        property var taskModel: globalTaskModel
        anchors.fill: parent
        anchors.margins: 25
        anchors.topMargin: 70


        function sortTasksByDeadline() {
            // Ambil semua item ke array
            let items = []
            for (let i = 0; i < globalTaskModel.count; i++) {
                items.push(globalTaskModel.get(i))
            }

            // Sort berdasarkan deadlineTimestamp (ascending = paling dekat dulu)
            items.sort(function(a, b) {
                return a.deadlineTimestamp - b.deadlineTimestamp
            })

            // Tulis balik ke model
            globalTaskModel.clear()
            for (let j = 0; j < items.length; j++) {
                globalTaskModel.append(items[j])
            }
        }

        // --- HEADER ---
        RowLayout {
            id: headerSection
            width: parent.width
            height: 60

            Text {
                text: lang.daftarTugas
                color: window.textPrimary
                font.pixelSize: 24; font.bold: true
            }
            Item { Layout.fillWidth: true }
            Button {
                id: addBtn
                text: "+ " + lang.tambahTugas
                contentItem: Text { text: addBtn.text; color: "black"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: window.textPrimary; radius: 20 }
                onClicked: {
                        editingIndex = -1 // Pastikan index reset ke -1 (tambah baru)
                        titleInput.text = ""
                        addDialog.open()
                    }
            }
        }

        // --- LIST TUGAS ---
        ListView {
            id: taskListView
            anchors.top: headerSection.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 20
            spacing: 10
            model: globalTaskModel
            clip: true
            delegate: Rectangle {
                id: taskCard
                width: taskListView.width
                height: 70
                color: window.bgSecondary
                radius: 10
                opacity: model.isDone ? 0.4 : 1.0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // --- 1. KOTAK SELESAI (Kiri) ---
                    Rectangle {
                                id: checkBox
                                width: 30; height: 30; radius: 6 // Ukuran diperbesar sedikit agar mudah diklik
                                color: "transparent"
                                border.color: window.accentColor
                                border.width: 2
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "✔"
                                    anchors.centerIn: parent
                                    color: window.accentColor
                                    font.pixelSize: 18
                                    visible: model.isDone
                                }

                                // MouseArea diletakkan paling atas dengan z: 1
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Pastikan merujuk ke globalTaskModel secara langsung jika taskModel bermasalah
                                        globalTaskModel.setProperty(index, "isDone", !model.isDone)
                                    }
                                }
                            }
                    // --- INFO TUGAS ---
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: model.title
                                    color: window.textPrimary
                                    font.bold: true
                                    font.strikeout: model.isDone
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.deadline
                                    color: window.accentColor
                                    font.pixelSize: 12
                                }
                            }

                            // --- 2. IKON EDIT & HAPUS (Kanan) ---
                            Row {
                                spacing: 20
                                Layout.alignment: Qt.AlignVCenter

                                // Ikon Pensil (Edit)
                                Text {
                                    text: "✎"
                                    color: window.accentColor
                                    font.pixelSize: 20
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -10
                                            onClicked: {
                                                editingIndex = index
                                                titleInput.text = model.title
                                                addDialog.open()
                                            }
                                    }
                                }

                                // Ikon Silang (Hapus)
                                Text {
                                    text: "✕"
                                    color: "#ff4d4d"
                                    font.pixelSize: 20
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -10
                                        onClicked: {
                                            globalTaskModel.remove(index)// Menghapus dari list
                                        }
                                    }
                                }
                            }
                        }
                    }
        }
    }

    // --- POPUP TAMBAH / EDIT TUGAS ---
    Popup {
        id: addDialog

        // Pakai Overlay.overlay agar popup benar-benar center di atas ApplicationWindow
        parent: Overlay.overlay
        anchors.centerIn: parent

        width: Math.min(560, window.width * 0.88)
        height: Math.min(640, window.height * 0.88)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Reset field setiap kali popup dibuka
        onOpened: {
            // Kalender kembali ke hari ini jika tambah baru
            if (inputTugasPage.editingIndex === -1) {
                calendarInput.month = new Date().getMonth()
                calendarInput.year  = new Date().getFullYear()
                calendarInput.selectedDay = new Date().getDate()
                hourInput.text   = ""
                minuteInput.text = ""
                titleInput.text  = ""
            }
        }

        background: Rectangle {
            color: window.bgPrimary
            radius: 20
            border.color: window.borderColor
            border.width: 1.5
        }

        // ── Konten popup ──────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14

                // Judul popup
                Text {
                    text: inputTugasPage.editingIndex === -1 ? "📋 " + lang.tambahTugas : "✎ Edit Tugas"
                    color: window.textPrimary; font.bold: true; font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }

                // ── Kalender ──────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 300
                    color: window.bgSecondary
                    radius: 15
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        // Navigasi Bulan
                        RowLayout {
                            Layout.fillWidth: true
                            Button {
                                flat: true
                                contentItem: Text { text: "‹"; color: window.accentColor; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter }
                                onClicked: {
                                    if (calendarInput.month === 0) { calendarInput.year -= 1; calendarInput.month = 11 }
                                    else calendarInput.month -= 1
                                }
                            }
                            Text {
                                id: monthYearText
                                Layout.fillWidth: true
                                text: Qt.locale("id_ID").monthName(calendarInput.month) + " " + calendarInput.year
                                color: window.textPrimary; font.bold: true; horizontalAlignment: Text.AlignHCenter
                            }
                            Button {
                                flat: true
                                contentItem: Text { text: "›"; color: window.accentColor; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter }
                                onClicked: {
                                    if (calendarInput.month === 11) { calendarInput.year += 1; calendarInput.month = 0 }
                                    else calendarInput.month += 1
                                }
                            }
                        }

                        DayOfWeekRow {
                            Layout.fillWidth: true
                            locale: calendarInput.locale
                            delegate: Text {
                                text: model.shortName; color: window.textMuted
                                font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MonthGrid {
                            id: calendarInput
                            Layout.fillWidth: true; Layout.fillHeight: true

                            property int selectedDay: new Date().getDate()
                            property string selectedMonthName: monthYearText.text
                            month: new Date().getMonth()
                            year:  new Date().getFullYear()
                            locale: Qt.locale("id_ID")

                            delegate: Rectangle {
                                implicitWidth: 40; implicitHeight: 40; radius: width / 2
                                visible: model.month === calendarInput.month
                                color: model.day === calendarInput.selectedDay && model.month === calendarInput.month
                                       ? window.accentColor : "transparent"
                                Text {
                                    text: model.day; anchors.centerIn: parent
                                    color: model.day === calendarInput.selectedDay && model.month === calendarInput.month
                                           ? "black" : window.textPrimary
                                    font.bold: model.day === calendarInput.selectedDay
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        calendarInput.selectedDay = model.day
                                        calendarInput.selectedMonthName = monthYearText.text
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Input Judul ───────────────────────────────────────────
                TextField {
                    id: titleInput
                    Layout.fillWidth: true
                    placeholderText: lang.judulTugas + "..."
                    placeholderTextColor: window.textMuted
                    color: window.textPrimary
                    background: Rectangle { color: window.bgSecondary; radius: 10; border.color: window.borderColor }
                }

                // ── Input Jam:Menit ───────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Text { text: lang.deadline + " (HH:MM):"; color: window.textPrimary; font.pixelSize: 13 }
                    TextField {
                        id: hourInput; placeholderText: "00"; Layout.preferredWidth: 55
                        color: window.textPrimary; horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator { bottom: 0; top: 23 }
                        background: Rectangle { color: window.bgSecondary; radius: 8; border.color: window.borderColor }
                    }
                    Text { text: ":"; color: window.textPrimary; font.pixelSize: 18; font.bold: true }
                    TextField {
                        id: minuteInput; placeholderText: "00"; Layout.preferredWidth: 55
                        color: window.textPrimary; horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator { bottom: 0; top: 59 }
                        background: Rectangle { color: window.bgSecondary; radius: 8; border.color: window.borderColor }
                    }
                }

                // ── Pesan validasi ────────────────────────────────────────
                Text {
                    id: validasiMsg
                    visible: false
                    text: "⚠️ Judul tugas tidak boleh kosong!"
                    color: "#ff4444"; font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }

                // ── Tombol Simpan ─────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; height: 48; radius: 12
                    color: simpanArea.pressed ? Qt.darker(window.accentColor, 1.15) : window.accentColor
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: inputTugasPage.editingIndex === -1 ? "💾 " + lang.simpanTugas : "💾 Simpan Perubahan"
                        color: "#001b2e"; font.bold: true; font.pixelSize: 14
                    }

                    MouseArea {
                        id: simpanArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (titleInput.text.trim() === "") {
                                validasiMsg.visible = true
                                return
                            }
                            validasiMsg.visible = false

                            let hh = parseInt(hourInput.text)   || 0
                            let mm = parseInt(minuteInput.text) || 0
                            let selectedDate = new Date(
                                calendarInput.year, calendarInput.month, calendarInput.selectedDay, hh, mm
                            )
                            let taskData = {
                                "title":             titleInput.text.trim(),
                                "deadline":          calendarInput.selectedDay + " " + calendarInput.selectedMonthName
                                                     + " - " + String(hh).padStart(2,"0") + ":" + String(mm).padStart(2,"0"),
                                "deadlineTimestamp": selectedDate.getTime(),
                                "isDone":            false
                            }

                            if (inputTugasPage.editingIndex === -1) {
                                globalTaskModel.append(taskData)
                            } else {
                                globalTaskModel.set(inputTugasPage.editingIndex, taskData)
                                inputTugasPage.editingIndex = -1
                            }
                            var oldTitle = globalTaskModel.get(inputTugasPage.editingIndex).title
                            for (var key in window._notifiedTasks) {
                                if (key.indexOf(oldTitle + "_") === 0)
                                    delete window._notifiedTasks[key]
                            }

                            inputPage.sortTasksByDeadline()

                            // Tutup popup DULU, baru reset field
                            addDialog.close()
                        }
                    }
                }

                // ── Tombol Batal ──────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 12
                    color: batalArea.pressed ? window.borderColor : window.bgSecondary
                    border.color: window.borderColor; border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: lang.batal
                        color: window.textPrimary; font.bold: true; font.pixelSize: 14
                    }

                    MouseArea {
                        id: batalArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addDialog.close()
                    }
                }

                Item { height: 8 } // padding bawah
            }
        }

        // Reset field setelah popup benar-benar tertutup
        onClosed: {
            titleInput.text  = ""
            hourInput.text   = ""
            minuteInput.text = ""
            validasiMsg.visible = false
        }
    }
}