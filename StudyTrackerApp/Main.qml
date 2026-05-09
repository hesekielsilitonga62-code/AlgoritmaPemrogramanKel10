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
    property string currentActiveTask: "Belum Ada Tugas"
    property string currentChatFriend: ""
    property var chatHistories: ({})
    property string namaUser:         "Pengguna"
    property string statusUser:       "Semangat Belajar! 💪"
    property int    selectedAvatar:   0
    property string currentUser: ""
    property var _notifiedTasks: ({})

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
        if (appTheme === "gelap") {
            // Default — biru navy gelap
            bgPrimary   = "#001b2e"; bgSecondary = "#0a2a43"
            bgCard      = "#051624"; bgDeep      = "#020f1a"
            accentColor = "#ffcc00"; borderColor = "#163e5f"
            textPrimary = "#ffffff"; textMuted   = "#8a9fb1"
        } else if (appTheme === "hitam") {
            // Hitam pekat — AMOLED style
            bgPrimary   = "#0a0a0a"; bgSecondary = "#141414"
            bgCard      = "#050505"; bgDeep      = "#000000"
            accentColor = "#ffffff"; borderColor = "#2a2a2a"
            textPrimary = "#ffffff"; textMuted   = "#666666"
        } else if (appTheme === "putih") {
            // Putih terang — light mode bersih
            bgPrimary   = "#f0f4f8"; bgSecondary = "#ffffff"
            bgCard      = "#e8edf2"; bgDeep      = "#d8e0e8"
            accentColor = "#1565c0"; borderColor = "#cfd8dc"
            textPrimary = "#1a1a2e"; textMuted   = "#546e7a"
        } else if (appTheme === "pink") {
            // Pink Coquette — soft feminine rose
            bgPrimary   = "#1a0a12"; bgSecondary = "#2d1020"
            bgCard      = "#120709"; bgDeep      = "#0a0408"
            accentColor = "#ff6eb4"; borderColor = "#4a1a30"
            textPrimary = "#ffe0f0"; textMuted   = "#c27a9a"
        } else if (appTheme === "laut") {
            // Laut — biru muda lembut seperti langit siang
            bgPrimary   = "#0a1f3d"; bgSecondary = "#112d54"
            bgCard      = "#071529"; bgDeep      = "#040e1c"
            accentColor = "#38bdf8"; borderColor = "#1e4a7a"
            textPrimary = "#dbeafe"; textMuted   = "#7aadcc"
        } else if (appTheme === "adem") {
            // Hijau adem — mint / sage yang sejuk
            bgPrimary   = "#061a10"; bgSecondary = "#0e2e1c"
            bgCard      = "#040f09"; bgDeep      = "#020a05"
            accentColor = "#4ecca3"; borderColor = "#1a4a2e"
            textPrimary = "#d0f5e8"; textMuted   = "#6aab88"
        } else if (appTheme === "vintage") {
            // Vintage cokelat — earthy warm tones
            bgPrimary   = "#1c1208"; bgSecondary = "#2e1f0e"
            bgCard      = "#120c04"; bgDeep      = "#0a0700"
            accentColor = "#d4a24c"; borderColor = "#4a3010"
            textPrimary = "#f5e6c8"; textMuted   = "#9c7a4a"
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

    // Sound effect global untuk notifikasi
    SoundEffect { id: soundBeep; source: "qrc:/sounds/notif.wav" }

    // ════════════════════════════════════════════════════════════════════════
    // POMODORO NOTIFICATION LOGIC
    // ════════════════════════════════════════════════════════════════════════
    // Deteksi timer mulai
    onGlobalTimerRunningChanged: {
        if (globalTimerRunning) {
            pushNotif("🍅", "Sesi Fokus Dimulai!", pomodoroFokus + " menit fokus — semangat! 💪", "pomodoro")
        }
    }

    // Deteksi timer habis (value turun ke 0 saat running)
    onGlobalCurrentTimerValueChanged: {
        // Tepat habis → value jadi 0 dan timer masih running
        if (globalCurrentTimerValue === 0 && globalTimerRunning === false && globalSessionsCompleted > 0) {
            pushNotif("✅", "Sesi Selesai! 🎉", "Istirahat " + pomodoroIstirahat + " menit dulu ya!", "pomodoro")
        }
    }

    // Deteksi sesi selesai (globalSessionsCompleted naik)
    property int _prevSessions: 0
    onGlobalSessionsCompletedChanged: {
        if (globalSessionsCompleted > _prevSessions && _prevSessions >= 0) {
            _prevSessions = globalSessionsCompleted
            if (globalSessionsCompleted >= globalTargetSessions) {
                pushNotif("🏆", "Target Harian Tercapai!", globalSessionsCompleted + " sesi — luar biasa hari ini!", "pomodoro")
            } else {
                pushNotif("✅", "Sesi " + globalSessionsCompleted + " Selesai!", "Istirahat " + pomodoroIstirahat + " menit dulu ya~", "pomodoro")
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
        window.currentActiveTask       = "Belum Ada Tugas"
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
                { ms: 86400000, label: "1 hari",    key: "1d"  },
                { ms: 3600000,  label: "1 jam",     key: "1h"  },
                { ms: 1800000,  label: "30 menit",  key: "30m" },
                { ms: 900000,   label: "15 menit",  key: "15m" },
                { ms: 60000,    label: "1 menit",   key: "1m"  }
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
                            pushNotif("📋", "Deadline " + th.label + " lagi!", task.title, "task")
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // FRIEND MESSAGE NOTIFICATION — diproses via onLastFriendNotifChanged di atas
    // TemanPage cukup set: window.lastFriendNotif = namaUser + "||" + pesan
    // ════════════════════════════════════════════════════════════════════════

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
    }

    ListModel { id: chatModel }

    ListModel { id: searchResultModel }

    function navigateTo(pageName) {
        if (pageName === "Teman")         pageLoader.sourceComponent = temanComponent
        else if (pageName === "InputTugas") pageLoader.sourceComponent = inputTugasComponent
        else if (backend.login(userField.text, passField.text)) {
            loginRoot.loginAttempts = 0
            loginRoot.showError = false
            window.currentUser = userField.text   // ← tambah property ini di window
            backend.loadUserData(userField.text)
            pageLoader.sourceComponent = mainComponent
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
            "chatWith": friendName, "sender": "Saya",
            "message": messageText,
            "timestamp": new Date().toLocaleTimeString(Qt.locale("id_ID"), "HH:mm"),
            "isMe": true
        })
        Qt.callLater(function() {
            chatModel.append({
                "chatWith": friendName, "sender": friendName,
                "message": "Semangat belajarnya ya!",
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
                    Rectangle {
                        width: 52; height: 52; radius: 26
                        color: window.bgSecondary; border.color: window.accentColor; border.width: 2
                        Text { anchors.centerIn: parent; text: window.avatarList[window.selectedAvatar]; font.pixelSize: 28 }
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
                            { id: "motivasi", icon: "✨",  label: "Quotes"  }
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
                                        Text { text: model.deadline !== "" ? "📅 " + model.deadline : "Tanpa deadline"; color: window.accentColor; font.pixelSize: 10; opacity: model.isDone ? 0.5 : 1.0 }
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
                            MouseArea { id: addTugasArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { taskDrawer.close(); pageLoader.sourceComponent = inputTugasComponent } }
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
                        MouseArea { id: goTimerArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { taskDrawer.close(); pageLoader.source = "TimerBelajar.qml" } }
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
                        { text: "Pomodoro pertama hari ini sudah dimulai. Kamu luar biasa!", author: "— Study Tracker" }
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
    Loader {
        id: pageLoader; anchors.fill: parent; sourceComponent: loginComponent
        onLoaded: { if (item && item.hasOwnProperty("taskModel")) item.taskModel = globalTaskModel }
    }

    // ── TIMER JAM ────────────────────────────────────────────────────────────
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var date = new Date()
            timeText.text = date.toLocaleDateString(Qt.locale("id_ID"), "dddd, d MMMM yyyy") + " - " +
                            date.toLocaleTimeString(Qt.locale("id_ID"), "HH:mm")
        }
    }

    Text {
        id: timeText
        anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 20
        color: window.textMuted; font.pixelSize: 14; z: 100
        text: new Date().toLocaleDateString(Qt.locale("id_ID"), "dddd, d MMMM yyyy")
    }

    function getClosestTask() {
        if (globalTaskModel.count === 0) return lang.belumAdaTugas
        for (let i = 0; i < globalTaskModel.count; i++)
            if (!globalTaskModel.get(i).isDone) return globalTaskModel.get(i).title
        return lang.semuaTugasSelesai
    }

    property Component temanComp: temanComponent

    // ── KOMPONEN-KOMPONEN HALAMAN ─────────────────────────────────────────────
    Component {
        id: loginComponent
        Rectangle {
            id: loginRoot
            anchors.fill: parent; color: "transparent"

            property string errorMessage: ""
            property bool   showError:    false
            property int    loginAttempts: 0

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.9, 400); height: loginColumn.implicitHeight + 80
                radius: 20; color: window.textPrimary
                ColumnLayout {
                    id: loginColumn
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 40 }
                    spacing: 12

                    Text {
                        text: isLoginView ? lang.selamatDatang + " 👋" : lang.buatAkunBaru
                        font.pixelSize: 24; font.bold: true; color: "#1a1a2e"
                        Layout.alignment: Qt.AlignHCenter
                        topPadding: 10
                    }
                    Text {
                        text: isLoginView ? lang.masukKeApp : lang.daftarkanAkun
                        color: "#546e7a"; font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        visible: loginRoot.showError
                        text: loginRoot.errorMessage
                        color: loginRoot.errorMessage.includes("berhasil") ? "#2ecc71" : "#e74c3c"
                        font.pixelSize: 12; wrapMode: Text.WordWrap
                        Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (loginRoot.errorMessage.includes("daftar")) isLoginView = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 110; color: "#f8f9fa"; radius: 12; clip: true
                        Column {
                            anchors.fill: parent
                            TextField {
                                id: userField; width: parent.width; height: 55
                                placeholderText: lang.emailUsername; leftPadding: 20
                                color: "#333"; background: Rectangle { color: "transparent" }
                            }
                            Rectangle { width: parent.width * 0.9; height: 1; color: "#f0f0f0"; anchors.horizontalCenter: parent.horizontalCenter }
                            TextField {
                                id: passField; width: parent.width; height: 55
                                placeholderText: lang.kataSandi; echoMode: TextInput.Password
                                leftPadding: 20; color: "#333"; background: Rectangle { color: "transparent" }
                            }
                        }
                    }

                    Button {
                        id: loginBtn; Layout.fillWidth: true; Layout.topMargin: 25; height: 50
                        contentItem: Text {
                            text: isLoginView ? lang.masuk : lang.daftarSekarang
                            color: window.textPrimary; font.bold: true; font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle { color: loginBtn.pressed ? "#00c300" : "#05d605"; radius: 8 }
                        onClicked: {
                            if (isLoginView) {
                                if (userField.text === "" || passField.text === "") { loginRoot.errorMessage = lang.isiUsernamePassword; loginRoot.showError = true }
                                else if (!backend.checkUserExists(userField.text)) { loginRoot.errorMessage = lang.akunBelumAda; loginRoot.showError = true }
                                // GANTI line 972 dengan ini:
                                else if (backend.login(userField.text, passField.text)) {
                                    window.currentUser = userField.text
                                    var data = backend.loadUserData(userField.text)
                                    window.namaUser                = data.namaUser
                                    window.statusUser              = data.statusUser
                                    window.selectedAvatar          = data.selectedAvatar
                                    window.globalSessionsCompleted = data.sessionsCompleted
                                    window.globalSecondsFocused    = data.secondsFocused
                                    globalTaskModel.clear()
                                    var tasks = data.tasks
                                    for (var i = 0; i < tasks.length; i++) {
                                        globalTaskModel.append(tasks[i])
                                    }
                                    loginRoot.loginAttempts = 0
                                    loginRoot.showError = false
                                    pageLoader.sourceComponent = mainComponent
                                }
                                else { loginRoot.loginAttempts++; loginRoot.showError = true; loginRoot.errorMessage = (loginRoot.loginAttempts >= 3) ? lang.lupaPasswordKlik : lang.passwordSalah }
                            } else {
                                if (backend.registerUser(userField.text, passField.text)) { isLoginView = true; loginRoot.showError = true; loginRoot.errorMessage = lang.pendaftaranBerhasil }
                                else { loginRoot.showError = true; loginRoot.errorMessage = lang.gagalDaftar }
                            }
                        }
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 20; spacing: 15
                        Text {
                            text: isLoginView ? lang.lupaKataSandi : lang.kembali
                            color: "#546e7a"; font.pixelSize: 13
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (isLoginView) resetPopup.open(); else isLoginView = true } }
                        }
                        Text { text: "|"; color: "#546e7a" }
                        Text {
                            text: isLoginView ? lang.daftar : lang.sudahPunyaAkun
                            color: "#05d605"; font.pixelSize: 13; font.bold: true
                            MouseArea { anchors.fill: parent; onClicked: isLoginView = !isLoginView }
                        }
                    }

                    Popup {
                        id: resetPopup; anchors.centerIn: parent; width: 300; height: 200; modal: true
                        focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle { color: window.bgSecondary; radius: 15; border.color: window.accentColor }
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 15; spacing: 10
                            Text { text: lang.resetPasswordUntuk + userField.text; color: window.textPrimary; font.bold: true }
                            TextField { id: newPassField; placeholderText: lang.masukkanPasswordBaru; Layout.fillWidth: true; echoMode: TextInput.Password }
                            Button {
                                text: lang.simpanPassword; Layout.fillWidth: true
                                onClicked: { if (backend.resetPassword(userField.text, newPassField.text)) { loginRoot.errorMessage = "Password berhasil diubah! Silakan login."; loginRoot.loginAttempts = 0; resetPopup.close() } }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: mainComponent
        MainMenu {
            onLogoutRequested: {
                pageLoader.sourceComponent = loginComponent
                isLoginView = true
            }
        }
    }

    Component { id: temanComponent;      TemanPage {}      }
    Component { id: inputTugasComponent; InputTugas {}     }
    Component { id: studyRoomComponent;  StudyRoomPage {}  }
    Component { id: statistikComponent;  StatistikPage {}  }
    Component { id: settingsComponent;   SettingsPage {}   }
}
