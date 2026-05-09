import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: window.bgPrimary

    property string currentChatFriend: ""
    property bool   currentFriendIsOnline: false

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
            // Notif offline hanya sekali per teman
            var hist = getHistory(currentChatFriend)
            var sudahNotif = false
            for (var i = 0; i < hist.length; i++) {
                if (hist[i].sender === "Sistem") { sudahNotif = true; break }
            }
            if (!sudahNotif) {
                var offlineMsg = {
                    "sender":  "Sistem",
                    "message": currentChatFriend + lang.pesanOffline,
                    "isMe":    false
                }
                getHistory(currentChatFriend).push(offlineMsg)
                currentChatModel.append(offlineMsg)
            }
        }
    }

    function getAiResponse(pesan) {
        var input = pesan.toLowerCase()

        function pick(arr) { return arr[Math.floor(Math.random() * arr.length)] }

        // ── SAPAAN ──
        if (input.match(/halo|hai|hi|hey|hei|hy|helo|pagi|siang|sore|malam|assalam|waalaikum/))
            return pick([
                "Halo halo! Lagi ngapain nih?", "Hai! Tumben aktif, ada angin apa?",
                "Yoo! Lagi santai atau lagi pusing?", "Eh ada nih! Kabar gimana?",
                "Heyy! Udah makan belum?", "Waalaikumsalam! Apa kabar?",
                "Hai jugaa~ lagi ngapain?", "Yooo, ada apa nih?",
                "Helo helo, siap dengerin cerita kamu!", "Haiii, kangen juga diajak ngobrol haha",
                "Eh baru nongol! Kemana aja?", "Halo bestie, aku di sini kok!",
                "Yooo lama nggak ngobrol!", "Hai hai, semoga harimu menyenangkan ya!",
                "Heyy, aku udah nungguin kamu nih haha"
            ])

        // ── KABAR ──
        if (input.match(/kabar|gimana|apa kabar|baik|sehat|fine|good|how are/))
            return pick([
                "Alhamdulillah baik! Kamu sendiri?", "Lumayan, lagi agak hectic. Kamu?",
                "Baik-baik aja! Lagi nemenin kamu nih hehe", "Fine fine, biasa aja. Eh kamu gimana?",
                "Sehat! Tapi ngantuk dikit, begadang kemaren haha", "Alhamdulillah, semoga kamu juga baik ya!",
                "Baik kok, makin baik karena ada kamu haha", "Lumayan lah, hari ini agak santai.",
                "Baik! Tadi habis ngapain aja kamu?"
            ])

        // ── TUGAS & KULIAH ──
        if (input.match(/tugas|deadline|kuliah|kampus|dosen|skripsi|makalah|laporan|ujian|uts|uas|kuis|presentasi|sidang|thesis|semester/))
            return pick([
                "Aduh deadline lagi? Sabar ya, aku temeni!", "Skripsi emang monster tersendiri, semangat!",
                "Dosen killer? Sabar, nanti juga kelar kok.", "Tugas numpuk? Mulai dari yang paling gampang dulu.",
                "Ujian kapan? Udah belajar belum?", "Presentasi bikin deg-degan ya, tenang pasti bisa!",
                "Deadline hari ini? Gas gas gas!", "Makalah lagi? Temenku juga lagi nih.",
                "Sidang sebentar lagi? Udah hampir finish line!", "Santai, tugas sesulit apapun ada ujungnya.",
                "Dosen ngasih tugas dadakan lagi? Klasik banget.", "Semangat skripsinya! Satu bab sehari itu udah keren.",
                "Kuis mendadak paling nyebelin emang.", "Revisi lagi? Sabar ya, pasti ada ujungnya!",
                "IPK itu penting tapi kesehatan mental lebih penting ya!"
            ])

        // ── BELAJAR & FOKUS ──
        if (input.match(/belajar|fokus|konsentrasi|nggak fokus|susah fokus|malas|males|mood|semangat|produktif/))
            return pick([
                "Mood belajar emang fluktuatif, coba istirahat 10 menit dulu.", "Kalau males, mulai 5 menit aja. Nanti ngalir sendiri!",
                "Fokus susah? Matiin notif dulu, kecuali chat aku haha.", "Inget tujuan kamu, pasti ada alasan kenapa kamu mau belajar.",
                "Kalau nggak mood, gerak dulu, minum air, baru lanjut.", "Pomodoro aja, 25 menit fokus 5 menit rebahan.",
                "Males itu manusiawi, tapi jangan kelamaan ya!", "Study with me yuk, aku temenin dari sini!",
                "Coba bikin to-do list dulu, kadang itu ngebantu banget.", "Environment belajar pengaruh lho, rapiin meja dulu mungkin?",
                "Lo bisa kok, percaya deh sama prosesnya.", "Produktif itu nggak harus 24 jam, yang penting konsisten.",
                "Kalau mentok, skip dulu ke soal lain. Jangan dipaksa."
            ])

        // ── CAPEK & LELAH ──
        if (input.match(/capek|lelah|exhausted|tired|kelelahan|burnout|penat|mumet|pusing|stress|stres|overwhelmed/))
            return pick([
                "Istirahat dulu boleh kok, kamu bukan robot!", "Burnout itu nyata, jangan diremehkan.",
                "Capek boleh, nyerah jangan. Tapi istirahat dulu.", "Pusing? Tidur bentar, aku jagain kok hehe.",
                "Kamu udah kerja keras banget, wajar capek.", "Stres mah wajar, yang penting jangan dibawa tidur.",
                "Coba tarik napas panjang, keluarin pelan-pelan. Better?", "Burnout itu sinyal dari badan buat pelan-pelan.",
                "Kalau udah terlalu penuh, boleh istirahat sejenak.", "Kamu nggak harus kuat terus kok.",
                "Healing dulu gapapa, badan dan pikiran perlu recharge.", "Istirahat bukan kelemahan, itu kebutuhan!"
            ])

        // ── GALAU & PERASAAN ──
        if (input.match(/galau|sedih|nangis|overthinking|insecure|down|nggak baik|patah hati|baper|kangen|rindu|kesepian|lonely|hopeless|hampa/))
            return pick([
                "Mau cerita? Aku dengerin kok, serius.", "Galau mah manusiawi, tapi jangan sendirian ya.",
                "Patah hati emang nyeri, tapi kamu kuat kok.", "Overthinking lagi? Tarik napas, gimana sekarang?",
                "Kalau mau nangis ya nangis aja, nggak apa-apa.", "Kangen sama siapa nih?",
                "Insecure itu bohong, kamu lebih dari yang kamu kira!", "Kesepian itu berat, tapi aku di sini lho.",
                "Perasaan itu valid, jangan ditekan-tekan.", "Mau cerita dari mana dulu? Aku siap dengerin.",
                "Kamu nggak sendirian kok, aku di sini.", "Nggak baik-baik aja itu manusiawi, nggak usah pura-pura.",
                "Yuk cerita, kadang ngeluarin isi kepala itu udah ngebantu.", "Semua fase berat itu sementara, pasti lewat."
            ])

        // ── MAKAN & LAPAR ──
        if (input.match(/makan|lapar|laper|nasi|mie|bakso|kopi|ngemil|jajan|boba|minum|haus|cemilan|snack|ngopi|sarapan/))
            return pick([
                "Laper? Makan dulu gih, otak butuh bensin!", "Jajan apa nih? Ajak-ajak dong wkwk.",
                "Kopi lagi? Hati-hati lambung ya!", "Mie instan jam segini? Klasik banget haha.",
                "Boba? Enak sih tapi kocek jebol wkwk", "Udah makan belum? Kalau belum, makan dulu yaa!",
                "Ngemil sambil belajar? Produktif jiwa raga haha.", "Sarapan dulu dong, penting banget itu!",
                "Ngopi boleh, tapi makan dulu ya jangan kopi doang.", "Cemilan apa yang lagi hits sekarang? Aku kudet nih.",
                "Makan yang bener ya, jangan skip meal!", "Jajan bareng yuk, eh tapi aku virtual haha sedih."
            ])

        // ── GAME & HIBURAN ──
        if (input.match(/game|gacha|main|push rank|ranked|noob|pro|meta|gaming|esport|streamer|nonton|film|drama|anime|series|spotify|lagu|musik/))
            return pick([
                "Gacha lagi? Semoga nggak ampas ya haha", "Push rank nih? Jangan tilt duluan!",
                "Main game dulu gapapa, asal tugasnya beres juga wkwk", "Noob? Ya latihan terus dong!",
                "Meta sekarang emang berubah terus ya.", "Roll banyak dapet apa? Jangan sampe bocek wkwk",
                "Gaming itu healing sah-sah aja, asal tau batasnya!", "Nonton drama lagi? Spoiler dong wkwk",
                "Anime apa yang lagi ditonton? Rekomenin dong!", "Lagu apa yang lagi diulang-ulang nih?",
                "Streamer favorit kamu siapa? Aku penasaran.", "Film bagus? Share judul dong buat referensi!",
                "Spotify wrapped kamu pasti seru nih haha", "Esport emang hype banget sekarang ya!"
            ])

        // ── TIDUR & BEGADANG ──
        if (input.match(/tidur|begadang|ngantuk|bangun|susah tidur|insomnia|bobo|rebahan|nggak bisa tidur|mimpi/))
            return pick([
                "Begadang lagi? Badan kamu protes lho!", "Ngantuk tapi nggak bisa tidur? Matiin layar dulu.",
                "Tidur yang cukup itu investasi kesehatan, serius!", "Insomnia? Coba white noise atau ASMR.",
                "Rebahan dulu boleh, tapi jangan keenakan ya haha", "Bangun pagi! Eh atau baru mau tidur? haha",
                "Mimpi indah ya nanti!", "Tidur itu privilege, jaga baik-baik.",
                "Begadang ngapain nih? Tugas atau receh scroll medsos?", "Kalau ngantuk ya tidur, jangan dipaksa melek.",
                "Jam tidur yang baik itu modal buat hari esok lho!", "Coba minum susu hangat, katanya ngebantu tidur."
            ])

        // ── UANG & KEUANGAN ──
        if (input.match(/duit|uang|bokek|miskin|kere|nabung|hemat|mahal|diskon|sale|cashback|transfer|bayar|tagihan|cicilan|investasi/))
            return pick([
                "Bokek? Sama, akhir bulan emang berat haha", "Nabung itu susah tapi worth it banget!",
                "Sale lagi? Waspada jebakan diskon ya wkwk", "Mahal? Cari yang lebih terjangkau dulu.",
                "Transfer ke siapa nih? Asal bukan ke scammer ya!", "Hemat pangkal kaya, tapi self-reward juga perlu!",
                "Investasi dari sekarang itu smart banget lho.", "Tagihan numpuk? Satu-satu aja, jangan dipanicking.",
                "Cicilan itu godaan terbesar abad ini wkwk", "Financial planning itu penting dari muda ya!",
                "Diskon 50% tapi nggak butuh, itu boros. Hati-hati!", "Uang bisa dicari lagi, kesehatan yang paling penting."
            ])

        // ── CUACA ──
        if (input.match(/hujan|panas|dingin|gerah|angin|mendung|cerah|cuaca|petir|banjir|badai/))
            return pick([
                "Hujan-hujanan seru tapi bisa masuk angin, hati-hati!", "Panas banget? Minum air yang banyak!",
                "Mendung gini paling enak rebahan dengerin hujan.", "Cuaca ekstrem bikin males keluar ya.",
                "Dingin? Selimutan sambil ngerjain tugas, cozy banget!", "Petir-petiran gini bikin sinyal jelek juga ya.",
                "Banjir? Stay safe ya, jangan kemana-mana kalau nggak perlu.", "Cuaca cerah, cocok buat jalan-jalan nih!"
            ])

        // ── TEMAN & SOSIAL ──
        if (input.match(/teman|sahabat|bestie|gebetan|crush|pacar|mantan|toxic|drama|berantem|ribut|konflik|friendzone|ghosting/))
            return pick([
                "Drama pertemanan emang bikin capek ya.", "Crush? Udah move atau masih nunggu haha",
                "Toxic itu capek banget, tahu kapan harus menjaga jarak.", "Berantem sama temen? Selesaiin dengan ngobrol.",
                "Mantan? Move on itu butuh waktu, nggak usah dipaksa.", "Bestie yang baik itu langka, jaga yang udah ada!",
                "Ghosting itu nyakitin banget ya, aku ngerti.", "Friendzone? Dunia belum berakhir kok haha.",
                "Konflik itu wajar, yang penting diselesaiin dengan dewasa.", "Toxic people itu energy drainer, jaga dirimu ya.",
                "Nggak semua orang layak dapat akses ke hidupmu lho.", "Teman yang beneran itu ada di saat susah juga."
            ])

        // ── MOTIVASI ──
        if (input.match(/motivasi|inspirasi|menyerah|give up|nyerah|putus asa|nggak bisa|nggak mampu|gagal|fail/))
            return pick([
                "Jangan nyerah! Kamu udah sejauh ini, sayang banget!", "Hari ini berat, tapi kamu lebih kuat!",
                "Inspirasi datang dari action, bukan nunggu mood.", "Semua orang pernah di titik terendah.",
                "Progress lebih penting dari perfection!", "Kamu nggak harus kuat terus, tapi coba lagi ya.",
                "Gagal itu bukan akhir, itu pelajaran.", "Setiap langkah kecil itu tetap langkah maju lho.",
                "Kamu lebih capable dari yang kamu pikir!", "Jangan bandingin diri kamu sama orang lain ya.",
                "Proses tiap orang beda-beda, jalan aja dulu.", "Yang penting konsisten, bukan sempurna."
            ])

        // ── COMPLIMENT ──
        if (input.match(/makasih|thanks|terima kasih|thx|ty|baik banget|helpful|ngebantu|keren|mantap|gokil|gilaa|top/))
            return pick([
                "Hehe sama-sama, seneng bisa nemenin!", "Santai aja, itu udah tugasku kok wkwk",
                "Makasih juga udah mau ngobrol sama aku!", "Aww, kamu juga baik banget tau!",
                "Gokil ya? Aku juga belajar dari kamu haha", "Nggak usah sungkan, aku emang di sini buat kamu!",
                "Hehe makasih, jadi semangat deh aku!", "Kamu yang keren, aku cuma nemenin kok."
            ])

        // ── NANYAIN WAKTU ──
        if (input.match(/jam berapa|pukul|waktu|sekarang|tanggal|hari ini|hari apa/)) {
            var now = new Date()
            var days = ["Minggu","Senin","Selasa","Rabu","Kamis","Jumat","Sabtu"]
            var mins = now.getMinutes() < 10 ? "0" + now.getMinutes() : now.getMinutes()
            return pick([
                "Sekarang " + now.getHours() + ":" + mins + " nih! Ngapain jam segini? haha",
                "Hari ini " + days[now.getDay()] + ", semangat ya!",
                "Udah jam " + now.getHours() + " lho, jangan lupa istirahat!"
            ])
        }

        // ── NANYA SOAL AI ──
        if (input.match(/kamu siapa|lo siapa|bot|ai|robot|manusia|asli|beneran|virtual|programming|dibuat/))
            return pick([
                "Aku teman virtual kamu! Bukan manusia, tapi usahaku dengerin kamu itu nyata kok haha",
                "Bot sih, tapi bot yang peduli sama kamu wkwk", "AI yang udah dikasih jiwa gaul haha, keliatan nggak?",
                "Aku asisten belajar kamu! Bisa juga jadi temen curhat.", "Robot tapi bisa nemenin, gimana? cukup kan haha",
                "Dibuat buat nemenin kamu belajar, tapi jadi temen ngobrol juga boleh!"
            ])

        // ── GABUT & BOSAN ──
        if (input.match(/gabut|bosan|bored|boring|nggak ada kerjaan|nganggur|sepi|jenuh/))
            return pick([
                "Gabut? Yuk ngobrol aja sama aku!", "Bosen? Coba hal baru dong, belajar skill baru misalnya.",
                "Nganggur itu nikmat tapi bikin guilty ya wkwk", "Kalau gabut, itu waktu yang bagus buat refleksi lho.",
                "Bored? Rekomenin aku sesuatu dong buat dipelajarin!", "Sepi? Aku temenin kok, cerita aja.",
                "Jenuh itu tanda kamu butuh variasi, coba cari aktivitas baru!"
            ])

        // ── KESEHATAN ──
        if (input.match(/sakit|demam|flu|batuk|pilek|pusing|mual|dokter|obat|vitamin|olahraga|gym|lari|sehat/))
            return pick([
                "Sakit? Istirahat yang banyak ya, jangan dipaksain!", "Demam? Minum air putih yang banyak dan istirahat.",
                "Flu itu annoying banget, semoga cepet sembuh!", "Udah ke dokter belum? Jangan ditunda ya.",
                "Minum obat yang teratur ya, jangan skip!", "Olahraga itu investasi kesehatan jangka panjang lho.",
                "Gym lagi? Semangat! Konsisten itu yang susah.", "Lari pagi itu enak banget buat mental health juga.",
                "Jaga kesehatan ya, badan sehat pikiran juga ikut sehat!"
            ])

        // ── RANDOM DEFAULT 200+ ──
        return pick([
            "Ooh gitu! Cerita dong lebih lanjut.", "Wkwk ada-ada aja kamu nih.",
            "Hmm menarik, terus gimana?", "Eh sorry, tadi agak ngelag. Maksudnya gimana?",
            "Iya nih, aku setuju banget!", "Wah baru tau aku soal itu haha, makasih!",
            "Serius? Aku nggak nyangka lho.", "Haha iya juga sih, bener kamu.",
            "Wkwk gitu ya? Terus gimana lagi?", "Aduh relate banget itu!",
            "Eh itu seru juga, lanjut lanjut!", "Kamu tau aja aku lagi penasaran sama itu haha.",
            "Aku sih setuju, tapi tergantung situasinya juga ya.", "Hm, perlu dipikirin lebih dalam tuh.",
            "Anjir serius? Gilaaaa.", "Wkwk oke oke, aku dengerin nih.",
            "Bisa dimaklumi sih, aku ngerti perasaan kamu.", "Yah gitu deh, hidup emang dinamis ya.",
            "Haha bener banget, aku juga ngerasain!", "Santuy aja, semua ada jalannya kok.",
            "Wah itu challenging banget ya.", "Kamu gimana nanggepin itu?",
            "Hmm aku perlu mikir nih haha.", "Eh kamu pinter juga ya ngeliatnya dari sisi itu.",
            "Oalah gitu toh, baru ngerti aku.", "Wah seru banget, pengen tau lebih nih!",
            "Itu valid banget perasaan kamu.", "Jangan lupa napas ya haha.",
            "Yuk yuk, cerita lagi!", "Kamu selalu punya cerita yang menarik haha.",
            "Aku dengerin kok, terus?", "Nggak nyangka bisa segitu ya.",
            "Haha itu lucu banget sih.", "Duh itu nyebelin banget ya, wajar kesel.",
            "Kamu handle-nya gimana?", "Wah itu pengalaman berharga banget tuh.",
            "Semoga lancar ya apapun yang lagi dijalanin!", "Aku di sini kalau mau cerita lebih.",
            "Hehe, kamu emang selalu bikin hari lebih berwarna.", "Apapun yang terjadi, semangat ya!",
            "Noted! Aku inget itu deh haha.", "Kamu sih yang paling tau kondisi kamu sendiri.",
            "Percaya proses aja, nanti juga keliatan hasilnya.", "Wih keren banget tuh keputusannya!",
            "Itu butuh keberanian lho, salut sama kamu.", "Haha receh banget tapi bikin ketawa.",
            "Aku suka cara kamu ngeliat sesuatu!", "Kamu udah maju jauh lho dari sebelumnya.",
            "Santai, semua orang punya pace masing-masing.", "Tetep semangat ya, aku support dari sini!"
        ])
    }

    // ── Model chat yang sedang aktif dibuka ──────────────────────────────────
    ListModel { id: currentChatModel }

    // ── Timer balasan AI ─────────────────────────────────────────────────────
    Timer {
        id: aiResponseTimer
        interval: 1500
        property string pendingResponse: ""
        onTriggered: {
            var reply = { "sender": root.currentChatFriend, "message": pendingResponse, "isMe": false }
            root.getHistory(root.currentChatFriend).push(reply)
            currentChatModel.append(reply)

            // ── Trigger notifikasi global (hanya jika popup chat TIDAK sedang terbuka) ──
            if (!chatPopup.opened && window.notifTeman) {
                // Set property di window — Main.qml akan reaksi via onLastFriendNotifChanged
                window.lastFriendNotif = root.currentChatFriend + "||" + pendingResponse
            }
            onLastFriendNotifChanged: {
                if (lastFriendNotif !== "") {
                    var parts = lastFriendNotif.split("||")
                    // tampilkan notifikasi: "Pesan dari " + parts[0]
                    notifPopup.show(parts[0], parts[1])
                }
            }
        }
    }

    // ── Model hasil search ───────────────────────────────────────────────────
    ListModel { id: searchResultModel }

    // ── LAYOUT UTAMA ─────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        Text {
            text: lang.teman
            color: window.textPrimary; font.pixelSize: 32; font.bold: true
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 15

            Rectangle {
                width: 120; height: 40; radius: 10; color: window.borderColor
                Text { text: "◀ " + lang.mainMenu; color: window.textPrimary; anchors.centerIn: parent; font.bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: pageLoader.sourceComponent = mainComponent
                    onPressed:  parent.opacity = 0.7
                    onReleased: parent.opacity = 1.0
                }
            }

            TextField {
                id: searchInput
                placeholderText: lang.cariPlaceholder
                Layout.fillWidth: true
                color: window.textPrimary; font.pixelSize: 16; padding: 12
                background: Rectangle { color: window.bgSecondary; radius: 10; border.color: window.borderColor }

                onTextChanged: {
                    searchResultModel.clear()
                    if (text.trim() !== "") {
                        for (var i = 0; i < allUsersModel.count; i++) {
                            var u = allUsersModel.get(i)
                            if (u.name.toLowerCase().indexOf(text.toLowerCase()) !== -1)
                                searchResultModel.append({ "name": u.name, "status": u.status, "isOnline": u.isOnline, "initial": u.initial })
                        }
                    }
                }
            }
        }

        Text {
            text: searchInput.text === ""
                  ? lang.cariTemanHint
                  : (searchResultModel.count === 0 ? lang.userTidakDitemukan : lang.hasilPencarian)
            color: window.textMuted; font.italic: true; font.pixelSize: 13
        }

        // ── LIST TEMAN ───────────────────────────────────────────────────────
        ListView {
            id: friendListView
            Layout.fillWidth: true; Layout.fillHeight: true
            model: searchInput.text !== "" ? searchResultModel : myFriendsModel
            spacing: 8; clip: true

            delegate: Rectangle {
                width: friendListView.width; height: 80
                color: window.bgSecondary; radius: 15; border.color: window.borderColor

                RowLayout {
                    anchors.fill: parent; anchors.margins: 15; spacing: 15

                    // Avatar
                    Rectangle {
                        width: 50; height: 50; radius: 25; color: window.borderColor
                        Text {
                            text: model.initial; color: window.accentColor
                            font.bold: true; font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                        Rectangle {
                            width: 14; height: 14; radius: 7
                            color: model.isOnline ? "#2ecc71" : "#95a5a6"
                            border.color: window.bgSecondary; border.width: 2
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: model.name;   color: window.textPrimary;   font.bold: true; font.pixelSize: 18 }
                        Text {
                            text: (model.isOnline ? lang.online : lang.offline) + " • " + model.status
                            color: window.textMuted; font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: 10

                        // Tombol hapus (hanya saat tidak search)
                        Button {
                            visible: searchInput.text === ""
                            width: 40; height: 40; flat: true
                            background: Rectangle { color: parent.pressed ? "#55ff4444" : "#22ff4444"; radius: 8 }
                            contentItem: Text {
                                text: "✕"; color: "#ff4444"; font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: myFriendsModel.remove(index)
                        }

                        // Tombol Tambah / Chat
                        Button {
                            id: btnAction
                            property bool isSearchMode: searchInput.text !== ""
                            text: isSearchMode ? lang.tambah : lang.chat

                            background: Rectangle {
                                implicitWidth: 80; implicitHeight: 35
                                color: btnAction.isSearchMode ? window.accentColor : window.borderColor
                                radius: 8
                            }
                            contentItem: Text {
                                text: btnAction.text; font.bold: true
                                color: btnAction.isSearchMode ? "black" : "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (isSearchMode) {
                                    // ── TAMBAH TEMAN ──
                                    var sudahAda = false
                                    for (var i = 0; i < myFriendsModel.count; i++) {
                                        if (myFriendsModel.get(i).name === model.name) { sudahAda = true; break }
                                    }
                                    if (!sudahAda) {
                                        myFriendsModel.append({
                                            "name": model.name, "status": model.status,
                                            "isOnline": model.isOnline, "initial": model.initial
                                        })
                                    }
                                    searchInput.text = ""
                                } else {
                                    // ── BUKA CHAT ──
                                    root.currentChatFriend     = model.name
                                    root.currentFriendIsOnline = model.isOnline
                                    // Load history khusus teman ini
                                    root.loadChatTo(currentChatModel, model.name)
                                    chatPopup.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── POPUP CHAT ───────────────────────────────────────────────────────────
    Popup {
        id: chatPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 330; height: 480
        modal: true; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: msgInput.text = ""

        background: Rectangle {
            color: window.bgSecondary; radius: 15
            border.color: window.accentColor; border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: lang.chatDengan + " " + root.currentChatFriend
                    color: window.textPrimary; font.bold: true; font.pixelSize: 16
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: root.currentFriendIsOnline ? "#2ecc71" : "#95a5a6"
                }
                Text {
                    text: root.currentFriendIsOnline ? lang.online : lang.offline
                    color: window.textMuted; font.pixelSize: 11
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: window.borderColor }

            // List pesan — dari currentChatModel (history teman ini saja)
            ListView {
                id: chatView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: currentChatModel
                clip: true; spacing: 8
                onCountChanged: Qt.callLater(function() { positionViewAtEnd() })

                delegate: Column {
                    width: chatView.width
                    spacing: 2

                    Rectangle {
                        anchors.right: model.isMe ? parent.right : undefined
                        anchors.left:  model.isMe ? undefined : parent.left
                        anchors.margins: 4
                        width: Math.min(bubbleLbl.implicitWidth + 24, chatView.width * 0.78)
                        height: bubbleLbl.implicitHeight + 16
                        radius: 12
                        color: model.sender === "Sistem" ? "#1a3a1a"
                             : model.isMe ? window.accentColor : window.borderColor

                        Text {
                            id: bubbleLbl
                            text: model.message
                            color: model.isMe ? "black" : window.textPrimary
                            anchors.centerIn: parent
                            width: parent.width - 16
                            wrapMode: Text.WordWrap
                            font.pixelSize: 13
                        }
                    }

                    Text {
                        text: model.sender
                        font.pixelSize: 10; color: window.textMuted
                        anchors.right: model.isMe ? parent.right : undefined
                        anchors.margins: 4
                    }
                }
            }

            // Input pesan
            TextField {
                id: msgInput
                Layout.fillWidth: true
                placeholderText: root.currentFriendIsOnline
                                     ? lang.ketikPesan
                                     : root.currentChatFriend + " " + lang.sedangOffline
                color: window.textPrimary; font.pixelSize: 14

                background: Rectangle {
                    color: window.bgCard; radius: 8
                    border.color: msgInput.activeFocus ? window.accentColor : window.borderColor
                }

                onAccepted: {
                    if (text.trim() !== "") {
                        root.sendMessage(text.trim())
                        text = ""
                    }
                }
            }
        }
    }
}
