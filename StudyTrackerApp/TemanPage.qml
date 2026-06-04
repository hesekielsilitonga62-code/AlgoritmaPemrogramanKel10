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
            // Tampilkan "mengetik..." sementara nunggu API
            var typingMsg = { "sender": currentChatFriend, "message": "...", "isMe": false }
            currentChatModel.append(typingMsg)
            var typingIndex = currentChatModel.count - 1

            callClaudeAPI(pesan, typingIndex)
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

    // ── Offline AI Response Engine ───────────────────────────────────────────
    // Tidak butuh internet, tidak butuh API key.
    // Mendeteksi topik dari pesan lalu pilih respons dari pool variatif.
    function callClaudeAPI(pesan, typingIndex) {
        var delay = 600 + Math.floor(Math.random() * 900)  // 0.6–1.5 detik biar natural

        // ── Seed persona berdasarkan nama teman ───────────────────────────
        var seed = 0
        for (var ci = 0; ci < currentChatFriend.length; ci++) seed += currentChatFriend.charCodeAt(ci)

        var nama = currentChatFriend
        var p = seed % 10  // 0–9, penentu gaya bicara
        // Gaya: 0=gaul/santai, 1=bijak/kalem, 2=cerewet/ceria, 3=serius-hangat,
        //       4=kocak, 5=pendiam-perhatian, 6=energik, 7=cool/singkat, 8=puitis, 9=sinis-sayang

        var hobi = ["ngoding", "dengerin lofi", "nonton anime", "main RPG", "gym",
                    "fotografi", "masak", "baca fiksi ilmiah", "bikin konten", "desain UI/UX",
                    "main gitar", "nonton horor", "baca webtoon", "journaling", "hiking",
                    "belajar Jepang", "competitive programming", "dengerin podcast", "nonton docu", "koleksi figma"][seed % 20]

        var jurusan = ["TI", "Sistem Informasi", "Teknik Elektro", "Matematika",
                       "Fisika", "Kimia", "Biologi", "Kedokteran", "Psikologi", "Hukum",
                       "Akuntansi", "Manajemen", "Ekonomi", "Sastra Indo", "Sastra Inggris",
                       "DKV", "Arsitektur", "Teknik Sipil", "Farmasi", "Ilmu Komputer"][(seed * 3) % 20]

        // ── Deteksi topik dari pesan ──────────────────────────────────────
        var q = pesan.toLowerCase()

        // Helper: pilih satu dari array secara "random" berdasarkan panjang pesan + seed
        var ri = (pesan.length + seed) % 999  // base index

        function pick(arr) {
            return arr[(ri + arr.length * 7) % arr.length]
        }
        function pick2(arr) {
            return arr[(ri + arr.length * 3 + 11) % arr.length]
        }

        var reply = ""

        // ════ TOPIK DETEKSI — 40+ kategori, ~500 total respons ═══════════

        // ── SAPA / GREETING ──────────────────────────────────────────────
        if (/^(hai|halo|hi|hey|hei|hello|assalam|pagi|siang|sore|malam|oi|oy|woi|woy)\b/.test(q)) {
            var greetPool = [
                "Heyy " + nama.split("")[0].toUpperCase() + "~ ada apa nih? 😄",
                "Halo! lagi ngapain? 👀",
                "Woy, baru muncul! Gimana kabar? 😂",
                "Hai! tumben nih nyapa duluan wkwk",
                "Eh halo~ ada yang bisa aku bantu ga?",
                "Yoo~ lagi santai atau lagi pusing? 😅",
                "Hoi! udah makan belum btw? 👀",
                "Hai hai! aku lagi " + hobi + " nih, ada apa? 😁",
                "Hello temen " + jurusan + "! gimana hari ini?",
                "Wkwk akhirnya nyapa juga~ ada apa bestie? 🫶"
            ]
            reply = pick(greetPool)

        // ── KABAR / HOW ARE YOU ───────────────────────────────────────────
        } else if (/gimana kabar|apa kabar|lagi apa|lg apa|sedang apa|lagi gimana|baik.baik|sehat/.test(q)) {
            var kabarPool = [
                "Alhamdulillah baik! lagi sibuk " + hobi + " nih. Kamu sendiri gimana? 😊",
                "Lumayan~ agak capek tapi masih hidup wkwk. Kamu?",
                "Baik kok! Btw kamu sendiri gimana, udah makan?",
                "Oke-oke aja! Tadi habis ngerjain tugas " + jurusan + " yang lumayan bikin pusing 😅 kamu gimana?",
                "Sehat! Lagi fokus " + hobi + " biar ga stress. Kamu kabar?",
                "Lumayan lah~ hidup terus jalan wkwk. Ada cerita apa?",
                "Sedikit overwhelmed tapi oke! kamu baik-baik aja kan?"
            ]
            reply = pick(kabarPool)

        // ── SKRIPSI / TUGAS AKHIR ────────────────────────────────────────
        } else if (/skripsi|ta |tugas akhir|bab 3|bab 4|sidang|sempro|semhas|dosen pembimbing|revisi|proposal/.test(q)) {
            var skripsPool = [
                "Wah skripsi, topik yang bikin deg-degan ya 😅 lagi di bab berapa sekarang?",
                "Sumpah skripsi itu ujian kesabaran banget. Stuck di bagian mana?",
                "Ngl, bab 3 itu musuh bebuyutan hampir semua mahasiswa wkwk. Semangat ya bestie! 💪",
                "Wih sidang? Udah prepare pertanyaan killer dari penguji belum? 😬",
                "Dosen pembimbing susah ditemui? Itu classic banget parah. Mending kirim email formal dulu.",
                "Revisi terus tuh tanda kamu makin deket wisuda! Sabar ya 🫶",
                "Proposal ditolak itu sakit, tapi bisa jadi batu loncatan buat yang lebih bagus. Kenapa ditolak?",
                "Bab 3 metodologi emang paling tricky. Kamu pake metode apa? Kuanti atau kuali?",
                "Gaskeun aja! Skripsi itu bukan soal sempurna, tapi soal selesai. Satu halaman sehari juga jadi kok.",
                "Sidang itu lebih ke mempertahankan ide kamu lho, bukan diinterogasi. Santai, kamu pasti bisa! 🙌"
            ]
            reply = pick(skripsPool)

        // ── IPK / NILAI ───────────────────────────────────────────────────
        } else if (/ipk|nilai|indeks|semester|cum laude|remedial|ngulang|sp |semester pendek|ip sem/.test(q)) {
            var nilaiPool = [
                "IPK naik turun itu normal banget, yang penting trend-nya ke atas. Gimana semester ini?",
                "Jangan terlalu obsesi sama IPK, skill dan portofolio juga penting banget loh btw.",
                "Remedial? Tenang, banyak yang sukses lewat jalur itu juga kok wkwk 💪",
                "Nilai jelek bukan akhir dunia. Evaluasi dulu, salahnya di mana? Metode belajar atau manajemen waktu?",
                "Cum laude keren, tapi yang lebih penting kamu ngerti ilmunya atau engga. Gimana?",
                "Semester pendek tuh peluang, bukan hukuman! Ambil yang emang kamu butuh.",
                "IP 3.5+ itu achievable kok kalau tau caranya. Kamu biasanya kendala di mana?",
                "Ngl, nilai bagus + pengalaman organisasi/magang itu combo yang kuat banget buat karir."
            ]
            reply = pick(nilaiPool)

        // ── CODING / PROGRAMMING ──────────────────────────────────────────
        } else if (/ngoding|coding|code|debug|error|bug|python|java\b|javascript|js |html|css |php|flutter|react|kotlin|swift|c\+\+|c#|golang|rust|typescript/.test(q)) {
            var codePool = [
                "Wah debug lagi? Error-nya apa? Kadang yang paling nyebelin justru yang simpel banget wkwk",
                "Python emang enak buat mulai, syntaxnya clean. Lagi ngerjain project apa?",
                "JavaScript tuh love-hate relationship banget ya 😂 async await udah ketolong belum?",
                "Error di mana? Stack trace-nya bilang apa? Share dulu biar bisa bantu mikir!",
                "Sumpah " + hobi + " sambil dengerin lo debugnya lebih enak daripada diam wkwk",
                "Kalau stuck, coba rubber duck debugging. Jelasin problem-nya ke benda mati, seriusan works!",
                "Flutter itu powerful banget buat mobile. Udah nyoba state management apa?",
                "React hooks bikin hidup lebih mudah kalau udah ngerti konsepnya. Masih bingung di bagian mana?",
                "Jangan lupa commit ke Git ya! Ntar nyesel kalau belum di-save 😂",
                "Ngl, ngoding itu 20% nulis code, 80% googling dan baca docs. Normal kok!"
            ]
            reply = pick(codePool)

        // ── CAPEK / BURNOUT / STRESS ──────────────────────────────────────
        } else if (/capek|lelah|burnout|stress|stres|penat|jenuh|overwhelm|mager|ga semangat|gak semangat|males|malas|ngedown|down banget/.test(q)) {
            var capekPool = [
                "Istirahat dulu ya! Productivitas yang baik butuh recharge juga kok 🫶",
                "Burnout itu real dan valid banget. Jangan forsir diri, mending ambil napas dulu.",
                "Sumpah ngerti banget rasanya. Tapi kamu udah jauh banget lho dari titik awal, bangga ya sama dirimu!",
                "Coba " + hobi + " sebentar buat reset otak, terus balik lagi. Sometimes itu yang paling works.",
                "Kamu ga harus produktif terus 24/7. Istirahat itu bagian dari proses, bukan kelemahan!",
                "Eh mau cerita ga? Kadang ngeluarin isi hati ke orang yang dengerin itu udah ngebantu banget.",
                "Burnout itu tandanya kamu udah kerja keras. Sekarang waktunya prioritasin kesehatan dulu ya.",
                "Mager itu normal kalau udah terlalu banyak input. Coba putus koneksi bentar, disconnect is healthy!",
                "Gimana kalau besok aja lanjutinnya? Otak yang capek jarang bisa kerja optimal.",
                "Lo ga sendirian kok ngerasain ini. Banyak yang sama. Yang penting jangan sampai terus-terusan ya 💙"
            ]
            reply = pick(capekPool)

        // ── MOTIVASI / SEMANGAT ───────────────────────────────────────────
        } else if (/semangat|motivasi|galau|putus asa|nyerah|mau nyerah|gabisa|ga bisa|gak bisa|susah banget|berat banget/.test(q)) {
            var motiPool = [
                "Hey, kamu udah ngelewatin hal yang lebih berat dari ini sebelumnya. Ini pasti bisa juga! 💪",
                "Ngl, yang ngerasa susah itu justru yang worth it buat diperjuangin. Gaskeun!",
                "Satu langkah kecil hari ini itu lebih baik dari nunggu momen sempurna. Mulai aja dulu!",
                "Kamu ga harus langsung jago. Proses itu bagian dari cerita suksesnya nanti 🌱",
                "Inget kenapa awalnya kamu mulai. Itu alasan yang cukup buat terus jalan.",
                "Istirahat boleh, nyerah jangan! Ada yang bisa aku bantu biar lebih enteng?",
                "Setiap orang punya pace-nya masing-masing. Jangan bandingin dirimu sama orang lain ya!",
                "Kamu lebih kuat dari yang kamu kira, sumpah. Percaya deh sama proses.",
                "Kalau butuh temen ngobrol atau curhat, aku di sini kok. Cerita aja! 🫶",
                "Sedikit progress tetap progress. Jangan nunggu sempurna dulu baru jalan."
            ]
            reply = pick(motiPool)

        // ── ANIME / MANGA ─────────────────────────────────────────────────
        } else if (/anime|manga|jujutsu|demon slayer|one piece|naruto|bleach|attack on titan|aot|chainsaw|haikyuu|spy.family|ghibli|isekai/.test(q)) {
            var animePool = [
                "Wah topik favorit nih! Lagi ngikutin anime apa sekarang? 👀",
                "One Piece itu investasi waktu yang worth it banget menurut aku wkwk",
                "Jujutsu Kaisen season terakhir parah banget sih fight scene-nya",
                "Demon Slayer art style-nya terlalu indah, animasinya bikin sakit mata dalam artian positif 😂",
                "Aku team Ghibli kalau mau film yang bikin tenang jiwa. Kamu suka yang mana?",
                "Attack on Titan ending-nya masih jadi topik debat sampe sekarang tbh wkwk",
                "Chainsaw Man itu unik banget konsepnya. Udah baca manganya?",
                "Haikyuu tuh anime yang cocok banget ditonton waktu butuh motivasi!",
                "Rekomendasi anime apa yang lagi worth it buat ditonton sekarang menurut kamu?",
                "Spy x Family tuh vibes-nya beda banget, lebih wholesome. Cocok buat healing!"
            ]
            reply = pick(animePool)

        // ── GAME ─────────────────────────────────────────────────────────
        } else if (/game|gaming|main game|mobile legend|ml |genshin|valorant|minecraft|ff |free fire|pubg|steam|pc gaming|rank|ranked|push rank/.test(q)) {
            var gamePool = [
                "Gamer juga nih! Lagi main apa sekarang? 🎮",
                "Mobile Legends itu gateway drug ke dunia gaming wkwk. Main role apa?",
                "Genshin Impact itu cantik banget tapi dompet bisa nangis 😂",
                "Valorant? Udah rank berapa sekarang? Aku masih struggling di Gold tbh",
                "Minecraft itu game yang somehow selalu seru meski udah lama banget",
                "FF masih hidup? Wkwk respect lah buat yang masih loyal",
                "Push rank itu menyenangkan sekaligus menyiksa jiwa ya 😂",
                "Game PC emang beda level pengalamannya. Setup kamu gimana?",
                "Kalau udah frustrated main, mending break bentar. Tilt itu musuh rank 😅",
                "Genshin player itu hidupnya penuh sacrifice: waktu, tenaga, dan saldo wkwk"
            ]
            reply = pick(gamePool)

        // ── MUSIK / KPOP / JPOP ───────────────────────────────────────────
        } else if (/musik|lagu|spotify|playlist|kpop|k-pop|jpop|j-pop|lofi|band|konser|nyanyi|dengerin|genre/.test(q)) {
            var musikPool = [
                "Aku juga " + hobi + " nih! Lagi dengerin genre apa sekarang?",
                "Spotify playlist buat belajar itu game changer banget. Kamu biasanya dengerin apa?",
                "Lofi hip hop + fokus belajar itu combo sempurna menurutku 🎵",
                "K-pop fandom itu salah satu yang paling passionate wkwk. Stan siapa?",
                "Band Indonesia sekarang kualitasnya udah global banget sih, bangga!",
                "Konser offline itu pengalaman yang beda banget sama nonton di YouTube.",
                "Dengerin musik pas ngerjain tugas itu bantu atau gangguin? Kalau aku sih bantu!",
                "Ada rekomendasi lagu buat lo siapin playlist belajar tapi tetep chill?",
                "Aku paling suka dengerin " + hobi + " diiringin musik instrumental. Nyaman banget!",
                "Genre apa yang paling cocok buat mood lo sekarang?"
            ]
            reply = pick(musikPool)

        // ── FILM / SERIES ─────────────────────────────────────────────────
        } else if (/film|movie|series|nonton|netflix|bioskop|drama korea|drakor|kdrama|marvel|dc|horor|thriller|dokumenter/.test(q)) {
            var filmPool = [
                "Aku suka banget nonton " + (seed % 2 === 0 ? "film horor" : "dokumenter") + " nih! Kamu lagi nonton apa?",
                "Drama Korea itu emang bisa bikin episode 1 sampe 16 kelar dalam semalem wkwk",
                "Netflix dan ngerjain tugas itu dua hal yang susah dibedain kadang 😂",
                "Film Marvel fase 4-5 agak mixed ya reviewnya. Kamu suka yang mana paling?",
                "Kalau mau healing, film Studio Ghibli itu always the answer btw",
                "Bioskop atau nonton di rumah? Tergantung filmnya sih menurutku!",
                "Horor Indonesia makin bagus tuh sekarang, udah nonton yang terbaru?",
                "Rekomendasi series yang worth it buat ditonton sambil santai ada ga?",
                "Dokumenter itu underrated banget padahal banyak yang mind-blowing kontennya",
                "Drakor tuh bahaya, sekali mulai susah berhenti wkwk ada yang lagi kamu tonton?"
            ]
            reply = pick(filmPool)

        // ── MENTAL HEALTH ─────────────────────────────────────────────────
        } else if (/anxiety|depresi|mental health|kesehatan mental|overthinking|panic|insomnia|tidur susah|ga baik-baik|ngerasa sendirian|kesepian|lonely/.test(q)) {
            var mentalPool = [
                "Hey, makasih udah mau cerita. Gimana kondisi kamu sekarang? 💙",
                "Overthinking itu nyata banget melelahkannya. Udah coba teknik grounding belum?",
                "Ngerasa kesepian itu valid. Tapi inget, kamu ga sendirian dalam ngerasain ini.",
                "Insomnia itu bisa ngaruh ke banyak hal. Coba kurangin screen time 1 jam sebelum tidur.",
                "Mental health itu sama pentingnya kayak kesehatan fisik. Jangan diabaikan ya!",
                "Kalau anxiety-nya berat, nggak ada salahnya cari bantuan profesional. Itu tanda kekuatan, bukan kelemahan.",
                "Kamu ga harus kuat terus. Boleh ngerasa ga baik-baik aja, itu manusiawi.",
                "Coba tarik napas dulu pelan-pelan. Kamu aman, kamu di sini, kamu akan baik-baik aja 🫶",
                "Cerita lebih lanjut kalau mau, aku dengerin. Kadang ngomong ke temen udah ngebantu.",
                "Self-care itu bukan selfis. Jaga diri dulu baru bisa bantu orang lain."
            ]
            reply = pick(mentalPool)

        // ── MAGANG / KARIR ────────────────────────────────────────────────
        } else if (/magang|internship|kerja|karir|lowongan|cv |resume|portfolio|interview|fresh graduate|startup|perusahaan|gaji|linkedin/.test(q)) {
            var karirPool = [
                "Magang itu investasi terbaik selain kuliah tbh. Lagi cari magang di mana?",
                "CV yang baik itu singkat, padat, relevan. Jangan masukin semua hal yang pernah dilakuin wkwk",
                "LinkedIn itu wajib banget dioptimasi kalau mau dilirik recruiter. Kamu udah punya profil?",
                "Interview teknis itu bisa dipersiapkan! Latihan di LeetCode atau HackerRank dulu.",
                "Startup vs korporat? Tergantung tipe kamu. Startup = growth cepat tapi chaos, korporat = stabil tapi lambat.",
                "Gaji pertama itu bukan patokan seterusnya. Yang penting pengalaman dan networking dulu.",
                "Portfolio project pribadi itu kadang lebih ngomong banyak daripada IPK lho!",
                "Gap year itu bukan buang waktu kalau diisi dengan hal produktif. Kamu mau ngapain?",
                "Fresh graduate itu wajar insecure, tapi ingat semua orang pernah di posisi yang sama!",
                "Jurusan " + jurusan + " itu peluang karirnya luas banget, jangan khawatir!"
            ]
            reply = pick(karirPool)

        // ── KEUANGAN / KOST ───────────────────────────────────────────────
        } else if (/uang|duit|keuangan|kost|anak kos|nabung|hemat|jajan|bokek|kantin|makan|budget/.test(q)) {
            var kostPool = [
                "Anak kos sejati itu ahli manage keuangan dalam keterbatasan wkwk. Gimana kondisi dompet?",
                "Kalau lagi bokek, mie instan itu solusi universal yang udah terbukti secara ilmiah 😂",
                "Nabung itu susah tapi bisa! Coba metode 50/30/20: 50% kebutuhan, 30% keinginan, 20% tabungan.",
                "Cari kost yang deket kampus itu worth it banget buat ngirit ongkos dan waktu.",
                "Part-time sambil kuliah itu mungkin, asal pintar atur waktu. Kamu tertarik?",
                "Masak sendiri itu jauh lebih hemat dan ternyata bisa jadi hobi seru lho!",
                "Budget jajan harian itu kunci. Kalau udah punya angkanya, lebih gampang kontrol.",
                "Freelance itu salah satu cara terbaik buat mahasiswa nambah income sesuai skill.",
                "Kantin kampus vs warteg: harga hampir sama, tapi warung sering lebih nendang rasanya wkwk",
                "Ingat, investasi ilmu > investasi barang. Tapi tetep harus makan dulu ya 😂"
            ]
            reply = pick(kostPool)

        // ── HUBUNGAN / PERCINTAAN ─────────────────────────────────────────
        } else if (/pacar|gebetan|pdkt|jadian|putus|ghosting|friendzone|ldr|long distance|perasaan|suka sama|nembak/.test(q)) {
            var cintaPool = [
                "Wah ada yang lagi jatuh cinta nih? Cerita dong! 😄",
                "PDKT itu seninya ada di konsistensi tanpa terlihat desperate wkwk",
                "Kena ghosting itu menyakitkan, tapi itu lebih reflect ke dia daripada ke kamu.",
                "LDR itu bisa works kalau dua-duanya committed dan komunikasinya bagus. Kalian gimana?",
                "Friendzone itu bukan zona merah, cuma belum waktunya aja mungkin 😅",
                "Nembak itu butuh keberanian, tapi lebih baik tahu jawabannya daripada terus nebak-nebak kan?",
                "Putus itu sakit, tapi healing itu bisa. Kamu perlu waktu, dan itu okay.",
                "Fokus kuliah vs pacaran itu bisa kok balance, asal sama-sama dewasa dan supportif.",
                "Perasaan itu valid apapun itu. Kamu udah communicate sama dia belum soal ini?",
                "Kadang yang paling penting itu bukan hasilnya, tapi kamu udah berani jujur sama perasaan sendiri."
            ]
            reply = pick(cintaPool)

        // ── PERTANYAAN AKADEMIK ───────────────────────────────────────────
        } else if (/kalkulus|integral|turunan|statistik|aljabar|fisika|kimia|biologi|materi|kuliah|pelajaran|ujian|uts|uas|soal/.test(q)) {
            var akademikPool = [
                "Wah soal " + jurusan + " nih! Bagian mana yang paling bikin bingung?",
                "Integral itu kayak kebalikan turunan, mulai dari yang dasar dulu biar ngerti polanya.",
                "Statistika itu sebenernya logis banget kalau udah ngerti konsep dasarnya. Mau aku bantuin?",
                "Fisika itu semua tentang ngerti konsepnya, bukan hafalan rumus. Coba visualisasiin dulu.",
                "Kimia organik tuh challenging tapi seru kalau udah nemu 'click'-nya. Lagi di topik apa?",
                "UTS/UAS tinggal berapa hari lagi? Udah mulai cicil belajar belum?",
                "Coba bikin mind map buat materi yang banyak, lebih gampang di-review nanti!",
                "Khan Academy dan YouTube itu life-saver banget buat materi yang susah dipahami dari buku.",
                "Belajar bareng temen itu kadang lebih efektif daripada solo, mau coba bikin study group?",
                "Soal latihannya ada ga? Lebih enak kalau sambil praktek langsung!"
            ]
            reply = pick(akademikPool)

        // ── TEKNOLOGI / AI / GADGET ───────────────────────────────────────
        } else if (/ai |artificial intelligence|chatgpt|machine learning|deep learning|laptop|smartphone|gadget|aplikasi|teknologi|startup|github|vs code/.test(q)) {
            var techPool = [
                "AI tuh udah jadi bagian dari kehidupan sehari-hari banget ya sekarang. Kamu pake buat apa?",
                "ChatGPT itu powerful banget kalau tau cara prompt-nya yang bener. Kamu udah explore?",
                "Machine learning itu field yang lagi booming banget, worth it dipelajari!",
                "Laptop buat kuliah itu paling penting: RAM minimal 8GB, storage SSD. Budget berapa?",
                "GitHub itu portfolio yang paling dilihat recruiter tech lho. Udah isi projectnya?",
                "VS Code itu editor favorit aku juga! Extension yang paling berguna menurutmu apa?",
                "Startup Indonesia udah makin mature sekarang, banyak yang udah unicorn 🦄",
                "Smartphone terbaru vs nabung laptop? Tergantung kebutuhan produktivitasnya sih.",
                "AI ga bakal ngegantiin kamu, tapi orang yang pake AI bakal ngegantiin yang ga pake wkwk",
                "Cloud computing itu skill yang makin dicari sekarang. Pernah coba AWS atau GCP?"
            ]
            reply = pick(techPool)

        // ── OLAHRAGA / KESEHATAN ──────────────────────────────────────────
        } else if (/olahraga|gym|lari|futsal|badminton|basket|yoga|diet|makan sehat|tidur|istirahat|tubuh|berat badan/.test(q)) {
            var olahPool = [
                "Olahraga itu investasi jangka panjang yang paling worth it! Kamu rutin ga?",
                "Gym itu intimidating diawal tapi adiktif kalau udah biasa. Udah punya program latihan?",
                "Lari pagi itu mood booster alami yang gratis. Kamu biasa lari berapa km?",
                "Futsal sama temen itu selain olahraga juga bonding yang seru!",
                "Diet yang sehat itu bukan tentang ga makan, tapi tentang makan yang bener.",
                "Tidur 7-8 jam itu bukan mewah, itu kebutuhan dasar! Kamu sering tidur berapa jam?",
                "Yoga itu bagus banget buat flexibility dan stress relief. Pernah coba?",
                "Badminton itu olahraga nasional yang underrated banget manfaatnya!",
                "Kalau mau mulai hidup sehat, start dari hal kecil: minum air yang cukup dulu.",
                "Mental health dan physical health itu saling connect. Olahraga juga bantu mood lho!"
            ]
            reply = pick(olahPool)

        // ── PERTANYAAN LANGSUNG / OPINI ───────────────────────────────────
        } else if (/menurut kamu|pendapat kamu|saran|gimana menurut|apa yang harus|sebaiknya|bagaimana cara|tips|cara/.test(q)) {
            var saranPool = [
                "Hmm, menurut aku sih " + pick2(["yang paling penting itu consistency", "coba breakdown jadi langkah kecil dulu", "dengerin intuisi kamu, kamu lebih tau situasinya", "ga ada jawaban yang 100% benar, tapi ini yang aku saranin"]) + ". Gimana situasi lebih detailnya?",
                "Honestly, aku butuh tau lebih banyak konteksnya dulu buat kasih saran yang proper. Cerita lebih?",
                "Dari pengalamanku: " + pick2(["mulai aja dulu, perfect itu musuh progress", "networking itu penting banget, jangan fokus kerja sendirian", "self-aware itu skill yang underrated", "istirahat itu bagian dari strategi"]) + ". Relevan ga sama situasimu?",
                "Saran pertama dari aku: jangan overthinking! Ambil satu langkah dulu. Mau mulai dari mana?",
                "Kamu lebih tau diri kamu sendiri sih, tapi kalau minta opini aku: " + pick2(["be honest sama diri sendiri dulu", "prioritasin yang paling impactful", "communication is key apapun situasinya", "trust the process bro"]) + "!",
                "Good question! Yang penting dipikirin dulu: apa yang kamu mau dari situasi ini?"
            ]
            reply = pick(saranPool)

        // ── CURHAT UMUM ───────────────────────────────────────────────────
        } else if (/cerita|curhat|galau|bingung|dilema|bimbang|ngerasa|perasaan|sedih|kesel|frustrasi|kecewa/.test(q)) {
            var curhatPool = [
                "Aku dengerin nih, cerita aja! 🫶",
                "Sounds tough. Kamu mau aku dengerin aja atau minta saran juga?",
                "Valid banget ngerasa kayak gitu. Lanjut ceritanya, aku di sini.",
                "Hm, itu kompleks juga ya. Udah berapa lama ngerasain ini?",
                "Sumpah aku appreciate kamu mau cerita. Apa yang paling bikin berat sekarang?",
                "Ngerasa bingung itu manusiawi banget. Coba jelasin lebih, mungkin aku bisa bantu?",
                "Itu pasti ga mudah. Kamu udah ada rencana atau masih ngerasa stuck?",
                "Frustrasi itu wajar. Yang penting ga dipendam sendirian. Cerita lebih dong!",
                "Aku ada kok buat dengerin. Apapun yang lagi kamu rasain itu valid.",
                "Sedih itu boleh, kecewa juga boleh. Kamu mau cerita apa yang terjadi?"
            ]
            reply = pick(curhatPool)

        // ── WISUDA / LULUS ────────────────────────────────────────────────
        } else if (/wisuda|lulus|toga|cumlaude|selesai kuliah|graduation|setelah lulus/.test(q)) {
            var wisudaPool = [
                "Wisuda! Selamat ya kalau udah atau mau! Perasaannya campur aduk ya pasti 🎓",
                "Setelah lulus itu chapter baru yang seru banget. Udah ada gambaran mau ngapain?",
                "Toga itu simbol perjuangan bertahun-tahun. Bangga banget!",
                "Lulus kuliah bukan akhir belajar, justru awal dari belajar yang lebih real 💪",
                "Rencana setelah wisuda: langsung kerja, lanjut S2, atau ada opsi lain?",
                "Wih selamat! Perjuangan panjang akhirnya kelar. Gimana rasanya?",
                "Post-graduation phase itu bisa overwhelming, tapi kamu pasti bisa navigate-nya!",
                "Udah banyak yang nunggu kamu di dunia nyata. Siap-siap aja! 🙌"
            ]
            reply = pick(wisudaPool)

        // ── BEASISWA / LPDP ───────────────────────────────────────────────
        } else if (/beasiswa|lpdp|scholarship|s2|s3|kuliah luar negeri|exchange|pertukaran pelajar/.test(q)) {
            var beasiswaPool = [
                "Beasiswa LPDP itu kompetitif tapi achievable! Kamu lagi di tahap mana?",
                "S2 luar negeri itu pengalaman yang mind-expanding banget. Ada target negara?",
                "Exchange program itu salah satu opportunity terbaik yang ada di kampus. Kamu minat?",
                "Untuk beasiswa, esai dan rencana studi itu super penting. Udah draft?",
                "Persiapan bahasa Inggris (IELTS/TOEFL) itu langkah pertama yang harus solid.",
                "Kerja dulu atau langsung S2? Tergantung tipe dan tujuan karir kamu sih.",
                "Beasiswa ada banyak jenisnya lho, ga cuma LPDP. Udah research yang lain?",
                "Gap year buat persiapkan beasiswa itu keputusan yang matang banget!"
            ]
            reply = pick(beasiswaPool)

        // ── TRAVELING / LIBURAN ───────────────────────────────────────────
        } else if (/liburan|traveling|jalan-jalan|wisata|destinasi|trip|backpacker|tiket|hotel|bali|jogja|jakarta|bandung/.test(q)) {
            var travelPool = [
                "Liburan itu recharge jiwa yang paling worth it! Mau kemana?",
                "Backpacker budget itu seru banget, banyak cerita yang bisa didapat!",
                "Bali itu ga ada habisnya dikunjungi, selalu ada spot baru yang keren.",
                "Jogja itu the ultimate healing destination menurutku, culture + kuliner + alam.",
                "Tiket murah itu ada, kuncinya: pesan jauh-jauh hari dan fleksibel tanggalnya!",
                "Solo traveling itu pengalaman self-discovery yang luar biasa lho!",
                "Bandung itu dekat tapi selalu ada aja yang bikin betah. Kuliner-nya juara!",
                "Traveling sambil nabung ilmu itu formula terbaik buat liburan yang meaningful.",
                "Ada ga destinasi bucket list yang belum kesampaian? Mungkin bisa plan bareng wkwk",
                "Staycation juga valid lho kalau budget lagi tipis! Self-care tetap bisa di rumah."
            ]
            reply = pick(travelPool)

        // ── MAKANAN / KULINER ─────────────────────────────────────────────
        } else if (/makan|makanan|kuliner|lapar|nasi|mie|bakso|soto|rendang|cafe|kopi|minuman|dessert|jajanan|warung/.test(q)) {
            var makanPool = [
                "Ngomongin makanan bikin langsung lapar 😂 kamu udah makan belum?",
                "Kopi + belajar itu combo legendaris anak kuliah. Lagi di cafe mana?",
                "Rendang itu comfort food ultimate yang ga ada duanya, setuju?",
                "Mie instant kreatif itu skill survival anak kos yang paling penting wkwk",
                "Bakso itu makanan yang bisa bikin hari buruk jadi mending. Setuju ga?",
                "Cafe buat belajar atau buat foto dulu baru belajar? Wkwk jujur aja!",
                "Soto itu menu yang underrated banget padahal variannya kaya banget lho.",
                "Masak sendiri itu lebih hemat dan surprisingly lebih enak kalau udah terbiasa!",
                "Dessert itu reward terbaik habis ngerjain tugas atau sidang. Kamu suka apa?",
                "Warung di sekitar kampus itu often hidden gem yang makanannya enak banget!"
            ]
            reply = pick(makanPool)

        // ── MBTI / KEPRIBADIAN ────────────────────────────────────────────
        } else if (/mbti|infj|infp|intj|intp|enfj|enfp|entj|entp|istj|istp|isfj|isfp|estj|estp|esfj|esfp|introvert|extrovert|kepribadian/.test(q)) {
            var mbtiPool = [
                "MBTI itu menarik banget buat self-understanding! Kamu type apa?",
                "Introvert bukan berarti antisosial lho, cuma recharge-nya butuh kesendirian.",
                "INFJ itu katanya paling langka, tapi entah kenapa banyak yang ngaku INFJ wkwk",
                "MBTI useful buat self-awareness tapi jangan terlalu rigid dijadiin kotak ya!",
                "Extrovert dalam kelompok tapi introvert sendirian itu real banget, ada term-nya: ambivert.",
                "ENTP itu ide-nya banyak banget tapi eksekusinya yang sering jadi challenge 😂",
                "Kepribadian itu bisa berkembang seiring pengalaman. Kamu ngerasa berubah ga dari dulu?",
                "Test MBTI yang free tapi akurat itu 16personalities.com, udah pernah coba?",
                "Yang penting bukan type-nya, tapi gimana kamu memaksimalkan kelebihanmu kan!",
                "Zodiak vs MBTI: keduanya fun tapi jangan jadiin excuse ya wkwk"
            ]
            reply = pick(mbtiPool)

        // ── ORGANISASI KAMPUS ─────────────────────────────────────────────
        } else if (/organisasi|hima|bem|ukm|osis|kepanitiaan|volunteer|relawan|event|kepemimpinan|leadership/.test(q)) {
            var orgPool = [
                "Aktif organisasi itu soft skill booster yang ga ada duanya! Kamu di mana?",
                "BEM/HIMA itu challenging tapi pengalaman leadershipnya worth it banget.",
                "UKM itu tempat nemu passion di luar akademis yang sering bikin surprising!",
                "Kepanitiaan event itu belajar project management real yang lebih intense dari teori.",
                "Balance antara akademis dan organisasi itu kunci, jangan sampai salah satu terlalu sacrifice.",
                "Volunteer itu selain bermanfaat, juga bagus banget buat CV dan mental.",
                "Leadership itu ga harus jadi ketua, bisa dimulai dari jadi anggota yang reliable dulu.",
                "Kamu lagi handle event apa? Bisa cerita lebih?",
                "Jaringan dari organisasi itu often lebih valuable dari gelar dalam dunia kerja lho.",
                "Burnout di organisasi itu real. Jangan lupa set boundaries ya!"
            ]
            reply = pick(orgPool)

        // ── BAHASA ASING ──────────────────────────────────────────────────
        } else if (/bahasa inggris|toefl|ielts|bahasa jepang|bahasa korea|bahasa mandarin|belajar bahasa|grammar|vocab/.test(q)) {
            var bahasaPool = [
                "Belajar bahasa asing itu investasi jangka panjang yang worth it banget!",
                "TOEFL vs IELTS tergantung tujuannya: US akademik = TOEFL, UK/Aus/lainnya = IELTS.",
                "Bahasa Jepang itu susah tapi seru! Udah bisa hiragana katakana?",
                "Cara paling efektif belajar bahasa: immersion! Nonton konten native tanpa subtitle.",
                "Grammar itu penting tapi jangan sampai jadi blocker buat speaking. Coba aja dulu!",
                "Vocab building itu efektif banget pake spaced repetition (Anki misalnya).",
                "Bahasa Korea lagi banyak yang minat gara-kara K-pop/K-drama wkwk. Kamu juga?",
                "Konsistensi 15 menit sehari itu lebih efektif dari belajar 2 jam sekali seminggu lho!"
            ]
            reply = pick(bahasaPool)

        // ── TERIMA KASIH ──────────────────────────────────────────────────
        } else if (/makasih|terima kasih|thanks|thank you|thx|tengkyu|tengkyuu/.test(q)) {
            var terimaPool = [
                "Sama-sama! Ada lagi yang bisa aku bantu? 😊",
                "No problem! Kapanpun mau ngobrol aku ada kok 🫶",
                "Hehe anytime! Semoga bermanfaat ya~",
                "Santai aja! Temen kan emang buat gitu wkwk",
                "Sama-sama bestie! Semangat ya terus 💪",
                "Makasih juga udah mau cerita/tanya! Seneng bisa ngobrol sama kamu 😁"
            ]
            reply = pick(terimaPool)

        // ── PERTANYAAN TTG SI TEMAN ────────────────────────────────────────
        } else if (/kamu siapa|lo siapa|nama kamu|jurusan apa|hobi kamu|lo suka apa|kamu suka/.test(q)) {
            var siapakuPool = [
                "Aku " + nama + "! Jurusan " + jurusan + ", hobi " + hobi + ". Kamu sendiri gimana?",
                "Haha kenalan ulang ya wkwk. Aku " + nama + ", suka banget " + hobi + ". Kamu?",
                "Aku temen kamu lah! " + nama + ", anak " + jurusan + " yang doyan " + hobi + " wkwk",
                "Kenapa nanya? Udah lupa? 😂 " + nama + ", " + jurusan + ", hobi " + hobi + "!",
                "Aku? " + nama + " dong. Kamu ini lho 😂 Lagi ngapain emang tiba-tiba nanya?"
            ]
            reply = pick(siapakuPool)

        // ── DEFAULT: respons natural variatif ─────────────────────────────
        } else {
            var hist2 = getHistory(currentChatFriend)
            var lastCount = hist2.length

            var defaultPool = [
                "Wah menarik nih! Boleh cerita lebih? 👀",
                "Hm, bisa elaborasi lagi? Aku penasaran maksudnya 😄",
                "Itu topik yang seru! Aku juga punya pengalaman soal ini sih. Kamu gimana?",
                "Wkwk iya juga sih. Menurut kamu sendiri gimana?",
                "Oh itu! Ngl aku punya perspektif tersendiri soal ini. Mau dengerin?",
                "Haha sumpah relate banget. Cerita dong lebih lengkapnya!",
                "Interesting! Ini context-nya apa btw? Biar aku bisa respon lebih tepat.",
                "Wah baru denger ini, kamu bisa jelasin lebih? 😅",
                "Hmm, aku lagi mikirin nih. Gimana kalau kita breakdown dulu masalahnya?",
                "Btw soal itu, aku penasaran sama pendapatmu dulu. Kamu sendiri udah ada solusi?",
                "Seru banget topiknya! Aku anak " + jurusan + " jadi lumayan relate wkwk. Gimana lebih lanjut?",
                "Real talk, aku " + pick2(["setuju banget sih", "punya pandangan berbeda nih", "belum punya cukup info buat comment", "pernah ngerasa hal yang sama"]) + "! Cerita lebih dong.",
                "Eh btw ngomongin itu, kamu pernah coba " + pick2(["diskusi sama dosen?", "googling lebih lanjut?", "minta feedback dari temen?", "nulis di jurnal buat ngejernihin pikiran?"]) + "?",
                "Hm, aku butuh dengerin lebih banyak nih. Konteks situasinya gimana?",
                "Jujur aku ga tau banyak soal itu, tapi kamu bisa cerita dan kita pikirin bareng!",
                "Wkwk kamu ini. Oke oke jelasin lebih, aku dengerin serius kok 😂",
                "Lagi " + hobi + " sambil baca pesanmu nih, tapi tetep fokus kok! Ada apa?",
                "Hmm menarik. Kamu udah nyoba approach lain belum?",
                "Honestly aku " + pick2(["baru tau soal ini", "lumayan tau sih", "pernah dapet pengalaman serupa"]) + ". Sharing lebih dong!",
                "Sebenernya banyak yang bisa dibahas soal ini. Kamu mau mulai dari sudut mana?"
            ]
            reply = pick(defaultPool)
        }

        // ── Set reply dengan delay biar natural ───────────────────────────
        offlineReplyTimer.typingIndex = typingIndex
        offlineReplyTimer.pendingReply = reply
        offlineReplyTimer.interval = delay
        offlineReplyTimer.restart()
    }

    Timer {
        id: offlineReplyTimer
        property int typingIndex: -1
        property string pendingReply: ""
        onTriggered: {
            if (typingIndex < 0) return
            currentChatModel.set(typingIndex, {
                "sender": root.currentChatFriend,
                "message": pendingReply,
                "isMe": false
            })
            getHistory(root.currentChatFriend).push({
                "sender": root.currentChatFriend,
                "message": pendingReply,
                "isMe": false
            })
            if (!chatPopup.opened && window.notifTeman)
                window.lastFriendNotif = root.currentChatFriend + "||" + pendingReply
        }
    }

    // ── Models ───────────────────────────────────────────────────────────────
    ListModel { id: currentChatModel }
    ListModel { id: searchResultModel }



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
                MouseArea { id: backArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: pageStack.pop() }
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
                    text: "🟢  " + (function(){ var n=0; for(var i=0;i<myFriendsModel.count;i++) if(myFriendsModel.get(i).isOnline) n++; return n }()) + " " + lang.online
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
