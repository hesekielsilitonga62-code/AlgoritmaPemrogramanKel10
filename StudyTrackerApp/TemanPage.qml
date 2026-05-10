import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    property string currentChatFriend:    ""
    property bool   currentFriendIsOnline: false

    // ── Helpers warna adaptif ────────────────────────────────────────────────
    readonly property color accentSoft:   Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.12)
    readonly property color accentBorder: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.35)
    readonly property color onlineColor:  Qt.rgba(0.18, 0.80, 0.44, 1.0)   // hijau online
    readonly property color offlineColor: Qt.rgba(window.textMuted.r, window.textMuted.g, window.textMuted.b, 0.55)

    // ── Chat helpers ─────────────────────────────────────────────────────────
    function getHistory(namaKey) {
        if (!chatHistories[namaKey]) chatHistories[namaKey] = []
        return chatHistories[namaKey]
    }
    function loadChatTo(listModel, namaKey) {
        listModel.clear()
        var hist = getHistory(namaKey)
        for (var i = 0; i < hist.length; i++) listModel.append(hist[i])
    }
    function sendMessage(pesan) {
        if (pesan.trim() === "") return
        var msg = { "sender": "Saya", "message": pesan, "isMe": true }
        getHistory(currentChatFriend).push(msg)
        currentChatModel.append(msg)
        if (currentFriendIsOnline) {
            aiResponseTimer.pendingResponse = getAiResponse(pesan)
            aiResponseTimer.restart()
        } else {
            var hist = getHistory(currentChatFriend)
            var sudahNotif = false
            for (var i = 0; i < hist.length; i++) {
                if (hist[i].sender === "Sistem") { sudahNotif = true; break }
            }
            if (!sudahNotif) {
                var offlineMsg = { "sender": "Sistem", "message": currentChatFriend + lang.pesanOffline, "isMe": false }
                getHistory(currentChatFriend).push(offlineMsg)
                currentChatModel.append(offlineMsg)
            }
        }
    }

    // ── Cek apakah user sudah jadi teman ────────────────────────────────────
    function sudahDiTambah(nama) {
        for (var i = 0; i < myFriendsModel.count; i++)
            if (myFriendsModel.get(i).name === nama) return true
        return false
    }

    function getAiResponse(pesan) {
        var input = pesan.toLowerCase()
        function pick(arr) { return arr[Math.floor(Math.random() * arr.length)] }
        if (input.match(/halo|hai|hi|hey|hei|hy|helo|pagi|siang|sore|malam|assalam|waalaikum/))
            return pick(["Halo halo! Lagi ngapain nih?","Hai! Tumben aktif, ada angin apa?","Yoo! Lagi santai atau lagi pusing?","Eh ada nih! Kabar gimana?","Heyy! Udah makan belum?","Hai jugaa~ lagi ngapain?","Yooo, ada apa nih?","Helo helo, siap dengerin cerita kamu!","Haiii, kangen juga diajak ngobrol haha","Eh baru nongol! Kemana aja?","Halo bestie, aku di sini kok!"])
        if (input.match(/kabar|gimana|apa kabar|baik|sehat|fine|good|how are/))
            return pick(["Alhamdulillah baik! Kamu sendiri?","Lumayan, lagi agak hectic. Kamu?","Baik-baik aja! Lagi nemenin kamu nih hehe","Sehat! Tapi ngantuk dikit, begadang kemaren haha","Alhamdulillah, semoga kamu juga baik ya!","Baik kok, makin baik karena ada kamu haha"])
        if (input.match(/tugas|deadline|kuliah|kampus|dosen|skripsi|makalah|laporan|ujian|uts|uas|kuis|presentasi|sidang/))
            return pick(["Aduh deadline lagi? Sabar ya, aku temeni!","Skripsi emang monster tersendiri, semangat!","Dosen killer? Sabar, nanti juga kelar kok.","Tugas numpuk? Mulai dari yang paling gampang dulu.","Ujian kapan? Udah belajar belum?","Deadline hari ini? Gas gas gas!","Santai, tugas sesulit apapun ada ujungnya."])
        if (input.match(/belajar|fokus|konsentrasi|nggak fokus|susah fokus|malas|males|mood|semangat|produktif/))
            return pick(["Mood belajar emang fluktuatif, coba istirahat 10 menit dulu.","Kalau males, mulai 5 menit aja. Nanti ngalir sendiri!","Fokus susah? Matiin notif dulu, kecuali chat aku haha.","Pomodoro aja, 25 menit fokus 5 menit rebahan.","Study with me yuk, aku temenin dari sini!","Produktif itu nggak harus 24 jam, yang penting konsisten."])
        if (input.match(/capek|lelah|exhausted|tired|kelelahan|burnout|penat|mumet|pusing|stress|stres|overwhelmed/))
            return pick(["Istirahat dulu boleh kok, kamu bukan robot!","Burnout itu nyata, jangan diremehkan.","Capek boleh, nyerah jangan. Tapi istirahat dulu.","Pusing? Tidur bentar, aku jagain kok hehe.","Kamu udah kerja keras banget, wajar capek.","Kamu nggak harus kuat terus kok.","Istirahat bukan kelemahan, itu kebutuhan!"])
        if (input.match(/galau|sedih|nangis|overthinking|insecure|down|patah hati|baper|kangen|rindu|kesepian|lonely/))
            return pick(["Mau cerita? Aku dengerin kok, serius.","Galau mah manusiawi, tapi jangan sendirian ya.","Kalau mau nangis ya nangis aja, nggak apa-apa.","Kamu nggak sendirian kok, aku di sini.","Yuk cerita, kadang ngeluarin isi kepala itu udah ngebantu.","Semua fase berat itu sementara, pasti lewat."])
        if (input.match(/makan|lapar|laper|nasi|mie|bakso|kopi|ngemil|jajan|boba|minum|haus|snack/))
            return pick(["Laper? Makan dulu gih, otak butuh bensin!","Kopi lagi? Hati-hati lambung ya!","Udah makan belum? Kalau belum, makan dulu yaa!","Sarapan dulu dong, penting banget itu!","Makan yang bener ya, jangan skip meal!"])
        if (input.match(/game|gacha|main|push rank|gaming|nonton|film|drama|anime|series|lagu|musik/))
            return pick(["Gacha lagi? Semoga nggak ampas ya haha","Gaming itu healing sah-sah aja, asal tau batasnya!","Nonton drama lagi? Spoiler dong wkwk","Anime apa yang lagi ditonton? Rekomenin dong!","Lagu apa yang lagi diulang-ulang nih?"])
        if (input.match(/tidur|begadang|ngantuk|bangun|susah tidur|insomnia|bobo|rebahan/))
            return pick(["Begadang lagi? Badan kamu protes lho!","Ngantuk tapi nggak bisa tidur? Matiin layar dulu.","Tidur yang cukup itu investasi kesehatan, serius!","Insomnia? Coba white noise atau ASMR.","Mimpi indah ya nanti!"])
        if (input.match(/motivasi|inspirasi|menyerah|give up|nyerah|putus asa|nggak bisa|gagal|fail/))
            return pick(["Jangan nyerah! Kamu udah sejauh ini, sayang banget!","Hari ini berat, tapi kamu lebih kuat!","Progress lebih penting dari perfection!","Gagal itu bukan akhir, itu pelajaran.","Kamu lebih capable dari yang kamu pikir!"])
        if (input.match(/makasih|thanks|terima kasih|thx|ty|baik banget|keren|mantap/))
            return pick(["Hehe sama-sama, seneng bisa nemenin!","Santai aja, itu udah tugasku kok wkwk","Makasih juga udah mau ngobrol sama aku!","Aww, kamu juga baik banget tau!"])
        if (input.match(/kamu siapa|lo siapa|bot|ai|robot|manusia|asli|beneran|virtual/))
            return pick(["Aku teman virtual kamu! Bukan manusia, tapi usahaku dengerin kamu itu nyata kok haha","Bot sih, tapi bot yang peduli sama kamu wkwk","AI yang udah dikasih jiwa gaul haha, keliatan nggak?"])
        if (input.match(/gabut|bosan|bored|boring|nganggur|sepi|jenuh/))
            return pick(["Gabut? Yuk ngobrol aja sama aku!","Bosen? Coba hal baru dong, belajar skill baru misalnya.","Sepi? Aku temenin kok, cerita aja."])
        if (input.match(/jam berapa|pukul|waktu|sekarang|tanggal|hari ini|hari apa/)) {
            var now = new Date()
            var days = ["Minggu","Senin","Selasa","Rabu","Kamis","Jumat","Sabtu"]
            var mins = now.getMinutes() < 10 ? "0" + now.getMinutes() : now.getMinutes()
            return pick(["Sekarang " + now.getHours() + ":" + mins + " nih! Ngapain jam segini? haha","Hari ini " + days[now.getDay()] + ", semangat ya!"])
        }
        return pick(["Ooh gitu! Cerita dong lebih lanjut.","Wkwk ada-ada aja kamu nih.","Hmm menarik, terus gimana?","Iya nih, aku setuju banget!","Wah baru tau aku soal itu haha, makasih!","Aduh relate banget itu!","Eh itu seru juga, lanjut lanjut!","Santai, semua ada jalannya kok.","Kamu gimana nanggepin itu?","Tetep semangat ya, aku support dari sini!","Percaya proses aja, nanti juga keliatan hasilnya.","Kamu udah maju jauh lho dari sebelumnya."])
    }

    // ── Models ───────────────────────────────────────────────────────────────
    ListModel { id: currentChatModel }
    ListModel { id: searchResultModel }

    Timer {
        id: aiResponseTimer
        interval: 1400
        property string pendingResponse: ""
        onTriggered: {
            var reply = { "sender": root.currentChatFriend, "message": pendingResponse, "isMe": false }
            root.getHistory(root.currentChatFriend).push(reply)
            currentChatModel.append(reply)
            if (!chatPopup.opened && window.notifTeman)
                window.lastFriendNotif = root.currentChatFriend + "||" + pendingResponse
        }
    }

    // ── Rebuild search results, filter yg sudah jadi teman ──────────────────
    function doSearch(txt) {
        searchResultModel.clear()
        if (txt.trim() === "") return
        for (var i = 0; i < allUsersModel.count; i++) {
            var u = allUsersModel.get(i)
            if (u.name.toLowerCase().indexOf(txt.toLowerCase()) !== -1 && !sudahDiTambah(u.name))
                searchResultModel.append({ "name": u.name, "status": u.status, "isOnline": u.isOnline, "initial": u.initial })
        }
    }

    // ── Ketika myFriendsModel berubah, refresh hasil search ─────────────────
    Connections {
        target: myFriendsModel
        function onCountChanged() { root.doSearch(searchInput.text) }
    }

    // ════════════════════════════════════════════════════════════════════════
    // LAYOUT UTAMA
    // ════════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 0

        // ── HEADER ───────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 24
            spacing: 16

            // Tombol kembali
            Rectangle {
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
                    id: backRow; anchors.centerIn: parent; spacing: 7
                    Text { text: "←"; color: backArea.containsMouse ? window.accentColor : window.textMuted; font.pixelSize: 15; font.bold: true; anchors.verticalCenter: parent.verticalCenter; Behavior on color { ColorAnimation { duration: 160 } } }
                    Text { text: lang.mainMenu; color: backArea.containsMouse ? window.accentColor : window.textMuted; font.pixelSize: 13; font.bold: true; anchors.verticalCenter: parent.verticalCenter; Behavior on color { ColorAnimation { duration: 160 } } }
                }
                MouseArea { id: backArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: pageLoader.sourceComponent = mainComponent }
            }

            // Divider
            Rectangle { width: 1; height: 22; color: window.borderColor; opacity: 0.5 }

            // Judul
            Column {
                spacing: 2
                Text { text: lang.teman; color: window.textPrimary; font.pixelSize: 26; font.bold: true }
                Text {
                    text: myFriendsModel.count + " " + lang.orang + " • " +
                          (function(){ var n=0; for(var i=0;i<myFriendsModel.count;i++) if(myFriendsModel.get(i).isOnline) n++; return n }()) + " " + lang.online
                    color: window.textMuted; font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            // Badge teman online
            Rectangle {
                width: onlineBadge.implicitWidth + 20; height: 30; radius: 15
                color: root.accentSoft
                border.color: root.accentBorder; border.width: 1
                Text {
                    id: onlineBadge
                    anchors.centerIn: parent
                    text: "🟢  " + (function(){ var n=0; for(var i=0;i<myFriendsModel.count;i++) if(myFriendsModel.get(i).isOnline) n++; return n }()) + " online"
                    color: window.accentColor; font.pixelSize: 11; font.bold: true
                }
            }
        }

        // ── SEARCH BAR ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 48; radius: 14
            color: window.bgSecondary
            border.color: searchInput.activeFocus ? window.accentColor : window.borderColor
            border.width:  searchInput.activeFocus ? 1.5 : 1
            Layout.bottomMargin: 10
            Behavior on border.color { ColorAnimation { duration: 180 } }

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 12; spacing: 10

                Text { text: "🔍"; font.pixelSize: 16; opacity: 0.7 }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: lang.cariPlaceholder
                    color: window.textPrimary; font.pixelSize: 14
                    background: Rectangle { color: "transparent" }
                    padding: 0

                    onTextChanged: root.doSearch(text)
                }

                // Tombol clear
                Rectangle {
                    width: 22; height: 22; radius: 11
                    color: clearArea.containsMouse ? window.borderColor : "transparent"
                    visible: searchInput.text !== ""
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "✕"; color: window.textMuted; font.pixelSize: 11; font.bold: true }
                    MouseArea { id: clearArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: searchInput.text = "" }
                }
            }
        }

        // ── LABEL STATUS SEARCH ───────────────────────────────────────────────
        Item {
            Layout.fillWidth: true; height: 24
            visible: searchInput.text !== ""
            Layout.bottomMargin: 6

            RowLayout {
                anchors.fill: parent; spacing: 8

                Rectangle {
                    width: 4; height: 14; radius: 2
                    color: searchResultModel.count === 0 ? "#ff6b6b" : window.accentColor
                }
                Text {
                    text: searchResultModel.count === 0
                          ? lang.userTidakDitemukan
                          : searchResultModel.count + " " + lang.hasilPencarian
                    color: searchResultModel.count === 0 ? "#ff6b6b" : window.textMuted
                    font.pixelSize: 12; font.italic: true
                }
            }
        }

        // ── SECTION LABEL ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            spacing: 8

            Rectangle { width: 4; height: 16; radius: 2; color: window.accentColor }
            Text {
                text: searchInput.text !== "" ? lang.hasilPencarian : lang.temanku
                color: window.textMuted; font.pixelSize: 11; font.bold: true
                font.letterSpacing: 1.2
            }
            Item { Layout.fillWidth: true }
        }

        // ── LIST UTAMA ────────────────────────────────────────────────────────
        ListView {
            id: friendListView
            Layout.fillWidth: true; Layout.fillHeight: true
            model: searchInput.text !== "" ? searchResultModel : myFriendsModel
            spacing: 10; clip: true

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            // Empty state
            Rectangle {
                anchors.centerIn: parent
                width: 260; height: 140; radius: 18
                color: root.accentSoft
                border.color: root.accentBorder; border.width: 1
                visible: friendListView.count === 0

                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text !== "" ? "🔍" : "👥"
                        font.pixelSize: 36; opacity: 0.5
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text !== ""
                              ? lang.userTidakDitemukan
                              : lang.cariTemanHint
                        color: window.textMuted; font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            delegate: Rectangle {
                id: delegateCard
                width: friendListView.width; height: 76
                radius: 16
                color: cardHover.containsMouse ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.06) : window.bgSecondary
                border.color: cardHover.containsMouse ? root.accentBorder : window.borderColor
                border.width: cardHover.containsMouse ? 1.5 : 1

                Behavior on color        { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Stripe kiri — hijau kalau online, muted kalau offline
                Rectangle {
                    width: 4; height: parent.height - 20; radius: 2
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    color: model.isOnline ? root.onlineColor : root.offlineColor
                    opacity: 0.8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18; anchors.rightMargin: 14
                    anchors.topMargin: 10; anchors.bottomMargin: 10
                    spacing: 14

                    // Avatar bulat
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.15)
                        border.color: model.isOnline ? root.onlineColor : window.borderColor
                        border.width: model.isOnline ? 2 : 1

                        Text {
                            anchors.centerIn: parent
                            text: model.initial
                            color: window.accentColor
                            font.bold: true; font.pixelSize: 20
                        }

                        // Dot status online
                        Rectangle {
                            width: 13; height: 13; radius: 7
                            color: model.isOnline ? root.onlineColor : root.offlineColor
                            border.color: window.bgSecondary; border.width: 2
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            anchors.rightMargin: -1; anchors.bottomMargin: -1

                            // Animasi ping kalau online
                            Rectangle {
                                anchors.centerIn: parent
                                width: 9; height: 9; radius: 5
                                color: "transparent"
                                border.color: root.onlineColor; border.width: 1.5
                                visible: model.isOnline
                                SequentialAnimation on scale {
                                    running: model.isOnline
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 1.8; duration: 1200; easing.type: Easing.OutQuad }
                                    NumberAnimation { from: 1.8; to: 1.0; duration: 0 }
                                    PauseAnimation { duration: 1800 }
                                }
                                SequentialAnimation on opacity {
                                    running: model.isOnline
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.8; to: 0.0; duration: 1200 }
                                    NumberAnimation { from: 0.0; to: 0.8; duration: 0 }
                                    PauseAnimation { duration: 1800 }
                                }
                            }
                        }
                    }

                    // Info nama & status
                    Column {
                        spacing: 4; Layout.fillWidth: true

                        Text {
                            text: model.name
                            color: window.textPrimary; font.bold: true; font.pixelSize: 15
                        }
                        Row {
                            spacing: 6
                            // Pill status online/offline
                            Rectangle {
                                width: statusPill.implicitWidth + 10; height: 16; radius: 8
                                color: model.isOnline
                                       ? Qt.rgba(0.18, 0.80, 0.44, 0.15)
                                       : Qt.rgba(window.textMuted.r, window.textMuted.g, window.textMuted.b, 0.12)
                                border.color: model.isOnline ? root.onlineColor : root.offlineColor
                                border.width: 1
                                Text {
                                    id: statusPill
                                    anchors.centerIn: parent
                                    text: model.isOnline ? lang.online : lang.offline
                                    color: model.isOnline ? root.onlineColor : root.offlineColor
                                    font.pixelSize: 9; font.bold: true
                                }
                            }
                            Text {
                                text: "· " + model.status
                                color: window.textMuted; font.pixelSize: 12
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, 180)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Tombol aksi
                    Row {
                        spacing: 8

                        // Tombol hapus (hanya di daftar teman, bukan hasil search)
                        Rectangle {
                            width: 34; height: 34; radius: 17
                            visible: searchInput.text === ""
                            color: removeArea.pressed
                                   ? Qt.rgba(1, 0.27, 0.27, 0.30)
                                   : removeArea.containsMouse
                                     ? Qt.rgba(1, 0.27, 0.27, 0.15)
                                     : Qt.rgba(1, 0.27, 0.27, 0.08)
                            border.color: Qt.rgba(1, 0.27, 0.27, 0.4); border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: "✕"; color: "#ff4444"; font.bold: true; font.pixelSize: 12 }
                            MouseArea { id: removeArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: myFriendsModel.remove(index) }
                        }

                        // Tombol Tambah (search mode) / Chat (teman mode)
                        Rectangle {
                            property bool isSearchMode: searchInput.text !== ""
                            width: actionLabel.implicitWidth + 24; height: 34; radius: 17

                            color: isSearchMode
                                   ? (actionArea.pressed ? Qt.darker(window.accentColor, 1.15) : window.accentColor)
                                   : (actionArea.pressed ? window.borderColor : root.accentSoft)

                            border.color: isSearchMode ? "transparent" : root.accentBorder
                            border.width: isSearchMode ? 0 : 1

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                anchors.centerIn: parent; spacing: 5
                                Text {
                                    text: parent.parent.isSearchMode ? "+" : "💬"
                                    color: parent.parent.isSearchMode ? window.bgDeep : window.accentColor
                                    font.pixelSize: parent.parent.isSearchMode ? 16 : 13
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    id: actionLabel
                                    text: parent.parent.isSearchMode ? lang.tambah : lang.chat
                                    color: parent.parent.isSearchMode ? window.bgDeep : window.accentColor
                                    font.pixelSize: 12; font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: actionArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                                onClicked: {
                                    if (parent.isSearchMode) {
                                        // Tambah teman — tidak perlu cek duplikat karena sudah difilter di search
                                        myFriendsModel.append({
                                            "name": model.name, "status": model.status,
                                            "isOnline": model.isOnline, "initial": model.initial
                                        })
                                        // doSearch otomatis terpanggil via Connections onCountChanged
                                    } else {
                                        root.currentChatFriend     = model.name
                                        root.currentFriendIsOnline = model.isOnline
                                        root.loadChatTo(currentChatModel, model.name)
                                        chatPopup.open()
                                    }
                                }
                            }
                        }
                    }
                }

                // Hover detector untuk seluruh kartu
                MouseArea {
                    id: cardHover; anchors.fill: parent
                    hoverEnabled: true; acceptedButtons: Qt.NoButton
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // POPUP CHAT — Redesigned
    // ════════════════════════════════════════════════════════════════════════
    Popup {
        id: chatPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 360; height: 520
        modal: true; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: msgInput.text = ""

        background: Rectangle {
            color: window.bgSecondary; radius: 18
            border.color: root.accentBorder; border.width: 1.5
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // ── Chat header ──────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 64; radius: 18
                // Hanya radius atas
                Rectangle { anchors.fill: parent; anchors.topMargin: 10; color: parent.color }
                color: window.bgCard
                border.color: window.borderColor; border.width: 0

                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12

                    // Avatar mini
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: root.accentSoft
                        border.color: root.currentFriendIsOnline ? root.onlineColor : window.borderColor
                        border.width: root.currentFriendIsOnline ? 2 : 1
                        Text {
                            anchors.centerIn: parent
                            text: root.currentChatFriend.length > 0 ? root.currentChatFriend[0].toUpperCase() : "?"
                            color: window.accentColor; font.bold: true; font.pixelSize: 16
                        }
                        // Dot online
                        Rectangle {
                            width: 10; height: 10; radius: 5
                            color: root.currentFriendIsOnline ? root.onlineColor : root.offlineColor
                            border.color: window.bgCard; border.width: 2
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                        }
                    }

                    Column {
                        spacing: 2; Layout.fillWidth: true
                        Text {
                            text: root.currentChatFriend
                            color: window.textPrimary; font.bold: true; font.pixelSize: 15
                        }
                        Text {
                            text: root.currentFriendIsOnline ? lang.online : lang.offline
                            color: root.currentFriendIsOnline ? root.onlineColor : root.offlineColor
                            font.pixelSize: 11
                        }
                    }

                    // Tombol tutup
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: closeArea.containsMouse ? window.borderColor : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✕"; color: window.textMuted; font.pixelSize: 11; font.bold: true }
                        MouseArea { id: closeArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: chatPopup.close() }
                    }
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: window.borderColor; opacity: 0.5 }

            // ── Pesan ────────────────────────────────────────────────────
            ListView {
                id: chatView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: currentChatModel
                clip: true; spacing: 6
                topMargin: 12; bottomMargin: 12
                leftMargin: 14; rightMargin: 14
                onCountChanged: Qt.callLater(function() { positionViewAtEnd() })

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Column {
                    width: chatView.width - 28
                    spacing: 3

                    // Pesan sistem (tengah)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: sysLbl.implicitWidth + 20; height: sysLbl.implicitHeight + 10
                        radius: 10; color: window.bgCard
                        border.color: window.borderColor; border.width: 1
                        visible: model.sender === "Sistem"
                        Text { id: sysLbl; anchors.centerIn: parent; text: model.message; color: window.textMuted; font.pixelSize: 11; font.italic: true; wrapMode: Text.WordWrap; width: Math.min(implicitWidth, chatView.width - 60) }
                    }

                    // Bubble chat
                    Row {
                        anchors.right: model.isMe ? parent.right : undefined
                        anchors.left:  model.isMe ? undefined : parent.left
                        visible: model.sender !== "Sistem"
                        spacing: 8

                        // Avatar kiri (hanya pesan teman)
                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: root.accentSoft; border.color: root.accentBorder; border.width: 1
                            visible: !model.isMe
                            anchors.bottom: parent.bottom
                            Text { anchors.centerIn: parent; text: root.currentChatFriend.length > 0 ? root.currentChatFriend[0].toUpperCase() : "?"; color: window.accentColor; font.pixelSize: 12; font.bold: true }
                        }

                        // Bubble
                        Rectangle {
                            width: Math.min(bubbleLbl.implicitWidth + 24, chatView.width * 0.70)
                            height: bubbleLbl.implicitHeight + 18
                            radius: model.isMe ? 16 : 16
                            topLeftRadius:     model.isMe ? 16 : 4
                            bottomRightRadius: model.isMe ? 4  : 16

                            color: model.isMe
                                   ? window.accentColor
                                   : window.bgCard
                            border.color: model.isMe ? "transparent" : window.borderColor
                            border.width: model.isMe ? 0 : 1

                            Text {
                                id: bubbleLbl
                                anchors.centerIn: parent
                                width: parent.width - 20
                                text: model.message
                                color: model.isMe ? window.bgDeep : window.textPrimary
                                wrapMode: Text.WordWrap; font.pixelSize: 13
                            }
                        }
                    }

                    // Label pengirim
                    Text {
                        text: model.sender === "Sistem" ? "" : model.sender
                        font.pixelSize: 9; color: window.textMuted
                        anchors.right: model.isMe ? parent.right : undefined
                        topPadding: 1
                        visible: model.sender !== "Sistem"
                    }
                }
            }

            // ── Input pesan ──────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 56
                color: window.bgCard
                // Radius bawah
                Rectangle { anchors.fill: parent; anchors.bottomMargin: 18; color: parent.color }
                radius: 0

                // Garis atas
                Rectangle { width: parent.width; height: 1; color: window.borderColor; opacity: 0.4 }

                RowLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 10

                    TextField {
                        id: msgInput
                        Layout.fillWidth: true
                        placeholderText: root.currentFriendIsOnline ? lang.ketikPesan : root.currentChatFriend + " " + lang.sedangOffline
                        color: window.textPrimary; font.pixelSize: 13
                        background: Rectangle {
                            color: window.bgSecondary; radius: 10
                            border.color: msgInput.activeFocus ? window.accentColor : window.borderColor
                            border.width: msgInput.activeFocus ? 1.5 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                        leftPadding: 14; rightPadding: 14
                        onAccepted: {
                            if (text.trim() !== "") { root.sendMessage(text.trim()); text = "" }
                        }
                    }

                    // Tombol kirim
                    Rectangle {
                        width: 38; height: 38; radius: 19
                        color: sendArea.pressed
                               ? Qt.darker(window.accentColor, 1.15)
                               : sendArea.containsMouse
                                 ? window.accentColor
                                 : root.accentSoft
                        border.color: root.accentBorder; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent; text: "↑"
                            color: sendArea.containsMouse ? window.bgDeep : window.accentColor
                            font.pixelSize: 16; font.bold: true
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        MouseArea {
                            id: sendArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                            onClicked: {
                                if (msgInput.text.trim() !== "") { root.sendMessage(msgInput.text.trim()); msgInput.text = "" }
                            }
                        }
                    }
                }
            }
        }
    }
}
