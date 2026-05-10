import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: inputTugasPage
    anchors.fill: parent
    color: window.bgPrimary

    property int editingIndex: -1

    // ── Background dekoratif ──────────────────────────────────────────────────
    Rectangle {
        width: 320; height: 320; radius: 160
        x: -80; y: -80
        color: window.accentColor
        opacity: 0.04
    }
    Rectangle {
        width: 200; height: 200; radius: 100
        anchors.right: parent.right; anchors.rightMargin: -60
        anchors.bottom: parent.bottom; anchors.bottomMargin: 100
        color: window.accentColor
        opacity: 0.04
    }

    // ── Header Bar ────────────────────────────────────────────────────────────
    Rectangle {
        id: headerBar
        width: parent.width
        height: 80
        color: "transparent"
        z: 10

        // Garis bawah header
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: window.borderColor
            opacity: 0.5
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 20
            anchors.topMargin: 20
            spacing: 12

            // Tombol kembali
            Rectangle {
                width: 40; height: 40; radius: 12
                color: backBtnArea.containsMouse ? window.bgSecondary : "transparent"
                border.color: backBtnArea.containsMouse ? window.borderColor : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: window.accentColor
                    font.pixelSize: 24; font.bold: true
                }
                MouseArea {
                    id: backBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pageLoader.sourceComponent = mainComponent
                }
            }

            // Emoji & judul
            Text { text: "📋"; font.pixelSize: 20 }
            Text {
                text: lang.daftarTugas
                color: window.textPrimary
                font.pixelSize: 20; font.bold: true
                Layout.fillWidth: true
            }

            // Badge jumlah tugas
            Rectangle {
                visible: globalTaskModel.count > 0
                width: taskCountBadge.width + 16; height: 28; radius: 14
                color: window.accentColor

                Text {
                    id: taskCountBadge
                    anchors.centerIn: parent
                    text: globalTaskModel.count + " " + lang.tugas
                    color: window.bgPrimary
                    font.pixelSize: 12; font.bold: true
                }
            }

            // Tombol Tambah Tugas
            Rectangle {
                width: addBtnContent.width + 28; height: 40; radius: 12
                color: addBtnArea.pressed ? Qt.darker(window.accentColor, 1.2)
                     : addBtnArea.containsMouse ? Qt.lighter(window.accentColor, 1.1) : window.accentColor
                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    id: addBtnContent
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "+"; color: window.bgPrimary; font.pixelSize: 18; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: lang.tambahTugas; color: window.bgPrimary; font.pixelSize: 13; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }

                MouseArea {
                    id: addBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        editingIndex = -1
                        addDialog.open()
                    }
                }
            }
        }
    }

    // ── Konten Utama ──────────────────────────────────────────────────────────
    Item {
        anchors.top: headerBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 16

        function sortTasksByDeadline() {
            let items = []
            for (let i = 0; i < globalTaskModel.count; i++) {
                let t = globalTaskModel.get(i)
                items.push({ title: t.title, deadline: t.deadline, deadlineTimestamp: t.deadlineTimestamp, isDone: t.isDone })
            }
            items.sort((a, b) => a.deadlineTimestamp - b.deadlineTimestamp)
            globalTaskModel.clear()
            for (let j = 0; j < items.length; j++) {
                globalTaskModel.append(items[j])
            }
        }

        // ── Empty State ───────────────────────────────────────────────────────
        Column {
            anchors.centerIn: parent
            spacing: 16
            visible: globalTaskModel.count === 0

            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🎯"; font.pixelSize: 56 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: lang.belumAdaTugas
                color: window.textPrimary; font.pixelSize: 20; font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: lang.yukTambahTugas
                color: window.textMuted; font.pixelSize: 14
            }
        }

        // ── Daftar Tugas ──────────────────────────────────────────────────────
        ListView {
            id: taskListView
            anchors.fill: parent
            spacing: 10
            model: globalTaskModel
            clip: true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: taskCard
                width: taskListView.width
                height: 80
                radius: 14
                color: cardArea.containsMouse && !model.isDone
                       ? Qt.lighter(window.bgSecondary, 1.08)
                       : window.bgSecondary
                opacity: model.isDone ? 0.5 : 1.0
                border.color: model.isDone ? "transparent"
                            : urgencyColor(model.deadlineTimestamp)
                border.width: model.isDone ? 0 : 1.5

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // Garis aksen kiri berwarna urgensi
                Rectangle {
                    width: 4; height: parent.height - 20; radius: 2
                    anchors.left: parent.left; anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: model.isDone ? window.textMuted : urgencyColor(model.deadlineTimestamp)
                    opacity: model.isDone ? 0.3 : 1
                    visible: !model.isDone
                }

                function urgencyColor(ts) {
                    if (ts === 0) return window.accentColor
                    let diff = ts - Date.now()
                    let hours = diff / 3600000
                    if (hours < 0)   return "#ff4d4d"
                    if (hours < 24)  return "#ff7043"
                    if (hours < 72)  return "#ffcc00"
                    return window.accentColor
                }

                MouseArea {
                    id: cardArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                // ── Checkbox (kiri, vertikal center) ──
                Rectangle {
                    id: checkboxRect
                    width: 28; height: 28; radius: 8
                    anchors.left: parent.left; anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: model.isDone ? window.accentColor : "transparent"
                    border.color: model.isDone ? window.accentColor : window.borderColor
                    border.width: 2
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✔"
                        color: window.bgPrimary
                        font.pixelSize: 14; font.bold: true
                        opacity: model.isDone ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalTaskModel.setProperty(index, "isDone", !model.isDone)
                    }
                }

                // ── Tombol Edit & Hapus (kanan atas) ──
                Row {
                    id: actionRow
                    spacing: 4
                    anchors.right: parent.right; anchors.rightMargin: 12
                    anchors.top: parent.top; anchors.topMargin: 10

                    Rectangle {
                        width: 32; height: 32; radius: 9
                        color: editHover.containsMouse ? window.bgPrimary : "transparent"
                        border.color: editHover.containsMouse ? window.borderColor : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✎"; color: window.accentColor; font.pixelSize: 16 }
                        MouseArea {
                            id: editHover
                            anchors.fill: parent; anchors.margins: -4
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                editingIndex = index
                                titleInput.text = model.title
                                if (model.deadlineTimestamp > 0) {
                                    var d = new Date(model.deadlineTimestamp)
                                    calendarInput.year  = d.getFullYear()
                                    calendarInput.month = d.getMonth()
                                    calendarInput.selectedDay = d.getDate()
                                    hourInput.text   = String(d.getHours()).padStart(2,"0")
                                    minuteInput.text = String(d.getMinutes()).padStart(2,"0")
                                }
                                addDialog.open()
                            }
                        }
                    }

                    Rectangle {
                        width: 32; height: 32; radius: 9
                        color: delHover.containsMouse ? "#ff4d4d22" : "transparent"
                        border.color: delHover.containsMouse ? "#ff4d4d55" : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✕"; color: "#ff4d4d"; font.pixelSize: 15; font.bold: true }
                        MouseArea {
                            id: delHover
                            anchors.fill: parent; anchors.margins: -4
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: globalTaskModel.remove(index)
                        }
                    }
                }

                // ── Info Tugas: judul atas, deadline bawah ──
                Column {
                    anchors.left: checkboxRect.right; anchors.leftMargin: 14
                    anchors.right: actionRow.left;    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        width: parent.width
                        text: model.title
                        color: model.isDone ? window.textMuted : window.textPrimary
                        font.pixelSize: 14; font.bold: true
                        font.strikeout: model.isDone
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: 5
                        Text { text: "🗓"; font.pixelSize: 11 }
                        Text {
                            text: model.deadline
                            color: model.isDone ? window.textMuted
                                 : taskCard.urgencyColor(model.deadlineTimestamp)
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    // ── POPUP TAMBAH / EDIT ───────────────────────────────────────────────────
    Popup {
        id: addDialog
        parent: Overlay.overlay
        anchors.centerIn: parent

        width:  Math.min(520, window.width  * 0.88)
        height: Math.min(620, window.height * 0.90)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 0.92; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        }

        background: Rectangle {
            color: window.bgPrimary
            radius: 22
            border.color: window.accentColor
            border.width: 1.5

            // Inner glow atas
            Rectangle {
                anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.6; height: 2; radius: 1
                color: window.accentColor; opacity: 0.6
            }
        }

        onOpened: {
            if (inputTugasPage.editingIndex === -1) {
                calendarInput.month       = new Date().getMonth()
                calendarInput.year        = new Date().getFullYear()
                calendarInput.selectedDay = new Date().getDate()
                hourInput.text   = ""
                minuteInput.text = ""
                titleInput.text  = ""
                validasiMsg.visible = false
            }
        }

        onClosed: {
            titleInput.text     = ""
            hourInput.text      = ""
            minuteInput.text    = ""
            validasiMsg.visible = false
            inputTugasPage.editingIndex = -1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            // ── Judul Popup ──
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Text {
                    text: inputTugasPage.editingIndex === -1 ? "📋" : "✎"
                    font.pixelSize: 20
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: inputTugasPage.editingIndex === -1 ? lang.tambahTugas : lang.editTugas
                    color: window.textPrimary; font.bold: true; font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ── Input Judul Tugas ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "📝 " + lang.judulTugas
                    color: window.textMuted; font.pixelSize: 12; font.bold: true
                }

                TextField {
                    id: titleInput
                    Layout.fillWidth: true
                    height: 44
                    placeholderText: lang.contohJudul
                    placeholderTextColor: window.textMuted
                    color: window.textPrimary
                    font.pixelSize: 14
                    leftPadding: 14
                    background: Rectangle {
                        color: titleInput.activeFocus ? window.bgSecondary : Qt.darker(window.bgSecondary, 1.1)
                        radius: 10
                        border.color: titleInput.activeFocus ? window.accentColor : window.borderColor
                        border.width: titleInput.activeFocus ? 1.5 : 1
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // ── Kalender ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "🗓 " + lang.pilihTanggalDetail
                    color: window.textMuted; font.pixelSize: 12; font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 260
                    color: window.bgSecondary
                    radius: 14
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        // Navigasi Bulan
                        RowLayout {
                            Layout.fillWidth: true
                            height: 36

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: prevMonArea.containsMouse ? window.bgPrimary : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Text { anchors.centerIn: parent; text: "‹"; color: window.accentColor; font.pixelSize: 20; font.bold: true }
                                MouseArea {
                                    id: prevMonArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (calendarInput.month === 0) { calendarInput.year -= 1; calendarInput.month = 11 }
                                        else calendarInput.month -= 1
                                    }
                                }
                            }

                            Text {
                                id: monthYearText
                                Layout.fillWidth: true
                                text: Qt.locale(
                                    window.selectedLanguage === "English"  ? "en_US" :
                                    window.selectedLanguage === "Japanese" ? "ja_JP" :
                                    window.selectedLanguage === "Korean"   ? "ko_KR" :
                                    window.selectedLanguage === "Arabic"   ? "ar_SA" : "id_ID"
                                ).monthName(calendarInput.month) + " " + calendarInput.year
                                color: window.textPrimary; font.bold: true; font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: nextMonArea.containsMouse ? window.bgPrimary : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Text { anchors.centerIn: parent; text: "›"; color: window.accentColor; font.pixelSize: 20; font.bold: true }
                                MouseArea {
                                    id: nextMonArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (calendarInput.month === 11) { calendarInput.year += 1; calendarInput.month = 0 }
                                        else calendarInput.month += 1
                                    }
                                }
                            }
                        }

                        // Nama Hari
                        DayOfWeekRow {
                            Layout.fillWidth: true
                            locale: calendarInput.locale
                            delegate: Text {
                                text: model.shortName
                                color: window.textMuted; font.pixelSize: 11; font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Grid Tanggal
                        MonthGrid {
                            id: calendarInput
                            Layout.fillWidth: true; Layout.fillHeight: true

                            property int selectedDay: new Date().getDate()
                            property string selectedMonthName: monthYearText.text

                            month: new Date().getMonth()
                            year:  new Date().getFullYear()
                            locale: Qt.locale(
                                window.selectedLanguage === "English"  ? "en_US" :
                                window.selectedLanguage === "Japanese" ? "ja_JP" :
                                window.selectedLanguage === "Korean"   ? "ko_KR" :
                                window.selectedLanguage === "Arabic"   ? "ar_SA" : "id_ID"
                            )

                            delegate: Rectangle {
                                implicitWidth: 34; implicitHeight: 34; radius: width / 2
                                visible: model.month === calendarInput.month

                                property bool isSelected: model.day === calendarInput.selectedDay && model.month === calendarInput.month
                                property bool isToday: {
                                    let now = new Date()
                                    return model.day === now.getDate() &&
                                           model.month === now.getMonth() &&
                                           model.year === now.getFullYear()
                                }

                                color: isSelected ? window.accentColor
                                     : dayArea.containsMouse ? window.bgPrimary : "transparent"
                                border.color: isToday && !isSelected ? window.accentColor : "transparent"
                                border.width: 1.5

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: model.day
                                    font.pixelSize: 12; font.bold: parent.isSelected || parent.isToday
                                    color: parent.isSelected ? window.bgPrimary : window.textPrimary
                                }
                                MouseArea {
                                    id: dayArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        calendarInput.selectedDay = model.day
                                        calendarInput.selectedMonthName = monthYearText.text
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Input Jam ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text { text: "⏰ " + lang.deadline + " :"; color: window.textMuted; font.pixelSize: 12; font.bold: true }

                Item { Layout.fillWidth: true }

                TextField {
                    id: hourInput
                    placeholderText: "00"; width: 60
                    color: window.textPrimary; font.pixelSize: 16; font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    validator: IntValidator { bottom: 0; top: 23 }
                    background: Rectangle {
                        color: hourInput.activeFocus ? window.bgSecondary : Qt.darker(window.bgSecondary, 1.1)
                        radius: 8
                        border.color: hourInput.activeFocus ? window.accentColor : window.borderColor
                        border.width: hourInput.activeFocus ? 1.5 : 1
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }
                Text { text: ":"; color: window.textPrimary; font.pixelSize: 20; font.bold: true }
                TextField {
                    id: minuteInput
                    placeholderText: "00"; width: 60
                    color: window.textPrimary; font.pixelSize: 16; font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    validator: IntValidator { bottom: 0; top: 59 }
                    background: Rectangle {
                        color: minuteInput.activeFocus ? window.bgSecondary : Qt.darker(window.bgSecondary, 1.1)
                        radius: 8
                        border.color: minuteInput.activeFocus ? window.accentColor : window.borderColor
                        border.width: minuteInput.activeFocus ? 1.5 : 1
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // ── Pesan Validasi ──
            Text {
                id: validasiMsg
                visible: false
                text: "⚠️ " + lang.judulTugas + " " + lang.tidakBolehKosong
                color: "#ff6b6b"; font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
            }

            // ── Tombol Simpan ──
            Rectangle {
                Layout.fillWidth: true; height: 48; radius: 14
                color: simpanArea.pressed ? Qt.darker(window.accentColor, 1.2)
                     : simpanArea.containsMouse ? Qt.lighter(window.accentColor, 1.08) : window.accentColor
                Behavior on color { ColorAnimation { duration: 120 } }

                // Efek shine
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left
                    width: parent.width * 0.5; height: parent.height * 0.5
                    color: "white"; opacity: 0.06; radius: parent.radius
                }

                Row {
                    anchors.centerIn: parent; spacing: 8
                    Text { text: "💾"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: inputTugasPage.editingIndex === -1 ? lang.simpanTugas : lang.simpanPerubahan
                        color: window.bgPrimary; font.bold: true; font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: simpanArea
                    anchors.fill: parent
                    hoverEnabled: true
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
                        // Fix: bangun nama bulan langsung dari locale saat simpan, jangan andalkan selectedMonthName
                        let calLocStr = window.selectedLanguage === "English"  ? "en_US"
                                      : window.selectedLanguage === "Japanese" ? "ja_JP"
                                      : window.selectedLanguage === "Korean"   ? "ko_KR"
                                      : window.selectedLanguage === "Arabic"   ? "ar_SA" : "id_ID"
                        let bulanStr = Qt.locale(calLocStr).monthName(calendarInput.month)
                        let deadlineStr = calendarInput.selectedDay + " " + bulanStr + " " + calendarInput.year
                                         + " - " + String(hh).padStart(2,"0") + ":" + String(mm).padStart(2,"0")
                        let taskData = {
                            "title":             titleInput.text.trim(),
                            "deadline":          deadlineStr,
                            "deadlineTimestamp": selectedDate.getTime(),
                            "isDone":            false
                        }

                        if (inputTugasPage.editingIndex === -1) {
                            globalTaskModel.append(taskData)
                        } else {
                            var oldTitle = globalTaskModel.get(inputTugasPage.editingIndex).title
                            for (var key in window._notifiedTasks) {
                                if (key.indexOf(oldTitle + "_") === 0)
                                    delete window._notifiedTasks[key]
                            }
                            globalTaskModel.set(inputTugasPage.editingIndex, taskData)
                        }

                        // Sort berdasarkan deadline
                        let items = []
                        for (let i = 0; i < globalTaskModel.count; i++) {
                            let t = globalTaskModel.get(i)
                            items.push({ title: t.title, deadline: t.deadline, deadlineTimestamp: t.deadlineTimestamp, isDone: t.isDone })
                        }
                        items.sort((a, b) => a.deadlineTimestamp - b.deadlineTimestamp)
                        globalTaskModel.clear()
                        for (let j = 0; j < items.length; j++) {
                            globalTaskModel.append(items[j])
                        }

                        addDialog.close()
                        // ← TIDAK ada pageLoader.sourceComponent = mainComponent di sini!
                    }
                }
            }

            // ── Tombol Batal ──
            Rectangle {
                Layout.fillWidth: true; height: 42; radius: 14
                color: batalArea.pressed ? window.borderColor
                     : batalArea.containsMouse ? Qt.lighter(window.bgSecondary, 1.1) : window.bgSecondary
                border.color: window.borderColor; border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: lang.batal
                    color: window.textPrimary; font.bold: true; font.pixelSize: 14
                }
                MouseArea {
                    id: batalArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: addDialog.close()
                }
            }
        }
    }
}
