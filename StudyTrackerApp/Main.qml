import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia  

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "Study Tracker"
    color: window.bgPrimary

    // ── Status halaman ───────────────────────────────────────────────────────
    property bool isLoginView: true
    property bool globalTimerRunning: false
    property int globalCurrentTimerValue: 0
    property int globalSecondsFocused: 0
    property int globalSessionsCompleted: 0
    property int globalTargetSessions: 4
    property int globalSeconds: 0
    property bool isStudying: false
    property string currentActiveTask: lang.belumAdaTugas
    property string currentChatFriend: ""
    property var chatHistories: ({})
    property string namaUser:         "Pengguna"
    property string statusUser:       "Semangat Belajar! 💪"
    property int    selectedAvatar:   0
    property string currentUser: ""
    property var _notifiedTasks: ({})
    property string customAvatarPath: ""
    property real avatarOffsetX: 0
    property real avatarOffsetY: 0
    property int selectedBorder: 0
    property bool selectedBorderAnimated: false
    readonly property var borderAssets: [
        "",                                          // 0 = Default (tidak ada PNG)
        "qrc:/StudyTrackerApp/borders/kawaii.png",   // 1 Kawaii
        "qrc:/StudyTrackerApp/borders/galaxy.png",   // 2 Galaxy PNG
        "qrc:/StudyTrackerApp/borders/rainbow.png",  // 3 Rainbow PNG
        "", "", "", "", "", "",                      // 4–9  gradasi warna
        "", "", "", "", "", "",                      // 10–15
        "", "", "", "", "", "",                      // 16–21
        "", "", "", "", "", "",                      // 22–27
        "", "", "", "", "", "",                      // 28–33
        "", "", "", "", "", "",                      // 34–39
        "", "", "", "", "", "",                      // 40–45
        "", "", "", "",                              // 46–49
    ]
    // Setiap border gradasi didefinisikan sebagai pasangan [c1, c2, durasi_ms, lebar]
    // Index 0-3 diisi placeholder (PNG / default), index 4-49 adalah gradasi Canvas.
    readonly property var borderDefs: [
        // id: 0-3 placeholder
        {c1:"#ffcc00", c2:"#ffcc00", dur:2000, lw:3},  // 0 default
        {c1:"#ffcc00", c2:"#ffcc00", dur:2000, lw:3},  // 1 kawaii png
        {c1:"#ffcc00", c2:"#ffcc00", dur:2000, lw:3},  // 2 galaxy png
        {c1:"#ffcc00", c2:"#ffcc00", dur:2000, lw:3},  // 3 rainbow png
        // id 4-49 : gradasi Canvas
        {c1:"#ff0080", c2:"#ffcc00", dur:1800, lw:4},  // 4  Pelangi
        {c1:"#ff4500", c2:"#ffdd00", dur:1500, lw:4},  // 5  Api
        {c1:"#0066ff", c2:"#00e5ff", dur:2000, lw:4},  // 6  Laut
        {c1:"#8b00ff", c2:"#00e5ff", dur:2200, lw:4},  // 7  Galaxy
        {c1:"#ff6eb4", c2:"#ffb3d9", dur:2500, lw:4},  // 8  Sakura
        {c1:"#00ff88", c2:"#00ccff", dur:1600, lw:4},  // 9  Neon Hijau
        {c1:"#ff6600", c2:"#ff0000", dur:1200, lw:5},  // 10 Magma
        {c1:"#ffffff", c2:"#aaddff", dur:3000, lw:3},  // 11 Es Biru
        {c1:"#ffd700", c2:"#ff8c00", dur:1800, lw:4},  // 12 Emas
        {c1:"#7fff00", c2:"#00fa9a", dur:2000, lw:3},  // 13 Hutan
        {c1:"#da70d6", c2:"#9370db", dur:2200, lw:4},  // 14 Anggur
        {c1:"#ff1493", c2:"#ff69b4", dur:1400, lw:5},  // 15 Flamingo
        {c1:"#00ced1", c2:"#20b2aa", dur:2600, lw:3},  // 16 Toska
        {c1:"#ff4500", c2:"#ffd700", dur:1000, lw:6},  // 17 Matahari
        {c1:"#191970", c2:"#4169e1", dur:3500, lw:3},  // 18 Midnite
        {c1:"#ff007f", c2:"#7f00ff", dur:1600, lw:5},  // 19 Neon Ungu
        {c1:"#c0392b", c2:"#e74c3c", dur:1300, lw:4},  // 20 Merah Bara
        {c1:"#1abc9c", c2:"#16a085", dur:2000, lw:4},  // 21 Emerald
        {c1:"#f39c12", c2:"#e67e22", dur:1700, lw:4},  // 22 Oranye
        {c1:"#2980b9", c2:"#3498db", dur:2400, lw:3},  // 23 Biru Peter
        {c1:"#8e44ad", c2:"#9b59b6", dur:2800, lw:4},  // 24 Lavender
        {c1:"#27ae60", c2:"#2ecc71", dur:2200, lw:4},  // 25 Hijau Segar
        {c1:"#ff5f6d", c2:"#ffc371", dur:1500, lw:5},  // 26 Sunset
        {c1:"#2193b0", c2:"#6dd5ed", dur:2000, lw:4},  // 27 Langit
        {c1:"#ee0979", c2:"#ff6a00", dur:1200, lw:5},  // 28 Neon Merah
        {c1:"#11998e", c2:"#38ef7d", dur:1800, lw:4},  // 29 Menta
        {c1:"#f953c6", c2:"#b91d73", dur:1600, lw:4},  // 30 Magenta
        {c1:"#0f0c29", c2:"#302b63", dur:4000, lw:3},  // 31 Gelap Royal
        {c1:"#ffecd2", c2:"#fcb69f", dur:2500, lw:3},  // 32 Peach
        {c1:"#a18cd1", c2:"#fbc2eb", dur:2800, lw:3},  // 33 Pastel Ungu
        {c1:"#fda085", c2:"#f6d365", dur:2000, lw:4},  // 34 Persik
        {c1:"#96fbc4", c2:"#f9f586", dur:1800, lw:4},  // 35 Lemon Mint
        {c1:"#43e97b", c2:"#38f9d7", dur:1600, lw:4},  // 36 Matrix
        {c1:"#fa709a", c2:"#fee140", dur:1400, lw:5},  // 37 Candy
        {c1:"#30cfd0", c2:"#330867", dur:2200, lw:4},  // 38 Cyber
        {c1:"#a1c4fd", c2:"#c2e9fb", dur:3000, lw:3},  // 39 Soft Biru
        {c1:"#fddb92", c2:"#d1fdff", dur:2800, lw:3},  // 40 Krim
        {c1:"#e0c3fc", c2:"#8ec5fc", dur:2500, lw:3},  // 41 Lilac
        {c1:"#ff9a9e", c2:"#fecfef", dur:2200, lw:4},  // 42 Rose
        {c1:"#84fab0", c2:"#8fd3f4", dur:2000, lw:4},  // 43 Seafoam
        {c1:"#a6c0fe", c2:"#f68084", dur:1800, lw:4},  // 44 Dusk
        {c1:"#f77062", c2:"#fe5196", dur:1500, lw:5},  // 45 Flamingo 2
        {c1:"#43cfdd", c2:"#6253e1", dur:2000, lw:4},  // 46 Portal
        {c1:"#f8ff00", c2:"#3ad59f", dur:1600, lw:4},  // 47 Neon Volt
        {c1:"#ff758c", c2:"#ff7eb3", dur:2000, lw:4},  // 48 Bunga
        {c1:"#2afadf", c2:"#4c83ff", dur:1800, lw:4},  // 49 Neon Cyan
    ]

    // Tambahkan di Connections backend atau onUserDataLoaded
    Connections {
        target: backend
        function onUserDataLoaded(nama, status, avatar, sessions, focused, tasks) {
            window.namaUser = nama
            window.statusUser = status
            window.selectedAvatar = avatar
            window.globalSessionsCompleted = sessions
            window.globalSecondsFocused = focused
            globalTaskModel.clear()
            for (var i = 0; i < tasks.length; i++) {
                console.log("Task dari backend:", JSON.stringify(tasks[i]))  // ← lihat key-nya apa
                globalTaskModel.append(tasks[i])
            }
        }
    }

    onClosing: function(close) {
        if (window.currentUser !== "") {
            var tasks = []
            for (var i = 0; i < globalTaskModel.count; i++) {
                var t = globalTaskModel.get(i)
                tasks.push({
                    "title":             t.title,
                    "deadline":          t.deadline,
                    "deadlineTimestamp": t.deadlineTimestamp,
                    "isDone":            t.isDone
                })
            }
            backend.saveUserData(
                window.currentUser,
                window.namaUser,
                window.statusUser,
                window.selectedAvatar,
                window.globalSessionsCompleted,
                window.globalSecondsFocused,
                tasks
            )
        }
    }

    Timer {
        interval: 60000; running: window.currentUser !== ""; repeat: true
        onTriggered: {
            var tasks = []
            for (var i = 0; i < globalTaskModel.count; i++) {
                var t = globalTaskModel.get(i)
                tasks.push({
                    "title":             t.title,
                    "deadline":          t.deadline,
                    "deadlineTimestamp": t.deadlineTimestamp,
                    "isDone":            t.isDone
                })
            }
            backend.saveUserData(
                window.currentUser, window.namaUser, window.statusUser,
                window.selectedAvatar, window.globalSessionsCompleted,
                window.globalSecondsFocused, tasks
            )
        }
    }

    // ── SISTEM NOTIFIKASI GLOBAL ─────────────────────────────────────────────
    // Dipanggil dari mana saja: window.pushNotif("🍅", "Judul", "Isi", "type")
    // type: "pomodoro" | "task" | "friend" | "info"
    function pushNotif(emoji, title, body, type) {
        if (type === undefined) type = "info"
        if (type === "pomodoro" && !window.notifBelajar) return
        if (type === "task"     && !window.notifTugas)   return
        if (type === "friend"   && !window.notifTeman)   return
        globalNotifBanner.show(emoji, title, body, type)
    }

    // Sinyal agar TemanPage bisa trigger notif NPC ke sini — digantikan lastFriendNotif property

    // ── Tema & Bahasa ────────────────────────────────────────────────────────
    property string appTheme:         "gelap"
    property string selectedLanguage: "Indonesia"

    // ── Warna Tema (REAKTIF — semua ikut appTheme) ───────────────────────────
    // PENTING: hanya deklarasi satu kali di sini, tidak ada duplikat di bawah!
    property color bgPrimary:   "#001b2e"
    property color bgSecondary: "#0a2a43"
    property color bgCard:      "#051624"
    property color bgDeep:      "#020f1a"
    property color accentColor: "#ffcc00"
    property color borderColor: "#163e5f"
    property color textPrimary: "#ffffff"
    property color textMuted:   "#8a9fb1"

    // ── Notifikasi & Pomodoro ────────────────────────────────────────────────
    property bool   notifBelajar:      true
    property bool   notifTugas:        true
    property bool   notifTeman:        true
    property bool   soundEnabled:      true
    property int    pomodoroFokus:     25
    property int    pomodoroIstirahat: 5

    // ── Avatar list ──────────────────────────────────────────────────────────
    readonly property var avatarList: [
        "😀","😃","😄","😆","😁","🥹","😅","😂","🤣","🥲","😊","😇","🙂","🙃","😉","😌","😍","🥰","😘","😗","😙","😚","😋","😛","😝","😜","🤪","🤨","🧐","🤓","😎","🥸","🤩","🥳","😏","😒","😞","😔","😟","😕","🙁","😣","😖","😫","😩","🥺","😢","😭","😤","😠","😡","🤬","🤯","😳","🥵","🥶","😶‍🌫️","😱","😨","😰","😥","😓","🤗","🤔","🫣","🤭","🫢","🫡","🤫","🫠","🤥","😶","🫥","😐","🫤","😑","🫨","😬","🙄","😯","😦","😧","😮","😲","🥱","🫩","😴","🤤","😪","😮‍💨","😵","😵‍💫","🤐","🥴","🤢","🤮","😷","🤒","🤕","🤑","🤠","😈","👿","👹","👺","🤡","💩","👻","💀","☠️","👽","👾","🤖","🎃","😺","😸","😹","😻","😼","😽","🙀","😿","😾","🫶","🤲","👐","🙌","👏","🤝","👍","👎","👊","✊","🤛","🤜","🫷","🫸","🤞","✌️","🫰","🤟","🤘","👌","🤌","🤏","🫳","🖐️","🫴","👈","👉","👆","👇","☝️","✋","🤚","🖖","👋","🤙","🫲","🫱","💪","🦾","🖕","✍️","🙏","🫵",
        "👶","👧","🧒","👦","👩","🧑","👨","👩‍🦱","🧑‍🦱","👨‍🦱","👩‍🦰","🧑‍🦰","👨‍🦰","👱","👩‍🦳","🧑‍🦳","👨‍🦳","👩‍🦲","🧑‍🦲","👨‍🦲","🧔","👵","🧓","👴","👲","👳","🧕","👮","👷","💂","🕵","👩‍⚕","🧑‍⚕","👨‍⚕","👩‍🌾","🧑‍🌾","👨‍🌾","👩‍🍳","🧑‍🍳","👨‍🍳","👩‍🎓","🧑‍🎓","👨‍🎓","👩‍🎤","🧑‍🎤","👨‍🎤","👩‍🏫","🧑‍🏫","👨‍🏫","👩‍🏭","🧑‍🏭","👨‍🏭","👩‍💻","🧑‍💻","👨‍💻","👩‍💼","🧑‍💼","👨‍💼","👩‍🔧","🧑‍🔧","👨‍🔧","👩‍🔬","🧑‍🔬","👨‍🔬","👩‍🎨","🧑‍🎨","👨‍🎨","👩‍🚒","🧑‍🚒","👨‍🚒","👩‍✈️","🧑‍✈️","👨‍✈️","👩‍🚀","🧑‍🚀","👨‍🚀","👩‍⚖️","🧑‍⚖️","👨‍⚖️","👰‍♀️","🤵","🤵‍♂️","👸","🫅","🤴","🥷","🦸‍♀️","🦸","🦸‍♂️","🦹‍♀️","🦹","🦹‍♂️","🤶","🧑‍🎄","🎅","🧙","🧝‍♀️","🧝","🧝‍♂️","🧌","🧛‍♀️","🧛","🧛‍♂️","🧟‍♀️","🧟","🧟‍♂️","🧞‍♀️","🧞","🧞‍♂️","🧜‍♀️","🧜","🧜‍♂️","🧚‍♀️","🧚","🧚‍♂️","👼",
        "🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🐔","🐧","🐦","🐤","🐥","🐣","🪿","🐦‍⬛","🦅","🐗","🐺","🐴","🦄","🫎","🐝","🪱","🐛","🐌","🐞","🐜","🪰","🪲","🪳","🦗","🕸","🐢","🐍","🦎","🦖","🦕","🦑","🪼","🦀","🐡","🐠","🐟","🐬","🐳","🐋","🦭","🐊","🐅","🐆","🦓","🦍","🦒","🦘","🦬","🐃","🐂","🐄","🫏","🐎","🐖","🐑","🦙","🐐","🐕","🐩","🦮","🐈","🐈‍⬛","🪶","🪽","🐓","🦤","🦚","🦜","🦩","🕊️","🐇","🦨","🦡","🐁","🐀","🐿️","🦔","🐾","🐉","🐲","🐦‍🔥","🌵","🎄","🌲","🌳","🌴","🪾","🪵","🌱","🌿","☘️","🍀","🎍","🪴","🎋","🍃","🍂","🍁","🪺","🪹","🍄‍🟫","🐚","🪸","🪨","🌾","💐","🌷","🌹","🥀","🪻","🪷","🌺","🌸","🌼","🌻",
        "🍏","🍎","🍐","🍊","🍋","🍋‍🟩","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🍅","🍆","🫛","🥬","🌶️","🫑","🌽","🫒","🧄","🫜","🫚","🥐","🍳","🥞","🍔","🍟","🍕","🥗","🥘",
        "⚽","🏀","🏈","⚾","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🏒","🏑","🥍","🪃","🥅","⛳","🪁","🛝","🏹","🎣","🤿","🥊","🥋","🤸","⛹","🏋","🤺","🤾","🏌","🏇","🧘","🏄","🤽","🚣","🧗‍♀️","🧗","🧗‍♂️","🚵‍♀️","🚵","🚵‍♂️","🚴‍♀️","🚴","🚴‍♂️",
        "⌚","📱","💻","🖥","⌨","🖨","🖱","🖲","🕹","🗜","💽","💾","💿","📀","📼","📷","📸","📹","🎥","📽","🎞","📞","☎","📟","📻","📺","🎙","🎚","🎛","🧭","⏱","⏲","⏰","🕰","⌛","⏳","📡","🔋","🪫","🔌","💡","🧯","💸","💵","💴","💶","💷","🪙","💰","💳","🪪","💎","🪎","⚖️","🪜","🧰","🪛","⛏️","🪏","🔫","🪚","🧨","⛓️‍💥","📩","✉️","📬","📥","📫","📤","📪","📦","🪧","🏷️","📭","🧾","📑","📮","📄","📯","📃","📜","🗑️","📊","📅","📈","📆","📉","🗓️","🗒️","📇","🗂️","📂","🗃️","📁","🗳️","📋","🗄️","📘","🗞️","📗","📰","📕","📓","📒","📔","🖇️","📙","📎","📚","🔗","📖","🧷","🔖","🖋","📐","🖊","📏","✂","🧮","📍","📌","🔏","✒️","🔎","🖌️","🖍️","✏️","📝","🔐","🔓","🔒","🩷","❤️","🧡","💛","💚","🩵","💙","💜","🖤","🩶","🤍","🤎","💔","❤️‍🔥","❤️‍🩹","❣️","💕","💞","💓","💗","💖","💘","💝","💟","☮️","✝️","☪️","🕉️","☸️","🪯","✡️","🔯","🕎","☯️","☦️","🛐","⛎","♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓","🆔","⚛️","🉑","☢️","☣️","📴","🈶","📳","🈚","🈺","🈸","🈷️","🆚","🉐","✴️","💮","㊙️","🈴","㊗️","🈹","🅱️","🆑","🆎","🅾️","🆘","⭕","🛑","⛔","📛","🚫","💯","💢","♨️","🚷","🅰️","❌","🚯","🚳","🚱","🔞","📵","🚭","❗","❕","❓","❔","‼️","⁉️","🔅","🔆","〽️","⚠️","🚸","🔰","❇️","♻️","💹","✅","🈯","✳️","🏧","❎","💤","🌐","🌀","💠","Ⓜ️","🛃","🚾","🛂","♿","🈂️","🅿️","🈳","🛗","🈁","🛄","🛅","🚼","🚹","🚺","🛜","📶","🚮","🚻","⚧️","🆙","🔣","🆗","ℹ️","🆖","🔡","🔠","🆒","🆕","🆓","0️⃣","1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟","🔢","#️⃣","*️⃣","⏏️","▶️","⏸️","⏯️","⏹️","⏺️","⏭️","⏮️","⏩","⏪","⏫","⏬","◀️","🔼","🔽","➡️","⬅️","↖️","↙️","⬆️","↘️","⬇️","↗️","↕️","🔁","↔️","🔀","↪️","⤵️","↩️","⤴️","🔂","🔄","🔃","🎵","🎶","➕","➖","➗","✖️","®️","🟰","™️","♾️","💱","💲","👁️‍🗨️","➰","🔚","〰️","🔙","🔝","🔛","🔜","➿","🟢","✔️","🟡","☑️","🟠","🔘","🔴","🔵","🔸","🟣","🔻","⚫","🔺","⚪","🟤","🔹","◾","🔶","▫️","🔲","🔷","▪️","🔳","◽","🟦","◼️","🟩","◻️","🟨","🟥","🟧","🟪","🔊","⬛","🔉","⬜","🔇","🟫","🔈","🔔","♠️","🔕","🗯️","📣","💭","📢","💬","♣️","♥️","♦️","🀄","🃏","🎴","🕙","🕒","🕘","🕓","🕗","🕔","🕖","🕕","🕚","🕡","🕛","🕠","🕜","🕟","🕝","🕞","🕢","🕧","🕣","🕦","🏳️","🏳️‍🌈","🏴","🏳️‍⚧️","🏴‍☠️","🚩","🏁"
    ]

    // ════════════════════════════════════════════════════════════════════════
    // onAppThemeChanged — SATU-SATUNYA tempat warna di-update
    // ════════════════════════════════════════════════════════════════════════
    onAppThemeChanged: {
        // ── Tema Gelap ─────────────────────────────────────────────────────
        if (appTheme === "gelap") {
            bgPrimary="#001b2e";bgSecondary="#0a2a43";bgCard="#051624";bgDeep="#020f1a"
            accentColor="#ffcc00";borderColor="#163e5f";textPrimary="#ffffff";textMuted="#8a9fb1"
        } else if (appTheme === "hitam") {
            bgPrimary="#0a0a0a";bgSecondary="#141414";bgCard="#050505";bgDeep="#000000"
            accentColor="#ffffff";borderColor="#2a2a2a";textPrimary="#ffffff";textMuted="#666666"
        } else if (appTheme === "gelap_merah") {
            bgPrimary="#150505";bgSecondary="#2a0a0a";bgCard="#0d0303";bgDeep="#080101"
            accentColor="#ff3333";borderColor="#4a1010";textPrimary="#ffe0e0";textMuted="#aa6666"
        } else if (appTheme === "gelap_ungu") {
            bgPrimary="#110d1e";bgSecondary="#1e1433";bgCard="#0a0816";bgDeep="#06040e"
            accentColor="#bd93f9";borderColor="#3a2a5a";textPrimary="#f8f8f2";textMuted="#8a7aaa"
        } else if (appTheme === "gelap_hijau") {
            bgPrimary="#030d03";bgSecondary="#0a1a0a";bgCard="#010801";bgDeep="#000500"
            accentColor="#00ff41";borderColor="#0a3010";textPrimary="#ccffcc";textMuted="#448844"
        } else if (appTheme === "gelap_biru") {
            bgPrimary="#060f1a";bgSecondary="#0d1b2a";bgCard="#040a12";bgDeep="#02060d"
            accentColor="#4fc3f7";borderColor="#102840";textPrimary="#e3f2fd";textMuted="#6090b0"
        } else if (appTheme === "gelap_oranye") {
            bgPrimary="#0d0600";bgSecondary="#1a0d00";bgCard="#080400";bgDeep="#040200"
            accentColor="#ff6d00";borderColor="#3a1c00";textPrimary="#fff3e0";textMuted="#aa7040"
        } else if (appTheme === "gelap_toska") {
            bgPrimary="#000d0d";bgSecondary="#001a1a";bgCard="#000808";bgDeep="#000404"
            accentColor="#00e5cc";borderColor="#003a3a";textPrimary="#e0ffff";textMuted="#50a0a0"
        } else if (appTheme === "gelap_kuning") {
            bgPrimary="#0a0a00";bgSecondary="#111100";bgCard="#060600";bgDeep="#030300"
            accentColor="#ffe600";borderColor="#2a2a00";textPrimary="#ffffe0";textMuted="#999900"
        } else if (appTheme === "gelap_silver") {
            bgPrimary="#080a0e";bgSecondary="#0e1117";bgCard="#050607";bgDeep="#020304"
            accentColor="#b0bec5";borderColor="#1e2530";textPrimary="#eceff1";textMuted="#607d8b"
        // ── Tema Terang ────────────────────────────────────────────────────
        } else if (appTheme === "putih") {
            bgPrimary="#f0f4f8";bgSecondary="#ffffff";bgCard="#e8edf2";bgDeep="#d8e0e8"
            accentColor="#1565c0";borderColor="#cfd8dc";textPrimary="#1a1a2e";textMuted="#546e7a"
        } else if (appTheme === "krem") {
            bgPrimary="#f0e8d5";bgSecondary="#f5efe0";bgCard="#e8dfc8";bgDeep="#ddd0b8"
            accentColor="#8d5524";borderColor="#d4c4a0";textPrimary="#3e2723";textMuted="#795548"
        } else if (appTheme === "pastel_pink") {
            bgPrimary="#ffd6e7";bgSecondary="#ffe0ec";bgCard="#ffcad4";bgDeep="#ffc0cb"
            accentColor="#e91e8c";borderColor="#f48fb1";textPrimary="#4a0020";textMuted="#c2185b"
        } else if (appTheme === "pastel_biru") {
            bgPrimary="#cce5f6";bgSecondary="#daeaf7";bgCard="#bcd8ee";bgDeep="#aaccde"
            accentColor="#1976d2";borderColor="#90c8f0";textPrimary="#0d2040";textMuted="#1565c0"
        } else if (appTheme === "pastel_hijau") {
            bgPrimary="#c8edcc";bgSecondary="#d8f3dc";bgCard="#b8e0bc";bgDeep="#a8d0ac"
            accentColor="#2d6a4f";borderColor="#95d5b2";textPrimary="#1b4332";textMuted="#40916c"
        } else if (appTheme === "pastel_ungu") {
            bgPrimary="#e1d5f0";bgSecondary="#ede7f6";bgCard="#d5c8ea";bgDeep="#c8b8e0"
            accentColor="#6a1b9a";borderColor="#ce93d8";textPrimary="#2a0a4a";textMuted="#7b1fa2"
        } else if (appTheme === "pastel_kuning") {
            bgPrimary="#f8f4b0";bgSecondary="#fff9c4";bgCard="#f0ea9c";bgDeep="#e8de88"
            accentColor="#f57f17";borderColor="#fff176";textPrimary="#3e2800";textMuted="#f9a825"
        } else if (appTheme === "pastel_peach") {
            bgPrimary="#f5d8c0";bgSecondary="#ffe8d6";bgCard="#ecd0b0";bgDeep="#e0c098"
            accentColor="#bf5700";borderColor="#ffcc99";textPrimary="#3e1a00";textMuted="#bf5700"
        } else if (appTheme === "nordic") {
            bgPrimary="#dce4ec";bgSecondary="#e8edf2";bgCard="#d0d8e0";bgDeep="#c4ccd4"
            accentColor="#2e7d8c";borderColor="#b0c4cc";textPrimary="#1a2a30";textMuted="#4a7080"
        } else if (appTheme === "paper") {
            bgPrimary="#ece8df";bgSecondary="#f4f1ea";bgCard="#e0dcd2";bgDeep="#d4d0c4"
            accentColor="#5d4037";borderColor="#c8c0b0";textPrimary="#2a1a10";textMuted="#795548"
        // ── Tema Warna Solid ───────────────────────────────────────────────
        } else if (appTheme === "pink") {
            bgPrimary="#1a0a12";bgSecondary="#2d1020";bgCard="#120709";bgDeep="#0a0408"
            accentColor="#ff6eb4";borderColor="#4a1a30";textPrimary="#ffe0f0";textMuted="#c27a9a"
        } else if (appTheme === "merah") {
            bgPrimary="#150404";bgSecondary="#2a0808";bgCard="#0d0303";bgDeep="#080202"
            accentColor="#f44336";borderColor="#4a0808";textPrimary="#ffebee";textMuted="#ef9a9a"
        } else if (appTheme === "oranye") {
            bgPrimary="#0d0600";bgSecondary="#1a0d00";bgCard="#080400";bgDeep="#040200"
            accentColor="#ff9800";borderColor="#3a1c00";textPrimary="#fff3e0";textMuted="#ffb74d"
        } else if (appTheme === "kuning") {
            bgPrimary="#0d0c00";bgSecondary="#1a1600";bgCard="#080800";bgDeep="#040400"
            accentColor="#fdd835";borderColor="#3a3200";textPrimary="#fffff0";textMuted="#f9a825"
        } else if (appTheme === "hijau") {
            bgPrimary="#041404";bgSecondary="#091a09";bgCard="#030d03";bgDeep="#020802"
            accentColor="#4caf50";borderColor="#0a300a";textPrimary="#e8f5e9";textMuted="#81c784"
        } else if (appTheme === "toska") {
            bgPrimary="#001410";bgSecondary="#001a18";bgCard="#000d0a";bgDeep="#000804"
            accentColor="#26a69a";borderColor="#003a34";textPrimary="#e0f2f1";textMuted="#4db6ac"
        } else if (appTheme === "laut") {
            bgPrimary="#0a1f3d";bgSecondary="#112d54";bgCard="#071529";bgDeep="#040e1c"
            accentColor="#38bdf8";borderColor="#1e4a7a";textPrimary="#dbeafe";textMuted="#7aadcc"
        } else if (appTheme === "biru") {
            bgPrimary="#060e28";bgSecondary="#0a1a40";bgCard="#040c1c";bgDeep="#020810"
            accentColor="#2196f3";borderColor="#102060";textPrimary="#e3f2fd";textMuted="#64b5f6"
        } else if (appTheme === "ungu") {
            bgPrimary="#0e0618";bgSecondary="#150a2a";bgCard="#090412";bgDeep="#05020a"
            accentColor="#9c27b0";borderColor="#2a0a40";textPrimary="#f3e5f5";textMuted="#ce93d8"
        } else if (appTheme === "coklat") {
            bgPrimary="#100806";bgSecondary="#1c100a";bgCard="#0c0604";bgDeep="#080402"
            accentColor="#795548";borderColor="#3a1c10";textPrimary="#efebe9";textMuted="#a1887f"
        // ── Tema Alam ──────────────────────────────────────────────────────
        } else if (appTheme === "adem") {
            bgPrimary="#061a10";bgSecondary="#0e2e1c";bgCard="#040f09";bgDeep="#020a05"
            accentColor="#4ecca3";borderColor="#1a4a2e";textPrimary="#d0f5e8";textMuted="#6aab88"
        } else if (appTheme === "hutan") {
            bgPrimary="#060f06";bgSecondary="#0a1f0a";bgCard="#040a04";bgDeep="#020502"
            accentColor="#8bc34a";borderColor="#143c14";textPrimary="#dcedc8";textMuted="#7cb342"
        } else if (appTheme === "gurun") {
            bgPrimary="#140f04";bgSecondary="#2a1e0a";bgCard="#0c0a02";bgDeep="#080600"
            accentColor="#ffb300";borderColor="#4a3810";textPrimary="#fff8e1";textMuted="#ffa000"
        } else if (appTheme === "salju") {
            bgPrimary="#c8d8e4";bgSecondary="#d0dde8";bgCard="#bcccd8";bgDeep="#b0c0cc"
            accentColor="#0288d1";borderColor="#a0b8c8";textPrimary="#1a2a38";textMuted="#4a7090"
        } else if (appTheme === "pantai") {
            bgPrimary="#051c28";bgSecondary="#0d2a36";bgCard="#031018";bgDeep="#020a0e"
            accentColor="#00bcd4";borderColor="#0a3c4a";textPrimary="#e0f7fa";textMuted="#4dd0e1"
        } else if (appTheme === "aurora") {
            bgPrimary="#030810";bgSecondary="#061020";bgCard="#020508";bgDeep="#010204"
            accentColor="#00e5ff";borderColor="#0a2040";textPrimary="#e0ffff";textMuted="#40c0cc"
        } else if (appTheme === "musim_gugur") {
            bgPrimary="#0d0800";bgSecondary="#1a0e00";bgCard="#080500";bgDeep="#040300"
            accentColor="#ff8f00";borderColor="#3a2000";textPrimary="#fff8e1";textMuted="#ffa000"
        } else if (appTheme === "musim_semi") {
            bgPrimary="#140a10";bgSecondary="#1a1000";bgCard="#0c0608";bgDeep="#080408"
            accentColor="#f48fb1";borderColor="#4a2040";textPrimary="#fce4ec";textMuted="#f06292"
        } else if (appTheme === "volcano") {
            bgPrimary="#0a0200";bgSecondary="#1a0500";bgCard="#060100";bgDeep="#030000"
            accentColor="#ff5722";borderColor="#3a0e00";textPrimary="#fbe9e7";textMuted="#ff8a65"
        } else if (appTheme === "bambu") {
            bgPrimary="#090f04";bgSecondary="#111a08";bgCard="#060a02";bgDeep="#030500"
            accentColor="#aed581";borderColor="#1a3008";textPrimary="#f1f8e9";textMuted="#9ccc65"
        // ── Tema Makanan & Minuman ─────────────────────────────────────────
        } else if (appTheme === "kopi") {
            bgPrimary="#0e0804";bgSecondary="#1c1008";bgCard="#0a0603";bgDeep="#060402"
            accentColor="#d7a86e";borderColor="#3a2010";textPrimary="#fdf0e0";textMuted="#b07050"
        } else if (appTheme === "matcha") {
            bgPrimary="#080f04";bgSecondary="#0e1a0a";bgCard="#050a03";bgDeep="#030602"
            accentColor="#69b578";borderColor="#183818";textPrimary="#e8f5e9";textMuted="#66bb6a"
        } else if (appTheme === "boba") {
            bgPrimary="#0e0818";bgSecondary="#1a1020";bgCard="#080612";bgDeep="#04040c"
            accentColor="#cc99ff";borderColor="#3a1a50";textPrimary="#f3e5f5";textMuted="#ab70cc"
        } else if (appTheme === "stroberi") {
            bgPrimary="#0d0408";bgSecondary="#1a0810";bgCard="#080305";bgDeep="#050205"
            accentColor="#f06292";borderColor="#4a1028";textPrimary="#fce4ec";textMuted="#e57399"
        } else if (appTheme === "blueberry") {
            bgPrimary="#050510";bgSecondary="#0a0a1a";bgCard="#030308";bgDeep="#020205"
            accentColor="#7986cb";borderColor="#1a1a40";textPrimary="#e8eaf6";textMuted="#7986cb"
        } else if (appTheme === "vanilla") {
            bgPrimary="#e0d8c0";bgSecondary="#e8dfc8";bgCard="#d8d0b8";bgDeep="#ccc8ac"
            accentColor="#795548";borderColor="#c8c0a0";textPrimary="#3e2a10";textMuted="#8d6e63"
        } else if (appTheme === "coklat_susu") {
            bgPrimary="#0e0a06";bgSecondary="#1e140a";bgCard="#0c0806";bgDeep="#080604"
            accentColor="#bcaaa4";borderColor="#3a2818";textPrimary="#efebe9";textMuted="#a1887f"
        } else if (appTheme === "nasi") {
            bgPrimary="#0e0a00";bgSecondary="#1a1000";bgCard="#0a0800";bgDeep="#060500"
            accentColor="#ffcc80";borderColor="#3a2a00";textPrimary="#fff8e1";textMuted="#ffa726"
        } else if (appTheme === "teh_tarik") {
            bgPrimary="#0d0804";bgSecondary="#1a0e08";bgCard="#080603";bgDeep="#040402"
            accentColor="#ffa726";borderColor="#3a2010";textPrimary="#fff8e1";textMuted="#ff8f00"
        } else if (appTheme === "es_krim") {
            bgPrimary="#ffd6e8";bgSecondary="#ffe0f0";bgCard="#ffcad8";bgDeep="#ffb8cc"
            accentColor="#e91e8c";borderColor="#f48fb1";textPrimary="#3a0018";textMuted="#c2185b"
        // ── Tema Pop Culture ───────────────────────────────────────────────
        } else if (appTheme === "vintage") {
            bgPrimary="#1c1208";bgSecondary="#2e1f0e";bgCard="#120c04";bgDeep="#0a0700"
            accentColor="#d4a24c";borderColor="#4a3010";textPrimary="#f5e6c8";textMuted="#9c7a4a"
        } else if (appTheme === "retro") {
            bgPrimary="#050010";bgSecondary="#0a0018";bgCard="#030008";bgDeep="#020006"
            accentColor="#ff00ff";borderColor="#280040";textPrimary="#ffe0ff";textMuted="#cc44cc"
        } else if (appTheme === "vaporwave") {
            bgPrimary="#100020";bgSecondary="#1a0028";bgCard="#0c0018";bgDeep="#080010"
            accentColor="#ff71ce";borderColor="#3a0050";textPrimary="#fff0ff";textMuted="#b060cc"
        } else if (appTheme === "cyberpunk") {
            bgPrimary="#06000e";bgSecondary="#0a0014";bgCard="#040008";bgDeep="#020006"
            accentColor="#ffe600";borderColor="#200038";textPrimary="#fffff0";textMuted="#9900ff"
        } else if (appTheme === "lofi") {
            bgPrimary="#0e0c18";bgSecondary="#1a1428";bgCard="#090810";bgDeep="#060610"
            accentColor="#b39ddb";borderColor="#2a2040";textPrimary="#ede7f6";textMuted="#9575cd"
        } else if (appTheme === "cottagecore") {
            bgPrimary="#d8cebc";bgSecondary="#e8dcc8";bgCard="#ccc4b0";bgDeep="#c0b8a0"
            accentColor="#5d4e37";borderColor="#b8aa90";textPrimary="#2a1c10";textMuted="#795548"
        } else if (appTheme === "dark_academia") {
            bgPrimary="#100e08";bgSecondary="#1e1810";bgCard="#0a0c06";bgDeep="#060800"
            accentColor="#c8a96e";borderColor="#3a3018";textPrimary="#f5ead8";textMuted="#a89060"
        } else if (appTheme === "y2k") {
            bgPrimary="#060c18";bgSecondary="#0a1428";bgCard="#040a10";bgDeep="#020610"
            accentColor="#00ffff";borderColor="#103050";textPrimary="#e0ffff";textMuted="#0099cc"
        } else if (appTheme === "pastel_goth") {
            bgPrimary="#0e0810";bgSecondary="#1a0a1a";bgCard="#080608";bgDeep="#040404"
            accentColor="#cc99ff";borderColor="#2a0a2a";textPrimary="#f0e0f0";textMuted="#9966aa"
        } else if (appTheme === "skater") {
            bgPrimary="#080808";bgSecondary="#0f0f0f";bgCard="#060606";bgDeep="#040404"
            accentColor="#ff4500";borderColor="#222222";textPrimary="#eeeeee";textMuted="#888888"
        // ── Tema Angkasa & Sci-fi ──────────────────────────────────────────
        } else if (appTheme === "galaxy") {
            bgPrimary="#020212";bgSecondary="#050520";bgCard="#010110";bgDeep="#010108"
            accentColor="#7c4dff";borderColor="#100838";textPrimary="#ede7f6";textMuted="#7c5ccc"
        } else if (appTheme === "nebula") {
            bgPrimary="#080318";bgSecondary="#0d0520";bgCard="#060210";bgDeep="#040108"
            accentColor="#e040fb";borderColor="#220840";textPrimary="#f3e5f5";textMuted="#aa44cc"
        } else if (appTheme === "cosmos") {
            bgPrimary="#040610";bgSecondary="#060a1e";bgCard="#020408";bgDeep="#010308"
            accentColor="#40c4ff";borderColor="#0c1840";textPrimary="#e3f2fd";textMuted="#4488cc"
        } else if (appTheme === "mars") {
            bgPrimary="#0a0602";bgSecondary="#1a0a05";bgCard="#080502";bgDeep="#060402"
            accentColor="#ff6e40";borderColor="#3a1808";textPrimary="#fbe9e7";textMuted="#ff8a65"
        } else if (appTheme === "bulan") {
            bgPrimary="#080808";bgSecondary="#0e0e14";bgCard="#060606";bgDeep="#040404"
            accentColor="#eeeeee";borderColor="#202028";textPrimary="#f5f5f5";textMuted="#aaaaaa"
        } else if (appTheme === "bima_sakti") {
            bgPrimary="#020210";bgSecondary="#040418";bgCard="#010108";bgDeep="#010106"
            accentColor="#82b1ff";borderColor="#0a0a30";textPrimary="#e8eaf6";textMuted="#5c7acc"
        } else if (appTheme === "blackhole") {
            bgPrimary="#000002";bgSecondary="#000005";bgCard="#000001";bgDeep="#000000"
            accentColor="#ea80fc";borderColor="#0a000a";textPrimary="#e0d0e0";textMuted="#7a5080"
        } else if (appTheme === "neon_space") {
            bgPrimary="#040010";bgSecondary="#080018";bgCard="#030008";bgDeep="#010005"
            accentColor="#69ff47";borderColor="#102010";textPrimary="#e0ffe0";textMuted="#44aa44"
        } else if (appTheme === "asteroid") {
            bgPrimary="#050404";bgSecondary="#0a0808";bgCard="#040303";bgDeep="#030202"
            accentColor="#ff6d00";borderColor="#1a1008";textPrimary="#fbe9e7";textMuted="#cc7040"
        } else if (appTheme === "saturn") {
            bgPrimary="#060810";bgSecondary="#0d1020";bgCard="#040608";bgDeep="#030408"
            accentColor="#ffca28";borderColor="#181828";textPrimary="#fffde7";textMuted="#ffb300"
        // ── Tema Seni & Estetika ───────────────────────────────────────────
        } else if (appTheme === "monokrom") {
            bgPrimary="#0e0e0e";bgSecondary="#1a1a1a";bgCard="#0a0a0a";bgDeep="#060606"
            accentColor="#aaaaaa";borderColor="#2a2a2a";textPrimary="#eeeeee";textMuted="#666666"
        } else if (appTheme === "sepia") {
            bgPrimary="#140e08";bgSecondary="#2a1e10";bgCard="#0e0a06";bgDeep="#0a0804"
            accentColor="#c8a96e";borderColor="#4a3420";textPrimary="#f5e6cc";textMuted="#9c7a4a"
        } else if (appTheme === "neon") {
            bgPrimary="#020302";bgSecondary="#050505";bgCard="#010201";bgDeep="#000100"
            accentColor="#39ff14";borderColor="#0a1a0a";textPrimary="#e0ffe0";textMuted="#40aa44"
        } else if (appTheme === "glassmorphism") {
            bgPrimary="#0e1428";bgSecondary="#1a2240";bgCard="#0a1020";bgDeep="#060c18"
            accentColor="#90caf9";borderColor="#2040a0";textPrimary="#e3f2fd";textMuted="#5c8acc"
        } else if (appTheme === "bauhaus") {
            bgPrimary="#f0e8e0";bgSecondary="#f5f0e8";bgCard="#ece0d8";bgDeep="#e0d4c8"
            accentColor="#e53935";borderColor="#d4c4b8";textPrimary="#1a1008";textMuted="#795548"
        } else if (appTheme === "memphis") {
            bgPrimary="#f2f2f2";bgSecondary="#fafafa";bgCard="#eaeaea";bgDeep="#e0e0e0"
            accentColor="#ff6f00";borderColor="#cccccc";textPrimary="#1a1a1a";textMuted="#666666"
        } else if (appTheme === "brutalist") {
            bgPrimary="#e0d8cc";bgSecondary="#e8e0d0";bgCard="#d8d0c4";bgDeep="#ccc8bc"
            accentColor="#212121";borderColor="#b8b4a8";textPrimary="#0a0808";textMuted="#444444"
        } else if (appTheme === "grunge") {
            bgPrimary="#0a0a04";bgSecondary="#1a1008";bgCard="#080804";bgDeep="#060604"
            accentColor="#9e9d24";borderColor="#2a2a10";textPrimary="#f5f5e0";textMuted="#7a7844"
        } else if (appTheme === "watercolor") {
            bgPrimary="#dceef4";bgSecondary="#e8f4f8";bgCard="#d0e8f0";bgDeep="#c4dde8"
            accentColor="#0277bd";borderColor="#a0c8dc";textPrimary="#0a2030";textMuted="#3a8098"
        } else if (appTheme === "noir") {
            bgPrimary="#060606";bgSecondary="#0a0a0a";bgCard="#040404";bgDeep="#020202"
            accentColor="#c8b8a2";borderColor="#181818";textPrimary="#d8d0c8";textMuted="#888878"
        // ── Tema Budaya ────────────────────────────────────────────────────
        } else if (appTheme === "sakura") {
            bgPrimary="#0e060a";bgSecondary="#1a0a14";bgCard="#0a0408";bgDeep="#070306"
            accentColor="#f48fb1";borderColor="#3a1028";textPrimary="#fce4ec";textMuted="#e57399"
        } else if (appTheme === "samurai") {
            bgPrimary="#050500";bgSecondary="#0a0a00";bgCard="#030300";bgDeep="#020200"
            accentColor="#c62828";borderColor="#202000";textPrimary="#fff8e0";textMuted="#aa8844"
        } else if (appTheme === "batik") {
            bgPrimary="#0c0a00";bgSecondary="#1a0e00";bgCard="#080800";bgDeep="#050500"
            accentColor="#ff8f00";borderColor="#3a2800";textPrimary="#fff8e0";textMuted="#cc7700"
        } else if (appTheme === "melayu") {
            bgPrimary="#060e0c";bgSecondary="#0a1a14";bgCard="#040a08";bgDeep="#030806"
            accentColor="#4db6ac";borderColor="#103828";textPrimary="#e0f2f0";textMuted="#4aa498"
        } else if (appTheme === "india") {
            bgPrimary="#0d0600";bgSecondary="#1a0a00";bgCard="#080400";bgDeep="#040200"
            accentColor="#ff9800";borderColor="#3a1800";textPrimary="#fff3e0";textMuted="#ffa726"
        } else if (appTheme === "nordic2") {
            bgPrimary="#080e14";bgSecondary="#0e1820";bgCard="#060a0e";bgDeep="#040608"
            accentColor="#78909c";borderColor="#182030";textPrimary="#eceff1";textMuted="#607d8b"
        } else if (appTheme === "aztec") {
            bgPrimary="#0d0a00";bgSecondary="#1a0e00";bgCard="#0a0800";bgDeep="#060600"
            accentColor="#ffca28";borderColor="#3a2800";textPrimary="#fff8e0";textMuted="#ffb300"
        } else if (appTheme === "mediterania") {
            bgPrimary="#060e0c";bgSecondary="#0a1814";bgCard="#040a08";bgDeep="#030806"
            accentColor="#26a69a";borderColor="#0a3430";textPrimary="#e0f2f0";textMuted="#4db6ac"
        } else if (appTheme === "amazon") {
            bgPrimary="#050d04";bgSecondary="#0a1a08";bgCard="#030a02";bgDeep="#020602"
            accentColor="#66bb6a";borderColor="#0e3010";textPrimary="#e8f5e9";textMuted="#4caf50"
        } else if (appTheme === "arctic") {
            bgPrimary="#060c18";bgSecondary="#0a1428";bgCard="#040a10";bgDeep="#020810"
            accentColor="#b3e5fc";borderColor="#102848";textPrimary="#e1f5fe";textMuted="#4fc3f7"
        // ── Tema Bonus ─────────────────────────────────────────────────────
        } else if (appTheme === "neon_pink") {
            bgPrimary="#0d000d";bgSecondary="#1a001a";bgCard="#080008";bgDeep="#040004"
            accentColor="#ff4dd2";borderColor="#3a0038";textPrimary="#ffe0ff";textMuted="#cc44cc"
        } else if (appTheme === "emerald") {
            bgPrimary="#000e06";bgSecondary="#001a0e";bgCard="#000a04";bgDeep="#000602"
            accentColor="#00e676";borderColor="#003a18";textPrimary="#e0fff0";textMuted="#44cc88"
        } else if (appTheme === "amber") {
            bgPrimary="#0e0800";bgSecondary="#1a0e00";bgCard="#0a0600";bgDeep="#060400"
            accentColor="#ffab40";borderColor="#3a2000";textPrimary="#fff8e0";textMuted="#ff8f00"
        } else if (appTheme === "indigo") {
            bgPrimary="#060618";bgSecondary="#0a0a28";bgCard="#040410";bgDeep="#020210"
            accentColor="#536dfe";borderColor="#141450";textPrimary="#e8eaf6";textMuted="#5c72cc"
        } else if (appTheme === "rose_gold") {
            bgPrimary="#120608";bgSecondary="#200a10";bgCard="#0e0406";bgDeep="#0a0304"
            accentColor="#f48fb1";borderColor="#401020";textPrimary="#fce4ec";textMuted="#e06080"
        } else if (appTheme === "obsidian") {
            bgPrimary="#050508";bgSecondary="#08080c";bgCard="#040406";bgDeep="#020204"
            accentColor="#607d8b";borderColor="#141620";textPrimary="#eceff1";textMuted="#546e7a"
        } else if (appTheme === "senja") {
            bgPrimary="#0e0608";bgSecondary="#1a0d10";bgCard="#0a0406";bgDeep="#080304"
            accentColor="#ff7043";borderColor="#3a1418";textPrimary="#fbe9e7";textMuted="#ff8a65"
        } else if (appTheme === "pagi") {
            bgPrimary="#f8e0c0";bgSecondary="#ffe0b0";bgCard="#f4d8b0";bgDeep="#eccca0"
            accentColor="#e65100";borderColor="#d4b890";textPrimary="#2a1000";textMuted="#bf5500"
        } else if (appTheme === "neon_biru") {
            bgPrimary="#000610";bgSecondary="#000a18";bgCard="#000408";bgDeep="#000306"
            accentColor="#00b0ff";borderColor="#002040";textPrimary="#e0f4ff";textMuted="#0088cc"
        } else if (appTheme === "pistachio") {
            bgPrimary="#080f04";bgSecondary="#0e1a08";bgCard="#060a02";bgDeep="#040702"
            accentColor="#c5e1a5";borderColor="#182c0a";textPrimary="#f1f8e9";textMuted="#8bc34a"
        }
        color = bgPrimary
    }

    // ════════════════════════════════════════════════════════════════════════
    // GLOBAL NOTIFICATION BANNER
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: globalNotifBanner
        z: 9999
        width: 360; height: 72; radius: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 16
        visible: false; opacity: 0

        // warna border sesuai tipe
        property string notifType: "info"
        property color borderCol: notifType === "pomodoro" ? "#ff6b35"
                                 : notifType === "task"    ? "#ffcc00"
                                 : notifType === "friend"  ? "#2ecc71"
                                 : window.accentColor

        color: window.bgSecondary
        border.color: borderCol; border.width: 2

        // Shadow effect
        layer.enabled: true
        layer.effect: null

        property string notifEmoji: "🔔"
        property string notifTitle: ""
        property string notifBody:  ""

        function show(emoji, title, body, type) {
            notifEmoji = emoji; notifTitle = title; notifBody = body; notifType = type || "info"
            visible = true
            showAnim.restart()
            autoHide.restart()
        }

        NumberAnimation { id: showAnim; target: globalNotifBanner; property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
        NumberAnimation { id: hideAnim; target: globalNotifBanner; property: "opacity"; from: 1; to: 0; duration: 300; easing.type: Easing.InCubic; onFinished: globalNotifBanner.visible = false }
        Timer { id: autoHide; interval: 4500; onTriggered: hideAnim.restart() }

        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 12

            // Ikon lingkaran berwarna
            Rectangle {
                width: 44; height: 44; radius: 22
                color: Qt.rgba(globalNotifBanner.borderCol.r, globalNotifBanner.borderCol.g, globalNotifBanner.borderCol.b, 0.18)
                border.color: globalNotifBanner.borderCol; border.width: 1.5
                Text { anchors.centerIn: parent; text: globalNotifBanner.notifEmoji; font.pixelSize: 22 }
            }

            Column {
                spacing: 3; Layout.fillWidth: true
                Text { text: globalNotifBanner.notifTitle; color: window.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width }
                Text { text: globalNotifBanner.notifBody;  color: window.textMuted;   font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }
            }

            // Tombol tutup
            Rectangle {
                width: 24; height: 24; radius: 12; color: window.borderColor
                Text { anchors.centerIn: parent; text: "✕"; color: window.textMuted; font.pixelSize: 10; font.bold: true }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: hideAnim.restart() }
            }
        }

        // Klik banner untuk dismiss
        MouseArea { anchors.fill: parent; onClicked: hideAnim.restart() }
    }

    component AnimatedBorder : Item {
        property int borderStyle: window.selectedBorder
        property int size: 64
        width: size; height: size

        // Style 1: Rotating gradient ring
        Rectangle {
            visible: borderStyle === 1
            anchors.fill: parent; radius: width/2
            color: "transparent"
            border.width: 3
            border.color: "transparent"

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    var grad = ctx.createLinearGradient(0, 0, width, height)
                    grad.addColorStop(0, "#ff0080")
                    grad.addColorStop(0.5, "#ffcc00")
                    grad.addColorStop(1, "#00ff88")
                    ctx.strokeStyle = grad
                    ctx.lineWidth = 4
                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/2 - 3, 0, Math.PI*2)
                    ctx.stroke()
                }
            }

            RotationAnimator {
                target: parent; from: 0; to: 360
                duration: 3000; loops: Animation.Infinite; running: borderStyle === 1
            }
        }
    }

    // Sound effect global untuk notifikasi
    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    // ════════════════════════════════════════════════════════════════════════
    // POMODORO NOTIFICATION LOGIC
    // ════════════════════════════════════════════════════════════════════════
    // Deteksi timer mulai
    onGlobalTimerRunningChanged: {
        if (globalTimerRunning) {
            pushNotif("🍅", lang.fokus + " " + lang.mulaiSesi + "!", pomodoroFokus + " " + lang.menit + " " + lang.fokus + " — " + lang.semangatBelajar, "pomodoro")
        }
    }

    // Deteksi timer habis (value turun ke 0 saat running)
    onGlobalCurrentTimerValueChanged: {
        // Tepat habis → value jadi 0 dan timer masih running
        if (globalCurrentTimerValue === 0 && globalTimerRunning === false && globalSessionsCompleted > 0) {
            pushNotif("✅", lang.sesiSelesai + "! 🎉", lang.istirahat + " " + pomodoroIstirahat + " " + lang.menit + "!", "pomodoro")
        }
    }

    // Deteksi sesi selesai (globalSessionsCompleted naik)
    property int _prevSessions: 0
    onGlobalSessionsCompletedChanged: {
        if (globalSessionsCompleted > _prevSessions && _prevSessions >= 0) {
            _prevSessions = globalSessionsCompleted
            if (globalSessionsCompleted >= globalTargetSessions) {
                pushNotif("🏆", lang.targetHarian + "!", globalSessionsCompleted + " " + lang.sesi + " — " + lang.motivasiAkhir, "pomodoro")
            } else {
                pushNotif("✅", lang.sesiKe + globalSessionsCompleted + " " + lang.selesai + "!", lang.istirahat + " " + pomodoroIstirahat + " " + lang.menit + "~", "pomodoro")
            }
        }
    }

    function resetWindowState() {
        window.namaUser                = "Pengguna"
        window.statusUser              = "Semangat Belajar! 💪"
        window.selectedAvatar          = 0
        window.globalSessionsCompleted = 0
        window.globalSecondsFocused    = 0
        window.globalSeconds           = 0
        window.globalTimerRunning      = false
        window.globalCurrentTimerValue = 0
        window.currentUser             = ""
        window.currentActiveTask       = lang.belumAdaTugas
        window.chatHistories           = ({})
        globalTaskModel.clear()
        chatModel.clear()
    }

    // ── Property untuk notif teman (TemanPage set ini, Main.qml reaksi) ─────
    // Menggunakan property + onChanged karena Loader membuat TemanPage di scope berbeda
    // sehingga signal tidak bisa di-emit langsung ke parent window.
    property string lastFriendNotif: ""   // format: "NamaUser||PesanBalasan"

    onLastFriendNotifChanged: {
        if (lastFriendNotif !== "") {
            var parts = lastFriendNotif.split("||")
            pushNotif("💬", parts[0], parts[1], "friend")   // ✅ pakai fungsi global
        }
    }

    Timer {
        id: taskReminderTimer
        interval: 20000; repeat: true; running: true
        onTriggered: {
            var now = Date.now()
            var thresholds = [
                { ms: 86400000, label: "1 " + lang.hari,   key: "1d"  },
                { ms: 3600000,  label: "1 " + lang.jam,    key: "1h"  },
                { ms: 1800000,  label: "30 " + lang.menit, key: "30m" },
                { ms: 900000,   label: "15 " + lang.menit, key: "15m" },
                { ms: 60000,    label: "1 " + lang.menit,  key: "1m"  },
            ]
            for (var i = 0; i < globalTaskModel.count; i++) {
                var task = globalTaskModel.get(i)
                if (task.isDone) continue
                var sisa = task.deadlineTimestamp - now
                if (sisa <= 0) continue

                for (var t = 0; t < thresholds.length; t++) {
                    var th = thresholds[t]
                    // Window 65 detik lebih lebar dari interval 20s → tidak akan kelewat
                    if (sisa <= th.ms && sisa > th.ms - 65000) {
                        var notifKey = task.title + "_" + th.key
                        if (!window._notifiedTasks[notifKey]) {
                            window._notifiedTasks[notifKey] = true
                            pushNotif("📋", lang.deadline + " " + th.label + " lagi!", task.title, "task")
                        }
                    }
                }
            }
        }
    }

    Languange { id: lang }

    // ── DATA DATABASE TEMAN ──────────────────────────────────────────────────
    ListModel {
        id: allUsersModel
        ListElement { name: "Hesekiel"; status: "Online • Fokus Belajar"; isOnline: true; initial: "H" }
        ListElement { name: "Arcellya"; status: "Offline • Terakhir 5m lalu"; isOnline: false; initial: "A" }
        ListElement { name: "Salsabila"; status: "Online • Menulis Tugas"; isOnline: true; initial: "S" }
        ListElement { name: "Monika"; status: "Online • Study Room"; isOnline: true; initial: "M" }
        ListElement { name: "Andi"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "A" }
        ListElement { name: "Budi"; status: "Online • Mengejar Deadline"; isOnline: true; initial: "B" }
        ListElement { name: "Citra"; status: "Online • Fokus Belajar"; isOnline: true; initial: "C" }
        ListElement { name: "Dewi"; status: "Offline • Terakhir 60m lalu"; isOnline: false; initial: "D" }
        ListElement { name: "Dyra"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "D" }
        ListElement { name: "Iraya"; status: "Online • Mengerjakan Tugas"; isOnline: true; initial: "I" }
        ListElement { name: "Putri"; status: "Online • Istirahat"; isOnline: true; initial: "P" }
        ListElement { name: "Naomi"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "N" }
        ListElement { name: "Jannah"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "J" }
        ListElement { name: "Maria"; status: "Offline • Terakhir 10m lalu"; isOnline: false; initial: "M" }
        ListElement { name: "Bella"; status: "Online • Fokus Belajar"; isOnline: true; initial: "B" }
        ListElement { name: "Ika"; status: "Offline • Terakhir 2h lalu"; isOnline: false; initial: "I" }
        ListElement { name: "Jibran"; status: "Online • Bermain musik"; isOnline: true; initial: "J" }
        ListElement { name: "Kia"; status: "Offline • Terakhir 14m lalu"; isOnline: false; initial: "K" }
        ListElement { name: "Artika"; status: "Online • Fokus Belajar"; isOnline: true; initial: "A" }
        ListElement { name: "Keysya"; status: "Offline • Terakhir 25m lalu"; isOnline: false; initial: "K" }
        ListElement { name: "Sahira"; status: "Online • Mengerjakan Laprak"; isOnline: true; initial: "S" }
        ListElement { name: "Vanesya"; status: "Offline • Terakhir 10d lalu"; isOnline: false; initial: "V" }
        ListElement { name: "Ahmad"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "A" }
        ListElement { name: "Herbert"; status: "Online • Ngoding"; isOnline: true; initial: "H" }
        ListElement { name: "Ana"; status: "Online"; isOnline: true; initial: "A" }
        ListElement { name: "Raduola"; status: "Offline • Terakhir 36m lalu"; isOnline: false; initial: "R" }
        ListElement { name: "Hafiz"; status: "Online • Fokus Belajar"; isOnline: true; initial: "H" }
        ListElement { name: "Wawan"; status: "Online • Study Date"; isOnline: true; initial: "W" }
        ListElement { name: "Zahra"; status: "Offline • Terakhir 9j lalu"; isOnline: false; initial: "Z" }
        ListElement { name: "Xanon"; status: "Online • Mengerjakan Tugas"; isOnline: true; initial: "X" }
        ListElement { name: "Xinon"; status: "Online • Mengerjakan Tugas"; isOnline: true; initial: "X" }
        ListElement { name: "Yohana"; status: "Online • Menulis Tugas"; isOnline: true; initial: "Y" }
        ListElement { name: "Ella"; status: "Online • Istirahat"; isOnline: true; initial: "E" }
        ListElement { name: "Fufufafa"; status: "Offline • Terakhir 300h lalu"; isOnline: false; initial: "F" }
        ListElement { name: "Fathan"; status: "Online • Mengerjakan Laprak"; isOnline: true; initial: "F" }
        ListElement { name: "Galih"; status: "Offline • Terakhir 5h lalu"; isOnline: false; initial: "G" }
        ListElement { name: "Gugugaga"; status: "Offline • Terakhir 200h lalu"; isOnline: false; initial: "G" }
        ListElement { name: "Jihan"; status: "Online • Fokus Belajar"; isOnline: true; initial: "J" }
        ListElement { name: "LemonNipis"; status: "Offline • Terakhir 36h lalu"; isOnline: false; initial: "L" }
        ListElement { name: "Liza"; status: "Offline • Terakhir 19m lalu"; isOnline: false; initial: "L" }
        ListElement { name: "Keke"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "K" }
        ListElement { name: "Nadhif"; status: "Online • Ngoding"; isOnline: true; initial: "N" }
        ListElement { name: "Oswinov"; status: "Online • Ngoding"; isOnline: true; initial: "O" }
        ListElement { name: "Omara"; status: "Online • Membaca"; isOnline: true; initial: "O" }
        ListElement { name: "Ollie"; status: "Online • Melukis"; isOnline: true; initial: "O" }
        ListElement { name: "Patrick"; status: "Offline • Terakhir 2h lalu"; isOnline: false; initial: "P" }
        ListElement { name: "Qori"; status: "Offline • Terakhir 1m lalu"; isOnline: false; initial: "Q" }
        ListElement { name: "Qoqo"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "Q" }
        ListElement { name: "Rara"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "R" }
        ListElement { name: "Teguh"; status: "Offline • Terakhir 2h lalu"; isOnline: false; initial: "T" }
        ListElement { name: "Ulala"; status: "Online"; isOnline: true; initial: "U" }
        ListElement { name: "Udin"; status: "Online • Bermain Game"; isOnline: true; initial: "U" }
        ListElement { name: "Vania"; status: "Online • Fokus Belajar"; isOnline: true; initial: "V" }
        ListElement { name: "Salim"; status: "Online • Fokus Belajar"; isOnline: true; initial: "S" }
        ListElement { name: "Sandi"; status: "Online • Mengerjakan Tugas"; isOnline: true; initial: "S" }
        ListElement { name: "Willy"; status: "Online • Ngoding"; isOnline: true; initial: "W" }
        ListElement { name: "Yehezkiel"; status: "Offline • Terakhir 6h lalu"; isOnline: false; initial: "Y" }
        ListElement { name: "Kobo"; status: "Online • Bermain Game"; isOnline: true; initial: "K" }
        ListElement { name: "Nana"; status: "Offline"; isOnline: false; initial: "N" }
        ListElement { name: "Cici"; status: "Online • Ngoding"; isOnline: true; initial: "C" }
        ListElement { name: "Zeta"; status: "Online • Belajar"; isOnline: true; initial: "Z" }
        ListElement { name: "Nazwa"; status: "Online • Membaca"; isOnline: true; initial: "N" }
        ListElement { name: "Sunny"; status: "Offline"; isOnline: false; initial: "S" }
        ListElement { name: "Koko"; status: "Offline"; isOnline: false; initial: "K" }
        ListElement { name: "Fitri"; status: "Offline"; isOnline: false; initial: "F" }
        ListElement { name: "Airin"; status: "Offline"; isOnline: false; initial: "A" }
        ListElement { name: "Lapu-Lapu"; status: "Offline"; isOnline: false; initial: "L" }
        ListElement { name: "Aira"; status: "Offline"; isOnline: false; initial: "A" }
        ListElement { name: "Emu Otori"; status: "Offline"; isOnline: false; initial: "E" }
        ListElement { name: "Tsukasa"; status: "Offline"; isOnline: false; initial: "T" }
        ListElement { name: "Toya"; status: "Offline"; isOnline: false; initial: "T" }
        ListElement { name: "Aoyagi"; status: "Online • Bermain Musik"; isOnline: false; initial: "A" }
        ListElement { name: "Zyo"; status: "Online"; isOnline: true; initial: "Z" }
        ListElement { name: "Carmen"; status: "Online • Belajar"; isOnline: true; initial: "C" }
        ListElement { name: "Yeon"; status: "Online • Membaca"; isOnline: true; initial: "Y" }
        ListElement { name: "Yaya"; status: "Online • Belajar"; isOnline: true; initial: "Y" }
        ListElement { name: "Kobo"; status: "Online • Bermain Game"; isOnline: true; initial: "K" }
        ListElement { name: "Rosblok"; status: "Online • Bermain Game"; isOnline: true; initial: "R" }
        ListElement { name: "Bill Gates"; status: "Online"; isOnline: true; initial: "B" }
        ListElement { name: "Einstein"; status: "Offline"; isOnline: false; initial: "E" }
        ListElement { name: "Enanan"; status: "Offline"; isOnline: false; initial: "E" }
        ListElement { name: "Lucy"; status: "Offline"; isOnline: false; initial: "L" }
        ListElement { name: "Lulu"; status: "Offline"; isOnline: false; initial: "L" }
        ListElement { name: "Aqila"; status: "Offline"; isOnline: false; initial: "A" }
        ListElement { name: "Mama"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Mimi"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Momo"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Pororo"; status: "Offline"; isOnline: false; initial: "P" }
        ListElement { name: "Chikawa"; status: "Offline"; isOnline: false; initial: "C" }
        ListElement { name: "Usagi"; status: "Offline"; isOnline: false; initial: "U" }
        ListElement { name: "Hachiware"; status: "Offline"; isOnline: false; initial: "H" }
        ListElement { name: "Momonga"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Kurimanju"; status: "Offline"; isOnline: false; initial: "K" }
        ListElement { name: "Soto"; status: "Offline"; isOnline: false; initial: "S" }
        ListElement { name: "Sawako"; status: "Offline"; isOnline: false; initial: "S" }
        ListElement { name: "Miyamura"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Moona"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Pekora"; status: "Offline"; isOnline: false; initial: "P" }
        ListElement { name: "Risu"; status: "Offline"; isOnline: false; initial: "R" }
        ListElement { name: "Ayunda"; status: "Offline"; isOnline: false; initial: "A" }
        ListElement { name: "Kiki"; status: "Offline"; isOnline: false; initial: "K" }
        ListElement { name: "Tiki"; status: "Offline"; isOnline: false; initial: "T" }
        ListElement { name: "Wonhee"; status: "Offline"; isOnline: false; initial: "W" }
        ListElement { name: "Moka"; status: "Offline"; isOnline: false; initial: "M" }
        ListElement { name: "Gehlee"; status: "Offline"; isOnline: false; initial: "G" }
        ListElement { name: "Abdi"; status: "Online • Review Materi"; isOnline: true; initial: "A" }
            ListElement { name: "Aditya"; status: "Offline • Terakhir 12m lalu"; isOnline: false; initial: "A" }
            ListElement { name: "Angga"; status: "Online • Diskus Kelompok"; isOnline: true; initial: "A" }
            ListElement { name: "Anisa"; status: "Online • Membuat Summary"; isOnline: true; initial: "A" }
            ListElement { name: "Ari"; status: "Offline • Terakhir 45m lalu"; isOnline: false; initial: "A" }
            ListElement { name: "Arif"; status: "Online • Baca E-Book"; isOnline: true; initial: "A" }
            ListElement { name: "Aulia"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "A" }
            ListElement { name: "Aziz"; status: "Online • Belajar UTS"; isOnline: true; initial: "A" }
            ListElement { name: "Bagus"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "B" }
            ListElement { name: "Bambang"; status: "Online • Ngoding C++"; isOnline: true; initial: "B" }
            ListElement { name: "Beni"; status: "Online • Cari Jurnal"; isOnline: true; initial: "B" }
            ListElement { name: "Bintang"; status: "Offline • Terakhir 8j lalu"; isOnline: false; initial: "B" }
            ListElement { name: "Candra"; status: "Online • Nulis Laporan"; isOnline: true; initial: "C" }
            ListElement { name: "Chandra"; status: "Offline • Terakhir 16m lalu"; isOnline: false; initial: "C" }
            ListElement { name: "Cynthia"; status: "Online • Review Kuis"; isOnline: true; initial: "C" }
            ListElement { name: "Daniel"; status: "Online • Simulasi UTBK"; isOnline: true; initial: "D" }
            ListElement { name: "Denny"; status: "Offline • Terakhir 22m lalu"; isOnline: false; initial: "D" }
            ListElement { name: "Desta"; status: "Online • Bikin PPT"; isOnline: true; initial: "D" }
            ListElement { name: "Dian"; status: "Offline • Terakhir 15j lalu"; isOnline: false; initial: "D" }
            ListElement { name: "Diki"; status: "Online • Room 3"; isOnline: true; initial: "D" }
            ListElement { name: "Dimas"; status: "Online • Mengerjakan Kuis"; isOnline: true; initial: "D" }
            ListElement { name: "Dina"; status: "Offline • Terakhir 4m lalu"; isOnline: false; initial: "D" }
            ListElement { name: "Dinda"; status: "Online • Belajar Mandiri"; isOnline: true; initial: "D" }
            ListElement { name: "Doni"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "D" }
            ListElement { name: "Edo"; status: "Online • Latihan Coding"; isOnline: true; initial: "E" }
            ListElement { name: "Eka Putra"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "E" }
            ListElement { name: "Eko"; status: "Online • Cari Referensi"; isOnline: true; initial: "E" }
            ListElement { name: "Elisa"; status: "Offline • Terakhir 30m lalu"; isOnline: false; initial: "E" }
            ListElement { name: "Elsa"; status: "Online • Fokus Pomodoro"; isOnline: true; initial: "E" }
            ListElement { name: "Endah"; status: "Offline • Terakhir 2d lalu"; isOnline: false; initial: "E" }
            ListElement { name: "Erick"; status: "Online • Push Laprak"; isOnline: true; initial: "E" }
            ListElement { name: "Erwin"; status: "Offline • Terakhir 4h lalu"; isOnline: false; initial: "E" }
            ListElement { name: "Fadilah"; status: "Online • Ngerangkum Bab 4"; isOnline: true; initial: "F" }
            ListElement { name: "Fahmi"; status: "Offline • Terakhir 12j lalu"; isOnline: false; initial: "F" }
            ListElement { name: "Faisal"; status: "Online • Mengerjakan Tugas"; isOnline: true; initial: "F" }
            ListElement { name: "Fajar"; status: "Online • Cari Ide Projek"; isOnline: true; initial: "F" }
            ListElement { name: "Farah"; status: "Offline • Terakhir 18m lalu"; isOnline: false; initial: "F" }
            ListElement { name: "Farhan"; status: "Online • Review Matkul"; isOnline: true; initial: "F" }
            ListElement { name: "Faris"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "F" }
            ListElement { name: "Febri"; status: "Online • Ngedit Video"; isOnline: true; initial: "F" }
            ListElement { name: "Ferry"; status: "Offline • Terakhir 3d lalu"; isOnline: false; initial: "F" }
            ListElement { name: "Gani"; status: "Online • Belajar Alpro"; isOnline: true; initial: "G" }
            ListElement { name: "Guntur"; status: "Offline • Terakhir 55m lalu"; isOnline: false; initial: "G" }
            ListElement { name: "Hadi"; status: "Online • Nulis Logbook"; isOnline: true; initial: "H" }
            ListElement { name: "Hana"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "H" }
            ListElement { name: "Hany"; status: "Online • Diskusi Zoom"; isOnline: true; initial: "H" }
            ListElement { name: "Haris"; status: "Offline • Terakhir 4d lalu"; isOnline: false; initial: "H" }
            ListElement { name: "Hendra"; status: "Online • Latihan Soal"; isOnline: true; initial: "H" }
            ListElement { name: "Heru"; status: "Offline • Terakhir 12m lalu"; isOnline: false; initial: "H" }
            ListElement { name: "Hussein"; status: "Online • Room Belajar 1"; isOnline: true; initial: "H" }
            ListElement { name: "Ichsan"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "I" }
            ListElement { name: "Ihsan"; status: "Online • Ngoding Python"; isOnline: true; initial: "I" }
            ListElement { name: "Ilham"; status: "Online • Baca Diktat"; isOnline: true; initial: "I" }
            ListElement { name: "Indah"; status: "Offline • Terakhir 17m lalu"; isOnline: false; initial: "I" }
            ListElement { name: "Indra"; status: "Online • Tugas Struktur Data"; isOnline: true; initial: "I" }
            ListElement { name: "Irfan"; status: "Offline • Terakhir 9j lalu"; isOnline: false; initial: "I" }
            ListElement { name: "Iwan"; status: "Online • Grind Kuis"; isOnline: true; initial: "I" }
            ListElement { name: "Jajang"; status: "Offline • Terakhir 6h lalu"; isOnline: false; initial: "J" }
            ListElement { name: "Joko"; status: "Online • Belajar Kalkulus"; isOnline: true; initial: "J" }
            ListElement { name: "Joni"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "J" }
            ListElement { name: "Julia"; status: "Online • Translate Jurnal"; isOnline: true; initial: "J" }
            ListElement { name: "Kevin"; status: "Online • Kelompok 5"; isOnline: true; initial: "K" }
            ListElement { name: "Kiki Amalia"; status: "Offline • Terakhir 4m lalu"; isOnline: false; initial: "K" }
            ListElement { name: "Kurnia"; status: "Online • Resume Bab 2"; isOnline: true; initial: "K" }
            ListElement { name: "Laras"; status: "Offline • Terakhir 8j lalu"; isOnline: false; initial: "L" }
            ListElement { name: "Latifah"; status: "Online • Kelompok Statistik"; isOnline: true; initial: "L" }
            ListElement { name: "Lestari"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "L" }
            ListElement { name: "Lia"; status: "Online • Tugas Mandiri"; isOnline: true; initial: "L" }
            ListElement { name: "Lukman"; status: "Offline • Terakhir 44m lalu"; isOnline: false; initial: "L" }
            ListElement { name: "Luthfi"; status: "Online • Setup Project"; isOnline: true; initial: "L" }
            ListElement { name: "Maman"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "M" }
            ListElement { name: "Mansur"; status: "Online • Ngedit Dokumen"; isOnline: true; initial: "M" }
            ListElement { name: "Maulana"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "M" }
            ListElement { name: "Mega"; status: "Online • Room Sunyi"; isOnline: true; initial: "M" }
            ListElement { name: "Melati"; status: "Offline • Terakhir 14j lalu"; isOnline: false; initial: "M" }
            ListElement { name: "Miftah"; status: "Online • Cari Kisi-Kisi"; isOnline: true; initial: "M" }
            ListElement { name: "Muamar"; status: "Offline • Terakhir 7m lalu"; isOnline: false; initial: "M" }
            ListElement { name: "Nabila"; status: "Online • Bikin Flowchart"; isOnline: true; initial: "N" }
            ListElement { name: "Nadia"; status: "Offline • Terakhir 50m lalu"; isOnline: false; initial: "N" }
            ListElement { name: "Naufal"; status: "Online • Git Commit Lab"; isOnline: true; initial: "N" }
            ListElement { name: "Novi"; status: "Offline • Terakhir 13j lalu"; isOnline: false; initial: "N" }
            ListElement { name: "Nurul"; status: "Online • Kerjain Makalah"; isOnline: true; initial: "N" }
            ListElement { name: "Oka"; status: "Offline • Terakhir 2h lalu"; isOnline: false; initial: "O" }
            ListElement { name: "Panji"; status: "Online • Baca PDF Kuliah"; isOnline: true; initial: "P" }
            ListElement { name: "Pratama"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "P" }
            ListElement { name: "Puji"; status: "Online • Gambar Teknik"; isOnline: true; initial: "P" }
            ListElement { name: "Putra"; status: "Offline • Terakhir 35m lalu"; isOnline: false; initial: "P" }
            ListElement { name: "Rahma"; status: "Online • Review Matkul AI"; isOnline: true; initial: "R" }
            ListElement { name: "Rian"; status: "Offline • Terakhir 18j lalu"; isOnline: false; initial: "R" }
            ListElement { name: "Riki"; status: "Online • Ngoding FrontEnd"; isOnline: true; initial: "R" }
            ListElement { name: "Riza"; status: "Offline • Terakhir 6m lalu"; isOnline: false; initial: "R" }
            ListElement { name: "Rizal"; status: "Online • Ngerangkum Jurnal"; isOnline: true; initial: "R" }
            ListElement { name: "Rizki"; status: "Online • Sesi Fokus"; isOnline: true; initial: "R" }
            ListElement { name: "Rizky"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "R" }
            ListElement { name: "Sandiaga"; status: "Online • Edit Poster"; isOnline: true; initial: "S" }
            ListElement { name: "Satria"; status: "Offline • Terakhir 28m lalu"; isOnline: false; initial: "S" }
            ListElement { name: "Septian"; status: "Online • Nugas Kelompok"; isOnline: true; initial: "S" }
                ListElement { name: "Sila"; status: "Offline • Terakhir 11j lalu"; isOnline: false; initial: "S" }
                ListElement { name: "Sinta"; status: "Online • Latihan Toefl"; isOnline: true; initial: "S" }
                ListElement { name: "Siti"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "S" }
                ListElement { name: "Sri"; status: "Online • Baca Diktat Kuliah"; isOnline: true; initial: "S" }
                ListElement { name: "Suci"; status: "Offline • Terakhir 40m lalu"; isOnline: false; initial: "S" }
                ListElement { name: "Suryo"; status: "Online • Projek Web"; isOnline: true; initial: "S" }
                ListElement { name: "Tantri"; status: "Offline • Terakhir 5d lalu"; isOnline: false; initial: "T" }
                ListElement { name: "Taufik"; status: "Online • Kalkulus Dasar"; isOnline: true; initial: "T" }
                ListElement { name: "Tika"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "T" }
                ListElement { name: "Tri"; status: "Online • Analisis Data"; isOnline: true; initial: "T" }
                ListElement { name: "Utami"; status: "Offline • Terakhir 9m lalu"; isOnline: false; initial: "U" }
                ListElement { name: "Vicky"; status: "Online • Desain UI/UX"; isOnline: true; initial: "V" }
                ListElement { name: "Vina"; status: "Offline • Terakhir 16j lalu"; isOnline: false; initial: "V" }
                ListElement { name: "Wahyu"; status: "Online • Bikin Sketsa"; isOnline: true; initial: "W" }
                ListElement { name: "Widi"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "W" }
                ListElement { name: "Wijaya"; status: "Online • Kelompok Metpen"; isOnline: true; initial: "W" }
                ListElement { name: "Winda"; status: "Offline • Terakhir 4h lalu"; isOnline: false; initial: "W" }
                ListElement { name: "Yanto"; status: "Online • Cari Data Set"; isOnline: true; initial: "Y" }
                ListElement { name: "Yayan"; status: "Offline • Terakhir 14m lalu"; isOnline: false; initial: "Y" }
                ListElement { name: "Yuda"; status: "Online • Belajar Matdis"; isOnline: true; initial: "Y" }
                ListElement { name: "Yulia"; status: "Offline • Terakhir 30m lalu"; isOnline: false; initial: "Y" }
                ListElement { name: "Yunus"; status: "Online • Ngerangkum Perekonomian"; isOnline: true; initial: "Y" }
                ListElement { name: "Yusuf"; status: "Offline • Terakhir 12j lalu"; isOnline: false; initial: "Y" }
                ListElement { name: "Zainal"; status: "Online • Latihan SQL"; isOnline: true; initial: "Z" }
                ListElement { name: "Zaki"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "Z" }
                ListElement { name: "Zul"; status: "Online • Fix Bug Coding"; isOnline: true; initial: "Z" }
                ListElement { name: "Zulaikha"; status: "Offline • Terakhir 3d lalu"; isOnline: false; initial: "Z" }
                ListElement { name: "Abel"; status: "Online • Room Study 4"; isOnline: true; initial: "A" }
                ListElement { name: "Acep"; status: "Offline • Terakhir 18m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Achmad"; status: "Online • Tugas Alpro"; isOnline: true; initial: "A" }
                ListElement { name: "Ade"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Adelia"; status: "Online • Catat Rumus"; isOnline: true; initial: "A" }
                ListElement { name: "Adit"; status: "Offline • Terakhir 45m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Adri"; status: "Online • Sesi Baca Jurnal"; isOnline: true; initial: "A" }
                ListElement { name: "Agnes"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Agung"; status: "Online • Ngoding Python"; isOnline: true; initial: "A" }
                ListElement { name: "Agus"; status: "Offline • Terakhir 9j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Aldi"; status: "Online • Kelompok Basis Data"; isOnline: true; initial: "A" }
                ListElement { name: "Aldo"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Alex"; status: "Online • Cari Bahan Slide"; isOnline: true; initial: "A" }
                ListElement { name: "Alif"; status: "Offline • Terakhir 22m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Amelia"; status: "Online • Room Pomodoro"; isOnline: true; initial: "A" }
                ListElement { name: "Amin"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Amir"; status: "Online • Kelompok Kewirausahaan"; isOnline: true; initial: "A" }
                ListElement { name: "Andika"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Andre"; status: "Online • Tugas Pengantar TI"; isOnline: true; initial: "A" }
                ListElement { name: "Anggi"; status: "Offline • Terakhir 2d lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Anggoro"; status: "Online • Latihan Logika"; isOnline: true; initial: "A" }
                ListElement { name: "Anwar"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Aprilianto"; status: "Online • Analisis Laprak"; isOnline: true; initial: "A" }
                ListElement { name: "Ardi"; status: "Offline • Terakhir 13m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Ardiansyah"; status: "Online • Kelompok Kewarganegaraan"; isOnline: true; initial: "A" }
                ListElement { name: "Arga"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Aria"; status: "Online • Simulasi Soal UTBK"; isOnline: true; initial: "A" }
                ListElement { name: "Arie"; status: "Offline • Terakhir 8j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Aril"; status: "Online • Cari Solusi Bug"; isOnline: true; initial: "A" }
                ListElement { name: "Aris"; status: "Offline • Terakhir 3d lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Arman"; status: "Online • Baca PDF Modul"; isOnline: true; initial: "A" }
                ListElement { name: "Arya"; status: "Offline • Terakhir 24m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Asri"; status: "Online • Resume Bab 5"; isOnline: true; initial: "A" }
                ListElement { name: "Asep"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Ayu"; status: "Online • Desain Canva"; isOnline: true; initial: "A" }
                ListElement { name: "Azhar"; status: "Offline • Terakhir 5m lalu"; isOnline: false; initial: "A" }
                ListElement { name: "Bagus Adi"; status: "Online • Kerjain Makalah"; isOnline: true; initial: "B" }
                ListElement { name: "Bakri"; status: "Offline • Terakhir 11j lalu"; isOnline: false; initial: "B" }
                ListElement { name: "Baron"; status: "Online • Coding HTML"; isOnline: true; initial: "B" }
                ListElement { name: "Basuki"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "B" }
                ListElement { name: "Bayu"; status: "Online • Room Teknik"; isOnline: true; initial: "B" }
                ListElement { name: "Bimo"; status: "Offline • Terakhir 50m lalu"; isOnline: false; initial: "B" }
                ListElement { name: "Boas"; status: "Online • Cari Sumber Jurnal"; isOnline: true; initial: "B" }
                ListElement { name: "Bobby"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "B" }
                ListElement { name: "Boy"; status: "Online • Input Data Nilai"; isOnline: true; initial: "B" }
                ListElement { name: "Brian"; status: "Offline • Terakhir 16j lalu"; isOnline: false; initial: "B" }
                ListElement { name: "Cahyono"; status: "Online • Ngerangkum Sosiologi"; isOnline: true; initial: "C" }
                ListElement { name: "Calvin"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "C" }
                ListElement { name: "Carla"; status: "Online • Kelompok Akuntansi"; isOnline: true; initial: "C" }
                ListElement { name: "Cecep"; status: "Offline • Terakhir 4h lalu"; isOnline: false; initial: "C" }
                ListElement { name: "Charles"; status: "Online • Latihan Struktur Data"; isOnline: true; initial: "C" }
                ListElement { name: "Chelsea"; status: "Offline • Terakhir 19m lalu"; isOnline: false; initial: "C" }
                ListElement { name: "Christian"; status: "Online • Ngoding JavaScript"; isOnline: true; initial: "C" }
                ListElement { name: "Christopher"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "C" }
                ListElement { name: "Clara"; status: "Online • Review Slide Dosen"; isOnline: true; initial: "C" }
                ListElement { name: "Cucu"; status: "Offline • Terakhir 12j lalu"; isOnline: false; initial: "C" }
                ListElement { name: "Dadang"; status: "Online • Cari Template PPT"; isOnline: true; initial: "D" }
                ListElement { name: "Dahlia"; status: "Offline • Terakhir 33m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Damar"; status: "Online • Tugas Aljabar"; isOnline: true; initial: "D" }
                ListElement { name: "Damian"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dandy"; status: "Online • Review Nilai Tugas"; isOnline: true; initial: "D" }
                ListElement { name: "Dani"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Danang"; status: "Online • Room Sains"; isOnline: true; initial: "D" }
                ListElement { name: "Danu"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dany"; status: "Online • Latihan Soal Logika"; isOnline: true; initial: "D" }
                ListElement { name: "Darius"; status: "Offline • Terakhir 2d lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Darsono"; status: "Online • Baca PDF Teori"; isOnline: true; initial: "D" }
                ListElement { name: "Darwin"; status: "Offline • Terakhir 8m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "David"; status: "Online • Ngoding Backend"; isOnline: true; initial: "D" }
                ListElement { name: "Dede"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Deden"; status: "Online • Review Hasil Lab"; isOnline: true; initial: "D" }
                ListElement { name: "Dedi"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Deddy"; status: "Online • Edit Coding Skripsi"; isOnline: true; initial: "D" }
                ListElement { name: "Dedy"; status: "Offline • Terakhir 11j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Delia"; status: "Online • Cari Ide Judul"; isOnline: true; initial: "D" }
                ListElement { name: "Denis"; status: "Offline • Terakhir 40m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Deri"; status: "Online • Bikin Dokumentasi API"; isOnline: true; initial: "D" }
                ListElement { name: "Dermawan"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Deva"; status: "Online • Latihan Grammar"; isOnline: true; initial: "D" }
                ListElement { name: "Devi"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Devon"; status: "Online • Room Desain"; isOnline: true; initial: "D" }
                ListElement { name: "Dewi Kartika"; status: "Offline • Terakhir 18m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dhany"; status: "Online • Nugas Mandiri"; isOnline: true; initial: "D" }
                ListElement { name: "Dharma"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dhea"; status: "Online • Ringkasan Bab 6"; isOnline: true; initial: "D" }
                ListElement { name: "Dhika"; status: "Offline • Terakhir 45m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dhimas"; status: "Online • Push Githb Repo"; isOnline: true; initial: "D" }
                ListElement { name: "Diah"; status: "Offline • Terakhir 9j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dian Sastro"; status: "Online • Baca Referensi Jurnal"; isOnline: true; initial: "D" }
                ListElement { name: "Diani"; status: "Offline • Terakhir 14j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dickson"; status: "Online • Room Analisis Data"; isOnline: true; initial: "D" }
                ListElement { name: "Dicky"; status: "Offline • Terakhir 3m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Diego"; status: "Online • Ngoding OOP"; isOnline: true; initial: "D" }
                ListElement { name: "Dika"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Diky"; status: "Online • Kerjain Esai PBM"; isOnline: true; initial: "D" }
                ListElement { name: "Dina Mariana"; status: "Offline • Terakhir 5d lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dindin"; status: "Online • Rumus Distribusi Frekuensi"; isOnline: true; initial: "D" }
                ListElement { name: "Dino"; status: "Offline • Terakhir 22m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dio"; status: "Online • Nyusun Outline Projek"; isOnline: true; initial: "D" }
                ListElement { name: "Dirga"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dito"; status: "Online • Cari Font Poster"; isOnline: true; initial: "D" }
                ListElement { name: "Doddy"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dodi"; status: "Online • Room Study 7"; isOnline: true; initial: "D" }
                ListElement { name: "Dolly"; status: "Offline • Terakhir 3h lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Donny"; status: "Online • Latihan Codeforces"; isOnline: true; initial: "D" }
                ListElement { name: "Dora"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Dwi"; status: "Online • Review Kisi Kuis"; isOnline: true; initial: "D" }
                ListElement { name: "Dyan"; status: "Offline • Terakhir 12j lalu"; isOnline: false; initial: "D" }
                ListElement { name: "Edi"; status: "Online • Cari Vektor Grafis"; isOnline: true; initial: "E" }
                ListElement { name: "Eddy"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Edgar"; status: "Online • Room Database"; isOnline: true; initial: "E" }
                ListElement { name: "Edy"; status: "Offline • Terakhir 25m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Edward"; status: "Online • Latihan Array Manipulation"; isOnline: true; initial: "E" }
                ListElement { name: "Edwin"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Efrat"; status: "Online • Nulis Mindmap"; isOnline: true; initial: "E" }
                ListElement { name: "Eka"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Eki"; status: "Online • Nyari Kumpulan Soal"; isOnline: true; initial: "E" }
                ListElement { name: "Eky"; status: "Offline • Terakhir 9m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Elena"; status: "Online • Room Bahasa"; isOnline: true; initial: "E" }
                ListElement { name: "Eline"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Elisabeth"; status: "Online • Ngerangkum Buku PPU"; isOnline: true; initial: "E" }
                ListElement { name: "Elvin"; status: "Offline • Terakhir 14j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Emanuel"; status: "Online • Ngoding C++ Matkul"; isOnline: true; initial: "E" }
                ListElement { name: "Emil"; status: "Offline • Terakhir 8m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Emilia"; status: "Online • Belajar EYD V"; isOnline: true; initial: "E" }
                ListElement { name: "Emily"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Emma"; status: "Online • Room Seni Rupa"; isOnline: true; initial: "E" }
                ListElement { name: "Endang"; status: "Offline • Terakhir 6d lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Enny"; status: "Online • Review Catatan Lama"; isOnline: true; initial: "E" }
                ListElement { name: "Enrico"; status: "Offline • Terakhir 50m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Ephraim"; status: "Online • Sesi Coding Malam"; isOnline: true; initial: "E" }
                ListElement { name: "Eric"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Erika"; status: "Online • Room Sosiologi"; isOnline: true; initial: "E" }
                ListElement { name: "Erlangga"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Erna"; status: "Online • Catat Kosakata Baru"; isOnline: true; initial: "E" }
                ListElement { name: "Ernest"; status: "Offline • Terakhir 11m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Erni"; status: "Online • Review Pertemuan 6"; isOnline: true; initial: "E" }
                ListElement { name: "Ernawati"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Eros"; status: "Online • Latihan Soal PU"; isOnline: true; initial: "E" }
                ListElement { name: "Ervan"; status: "Offline • Terakhir 3d lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Ervi"; status: "Online • Analisis Tabel Frekuensi"; isOnline: true; initial: "E" }
                ListElement { name: "Ervin"; status: "Offline • Terakhir 19m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Esa"; status: "Online • Room Sejarah"; isOnline: true; initial: "E" }
                ListElement { name: "Esther"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Eva"; status: "Online • Membuat Ringkasan T-Test"; isOnline: true; initial: "E" }
                ListElement { name: "Evan"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Evelyn"; status: "Online • Hitung Distribusi T"; isOnline: true; initial: "E" }
                ListElement { name: "Ezra"; status: "Offline • Terakhir 33m lalu"; isOnline: false; initial: "E" }
                ListElement { name: "Fabiola"; status: "Online • Room Study 12"; isOnline: true; initial: "F" }
                ListElement { name: "Fadel"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fadhil"; status: "Online • Nyusun Data Mentah"; isOnline: true; initial: "F" }
                ListElement { name: "Fadhila"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fadlan"; status: "Online • Belajar Matdis 2"; isOnline: true; initial: "F" }
                ListElement { name: "Fadli"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fadly"; status: "Online • Room Coding Python"; isOnline: true; initial: "F" }
                ListElement { name: "Fady"; status: "Offline • Terakhir 2d lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fahrezal"; status: "Online • Ngerangkum Bab 7"; isOnline: true; initial: "F" }
                ListElement { name: "Fahrezi"; status: "Offline • Terakhir 8m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fahri"; status: "Online • Review Matkul Logika"; isOnline: true; initial: "F" }
                ListElement { name: "Fahrul"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Faik"; status: "Online • Room Matematika"; isOnline: true; initial: "F" }
                ListElement { name: "Faisal Rahman"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Faiz"; status: "Online • Latihan Coding Array"; isOnline: true; initial: "F" }
                ListElement { name: "Faizal"; status: "Offline • Terakhir 11j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fajri"; status: "Online • Nyari Contoh Kasus"; isOnline: true; initial: "F" }
                ListElement { name: "Fakhri"; status: "Offline • Terakhir 40m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fakhrul"; status: "Online • Room UI/UX"; isOnline: true; initial: "F" }
                ListElement { name: "Fandi"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fanji"; status: "Online • Setup Environment"; isOnline: true; initial: "F" }
                ListElement { name: "Fanny"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fany"; status: "Online • Bikin Mindmap UTS"; isOnline: true; initial: "F" }
                ListElement { name: "Faradilla"; status: "Offline • Terakhir 18m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Farah Salsabila"; status: "Online • Sesi Fokus Malam"; isOnline: true; initial: "F" }
                ListElement { name: "Farand"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Faras"; status: "Online • Cari Referensi Skripsi"; isOnline: true; initial: "F" }
                ListElement { name: "Farrel"; status: "Offline • Terakhir 45m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fathur"; status: "Online • Hitung ANOVA Dua Arah"; isOnline: true; initial: "F" }
                ListElement { name: "Fathia"; status: "Offline • Terakhir 9j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fatih"; status: "Online • Room Sesi Pomodoro"; isOnline: true; initial: "F" }
                ListElement { name: "Fatima"; status: "Offline • Terakhir 14j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fatma"; status: "Online • Baca PDF Pertemuan 6"; isOnline: true; initial: "F" }
                ListElement { name: "Fatmawati"; status: "Offline • Terakhir 3m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fauzan"; status: "Online • Coding C++ Fungsi"; isOnline: true; initial: "F" }
                ListElement { name: "Fauzi"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fauziah"; status: "Online • Latihan Silogisme PU"; isOnline: true; initial: "F" }
                ListElement { name: "Fawwaz"; status: "Offline • Terakhir 5d lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Febrian"; status: "Online • Analisis Varians Data"; isOnline: true; initial: "F" }
                ListElement { name: "Febriana"; status: "Offline • Terakhir 22m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Febriansyah"; status: "Online • Room Lab Alpro"; isOnline: true; initial: "F" }
                ListElement { name: "Febrianti"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Felix"; status: "Online • Latihan Soal PBM"; isOnline: true; initial: "F" }
                ListElement { name: "Femi"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fendy"; status: "Online • Room Belajar Bersama"; isOnline: true; initial: "F" }
                ListElement { name: "Feni"; status: "Offline • Terakhir 3h lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Ferdian"; status: "Online • Nyari E-Book Matdis"; isOnline: true; initial: "F" }
                ListElement { name: "Ferdinand"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Ferdy"; status: "Online • Kerjain Tugas Mandiri"; isOnline: true; initial: "F" }
                ListElement { name: "Fernand"; status: "Offline • Terakhir 12j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fernando"; status: "Online • Room Analisis Python"; isOnline: true; initial: "F" }
                ListElement { name: "Ferri"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fia"; status: "Online • Latihan Soal UTBK PPU"; isOnline: true; initial: "F" }
                ListElement { name: "Fika"; status: "Offline • Terakhir 25m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fikri"; status: "Online • Ringkasan Materi T-Test"; isOnline: true; initial: "F" }
                ListElement { name: "Fiko"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Filipus"; status: "Online • Room Coding C++"; isOnline: true; initial: "F" }
                ListElement { name: "Fiona"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fira"; status: "Online • Belajar Aturan EYD V"; isOnline: true; initial: "F" }
                ListElement { name: "Firmansyah"; status: "Offline • Terakhir 9m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fitra"; status: "Online • Room Fokus Sunyi"; isOnline: true; initial: "F" }
                ListElement { name: "Fitria"; status: "Offline • Terakhir 3j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fitriani"; status: "Online • Membuat Tabel Frekuensi"; isOnline: true; initial: "F" }
                ListElement { name: "Frans"; status: "Offline • Terakhir 14j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fransisca"; status: "Online • Room Sesi Pagi"; isOnline: true; initial: "F" }
                ListElement { name: "Fredy"; status: "Offline • Terakhir 8m lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Fuad"; status: "Online • Latihan Logika Silogisme"; isOnline: true; initial: "F" }
                ListElement { name: "Fulan"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "F" }
                ListElement { name: "Gabriel"; status: "Online • Nyusun Slide Presentasi"; isOnline: true; initial: "G" }
                ListElement { name: "Gabriela"; status: "Offline • Terakhir 6d lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gading"; status: "Online • Room Analisis Statistika"; isOnline: true; initial: "G" }
                ListElement { name: "Gaffar"; status: "Offline • Terakhir 50m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gafur"; status: "Online • Latihan Menghitung P-Value"; isOnline: true; initial: "G" }
                ListElement { name: "Gama"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gamal"; status: "Online • Room Coding Python Pandas"; isOnline: true; initial: "G" }
                ListElement { name: "Gandi"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Ganesha"; status: "Online • Mengerjakan Laprak Fisika"; isOnline: true; initial: "G" }
                ListElement { name: "Gani Kusuma"; status: "Offline • Terakhir 11m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Ganjar"; status: "Online • Review Pembahasan Kuis"; isOnline: true; initial: "G" }
                ListElement { name: "Ganti"; status: "Offline • Terakhir 7j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gari"; status: "Online • Room Study Room 9"; isOnline: true; initial: "G" }
                ListElement { name: "Garin"; status: "Offline • Terakhir 3d lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gatot"; status: "Online • Latihan Coding Array 2D"; isOnline: true; initial: "G" }
                ListElement { name: "Gavin"; status: "Offline • Terakhir 19m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gayatri"; status: "Online • Ngerangkum Buku EYD"; isOnline: true; initial: "G" }
                ListElement { name: "Gaza"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gedon"; status: "Online • Room Kelompok Struktur Data"; isOnline: true; initial: "G" }
                ListElement { name: "Gema"; status: "Offline • Terakhir 10j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "George"; status: "Online • Nyusun Data Distribusi T"; isOnline: true; initial: "G" }
                ListElement { name: "Gerald"; status: "Offline • Terakhir 33m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gerardo"; status: "Online • Room Fokus Malam"; isOnline: true; initial: "G" }
                ListElement { name: "Gerry"; status: "Offline • Terakhir 1j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gia"; status: "Online • Latihan Bahasa Panda"; isOnline: true; initial: "G" }
                ListElement { name: "Gian"; status: "Offline • Terakhir 4j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gibran Al"; status: "Online • Room Coding C++ Alpro"; isOnline: true; initial: "G" }
                ListElement { name: "Gilang"; status: "Offline • Terakhir 15m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gina"; status: "Online • Membuat Grafik Seaborn"; isOnline: true; initial: "G" }
                ListElement { name: "Gino"; status: "Offline • Terakhir 2d lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Ginta"; status: "Online • Room Sesi Pomodoro 4"; isOnline: true; initial: "G" }
                ListElement { name: "Ginting"; status: "Offline • Terakhir 8m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gio"; status: "Online • Latihan Logika Penalaran Umum"; isOnline: true; initial: "G" }
                ListElement { name: "Giovanni"; status: "Offline • Terakhir 6j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gisela"; status: "Online • Room Diskus Makalah"; isOnline: true; initial: "G" }
                ListElement { name: "Gita"; status: "Offline • Terakhir 22j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gito"; status: "Online • Menghitung Nilai Rata-rata"; isOnline: true; initial: "G" }
                ListElement { name: "Gladys"; status: "Offline • Terakhir 11j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Glen"; status: "Online • Room Git & GitHub Github"; isOnline: true; initial: "G" }
                ListElement { name: "Glenn"; status: "Offline • Terakhir 40m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gloria"; status: "Online • Membuat Visualisasi Matplotlib"; isOnline: true; initial: "G" }
                ListElement { name: "Gomer"; status: "Offline • Terakhir 2j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Goni"; status: "Online • Room Study Room 15"; isOnline: true; initial: "G" }
                ListElement { name: "Grace"; status: "Offline • Terakhir 5j lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gratia"; status: "Online • Catat Ringkasan Pertemuan 6"; isOnline: true; initial: "G" }
                ListElement { name: "Gregorius"; status: "Offline • Terakhir 18m lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gusti"; status: "Online • Room Analisis Data Mahasiswa"; isOnline: true; initial: "G" }
                ListElement { name: "Guy"; status: "Offline • Terakhir 1d lalu"; isOnline: false; initial: "G" }
                ListElement { name: "Gwen"; status: "Online • Review Latihan Kuis Alpro"; isOnline: true; initial: "G" }
                ListElement { name: "Gwyneth"; status: "Offline • Terakhir 45m lalu"; isOnline: false; initial: "G" }
    }

    ListModel { id: chatModel }

    ListModel { id: searchResultModel }

    function navigateTo(pageName) {
        if (pageName === "Teman")         pageStack.push(temanComponent)
        else if (pageName === "InputTugas") pageStack.push(inputTugasComponent)
        else if (backend.login(userField.text, passField.text)) {
            loginRoot.loginAttempts = 0
            loginRoot.showError = false
            window.currentUser = userField.text   // ← tambah property ini di window
            // ✅ Tangkap return value, lalu masukkan ke window
            var data = backend.loadUserData(userField.text)
            window.namaUser                = data.namaUser
            window.statusUser              = data.statusUser
            window.selectedAvatar          = data.selectedAvatar
            window.globalSessionsCompleted = data.sessionsCompleted
            window.globalSecondsFocused    = data.secondsFocused

            globalTaskModel.clear()
            var tasks = data.tasks
            for (var i = 0; i < tasks.length; i++) {
                globalTaskModel.append({
                    "title":             tasks[i].title             || "",
                    "deadline":          tasks[i].deadline          || "",
                    "deadlineTimestamp": tasks[i].deadlineTimestamp || 0,
                    "isDone":            tasks[i].isDone            || false
                })
            }
            pageStack.replace(null, mainComponent)
        }
    }

    Timer {
        id: globalStudyTimer
        interval: 1000; running: isStudying; repeat: true
        onTriggered: globalSeconds++
    }

    function sendMessage(friendName, messageText) {
        if (messageText.trim() === "") return
        chatModel.append({
            "chatWith": friendName, "sender": lang.kamu,
            "message": messageText,
            "timestamp": new Date().toLocaleTimeString(Qt.locale("id_ID"), "HH:mm"),
            "isMe": true
        })
        Qt.callLater(function() {
            chatModel.append({
                "chatWith": friendName, "sender": friendName,
                "message": lang.semangatBelajar,
                "timestamp": new Date().toLocaleTimeString(Qt.locale("id_ID"), "HH:mm"),
                "isMe": false
            })
        })
    }

    Timer {
        id: globalTimerLogic
        interval: 1000; repeat: true; running: globalTimerRunning
        onTriggered: {
            if (globalCurrentTimerValue > 0) {
                globalCurrentTimerValue--
                globalSecondsFocused++
            } else {
                globalTimerRunning = false
                globalSessionsCompleted++
            }
        }
    }

    function formatTime(s) {
        let h   = Math.floor(s / 3600).toString().padStart(2, '0')
        let m   = Math.floor((s % 3600) / 60).toString().padStart(2, '0')
        let sec = (s % 60).toString().padStart(2, '0')
        return h + ":" + m + ":" + sec
    }

    ListModel { id: globalTaskModel }
    ListModel { id: studyRoomFriendsModel }

    // ── DRAWER ───────────────────────────────────────────────────────────────
    Drawer {
        id: taskDrawer
        width: 320; height: parent.height; edge: Qt.LeftEdge

        background: Rectangle {
            color: window.bgDeep
            Rectangle { width: 1; height: parent.height; anchors.right: parent.right; color: window.borderColor }
        }

        property string activeTab: "tugas"

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            // Header profil
            Rectangle {
                Layout.fillWidth: true; height: 110; color: window.bgDeep
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: window.borderColor }
                RowLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 14
                    Item {
                        width: 72; height: 72

                        // ── Foto/emoji avatar — ukuran SAMA dengan border, terpotong lingkaran ──
                        Rectangle {
                            id: drawerAvatarCircle
                            anchors.fill: parent          // 72×72, isi penuh
                            radius: width / 2             // lingkaran sempurna
                            color: window.bgSecondary
                            clip: true
                            z: 1

                            Image {
                                readonly property real cropScale: 72 / 200
                                width: parent.width; height: parent.height
                                source: window.customAvatarPath !== "" ? window.customAvatarPath : ""
                                fillMode: Image.PreserveAspectCrop
                                x: window.avatarOffsetX * cropScale
                                y: window.avatarOffsetY * cropScale
                                visible: window.customAvatarPath !== ""
                            }
                            Text {
                                anchors.centerIn: parent
                                text: (window.selectedAvatar >= 0 && window.selectedAvatar < window.avatarList.length)
                                      ? window.avatarList[window.selectedAvatar] : "👤"
                                font.pixelSize: 32
                                visible: window.customAvatarPath === ""
                            }
                        }

                        // ── Border PNG (kawaii/galaxy/rainbow) berputar di atas ──
                        Image {
                            id: drawerBorderPng
                            anchors.centerIn: parent
                            width: 72; height: 72
                            source: (window.selectedBorder >= 1 && window.selectedBorder <= 3)
                                    ? (window.borderAssets[window.selectedBorder] ?? "") : ""
                            fillMode: Image.PreserveAspectFit
                            visible: (window.selectedBorder >= 1 && window.selectedBorder <= 3)
                            z: 2
                            RotationAnimator {
                                target: drawerBorderPng; from: 0; to: 360
                                duration: 6000; loops: Animation.Infinite
                                running: drawerBorderPng.visible
                            }
                        }

                        // ── Border gradasi Canvas (id 4-49) berputar di atas ──
                        Canvas {
                            id: drawerBorderCanvas
                            anchors.centerIn: parent
                            width: 72; height: 72
                            z: 2
                            visible: window.selectedBorder >= 4

                            property real angle: 0
                            NumberAnimation on angle {
                                from: 0; to: Math.PI * 2
                                duration: window.selectedBorder >= 4 ? window.borderDefs[window.selectedBorder].dur : 2000
                                loops: Animation.Infinite
                                running: drawerBorderCanvas.visible
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
                            width: 72; height: 72; radius: 36
                            color: "transparent"
                            border.color: window.selectedBorder === 0 ? window.accentColor : "transparent"
                            border.width: 2
                            z: 2
                        }
                    }
                    Column {
                        spacing: 3; Layout.fillWidth: true
                        Text { text: window.namaUser; color: window.textPrimary; font.pixelSize: 15; font.bold: true }
                        Text { text: window.statusUser; color: window.textMuted; font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }
                        Rectangle {
                            height: 18; width: badgeTxt.implicitWidth + 14; radius: 9
                            color: Qt.rgba(255/255,204/255,0/255,0.15); border.color: window.accentColor; border.width: 1
                            Text { id: badgeTxt; anchors.centerIn: parent; text: "🍅 " + window.globalSessionsCompleted + " " + lang.sesiHariIni; color: window.accentColor; font.pixelSize: 9; font.bold: true }
                        }
                    }
                    Rectangle {
                        width: 28; height: 28; radius: 14; color: window.bgSecondary
                        Text { anchors.centerIn: parent; text: "✕"; color: window.textMuted; font.pixelSize: 12 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: taskDrawer.close() }
                    }
                }
            }

            // Tab navigator
            Rectangle {
                Layout.fillWidth: true; height: 46; color: window.bgDeep
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: window.borderColor }
                RowLayout {
                    anchors.fill: parent; spacing: 0
                    Repeater {
                        model: [
                            { id: "tugas",    icon: "📋", label: lang.tugas   },
                            { id: "fokus",    icon: "⏱",  label: lang.fokus   },
                            { id: "motivasi", icon: "✨", label: lang.quoteHariIni }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            color: taskDrawer.activeTab === modelData.id ? Qt.rgba(255/255,204/255,0/255,0.08) : "transparent"
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: taskDrawer.activeTab === modelData.id ? window.accentColor : "transparent" }
                            Column {
                                anchors.centerIn: parent; spacing: 2
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.icon; font.pixelSize: 14 }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label
                                    color: taskDrawer.activeTab === modelData.id ? window.accentColor : window.textMuted
                                    font.pixelSize: 10; font.bold: taskDrawer.activeTab === modelData.id
                                }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: taskDrawer.activeTab = modelData.id }
                        }
                    }
                }
            }

            // Konten tab
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true

                // Tab tugas
                ColumnLayout {
                    anchors.fill: parent; visible: taskDrawer.activeTab === "tugas"; spacing: 0

                    Rectangle {
                        Layout.fillWidth: true; height: 48; color: window.bgDeep
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: window.borderColor }
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 10
                            property int doneCnt: { let n = 0; for (let i = 0; i < globalTaskModel.count; i++) if (globalTaskModel.get(i).isDone) n++; return n }
                            property int totalCnt: globalTaskModel.count
                            Text { text: "📋  " + parent.totalCnt + " " + lang.tugas; color: window.textPrimary; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                height: 22; width: progressPillTxt.implicitWidth + 16; radius: 11
                                color: parent.doneCnt === parent.totalCnt && parent.totalCnt > 0 ? Qt.rgba(46/255,204/255,113/255,0.2) : Qt.rgba(255/255,204/255,0/255,0.12)
                                border.color: parent.doneCnt === parent.totalCnt && parent.totalCnt > 0 ? "#2ecc71" : window.accentColor
                                Text { id: progressPillTxt; anchors.centerIn: parent; text: parent.parent.doneCnt + "/" + parent.parent.totalCnt + " " + lang.selesai; color: parent.parent.doneCnt === parent.parent.totalCnt && parent.parent.totalCnt > 0 ? "#2ecc71" : window.accentColor; font.pixelSize: 10; font.bold: true }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 3; color: window.borderColor
                        Rectangle {
                            property int doneCnt: { let n = 0; for (let i = 0; i < globalTaskModel.count; i++) if (globalTaskModel.get(i).isDone) n++; return n }
                            height: parent.height
                            width: globalTaskModel.count > 0 ? parent.width * (doneCnt / globalTaskModel.count) : 0
                            color: window.accentColor; radius: 2
                            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ListView {
                            id: drawerTaskList; model: globalTaskModel; spacing: 6
                            topMargin: 10; bottomMargin: 10; leftMargin: 12; rightMargin: 12
                            delegate: Rectangle {
                                width: drawerTaskList.width - 24; height: 64; radius: 12
                                color: model.isDone ? window.bgCard : window.bgSecondary
                                border.color: model.isDone ? window.borderColor : Qt.lighter(window.borderColor, 1.3)
                                border.width: 1; opacity: model.isDone ? 0.6 : 1.0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 12; spacing: 10
                                    Rectangle {
                                        width: 26; height: 26; radius: 13
                                        color: model.isDone ? "#2ecc71" : "transparent"
                                        border.color: model.isDone ? "#2ecc71" : window.accentColor; border.width: 2
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                        Text { anchors.centerIn: parent; text: "✓"; color: window.textPrimary; font.pixelSize: 13; font.bold: true; visible: model.isDone }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: globalTaskModel.setProperty(index, "isDone", !model.isDone) }
                                    }
                                    Column {
                                        spacing: 3; Layout.fillWidth: true
                                        Text { text: model.title; color: model.isDone ? window.textMuted : window.textPrimary; font.pixelSize: 13; font.bold: !model.isDone; font.strikeout: model.isDone; elide: Text.ElideRight; width: parent.width }
                                        Text { text: model.deadline !== "" ? "📅 " + model.deadline : lang.tanpaDeadline; color: window.accentColor; font.pixelSize: 10; opacity: model.isDone ? 0.5 : 1.0 }
                                    }
                                    Rectangle {
                                        width: 24; height: 24; radius: 12
                                        color: delArea.containsMouse ? "#ff4444" : "transparent"
                                        border.color: "#ff4444"; border.width: 1; visible: !model.isDone
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Text { anchors.centerIn: parent; text: "✕"; color: "#ff4444"; font.pixelSize: 10 }
                                        MouseArea { id: delArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: globalTaskModel.remove(index) }
                                    }
                                }
                            }
                            Item {
                                visible: globalTaskModel.count === 0; width: drawerTaskList.width; height: 200
                                Column {
                                    anchors.centerIn: parent; spacing: 10
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "📭"; font.pixelSize: 40 }
                                    Text { text: lang.belumAdaTugas; color: window.textMuted; font.pixelSize: 13; anchors.horizontalCenter: parent.horizontalCenter }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 52; color: window.bgDeep
                        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: window.borderColor }
                        Rectangle {
                            anchors.centerIn: parent; width: parent.width - 28; height: 38; radius: 10
                            color: addTugasArea.pressed ? Qt.darker(window.accentColor, 1.2) : window.accentColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                            RowLayout {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "+"; color: window.bgPrimary; font.pixelSize: 18; font.bold: true }
                                Text { text: lang.tambahTugas; color: window.bgPrimary; font.pixelSize: 13; font.bold: true }
                            }
                            MouseArea { id: addTugasArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { taskDrawer.close(); pageStack.push(inputTugasComponent) } }
                        }
                    }
                }

                // Tab fokus
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; visible: taskDrawer.activeTab === "fokus"; spacing: 12
                    Text { text: lang.statistikFokus ; color: window.accentColor; font.pixelSize: 13; font.bold: true; font.letterSpacing: 1 }
                    Rectangle {
                        Layout.fillWidth: true; height: 80; radius: 14; color: window.bgSecondary; border.color: window.borderColor
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 16; spacing: 12
                            Text { text: "🕐"; font.pixelSize: 28 }
                            Column {
                                spacing: 2
                                Text { text: lang.totalFokus; color: window.textMuted; font.pixelSize: 11 }
                                Text {
                                    text: Math.floor(window.globalSecondsFocused/3600) + "j " + Math.floor((window.globalSecondsFocused%3600)/60) + "m " + (window.globalSecondsFocused%60) + "d"
                                    color: window.textPrimary; font.pixelSize: 20; font.bold: true
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 80; radius: 14; color: window.bgSecondary; border.color: window.borderColor
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 16; spacing: 12
                            Text { text: "🍅"; font.pixelSize: 28 }
                            Column {
                                spacing: 2
                                Text { text: lang.sesiPomodoroSelesai; color: window.textMuted; font.pixelSize: 11 }
                                Row {
                                    spacing: 4
                                    Text { text: window.globalSessionsCompleted.toString(); color: window.accentColor; font.pixelSize: 20; font.bold: true }
                                    Text { text: "/ " + window.globalTargetSessions + "  " + lang.targetHarian; color: window.textMuted; font.pixelSize: 13; y: 4 }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 70; radius: 14; color: window.bgSecondary; border.color: window.borderColor
                        Column {
                            anchors.fill: parent; anchors.margins: 14; spacing: 6
                            Text { text: lang.progressTarget; color: window.textMuted; font.pixelSize: 11 }
                            Row {
                                spacing: 6
                                Repeater {
                                    model: Math.min(window.globalTargetSessions, 12)
                                    delegate: Rectangle {
                                        width: 18; height: 18; radius: 9
                                        color: index < window.globalSessionsCompleted ? window.accentColor : window.borderColor
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 56; radius: 14
                        color: window.globalTimerRunning ? Qt.rgba(46/255,204/255,113/255,0.12) : Qt.rgba(255/255,204/255,0/255,0.06)
                        border.color: window.globalTimerRunning ? "#2ecc71" : window.borderColor
                        Behavior on color { ColorAnimation { duration: 300 } }
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 10
                            Rectangle {
                                width: 10; height: 10; radius: 5
                                color: window.globalTimerRunning ? "#2ecc71" : window.textMuted
                                SequentialAnimation on opacity {
                                    running: window.globalTimerRunning; loops: Animation.Infinite
                                    NumberAnimation { from: 1; to: 0.2; duration: 700 }
                                    NumberAnimation { from: 0.2; to: 1; duration: 700 }
                                }
                            }
                            Text {
                                text: window.globalTimerRunning ? lang.timerBerjalan + window.formatTime(window.globalCurrentTimerValue) : lang.timerTidakAktif
                                color: window.globalTimerRunning ? "#2ecc71" : window.textMuted
                                font.pixelSize: 12; font.bold: true; Layout.fillWidth: true
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 38; radius: 10
                        color: goTimerArea.pressed ? Qt.darker(window.bgSecondary, 1.1) : window.bgSecondary
                        border.color: window.borderColor
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text { anchors.centerIn: parent; text: "⏱  " + lang.timer; color: window.textPrimary; font.pixelSize: 12; font.bold: true }
                        MouseArea { id: goTimerArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { taskDrawer.close(); pageStack.push(timerComponent) } }
                    }
                    Item { Layout.fillHeight: true }
                }

                // Tab motivasi
                ColumnLayout {
                    id: motivasiTab
                    anchors.fill: parent; anchors.margins: 20; visible: taskDrawer.activeTab === "motivasi"; spacing: 16

                    // ✅ property HARUS di atas sebelum child apapun
                    property int quoteIndex: 0
                    property var quotes: [
                        { text: "Belajar bukan beban, tapi investasi untuk masa depanmu.", author: "— Anonim" },
                                { text: "Setiap menit yang kamu fokus hari ini, adalah hadiah untuk dirimu di masa depan.", author: "— Study Tracker" },
                                { text: "Kesuksesan bukan milik orang pintar, tapi milik orang yang tidak mau menyerah.", author: "— Anonim" },
                                { text: "Satu langkah kecil setiap hari lebih baik dari satu langkah besar sekali setahun.", author: "— Anonim" },
                                { text: "Otak kamu seperti otot — semakin dilatih, semakin kuat.", author: "— Anonim" },
                                { text: "Jangan tunggu momen sempurna. Mulai sekarang, sempurnakan di jalan.", author: "— Anonim" },
                                { text: "Tidur boleh, menyerah jangan.", author: "— Anonim" },
                                { text: "Bukan soal berapa lama kamu belajar, tapi seberapa dalam kamu memahami.", author: "— Study Tracker" },
                                { text: "Konsistensi kecil setiap hari mengalahkan semangat besar yang hanya sesekali.", author: "— Anonim" },
                                { text: "Jangan takut salah. Kesalahan adalah guru terbaik yang tidak memungut bayaran.", author: "— Anonim" },
                                { text: "Investasi terbaik adalah investasi pada dirimu sendiri.", author: "— Benjamin Franklin" },
                                { text: "Pendidikan adalah senjata paling ampuh untuk mengubah dunia.", author: "— Nelson Mandela" },
                                { text: "Kamu tidak harus hebat untuk memulai, tapi kamu harus memulai untuk menjadi hebat.", author: "— Zig Ziglar" },
                                { text: "Setiap ahli dulunya adalah seorang pemula.", author: "— Helen Hayes" },
                                { text: "Disiplin adalah jembatan antara tujuan dan pencapaian.", author: "— Jim Rohn" },
                                { text: "Progress, bukan kesempurnaan, yang harus kamu kejar.", author: "— Anonim" },
                                { text: "Belajar tanpa berpikir adalah sia-sia. Berpikir tanpa belajar adalah berbahaya.", author: "— Konfusius" },
                                { text: "Dirimu lima tahun ke depan bergantung pada keputusan yang kamu buat hari ini.", author: "— Anonim" },
                                { text: "Fokus bukan tentang mengatakan ya, tapi mengatakan tidak pada 1000 hal lain.", author: "— Steve Jobs" },
                                { text: "Kerja keras mengalahkan bakat ketika bakat tidak bekerja keras.", author: "— Tim Notke" },
                                { text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "— Mahatma Gandhi" },
                                { text: "Orang yang berhenti belajar adalah orang yang sudah tua, baik di umur 20 maupun 80.", author: "— Henry Ford" },
                                { text: "Rasa lelah setelah belajar jauh lebih memuaskan dari rasa malas yang nyaman.", author: "— Anonim" },
                                { text: "Jangan bandingkan progresmu dengan orang lain. Kita punya jalur masing-masing.", author: "— Anonim" },
                                { text: "Pengetahuan adalah satu-satunya hal yang bertambah ketika dibagikan.", author: "— Anonim" },
                                { text: "Tetap semangat! Setiap usaha yang kamu lakukan hari ini pasti terbayar.", author: "— Study Tracker" },
                                { text: "Keunggulan bukan tujuan, itu kebiasaan yang dibangun setiap hari.", author: "— Aristoteles" },
                                { text: "Belajar memberi kita dunia yang lebih besar untuk dihuni.", author: "— Lisa Bu" },
                                { text: "Tidak ada jalan pintas menuju tempat yang layak untuk dituju.", author: "— Beverly Sills" },
                                { text: "Rasa ingin tahu adalah awal dari semua pengetahuan.", author: "— Dr. Seuss" },
                                { text: "Hari ini mungkin terasa sulit, tapi kamu sudah melewati hari sulit sebelumnya.", author: "— Anonim" },
                                { text: "Satu buku yang kamu baca bisa mengubah hidupmu selamanya.", author: "— Anonim" },
                                { text: "Mimpi tanpa aksi hanyalah harapan. Aksi tanpa mimpi hanyalah rutinitas biasa.", author: "— Anonim" },
                                { text: "Kamu lebih kuat dari yang kamu kira, dan lebih pintar dari yang kamu percaya.", author: "— A.A. Milne" },
                                { text: "Kesabaran dan ketekunan memiliki efek magis — kesulitan pun menghilang.", author: "— John Quincy Adams" },
                                { text: "Setiap sesi belajar yang kamu selesaikan membawamu selangkah lebih dekat ke tujuan.", author: "— Study Tracker" },
                                { text: "Ilmu pengetahuan adalah cahaya yang menerangi kegelapan ketidaktahuan.", author: "— Anonim" },
                                { text: "Bukan tentang punya waktu, tapi tentang membuat waktu untuk hal yang penting.", author: "— Anonim" },
                                { text: "Yang membedakan orang sukses dan gagal bukan kemampuan, tapi ketekunan.", author: "— Anonim" },
                                { text: "Sukses bukan kebetulan. Itu adalah kerja keras, ketekunan, dan belajar.", author: "— Pelé" },
                                { text: "Satu jam fokus penuh lebih bernilai dari delapan jam kerja sambil terdistraksi.", author: "— Anonim" },
                                { text: "Jangan pernah biarkan ketakutan akan gagal menghalangimu untuk mencoba.", author: "— Michael Jordan" },
                                { text: "Hidupmu akan berubah ketika kamu berubah.", author: "— Jim Rohn" },
                                { text: "Otak yang terbuka adalah otak yang terus berkembang.", author: "— Anonim" },
                                { text: "Belajar dari kesalahan orang lain — kamu tidak bisa membuat semua kesalahan sendiri.", author: "— Eleanor Roosevelt" },
                                { text: "Setiap langkah kecil yang kamu ambil hari ini adalah kemajuan nyata.", author: "— Study Tracker" },
                                { text: "Bukan IQ yang menentukan kesuksesan, tapi EQ dan kerja kerasmu.", author: "— Anonim" },
                                { text: "Mulailah dari mana kamu berada, gunakan apa yang kamu punya.", author: "— Arthur Ashe" },
                                { text: "Waktu yang kamu nikmati belajar adalah waktu yang tidak terbuang.", author: "— Anonim" },
                                { text: "Pomodoro pertama hari ini sudah dimulai. Kamu luar biasa!", author: "— Study Tracker" },
                                { text: "Hanya mereka yang berani gagal besar yang bisa mencapai keberhasilan besar.", author: "— Robert F. Kennedy" },
                                { text: "Belajar itu pahit di awal, tetapi manis di akhir buahnya.", author: "— Aristoteles" },
                                { text: "Cara terbaik untuk memprediksi masa depan adalah dengan menciptakannya.", author: "— Peter Drucker" },
                                { text: "Kecerdasan ditambah karakter—itulah tujuan dari pendidikan sejati.", author: "— Martin Luther King Jr." },
                                { text: "Lakukan hari ini apa yang orang lain tidak mau lakukan, agar besok kamu bisa mencapai apa yang orang lain tidak bisa capai.", author: "— Jerry Rice" },
                                { text: "Jangan biarkan apa yang tidak bisa kamu lakukan mengganggu apa yang bisa kamu lakukan.", author: "— John Wooden" },
                                { text: "Tantangan membuat hidup menarik; mengatasinya membuat hidup penuh makna.", author: "— Joshua J. Marine" },
                                { text: "Kamu tidak akan pernah kalah sampai kamu memutuskan untuk berhenti mencoba.", author: "— Albert Einstein" },
                                { text: "Energi dan ketekunan menaklukkan segala hal.", author: "— Benjamin Franklin" },
                                { text: "Orang yang mengajukan pertanyaan bodoh hanya bodoh selama lima menit. Orang yang tidak bertanya tetap bodoh selamanya.", author: "— Peribahasa Tiongkok" },
                                { text: "Aksi adalah kunci dasar untuk semua kesuksesan.", author: "— Pablo Picasso" },
                                { text: "Genius adalah 1% inspirasi dan 99% keringat.", author: "— Thomas Edison" },
                                { text: "Kesulitan yang kamu hadapi hari ini adalah kekuatan yang kamu butuhkan untuk esok hari.", author: "— Anonim" },
                                { text: "Semakin banyak kamu membaca, semakin banyak hal yang akan kamu ketahui.", author: "— Dr. Seuss" },
                                { text: "Jangan biarkan kemarin mengambil terlalu banyak porsi dari hari ini.", author: "— Will Rogers" },
                                { text: "Bekerjalah dalam diam, biarkan kesuksesanmu yang membuat kebisingan.", author: "— Frank Ocean" },
                                { text: "Fokuslah pada tempat yang ingin kamu tuju, bukan pada apa yang kamu takuti.", author: "— Tony Robbins" },
                                { text: "Rahasia untuk maju adalah dengan memulai.", author: "— Mark Twain" },
                                { text: "Kamu dilahirkan untuk menang, tapi untuk menjadi pemenang, kamu harus merencanakan, mempersiapkan, dan berharap untuk menang.", author: "— Zig Ziglar" },
                                { text: "Tidak ada kata terlambat untuk menjadi apa yang kamu inginkan.", author: "— George Eliot" },
                                { text: "Jika kamu tidak mengejar apa yang kamu inginkan, kamu tidak akan pernah memilikinya.", author: "— Nora Roberts" },
                                { text: "Perjalanan seribu mil dimulai dengan satu langkah kaki.", author: "— Lao Tzu" },
                                { text: "Nilai akhirmu tidak mendefinisikan nilaimu sebagai seorang manusia.", author: "— Study Tracker" },
                                { text: "Ketika kamu ingin menyerah, ingatlah alasan mengapa kamu memulainya.", author: "— Anonim" },
                                { text: "Jangan batasi tantanganmu. Tantang batasanmu.", author: "— Anonim" },
                                { text: "Kunci sukses adalah memfokuskan pikiran sadar kita pada hal-hal yang kita inginkan, bukan yang kita takuti.", author: "— Brian Tracy" },
                                { text: "Jika kamu bisa memimpikannya, kamu bisa melakukannya.", author: "— Walt Disney" },
                                { text: "Berpikir adalah pekerjaan terberat yang pernah ada, itulah mengapa sedikit sekali orang yang mau melakukannya.", author: "— Henry Ford" },
                                { text: "Jangan takut berjalan lambat, takutlah jika hanya berdiri diam.", author: "— Peribahasa Tiongkok" },
                                { text: "Persiapan terbaik untuk hari esok adalah melakukan yang terbaik hari ini.", author: "— H. Jackson Brown Jr." },
                                { text: "Belajarlah seolah-olah kamu akan hidup selamanya, hiduplah seolah-olah kamu akan mati besok.", author: "— Mahatma Gandhi" },
                                { text: "Ketekunan adalah kerja keras yang kamu lakukan setelah kamu lelah melakukan kerja keras yang sudah kamu lakukan.", author: "— Newt Gingrich" },
                                { text: "Optimisme adalah keyakinan yang mengarah pada pencapaian.", author: "— Helen Keller" },
                                { text: "Tinggalkan zona nyamanmu. Kamu hanya bisa tumbuh jika kamu bersedia merasa canggung dan tidak nyaman saat mencoba sesuatu yang baru.", author: "— Brian Tracy" },
                                { text: "Pikiran kita adalah segalanya. Apa yang kita pikirkan, kita akan menjadi seperti itu.", author: "— Buddha" },
                                { text: "Kesuksesan adalah jumlah dari usaha-usaha kecil yang diulangi hari demi hari.", author: "— Robert Collier" },
                                { text: "Waktumu terbatas, jadi jangan sia-siakan dengan menjalani hidup orang lain.", author: "— Steve Jobs" },
                                { text: "Jangan pernah menyerah pada mimpi hanya karena waktu yang dibutuhkan untuk mencapainya. Waktu akan terus berjalan bagaimanapun juga.", author: "— Earl Nightingale" },
                                { text: "Kebahagiaan bukan sesuatu yang sudah jadi. Itu berasal dari tindakanmu sendiri.", author: "— Dalai Lama" },
                                { text: "Lakukan apa yang harus kamu lakukan sampai kamu bisa melakukan apa yang ingin kamu lakukan.", author: "— Oprah Winfrey" },
                                { text: "Kritik adalah informasi gratis yang bisa membuatmu lebih pintar.", author: "— Anonim" },
                                { text: "Tidak ada pemenang yang tidak punya bekas luka.", author: "— Anonim" },
                                { text: "Kamu tidak perlu melihat seluruh anak tangga, cukup ambil langkah pertama saja.", author: "— Martin Luther King Jr." },
                                { text: "Hambatan adalah hal-hal menakutkan yang kamu lihat saat kamu mengalihkan pandangan dari tujuanmu.", author: "— Henry Ford" },
                                { text: "Kamu adalah arsitek dari nasibmu sendiri; kamulah yang menggambar cetak birunya.", author: "— Anonim" },
                                { text: "Jangan biarkan opini orang lain menenggelamkan suara hatimu sendiri.", author: "— Steve Jobs" },
                                { text: "Menatap ke depan dan belajar membuatmu terus awet muda.", author: "— Anonim" },
                                { text: "Satu-satunya batasan untuk pencapaian kita esok hari adalah keraguan kita hari ini.", author: "— Franklin D. Roosevelt" },
                                { text: "Sedikit demi sedikit, lama-lama menjadi bukit. Begitu juga dengan ilmumu.", author: "— Peribahasa Indonesia" },
                                { text: "Fokus pada prosesnya, biarkan hasil akhir mengejutkanmu.", author: "— Study Tracker" },
                                { text: "Kebiasaan buruk itu seperti tempat tidur yang hangat: mudah dimasuki, tapi sulit keluar.", author: "— Anonim" },
                                { text: "Pendidikan bukanlah persiapan untuk hidup; pendidikan adalah hidup itu sendiri.", author: "— John Dewey" },
                                { text: "Orang pintar menyelesaikan masalah. Orang bijak mencegah masalah.", author: "— Albert Einstein" },
                                { text: "Berusahalah untuk tidak menjadi orang yang sukses, tetapi jadilah orang yang bernilai.", author: "— Albert Einstein" },
                                { text: "Satu-satunya cara untuk melakukan pekerjaan hebat adalah dengan mencintai apa yang kamu lakukan.", author: "— Steve Jobs" },
                                { text: "Kemauan untuk menang tidak ada artinya tanpa kemauan untuk bersiap.", author: "— Juma Ikangaa" },
                                { text: "Disiplin adalah memilih antara apa yang kamu inginkan sekarang dan apa yang paling kamu inginkan nanti.", author: "— Abraham Lincoln" },
                                { text: "Belajarlah dari hari kemarin, hiduplah untuk hari ini, berharaplah untuk hari esok.", author: "— Albert Einstein" },
                                { text: "Jangan biarkan sekolah mengganggu pendidikanmu.", author: "— Mark Twain" },
                                { text: "Buku adalah sahabat paling setia, paling mudah diakses, dan konselor paling bijaksana.", author: "— Charles William Eliot" },
                                { text: "Jika kamu mengira pendidikan itu mahal, cobalah ketidaktahuan.", author: "— Andy McIntyre" },
                                { text: "Pendidikan adalah paspor menuju masa depan, karena hari esok adalah milik mereka yang mempersiapkannya hari ini.", author: "— Malcolm X" },
                                { text: "Arah yang diberikan pendidikan untuk mengawali seseorang akan menentukan masa depannya.", author: "— Plato" },
                                { text: "Investasikan 25 menit fokusmu sekarang, rasakan kepuasannya seharian.", author: "— Study Tracker" },
                                { text: "Bukan karena sulit kita tidak berani, tetapi karena kita tidak berani maka semuanya menjadi sulit.", author: "— Seneca" },
                                { text: "Kamu tidak bisa merubah masa lalu, tapi kamu bisa merusak masa depan dengan meratapi masa lalu.", author: "— Anonim" },
                                { text: "Jangan katakan 'aku tidak bisa', katakan 'aku belum belajar caranya'.", author: "— Anonim" },
                                { text: "Ketakutan terbesar kita seharusnya bukanlah pada kegagalan, melainkan pada keberhasilan dalam hal-hal yang tidak penting.", author: "— Francis Chan" },
                                { text: "Jika kamu berjalan di jalur yang benar dan bersedia terus berjalan, kamu pasti akan membuat kemajuan.", author: "— Barack Obama" },
                                { text: "Mengetahui saja tidak cukup; kita harus menerapkannya. Keinginan saja tidak cukup; kita harus melakukannya.", author: "— Johann Wolfgang von Goethe" },
                                { text: "Setiap kegagalan mengajari kita sesuatu yang baru yang belum pernah kita ketahui sebelumnya.", author: "— Anonim" },
                                { text: "Berpikirlah besar, mulailah dari yang kecil, bertindaklah sekarang.", author: "— Anonim" },
                                { text: "Waktu akan terasa kurang jika kita malas, tapi waktu akan terasa sangat lapang jika kita produktif.", author: "— Anonim" },
                                { text: "Kebahagiaan belajar terletak pada proses menemukan sesuatu yang belum kita ketahui.", author: "— Anonim" },
                                { text: "Kecerdasan tanpa ambisi seperti burung tanpa sayap.", author: "— Salvador Dali" },
                                { text: "Lakukan tugas tersulitmu terlebih dahulu di pagi hari.", author: "— Brian Tracy" },
                                { text: "Jangan biarkan apa yang ada di luar kendalimu merusak apa yang ada dalam kendalimu.", author: "— Anonim" },
                                { text: "Pemenang sejati adalah mereka yang bangkit satu kali lebih banyak daripada saat mereka jatuh.", author: "— Anonim" },
                                { text: "Jangan kurangi mimpimu, naikkan usahamu.", author: "— Anonim" },
                                { text: "Rasa lelah fisik akibat belajar akan hilang dengan tidur, tetapi kebodohan tidak akan hilang tanpa belajar.", author: "— Anonim" },
                                { text: "Gunakan waktumu dengan bijak. Sesi belajar singkat yang konsisten jauh lebih baik daripada sistem kebut semalam.", author: "— Study Tracker" },
                                { text: "Kualitas hidupmu ditentukan oleh kualitas kebiasaan harianmu.", author: "— Anonim" },
                                { text: "Satu jam yang kamu luangkan untuk membaca hari ini akan menyelamatkanmu dari kekeliruan esok hari.", author: "— Anonim" },
                                { text: "Sesuatu selalu terlihat mustahil sampai semuanya selesai dilakukan.", author: "— Nelson Mandela" },
                                { text: "Pendidikan yang baik adalah fondasi untuk masa depan yang lebih cerah.", author: "— Anonim" },
                                { text: "Kamu tidak akan pernah menemukan waktu untuk apa pun. Jika kamu menginginkan waktu, kamu harus membuatnya.", author: "— Charles Buxton" },
                                { text: "Belajarlah di saat orang lain sedang tidur; bekerjalah di saat orang lain bermalas-malasan.", author: "— William Arthur Ward" },
                                { text: "Jangan puas dengan mediokritas jika kamu memiliki potensi untuk menjadi luar biasa.", author: "— Anonim" },
                                { text: "Kunci dari segala keberhasilan adalah disiplin diri yang konsisten.", author: "— Anonim" },
                                { text: "Kegagalan adalah satu-satunya kesempatan untuk memulai lagi dengan lebih cerdas.", author: "— Henry Ford" },
                                { text: "Masa depanmu cerah jika kamu percaya pada kekuatan belajarmu.", author: "— Anonim" },
                                { text: "Tidak ada rahasia untuk sukses. Sukses adalah hasil dari persiapan, kerja keras, dan belajar dari kegagalan.", author: "— Colin Powell" },
                                { text: "Tindakan terkecil bernilai lebih dari niat terbesar.", author: "— Anonim" },
                                { text: "Pikiran yang diregangkan oleh pengalaman baru tidak akan pernah kembali ke dimensi aslinya.", author: "— Oliver Wendell Holmes Jr." },
                                { text: "Hidup ini seperti mengendarai sepeda. Untuk menjaga keseimbangan, kamu harus terus bergerak.", author: "— Albert Einstein" },
                                { text: "Belajarlah untuk menguasai keterampilan, bukan hanya sekadar untuk lulus ujian.", author: "— Study Tracker" },
                                { text: "Jangan hitung hari-harimu, buatlah hari-harimu itu berharga.", author: "— Muhammad Ali" },
                                { text: "Ketekunan bisa mengubah kegagalan menjadi pencapaian yang luar biasa.", author: "— Matt Biondi" },
                                { text: "Sukses adalah berjalan dari kegagalan ke kegagalan tanpa kehilangan antusiasme.", author: "— Winston Churchill" },
                                { text: "Setiap hari adalah kesempatan baru untuk memperbaiki kesalahan kemarin.", author: "— Anonim" },
                                { text: "Pendidikan adalah senjata terbaik yang dapat kamu gunakan untuk mengubah nasib hidupmu.", author: "— Anonim" },
                                { text: "Jangan biarkan gangguan kecil merusak fokus besarmu hari ini.", author: "— Study Tracker" },
                                { text: "Jika kamu menginginkan sesuatu yang belum pernah kamu miliki, kamu harus bersedia melakukan sesuatu yang belum pernah kamu lakukan.", author: "— Thomas Jefferson" },
                                { text: "Bakat tanpa kerja keras hanyalah potensi yang terbuang sia-sia.", author: "— Anonim" },
                                { text: "Fokus pada apa yang bisa kamu kontrol, abaikan sisanya.", author: "— Anonim" },
                                { text: "Kurva pembelajaran mungkin curam, tetapi pemandangan dari atas sangat indah.", author: "— Anonim" },
                                { text: "Masa depan adalah milik mereka yang menyiapkan diri sejak hari ini.", author: "— Anonim" },
                                { text: "Ilmu yang tidak diamalkan bagaikan pohon yang tidak berbuah.", author: "— Peribahasa" },
                                { text: "Kamu adalah kapten dari pikiranmu sendiri.", author: "— Anonim" },
                                { text: "Distraksi hanya berlangsung beberapa menit, penyesalan bisa bertahan selamanya. Tetap fokus!", author: "— Study Tracker" },
                                { text: "Jangan pernah berhenti belajar, karena hidup tidak pernah berhenti mengajar.", author: "— Anonim" },
                                { text: "Keyakinan adalah langkah pertama, bahkan sebelum kamu melihat anak tangganya.", author: "— Martin Luther King Jr." },
                                { text: "Kerja keras hari ini, petik manisnya esok hari.", author: "— Anonim" },
                                { text: "Disiplin diri adalah bentuk tertinggi dari rasa cinta pada diri sendiri.", author: "— Anonim" },
                                { text: "Ketika fokusmu tajam, rintangan apa pun akan terlihat kecil.", author: "— Anonim" },
                                { text: "Gagal itu biasa, bangkit dari kegagalan itu baru luar biasa.", author: "— Anonim" },
                                { text: "Belajar membuatmu mengerti bahwa dunia ini sangat luas dan indah.", author: "— Anonim" },
                                { text: "Jangan mengeluh tentang tugas yang banyak, bersyukurlah karena kamu diberi kesempatan untuk pintar.", author: "— Anonim" },
                                { text: "Waktu tidak bisa diputar kembali, jadi buatlah setiap detiknya berarti.", author: "— Anonim" },
                                { text: "Setiap bab baru dalam buku yang kamu baca membuka pintu gerbang baru di masa depan.", author: "— Anonim" },
                                { text: "Lakukan yang terbaik, maka hasil terbaik akan mengikutimu.", author: "— Anonim" },
                                { text: "Kurangi berbicara, perbanyak membaca dan bertindak.", author: "— Anonim" },
                                { text: "Jangan biarkan rasa malas mencuri masa depan yang sudah kamu impikan.", author: "— Study Tracker" },
                                { text: "Pendidikan memberimu sayap untuk terbang menuju impianmu.", author: "— Anonim" },
                                { text: "Kesuksesan sejati diukur dari seberapa banyak kamu bertumbuh sebagai manusia.", author: "— Anonim" },
                                { text: "Tantang dirimu sendiri untuk menjadi lebih baik dari dirimu yang kemarin.", author: "— Anonim" },
                                { text: "Menunda pekerjaan hanya akan membuat tugasmu menumpuk dan stresmu bertambah.", author: "— Anonim" },
                                { text: "Buku adalah jendela dunia, dan membaca adalah kuncinya.", author: "— Peribahasa" },
                                { text: "Tetap konsisten, karena konsistensi adalah kunci dari penguasaan ilmu.", author: "— Anonim" },
                                { text: "Fokus pada progres kecilmu, karena akumulasi hal kecil akan melahirkan hal besar.", author: "— Study Tracker" },
                                { text: "Belajar dengan penuh kesadaran memberikan pemahaman yang mendalam.", author: "— Anonim" },
                                { text: "Setiap tantangan akademik adalah latihan mental untuk memperkuat otakmu.", author: "— Anonim" },
                                { text: "Jangan biarkan kegagalan hari ini merusak semangat belajarmu besok.", author: "— Anonim" },
                                { text: "Orang yang berilmu akan diangkat derajatnya oleh kehidupan.", author: "— Anonim" },
                                { text: "Bukan tugasnya yang berat, melainkan niatmu yang belum bulat.", author: "— Anonim" },
                                { text: "Selesaikan satu sesi Pomodoro lagi, dan kamu berhak mendapatkan istirahat berkualitas.", author: "— Study Tracker" },
                                { text: "Kunci dari ketenangan saat ujian adalah persiapan matang jauh-jauh hari.", author: "— Anonim" },
                                { text: "Jangan pernah meremehkan kekuatan dari belajar 15 menit setiap hari.", author: "— Anonim" },
                                { text: "Pikiranmu adalah aset terbesarmu. Berikan ia makanan terbaik berupa ilmu pengetahuan.", author: "— Anonim" },
                                { text: "Hargai setiap proses belajarmu, karena proses itulah yang membentuk karaktermu.", author: "— Anonim" },
                                { text: "Sukses tidak datang kepadamu, kamu yang harus pergi menjemputnya dengan belajar.", author: "— Anonim" },
                                { text: "Jadilah pembelajar sepanjang hayat, karena dunia akan terus berubah dan berkembang.", author: "— Anonim" },
                                { text: "Ketika kamu lelah, belajarlah untuk beristirahat, bukan untuk menyerah.", author: "— Anonim" },
                                { text: "Setiap coretan rumus dan catatan kecilmu hari ini adalah pondasi suksesmu.", author: "— Study Tracker" },
                                { text: "Keberanian untuk memulai mengalahkan ketakutan akan kegagalan.", author: "— Anonim" },
                                { text: "Berinvestasilah pada buku dan ilmu, karena itu investasi bebas risiko dengan untung besar.", author: "— Anonim" },
                                { text: "Masa depan yang cerah tidak dibangun dalam semalam, melainkan dari kedisiplinan harian.", author: "— Anonim" },
                                { text: "Jangan biarkan media sosial menghabiskan waktu produktif yang kamu miliki.", author: "— Anonim" },
                                { text: "Fokus penuh selama 25 menit jauh lebih baik daripada belajar 2 jam penuh distraksi.", author: "— Study Tracker" },
                                { text: "Pendidikan adalah investasi terbaik yang hasilnya akan terus kamu nikmati seumur hidup.", author: "— Anonim" },
                                { text: "Setiap kesulitan dalam memahami materi adalah tanda bahwa otakmu sedang berkembang.", author: "— Anonim" },
                                { text: "Jadilah orang yang mandiri dengan menguasai banyak bidang keilmuan.", author: "— Anonim" },
                                { text: "Tidak ada kata gagal dalam kamus pembelajar, yang ada hanya sukses atau belajar.", author: "— Anonim" },
                                { text: "Kerja keras mengalahkan bakat ketika bakat memilih untuk malas.", author: "— Anonim" },
                                { text: "Buatlah target harian yang realistis dan selesaikan dengan penuh tanggung jawab.", author: "— Anonim" },
                                { text: "Ilmu adalah harta karun yang akan mengikuti pemiliknya ke mana pun ia pergi.", author: "— Peribahasa Tiongkok" },
                                { text: "Satu sesi fokus lagi untuk menyelamatkan masa depanmu dari ketidaktahuan.", author: "— Study Tracker" },
                                { text: "Jangan tunda sampai besok apa yang bisa kamu pelajari hari ini.", author: "— Anonim" },
                                { text: "Kegagalan akademik bukanlah akhir dari segalanya, melainkan awal untuk evaluasi.", author: "— Anonim" },
                                { text: "Menguasai diri sendiri adalah kemenangan terbesar bagi seorang manusia.", author: "— Plato" },
                                { text: "Pikiran yang teratur melahirkan tindakan yang efektif dan hasil yang memuaskan.", author: "— Anonim" },
                                { text: "Membaca adalah cara terbaik untuk bertualang tanpa harus berpindah tempat.", author: "— Anonim" },
                                { text: "Setiap menit yang kamu investasikan untuk belajar mendekatkanmu pada impianmu.", author: "— Anonim" },
                                { text: "Disiplin harian melahirkan keunggulan jangka panjang.", author: "— Anonim" },
                                { text: "Tingkatkan kefokusanmu, kurangi keluhanmu, dan lihat hasilnya berkembang.", author: "— Study Tracker" },
                                { text: "Jangan membandingkan kecepatan belajarmu dengan orang lain, fokuslah pada pemahamanmu.", author: "— Anonim" },
                                { text: "Orang bijak belajar dari kesalahan sendiri, orang jenius belajar dari kesalahan orang lain.", author: "— Anonim" },
                                { text: "Pengetahuan memberikan rasa percaya diri yang tidak bisa dihancurkan oleh siapa pun.", author: "— Anonim" },
                                { text: "Setiap lembar tugas yang kamu kerjakan adalah bukti perjuanganmu.", author: "— Anonim" },
                                { text: "Jangan biarkan kenyamanan zona malas merusak potensi besar dalam dirimu.", author: "— Anonim" },
                                { text: "Sukses di masa depan dimulai dari keputusan kecil untuk membuka buku hari ini.", author: "— Anonim" },
                                { text: "Isi tangki kepintaranmu setiap hari dengan membaca hal baru.", author: "— Anonim" },
                                { text: "Target tercapai hari ini adalah modal kepercayaan diri untuk esok hari.", author: "— Study Tracker" },
                                { text: "Ketekunan mengalahkan rintangan tersulit sekalipun.", author: "— Anonim" },
                                { text: "Gunakan fasilitas belajarmu dengan penuh rasa tanggung jawab dan rasa syukur.", author: "— Anonim" },
                                { text: "Belajarlah untuk mendengarkan, agar kamu bisa memahami dunia dengan lebih baik.", author: "— Anonim" },
                                { text: "Kecerdasan tanpa integritas moral adalah bahaya besar bagi masyarakat.", author: "— Anonim" },
                                { text: "Jangan pernah merasa puas dengan ilmu yang kamu miliki, teruslah mencari.", author: "— Anonim" },
                                { text: "Setiap sesi belajar mandiri melatih kemandirian berpikirmu.", author: "— Anonim" },
                                { text: "Waktu berlalu dengan cepat, pastikan kamu meninggalkan jejak produktif hari ini.", author: "— Anonim" },
                                { text: "Kerjakan deadline tugasmu dengan santai tanpa stres lewat manajemen waktu yang rapi.", author: "— Study Tracker" },
                                { text: "Pendidikan sejati melahirkan pemikiran yang kritis dan hati yang penuh empati.", author: "— Anonim" },
                                { text: "Kesabaran dalam belajar membuahkan pemahaman yang kokoh.", author: "— Anonim" },
                                { text: "Jangan takut untuk bertanya jika kamu tidak memahami suatu materi.", author: "— Anonim" },
                                { text: "Ilmu pengetahuan adalah warisan terbaik yang bisa kita tinggalkan untuk generasi mendatang.", author: "— Anonim" },
                                { text: "Setiap ujian adalah kesempatan untuk mengukur sejauh mana kamu telah bertumbuh.", author: "— Anonim" },
                                { text: "Fokuslah pada satu hal sampai selesai sebelum berpindah ke hal lain.", author: "— Anonim" },
                                { text: "Kurangi kebiasaan multitasking, karena fokus tunggal menghasilkan kualitas terbaik.", author: "— Anonim" },
                                { text: "Satu langkah kecil lagi menuju versi terbaik dari dirimu sendiri.", author: "— Study Tracker" },
                                { text: "Belajarlah untuk mencintai proses pencarian ilmu, bukan hanya sekadar mengejar nilai.", author: "— Anonim" },
                                { text: "Masa depan dunia ada di tangan para pembelajar yang giat.", author: "— Anonim" },
                                { text: "Jangan biarkan keputusasaan meruntuhkan jembatan mimpi yang sedang kamu bangun.", author: "— Anonim" },
                                { text: "Kerapian catatan belajarmu mencerminkan kerapian alur berpikirmu.", author: "— Anonim" },
                                { text: "Setiap kegagalan dalam eksperimen adalah data berharga untuk kesuksesan berikutnya.", author: "— Anonim" },
                                { text: "Kuasai konsep dasarnya, maka materi sesulit apa pun akan mudah dipelajari.", author: "— Anonim" },
                                { text: "Luangkan waktu sejenak untuk mengevaluasi progres belajarmu minggu ini.", author: "— Anonim" },
                                { text: "Selamat, kamu telah menyelesaikan sesi fokus ini dengan sangat baik!", author: "— Study Tracker" },
                                { text: "Belajarlah dari masa lalu, bersiaplah untuk masa depan, hiduplah di masa sekarang.", author: "— Anonim" },
                                { text: "Kecerdasan adalah kemampuan untuk beradaptasi terhadap perubahan.", author: "— Stephen Hawking" },
                                { text: "Semakin keras kamu bekerja untuk sesuatu, semakin besar rasa kepuasanmu saat mencapainya.", author: "— Anonim" },
                                { text: "Mimpi tidak akan terwujud melalui sihir; itu membutuhkan keringat, tekad, dan kerja keras.", author: "— Colin Powell" },
                                { text: "Jangan biarkan apa yang tidak bisa kamu lakukan menghentikanmu melakukan apa yang bisa kamu lakukan.", author: "— Anonim" },
                                { text: "Kunci keberhasilan adalah fokus pada tujuan kita, bukan pada hambatan kita.", author: "— Anonim" },
                                { text: "Lakukan sesuatu hari ini yang akan membuat dirimu di masa depan berterima kasih.", author: "— Anonim" },
                                { text: "Rahasia kesuksesan adalah melakukan hal-hal biasa dengan cara yang luar biasa.", author: "— John D. Rockefeller" },
                                { text: "Fokuslah pada perbaikan diri sendiri, bukan pada pembuktian kepada orang lain.", author: "— Study Tracker" },
                                { text: "Tantangan adalah apa yang membuat hidup menarik dan mengatasinya membuat hidup penuh makna.", author: "— Anonim" },
                                { text: "Kamu tidak pernah terlalu tua untuk menetapkan tujuan baru atau memimpikan impian baru.", author: "— C.S. Lewis" },
                                { text: "Jangan biarkan rasa takut gagal menghalangimu dari petualangan besar belajarmu.", author: "— Anonim" },
                                { text: "Disiplin adalah kemampuan untuk memaksa diri melakukan apa yang harus dilakukan, kapan pun harus dilakukan, suka atau tidak suka.", author: "— Anonim" },
                                { text: "Setiap hari adalah kesempatan baru untuk menjadi lebih baik daripada hari kemarin.", author: "— Anonim" },
                                { text: "Keberhasilan bukanlah akhir, kegagalan bukanlah fatal: keberanian untuk melanjutkanlah yang penting.", author: "— Winston Churchill" },
                                { text: "Jangan menunggu kesempatan datang, ciptakan kesempatan itu dengan belajar keras.", author: "— Anonim" },
                                { text: "Pendidikan adalah kunci untuk membuka pintu emas kebebasan masa depan.", author: "— George Washington Carver" },
                                { text: "Kelola waktumu dengan bijak menggunakan Study Tracker, asisten setiamu.", author: "— Study Tracker" },
                                { text: "Orang yang sukses tidak pernah mengeluh tentang beratnya perjuangan belajar.", author: "— Anonim" },
                                { text: "Belajar secara konsisten adalah rahasia para juara dunia.", author: "— Anonim" },
                                { text: "Jangan biarkan kritik orang lain meruntuhkan semangat belajarmu.", author: "— Anonim" },
                                { text: "Ilmu adalah cahaya kehidupan, carilah ia sampai ke ujung dunia.", author: "— Anonim" },
                                { text: "Setiap sesi belajar yang teratur membentuk masa depan yang terencana.", author: "— Anonim" },
                                { text: "Fokus pada progres harianmu, bukan pada kesempurnaan instan.", author: "— Anonim" },
                                { text: "Kurangi waktu bermain game, tambah waktu untuk membaca buku bermanfaat.", author: "— Anonim" },
                                { text: "Langkah kecil hari ini, lompatan besar di masa depan.", author: "— Study Tracker" },
                                { text: "Pendidikan membuat seseorang mudah dipimpin tetapi sulit dikendalikan.", author: "— Lord Brougham" },
                                { text: "Hargai setiap tetes keringat belajarmu, karena itu investasi masa depan.", author: "— Anonim" },
                                { text: "Jangan biarkan penyesalan masa lalu merusak produktivitasmu hari ini.", author: "— Anonim" },
                                { text: "Membaca buku adalah investasi terbaik untuk memperluas wawasan berpikirmu.", author: "— Anonim" },
                                { text: "Setiap bab baru yang kamu kuasai adalah anak tangga menuju kesuksesan.", author: "— Anonim" },
                                { text: "Tetap tenang dan terus belajar, tantangan pasti bisa dilewati.", author: "— Anonim" },
                                { text: "Manajemen waktu yang baik membedakan antara pemenang dan pecundang.", author: "— Anonim" },
                                { text: "Gunakan sisa waktu belajarmu hari ini dengan fokus maksimal.", author: "— Study Tracker" },
                                { text: "Jangan pernah lelah mencari ilmu, karena ilmu menjaga pemiliknya.", author: "— Anonim" },
                                { text: "Keberanian untuk mencoba hal baru di dunia akademik adalah kunci inovasi.", author: "— Anonim" },
                                { text: "Pikiran yang fokus melahirkan daya pemahaman yang luar biasa tajam.", author: "— Anonim" },
                                { text: "Jangan tunda tugas kuliahmu sampai menumpuk dan memicu stres.", author: "— Anonim" },
                                { text: "Sukses sejati diraih lewat tetesan keringat ketekunan harian.", author: "— Anonim" },
                                { text: "Setiap sesi diskusi dengan teman menambah sudut pandang baru dalam kepalamu.", author: "— Anonim" },
                                { text: "Kuasai teknologi, manfaatkan ilmu untuk kebaikan sesama manusia.", author: "— Anonim" },
                                { text: "Fokus tunggal pada tugas saat ini adalah kunci produktivitas mutakhir.", author: "— Study Tracker" },
                                { text: "Belajarlah untuk rendah hati saat berilmu, agar ilmumu berkah bagi sesama.", author: "— Anonim" },
                                { text: "Masa depan cerah menanti mereka yang giat belajar hari ini.", author: "— Anonim" },
                                { text: "Jangan biarkan rasa malas merenggut impian indah masa depanmu.", author: "— Anonim" },
                                { text: "Kualitas catatan kuliahmu menentukan kemudahan belajarmu menjelang ujian.", author: "— Anonim" },
                                { text: "Setiap rumus sulit bisa ditaklukkan lewat latihan soal yang intensif.", author: "— Anonim" },
                                { text: "Kelola fokusmu dengan baik demi masa depan yang terarah jelas.", author: "— Anonim" },
                                { text: "Kurangi membuang waktu secara sia-sia di platform media sosial.", author: "— Anonim" },
                                { text: "Satu jam fokus belajar bermutu tinggi mengalahkan seharian belajar terdistraksi.", author: "— Study Tracker" },
                                { text: "Pendidikan sejati melatih karakter unggul di samping kecerdasan otak.", author: "— Anonim" },
                                { text: "Jangan pernah menyerah pada kegagalan pertama di dunia perkuliahan.", author: "— Anonim" },
                                { text: "Pikiran terbuka laksana payung; berfungsi maksimal saat terbuka lebar.", author: "— Anonim" },
                                { text: "Setiap lembar buku yang dibaca menambah kosa kata dan kedalaman berpikir.", author: "— Anonim" },
                                { text: "Disiplin diri mengantar kita ke tempat yang tidak bisa dijangkau bakat.", author: "— Anonim" },
                                { text: "Jadilah teladan produktivitas bagi teman-teman di sekitarmu.", author: "— Anonim" },
                                { text: "Evaluasi harian membuat target belajarmu tetap berada di jalur yang benar.", author: "— Anonim" },
                                { text: "Buka halaman barumu, jalankan Pomodoro, raih impianmu bersama kami.", author: "— Study Tracker" },
                                { text: "Belajarlah seakan kamu kekurangan ilmu setiap saat.", author: "— Anonim" },
                                { text: "Kecerdasan tanpa moralitas adalah bencana bagi peradaban manusia.", author: "— Anonim" },
                                { text: "Jangan takut bersaing secara sehat dalam mengejar prestasi akademik.", author: "— Anonim" },
                                { text: "Ilmu pengetahuan sejati membebaskan jiwa dari belenggu prasangka buruk.", author: "— Anonim" },
                                { text: "Setiap tugas yang selesai memberi rasa lega luar biasa.", author: "— Anonim" },
                                { text: "Fokuslah pada esensi ilmu, bukan sekadar menghafal untuk nilai.", author: "— Anonim" },
                                { text: "Kerapian meja belajar meningkatkan kenyamanan dan durasi fokusmu.", author: "— Anonim" },
                                { text: "Sesi belajar hari ini adalah investasi emas bagi masa depan kariermu.", author: "— Study Tracker" },
                                { text: "Jangan biarkan rasa kantuk merusak jadwal belajar yang sudah disusun.", author: "— Anonim" },
                                { text: "Pendidikan membuka jutaan peluang baru yang tak pernah terbayangkan.", author: "— Anonim" },
                                { text: "Tetap konsisten meskipun motivasi belajarmu sedang menurun.", author: "— Anonim" },
                                { text: "Membaca melahirkan kedalaman, diskusi melahirkan ketajaman berpikir.", author: "— Anonim" },
                                { text: "Setiap kesalahan dalam menjawab soal adalah ruang evaluasi diri.", author: "— Anonim" },
                                { text: "Disiplin waktu adalah tanda penghargaan tertinggi terhadap umurmu sendiri.", author: "— Anonim" },
                                { text: "Jadilah pembelajar yang aktif bertanya di dalam kelas perkuliahan.", author: "— Anonim" },
                                { text: "Satu sesi fokus sukses dilewati, langkahmu kian mantap menuju puncak.", author: "— Study Tracker" },
                                { text: "Belajar mandiri melatih ketajaman analisa problem solving kita.", author: "— Anonim" },
                                { text: "Jangan pernah mengabaikan penjelasan dosen di jam kuliah kritis.", author: "— Anonim" },
                                { text: "Kunci menguasai keahlian baru adalah latihan berulang tanpa bosan.", author: "— Anonim" },
                                { text: "Masa depan bangsa bergantung pada semangat belajar generasi mudanya.", author: "— Anonim" },
                                { text: "Setiap coretan rancangan tugas adalah bukti proses kreatifmu berjalan.", author: "— Anonim" },
                                { text: "Fokus penuh adalah kunci menyerap informasi rumit secara efektif.", author: "— Anonim" },
                                { text: "Kelola stres akademik lewat olahraga teratur dan istirahat cukup.", author: "— Anonim" },
                                { text: "Study Tracker siap menemanimu menaklukkan semester berat ini.", author: "— Study Tracker" },
                                { text: "Pendidikan sejati membuang kebodohan dan menumbuhkan kebijaksanaan.", author: "— Anonim" },
                                { text: "Jangan biarkan omongan miring orang lain menyurutkan niat kuliahmu.", author: "— Anonim" },
                                { text: "Pikiran yang jernih bersumber dari manajemen waktu belajar yang rapi.", author: "— Anonim" },
                                { text: "Setiap artikel ilmiah yang dibaca memperluas cakrawala intelektualmu.", author: "— Anonim" },
                                { text: "Disiplin belajar hari ini menghindarkanmu dari penyesalan di masa tua.", author: "— Anonim" },
                                { text: "Jadikan hobi belajarmu sebagai petualangan mencari tahu misteri dunia.", author: "— Anonim" },
                                { text: "Selesaikan target harianmu sekarang, nikmati akhir pekan tanpa beban.", author: "— Study Tracker" },
                                { text: "Belajar itu laksana mendayung ke hulu; tidak maju berarti hanyut surut.", author: "— Peribahasa Tiongkok" },
                                { text: "Kecerdasan emosional melengkapi kecerdasan intelektual dalam karier nyata.", author: "— Anonim" },
                                { text: "Jangan tunda mengulang materi kuliah di hari yang sama.", author: "— Anonim" },
                                { text: "Ilmu pengetahuan modern berkembang pesat, jangan biarkan dirimu tertinggal.", author: "— Anonim" },
                                { text: "Setiap diskusi produktif mempertajam nalar kritis mahasiswa.", author: "— Anonim" },
                                { text: "Fokus pada kelebihan dirimu, perbaiki kekuranganmu lewat belajar.", author: "— Anonim" },
                                { text: "Kerapian manajemen file materi kuliah memudahkan proses belajar mandiri.", author: "— Anonim" },
                                { text: "Aplikasi Study Tracker dirancang khusus agar fokusmu terjaga maksimal.", author: "— Study Tracker" },
                                { text: "Jangan pernah puas dengan gelar, kejarlah pemahaman substansi ilmunya.", author: "— Anonim" },
                                { text: "Pendidikan melahirkan kemerdekaan berpikir sejati dari belenggu doktrin.", author: "— Anonim" },
                                { text: "Tetap gigih berjuang meskipun materi kuliah terasa sangat abstrak.", author: "— Anonim" },
                                { text: "Membaca esai bermutu tinggi merangsang sel saraf otak berkembang aktif.", author: "— Anonim" },
                                { text: "Setiap ringkasan bab kuliah yang kamu buat adalah peta kesuksesanmu.", author: "— Anonim" },
                                { text: "Disiplin adalah kunci rahasia mengubah mimpi abstrak menjadi kenyataan fisik.", author: "— Anonim" },
                                { text: "Jadilah mahasiswa yang proaktif mencari peluang magang dan riset.", author: "— Anonim" },
                                { text: "Fokusmu hari ini menentukan tingkat kemudahan hidupmu di masa esok.", author: "— Study Tracker" },
                                { text: "Belajar membuat hidupmu jauh lebih berwarna dan penuh arti.", author: "— Anonim" },
                                { text: "Jangan biarkan rasa malas di pagi hari merusak seluruh jadwal produktifmu.", author: "— Anonim" },
                                { text: "Ilmu matematika melatih logika berpikir runtut dan sistematis.", author: "— Anonim" },
                                { text: "Setiap presentasi kuliah adalah ajang melatih keterampilan public speaking.", author: "— Anonim" },
                                { text: "Fokus penuh melahirkan efisiensi waktu kerja yang luar biasa.", author: "— Anonim" },
                                { text: "Manajemen waktu kuliah yang buruk adalah musuh utama kesuksesan akademik.", author: "— Anonim" },
                                { text: "Nyalakan timer Pomodoro-mu, mari kita taklukkan bab tersulit ini bersama.", author: "— Study Tracker" },
                                { text: "Pendidikan yang baik mengubah cermin menjadi jendela dunia luar.", author: "— Sydney J. Harris" },
                                { text: "Jangan pernah menyerah karena proses belajar terasa lambat.", author: "— Anonim" },
                                { text: "Pikiran positif mendatangkan kemudahan dalam menyerap materi perkuliahan.", author: "— Anonim" },
                                { text: "Setiap tugas kelompok melatih kepemimpinan dan kemampuan kolaborasimu.", author: "— Anonim" },
                                { text: "Disiplin diri adalah jembatan kokoh penghubung cita-cita dan realita.", author: "— Anonim" },
                                { text: "Jadikan belajar sebagai kebutuhan utama pertumbuhann jiwa mudamu.", author: "— Anonim" },
                                { text: "Satu pencapaian fokus lagi, kamu terbukti mampu melampaui batasan dirimu.", author: "— Study Tracker" },
                                { text: "Belajar metodologi riset membuka gerbang pemecahan masalah ilmiah.", author: "— Anonim" },
                                { text: "Jangan biarkan tumpukan tugas membuatmu lupa menjaga kesehatan fisik.", author: "— Anonim" },
                                { text: "Kunci ketenangan menghadapi ujian akhir semester adalah mencicil belajar.", author: "— Anonim" },
                                { text: "Masa depan gemilang menanti mereka yang konsisten menjaga fokusnya.", author: "— Anonim" },
                                { text: "Setiap jam belajar mandiri adalah investasi modal intelektual berharga.", author: "— Anonim" },
                                { text: "Fokus tunggal pada pengerjaan tugas menghindarkan diri dari kelelahan mental.", author: "— Anonim" },
                                { text: "Gunakan fitur pengingat tugas agar hidup mahasiswamu tertata rapi.", author: "— Study Tracker" },
                                { text: "Pendidikan sejati memerdekakan manusia dari belenggu kebodohan struktural.", author: "— Anonim" },
                                { text: "Jangan pernah berhenti mengasah kemampuan analisis logismu.", author: "— Anonim" },
                                { text: "Pikiran yang terlatih fokus mudah menemukan solusi kreatif atas masalah.", author: "— Anonim" },
                                { text: "Setiap referensi buku ilmiah yang dibaca memperkuat argumentasi tulisanmu.", author: "— Anonim" },
                                { text: "Disiplin waktu kuliah mencerminkan profesionalisme karakter masa depanmu.", author: "— Anonim" },
                                { text: "Jadilah mahasiswa pembelajar yang haus akan wawasan baru bermanfaat.", author: "— Anonim" },
                                { text: "Fokus belajarmu hari ini adalah penentu kualitas masa depan kariermu.", author: "— Study Tracker" },
                                { text: "Belajarlah mengevaluasi diri demi perbaikan kualitas hidup berkelanjutan.", author: "— Anonim" },
                                { text: "Jangan biarkan distraksi gawai pintar menjauhkanmu dari target akademik.", author: "— Anonim" },
                                { text: "Ilmu statistika membantu kita membaca data dunia dengan objektif.", author: "— Anonim" },
                                { text: "Setiap lembar esai tulisanmu mencerminkan kedalaman pemahaman teorimu.", author: "— Anonim" },
                                { text: "Fokus penuh saat belajar menghemat waktu berhargamu untuk hobi.", author: "— Anonim" },
                                { text: "Manajemen waktu yang efektif mengurangi kecemasan berlebih saat ujian.", author: "— Anonim" },
                                { text: "Raih efisiensi belajar tertinggi lewat siklus manajemen fokus kami.", author: "— Study Tracker" },
                                { text: "Pendidikan bermutu tinggi melahirkan generasi pemikir solutif masa depan.", author: "— Anonim" },
                                { text: "Jangan takut salah saat mencoba menyelesaikan soal latihan rumit.", author: "— Anonim" },
                                { text: "Pikiran jernih mempermudah penyimpanan materi memori jangka panjang.", author: "— Anonim" },
                                { text: "Setiap sesi bimbingan memperjelas arah penyelesaian tugas akhirmu.", author: "— Anonim" },
                                { text: "Disiplin tanpa pengawasan adalah tanda kedewasaan karakter sejati.", author: "— Anonim" },
                                { text: "Jadikan perpustakaan sebagai laboratorium pengembangan kapasitas intelektualmu.", author: "— Anonim" },
                                { text: "Target harian selesai, nikmati tidur malam nyenyak penuh kepuasan luar biasa.", author: "— Study Tracker" },
                                { text: "Belajarlah memahami fenomena alam dengan kacamata metode ilmiah.", author: "— Anonim" },
                                { text: "Jangan biarkan kebiasaan menunda menghancurkan nilai indeks prestasimu.", author: "— Anonim" },
                                { text: "Kunci sukses ujian lisan adalah penguasaan konsep materi mendalam.", author: "— Anonim" },
                                { text: "Masa kuliah adalah waktu emas membangun jaringan dan kapasitas diri.", author: "— Anonim" },
                                { text: "Setiap rangkuman rumus yang kamu tulis mempermudah review kilat.", author: "— Anonim" },
                                { text: "Fokus pada solusi, bukan meratapi rumitnya problem akademik.", author: "— Anonim" },
                                { text: "Aplikasi Study Tracker setia menemani setiap perjuangan malam belajarmu.", author: "— Study Tracker" },
                                { text: "Pendidikan bermutu tinggi adalah senjata terbaik memutus rantai kemiskinan.", author: "— Anonim" },
                                { text: "Jangan pernah bosan membaca ulang materi perkuliahan yang sulit.", author: "— Anonim" },
                                { text: "Pikiran fokus memancarkan energi produktivitas tinggi ke lingkungan sekitar.", author: "— Anonim" },
                                { text: "Setiap presentasi kelompok yang sukses meningkatkan kepercayaan dirimu.", author: "— Anonim" },
                                { text: "Disiplin memanfaatkan waktu luang membedakan tingkat pencapaian mahasiswa.", author: "— Anonim" },
                                { text: "Jadilah mahasiswa kreatif penemu solusi atas problem nyata masyarakat.", author: "— Anonim" },
                                { text: "Fokus tajam laksana laser, taklukkan setiap rintangan tugas kuliah.", author: "— Study Tracker" },
                                { text: "Belajarlah menyusun argumen berbasis data valid dan tepercaya.", author: "— Anonim" },
                                { text: "Jangan biarkan stres akademik merusak kebahagiaan masa muda perkuliahanmu.", author: "— Anonim" },
                                { text: "Ilmu filsafat melatih ketajaman berpikir radikal dan mendalam.", author: "— Anonim" },
                                { text: "Setiap sesi membaca kritis jurnal ilmiah meningkatkan kapasitas analisismu.", author: "— Anonim" },
                                { text: "Fokus penuh meminimalisir kesalahan dalam pengerjaan hitungan rumit.", author: "— Anonim" },
                                { text: "Manajemen waktu yang rapi kunci keseimbangan hidup organisasi perkuliahan.", author: "— Anonim" },
                                { text: "Waktu belajarmu sangat berharga, optimalkan bersama kami sekarang juga.", author: "— Study Tracker" },
                                { text: "Pendidikan sejati mencerdaskan otak sekaligus melembutkan hati nurani.", author: "— Anonim" },
                                { text: "Jangan pernah ragu melangkah mengejar beasiswa impian ke luar negeri.", author: "— Anonim" },
                                { text: "Pikiran positif mempermudah penemuan ide segar pembuatan tugas akhir.", author: "— Anonim" },
                                { text: "Setiap tantangan praktikum laboratorium melatih keterampilan teknis industrimu.", author: "— Anonim" },
                                { text: "Disiplin belajar berkala menghindarkan diri dari kepanikan sistem kebut semalam.", author: "— Anonim" },
                                { text: "Jadikan belajar mandiri sebagai petualangan seru mengungkap misteri ilmu.", author: "— Anonim" },
                                { text: "Satu sesi fokus bermutu tinggi selesai, kualitas dirimu resmi meningkat.", author: "— Study Tracker" },
                                { text: "Belajarlah mengintegrasikan berbagai disiplin ilmu demi solusi komprehensif.", author: "— Anonim" },
                                { text: "Jangan tunda pengerjaan revisi tugas setelah mendapat masukan berharga.", author: "— Anonim" },
                                { text: "Kunci keberhasilan diskusi ilmiah adalah keterbukaan menerima kritik logis.", author: "— Anonim" },
                                { text: "Masa depan cerah dibangun dari ketekunan menyelesaikan tugas harian kuliah.", author: "— Anonim" },
                                { text: "Setiap glosarium istilah baru yang dihafal memperkaya khazanah bahasamu.", author: "— Anonim" },
                                { text: "Fokus penuh mengh menghindarkan otak dari kelelahan akibat perpindahan tugas kronis.", author: "— Anonim" },
                                { text: "Kelola lini masa tugas kuliahmu dengan elegan lewat dasbor kami.", author: "— Study Tracker" },
                                { text: "Pendidikan melahirkan kedewasaan sikap dalam menghadapi perbedaan pandangan dunia.", author: "— Anonim" },
                                { text: "Jangan pernah malu mengakui ketidaktahuan demi mendapatkan ilmu baru.", author: "— Anonim" },
                                { text: "Pikiran terfokus mempermudah penyerapan konsep algoritma pemrograman rumit.", author: "— Anonim" },
                                { text: "Setiap review literatur ilmiah memperluas landasan teori riset mandirimu.", author: "— Anonim" },
                                { text: "Disiplin akademik adalah investasi reputasi profesional jangka panjangmu.", author: "— Anonim" },
                                { text: "Jadilah pionir gerakan produktif positif di lingkungan kampus perkuliahanmu.", author: "— Anonim" },
                                { text: "Fokus belajarmu malam ini adalah pembuka jalan sukses esok hari.", author: "— Study Tracker" },
                                { text: "Belajarlah mendengarkan kritikan akademis dengan kepala dingin penuh kelapangan.", author: "— Anonim" },
                                { text: "Jangan biarkan rasa malas menunda mimpi lulus tepat waktu dengan pujian.", author: "— Anonim" },
                                { text: "Ilmu sosiologi membantu kita memahami dinamika interaksi sosial masyarakat secara mendalam.", author: "— Anonim" },
                                { text: "Setiap esai analisis kritis yang ditulis mengasah ketajaman berpendapat logismu.", author: "— Anonim" },
                                { text: "Fokus tunggal melahirkan kedalaman karya akademik yang bernilai tinggi.", author: "— Anonim" },
                                { text: "Manajemen waktu yang seimbang menjamin kesuksesan akademik dan kesehatan mentalmu.", author: "— Anonim" },
                                { text: "Mari selesaikan satu sesi fokus lagi, masa depan cerah menantimu di sana.", author: "— Study Tracker" }
                            ]

                    Text { text: lang.quoteHariIni; color: window.accentColor; font.pixelSize: 13; font.bold: true; font.letterSpacing: 1 }

                    Rectangle {
                        Layout.fillWidth: true; height: quoteColumn.implicitHeight + 36; radius: 16
                        color: window.bgSecondary; border.color: Qt.rgba(255/255,204/255,0/255,0.3); border.width: 1
                        Rectangle { width: parent.width; height: 3; radius: 2; anchors.top: parent.top; color: window.accentColor; opacity: 0.7 }
                        Column {
                            id: quoteColumn
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
                            spacing: 12
                            Text { text: "❝"; color: window.accentColor; font.pixelSize: 28; font.bold: true }
                            // ✅ pakai id langsung, bukan parent.parent.parent chain
                            Text { text: motivasiTab.quotes[motivasiTab.quoteIndex].text; color: window.textPrimary; font.pixelSize: 14; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4 }
                            Text { text: motivasiTab.quotes[motivasiTab.quoteIndex].author; color: window.accentColor; font.pixelSize: 12; font.italic: true }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 10
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 10
                            color: prevArea.pressed ? Qt.darker(window.bgSecondary, 1.1) : window.bgSecondary; border.color: window.borderColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text { anchors.centerIn: parent; text: "‹ " + lang.sebelumnya; color: window.textMuted; font.pixelSize: 12 }
                            MouseArea {
                                id: prevArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                // ✅ pakai id langsung
                                onClicked: motivasiTab.quoteIndex = (motivasiTab.quoteIndex - 1 + motivasiTab.quotes.length) % motivasiTab.quotes.length
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 10
                            color: nextArea.pressed ? Qt.darker(window.bgSecondary, 1.1) : window.bgSecondary; border.color: window.borderColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text { anchors.centerIn: parent; text: lang.berikutnya; color: window.textPrimary; font.pixelSize: 12; font.bold: true }
                            MouseArea {
                                id: nextArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                // ✅ pakai id langsung
                                onClicked: motivasiTab.quoteIndex = (motivasiTab.quoteIndex + 1) % motivasiTab.quotes.length
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 58; radius: 12; color: window.bgCard; border.color: window.borderColor
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 10
                            Text { text: "🔥"; font.pixelSize: 22 }
                            Column {
                                spacing: 2
                                Text { text: lang.streakBelajar; color: window.textMuted; font.pixelSize: 11 }
                                Text { text: window.globalSessionsCompleted > 0 ? window.globalSessionsCompleted + lang.tetapSemangat : lang.belumMulai; color: window.textPrimary; font.pixelSize: 13; font.bold: true }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    ListModel { id: myFriendsModel }

    // ── LOADER HALAMAN ───────────────────────────────────────────────────────
    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: loginComponent

        // Animasi PUSH — masuk dari kanan
        pushEnter: Transition {
            NumberAnimation { property: "x"; from: pageStack.width; to: 0; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        pushExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: -pageStack.width * 0.3; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }

        // Animasi POP — kembali ke kiri
        popEnter: Transition {
            NumberAnimation { property: "x"; from: -pageStack.width * 0.3; to: 0; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        popExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: pageStack.width; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }

        // Animasi REPLACE — fade (untuk login ↔ main)
        replaceEnter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        }
        replaceExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }
    }

    // ── TIMER JAM ────────────────────────────────────────────────────────────
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var date  = new Date()
            var locStr = window.selectedLanguage === "English"  ? "en_US"
                       : window.selectedLanguage === "Japanese" ? "ja_JP"
                       : window.selectedLanguage === "Korean"   ? "ko_KR"
                       : window.selectedLanguage === "Arabic"   ? "ar_SA"
                       : "id_ID"
            timeText.text = date.toLocaleDateString(Qt.locale(locStr), "dddd, d MMMM yyyy") +
                            "  " + date.toLocaleTimeString(Qt.locale("id_ID"), "HH:mm")
        }
    }

    // ── Panel kanan atas: tanggal/jam + tombol + mini task list ──────────────
    Column {
        id: topRightPanel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 14
        spacing: 6
        z: 100

        // Baris jam + tombol Tambah Tugas
        Row {
            anchors.right: parent.right
            spacing: 10

            Text {
                id: timeText
                anchors.verticalCenter: parent.verticalCenter
                color: window.textMuted; font.pixelSize: 13
                text: {
                    var locStr = window.selectedLanguage === "English"  ? "en_US"
                               : window.selectedLanguage === "Japanese" ? "ja_JP"
                               : window.selectedLanguage === "Korean"   ? "ko_KR"
                               : window.selectedLanguage === "Arabic"   ? "ar_SA"
                               : "id_ID"
                    return new Date().toLocaleDateString(Qt.locale(locStr), "dddd, d MMMM yyyy") +
                           "  " + new Date().toLocaleTimeString(Qt.locale("id_ID"), "HH:mm")
                }
            }
            // "+ X tugas lagi"
            Text {
                anchors.right: parent.right
                visible: globalTaskModel.count > 4
                text: "+" + (globalTaskModel.count - 4) + " " + lang.tugas + " lagi"
                color: window.textMuted; font.pixelSize: 10; font.italic: true
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: pageStack.push(inputTugasComponent)
                }
            }
        }
    }

    function getClosestTask() {
        if (globalTaskModel.count === 0) return lang.belumAdaTugas
        for (let i = 0; i < globalTaskModel.count; i++)
            if (!globalTaskModel.get(i).isDone) return globalTaskModel.get(i).title
        return lang.semuaTugasSelesai
    }

    property Component temanComp: temanComponent

    // ── KOMPONEN-KOMPONEN HALAMAN ─────────────────────────────────────────────────────────────
    Component {
        id: loginComponent
        Login {
            onLoginSuccess: pageStack.replace(null, mainComponent)
        }
    }
    Component {
        id: mainComponent
        MainMenu {
            onLogoutRequested: {
                pageStack.replace(null, loginComponent)
                isLoginView = true
            }
        }
    }

    Component { id: temanComponent;      TemanPage {}      }
    Component { id: inputTugasComponent; InputTugas {}     }
    Component { id: studyRoomComponent;  StudyRoomPage {}  }
    Component { id: statistikComponent;  StatistikPage {}  }
    Component { id: settingsComponent;   SettingsPage {}   }
    Component { id: timerComponent;      TimerBelajar {}   }
}
