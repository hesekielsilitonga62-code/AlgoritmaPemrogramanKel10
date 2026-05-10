import QtQuick

// ══════════════════════════════════════════════════════════════
//  Languange.qml  —  Sistem Terjemahan Multi-Bahasa
//  Bahasa: Indonesia, English, 中文, 日本語, 한국어,
//          Batak, Jawa, Español, Deutsch
// ══════════════════════════════════════════════════════════════

Item {
    id: root
    readonly property string lang: window.selectedLanguage
    // "Indonesia" | "English" | "中文" | "日本語" | "한국어"
    // | "Batak" | "Jawa" | "Español" | "Deutsch"

    // ── Helper internal ───────────────────────────────────────
    function t(id_ID, en, zh, ja, ko, btk, jv, es, de) {
        switch (root.lang) {
            case "English":  return en
            case "中文":      return zh
            case "日本語":    return ja
            case "한국어":    return ko
            case "Batak":    return btk
            case "Jawa":     return jv
            case "Español":  return es
            case "Deutsch":  return de
            default:         return id_ID   // Indonesia (default)
        }
    }

    // ══════════════════════════════════════════════════════════
    //  NAVIGASI & MENU UTAMA
    // ══════════════════════════════════════════════════════════
    readonly property string dashboard:       t("Dashboard",        "Dashboard",         "主页",          "ダッシュボード",  "대시보드",      "Dashboard",        "Dashboard",        "Panel",            "Übersicht")
    readonly property string tugas:           t("Tugas",            "Tasks",             "任务",          "タスク",          "과제",          "Ulaon",            "Tugas",            "Tareas",           "Aufgaben")
    readonly property string timer:           t("Timer Belajar",    "Study Timer",       "学习计时器",    "勉強タイマー",    "공부 타이머",   "Timer Parbelajaran","Timer Sinau",      "Temporizador",     "Lernzähler")
    readonly property string statistik:       t("Statistik",        "Statistics",        "统计",          "統計",            "통계",          "Statistik",        "Statistik",        "Estadísticas",     "Statistiken")
    readonly property string teman:           t("Teman",            "Friends",           "好友",          "フレンド",        "친구",          "Dongan",           "Kanca",            "Amigos",           "Freunde")
    readonly property string studyRoom:       t("Study Room",       "Study Room",        "学习室",        "スタディルーム",  "스터디룸",      "Kamar Parbelajaran","Ruang Sinau",      "Sala de Estudio",  "Lernraum")
    readonly property string pengaturan:      t("Pengaturan",       "Settings",          "设置",          "設定",            "설정",          "Pangaturan",       "Setelan",          "Configuración",    "Einstellungen")
    readonly property string keluarAkun:      t("Keluar Akun",      "Log Out",           "退出登录",      "ログアウト",      "로그아웃",      "Luar Akun",        "Medal Akun",       "Cerrar Sesión",    "Abmelden")
    readonly property string mainMenu:        t("Menu Utama",       "Main Menu",         "主菜单",        "メインメニュー",  "메인 메뉴",     "Menu Utama",       "Menu Utama",       "Menú Principal",   "Hauptmenü")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN DASHBOARD / MAIN MENU
    // ══════════════════════════════════════════════════════════
    readonly property string selamatDatang:     t("Selamat Datang",     "Welcome",             "欢迎",          "ようこそ",        "환영합니다",    "Horas",               "Sugeng Rawuh",        "Bienvenido",          "Willkommen")
    readonly property string semangatBelajar:   t("Semangat Belajar! 💪","Keep Learning! 💪",  "加油学习！💪",  "頑張って！💪",    "열공하자！💪",  "Horas Manjaha! 💪",   "Semangat Sinau! 💪",  "¡Ánimo! 💪",          "Weiter lernen! 💪")
    readonly property string mulaiSesi:         t("Mulai Sesi",          "Start Session",       "开始会话",      "セッション開始",  "세션 시작",     "Mulai Sesi",          "Miwiti Sesi",         "Iniciar Sesión",      "Sitzung starten")
    readonly property string sesiSelesai:       t("Sesi Selesai",        "Session Done",        "会话完成",      "セッション完了",  "세션 완료",     "Sesi Tamat",          "Sesi Rampung",        "Sesión Completa",     "Sitzung fertig")
    readonly property string waktuBelajar:      t("Waktu Belajar",       "Study Time",          "学习时间",      "学習時間",        "공부 시간",     "Waktu Parbelajaran",  "Wektu Sinau",         "Tiempo de Estudio",   "Lernzeit")
    readonly property string totalSesi:         t("Total Sesi",          "Total Sessions",      "总会话",        "合計セッション",  "총 세션",       "Total Sesi",          "Total Sesi",          "Sesiones Totales",    "Gesamtsitzungen")
    readonly property string fokus:             t("Fokus",               "Focus",               "专注",          "フォーカス",      "집중",          "Pakkokkon",           "Fokus",               "Enfoque",             "Fokus")
    readonly property string istirahat:         t("Istirahat",           "Break",               "休息",          "休憩",            "휴식",          "Istirahat",           "Ngaso",               "Descanso",            "Pause")
    readonly property string tugasAktif:        t("Tugas Aktif",         "Active Task",         "当前任务",      "現在のタスク",    "현재 과제",     "Ulaon Aktif",         "Gaweyan Aktif",       "Tarea Activa",        "Aktive Aufgabe")
    readonly property string belumAdaTugas:     t("Belum Ada Tugas",     "No Tasks Yet",        "暂无任务",      "タスクなし",      "과제 없음",     "Ndang Adong Ulaon",   "Durung Ana Tugas",    "Sin Tareas Aún",      "Noch keine Aufgaben")
    readonly property string semuaTugasSelesai: t("Semua Tugas Selesai!","All Tasks Done!",     "所有任务完成！", "全タスク完了！",  "모든 과제 완료!","Saluhut Ulaon Tamat!", "Kabeh Tugas Rampung!","¡Todo Listo!",        "Alle Aufgaben fertig!")
    readonly property string quoteHariIni:    t("Quote Hari Ini",         "Quote of the Day",      "每日名言",     "今日の名言",      "오늘의 명언",   "Quote Ari On",         "Quote Dina Iki",       "Cita del Día",          "Zitat des Tages")
    readonly property string sebelumnya:      t("Sebelumnya",             "Previous",              "上一条",       "前へ",            "이전",          "Naparjolo",            "Sadurunge",            "Anterior",              "Vorherige")
    readonly property string berikutnya:      t("Berikutnya",             "Next",                  "下一条",       "次へ",            "다음",          "Parpudi",              "Sabanjure",            "Siguiente",             "Nächste")
    readonly property string streakBelajar:   t("Streak belajar kamu",    "Your study streak",     "你的学习连续", "あなたの学習記録","학습 연속 기록","Streak parbalearanmu", "Streakmu sinau",       "Tu racha de estudio",   "Deine Lernserie")
    readonly property string tetapSemangat:   t("sesi · Tetap semangat!", "sessions · Keep it up!","节 · 继续加油！","回 · 頑張って！","회 · 파이팅！",  "sesi · Horas!",        "sesi · Tetap semangat!","ses. · ¡Ánimo!",        "Sitzungen · Weiter so!")
    readonly property string belumMulai:      t("Belum mulai hari ini",   "Not started today",     "今天还没开始", "今日未開始",      "오늘 아직 시작 안 함","Ndang mulai ari on","Durung miwiti dina iki","Aún sin empezar hoy",  "Heute noch nicht gestartet")
    readonly property string sesiHariIni: t("sesi hari ini",   "sessions today",   "节今天",   "回今日",   "회 오늘",   "sesi ari on",   "sesi dina iki",   "sesiones hoy",   "Sitzungen heute")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN TUGAS (InputTugas)
    // ══════════════════════════════════════════════════════════
    readonly property string tambahTugas:   t("Tambah Tugas",    "Add Task",          "添加任务",      "タスクを追加",    "과제 추가",     "Tambah Ulaon",     "Tambah Tugas",     "Agregar Tarea",    "Aufgabe hinzufügen")
    readonly property string judulTugas:    t("Judul Tugas",     "Task Title",        "任务标题",      "タスク名",        "과제 제목",     "Judul Ulaon",      "Judul Tugas",      "Título de Tarea",  "Aufgabentitel")
    readonly property string deadline:      t("Deadline",        "Deadline",          "截止日期",      "締め切り",        "마감일",        "Batas Waktu",      "Wates Waktu",      "Fecha Límite",     "Frist")
    readonly property string prioritas:     t("Prioritas",       "Priority",          "优先级",        "優先度",          "우선순위",      "Prioritas",        "Prioritas",        "Prioridad",        "Priorität")
    readonly property string tinggi:        t("Tinggi",          "High",              "高",            "高",              "높음",          "Gok",              "Dhuwur",           "Alto",             "Hoch")
    readonly property string sedang:        t("Sedang",          "Medium",            "中",            "中",              "보통",          "Tongah",           "Sedeng",           "Medio",            "Mittel")
    readonly property string rendah:        t("Rendah",          "Low",               "低",            "低",              "낮음",          "Sigumang",         "Asor",             "Bajo",             "Niedrig")
    readonly property string selesai:       t("Selesai",         "Done",              "完成",          "完了",            "완료",          "Tamat",            "Rampung",          "Listo",            "Fertig")
    readonly property string belumSelesai:  t("Belum Selesai",   "Not Done",          "未完成",        "未完了",          "미완료",        "Ndang Tamat",      "Durung Rampung",   "Sin Terminar",     "Nicht fertig")
    readonly property string hapus:         t("Hapus",           "Delete",            "删除",          "削除",            "삭제",          "Hapus",            "Busak",            "Eliminar",         "Löschen")
    readonly property string simpan:        t("Simpan",          "Save",              "保存",          "保存",            "저장",          "Simpan",           "Simpen",           "Guardar",          "Speichern")
    readonly property string batal:         t("Batal",           "Cancel",            "取消",          "キャンセル",      "취소",          "Batal",            "Batal",            "Cancelar",         "Abbrechen")
    readonly property string edit:          t("Edit",            "Edit",              "编辑",          "編集",            "편집",          "Edit",             "Sunting",          "Editar",           "Bearbeiten")
    readonly property string catatanTugas:  t("Catatan",         "Notes",             "备注",          "メモ",            "메모",          "Catatan",          "Cathetan",         "Notas",            "Notizen")
    readonly property string pilihTanggalDetail: t(
        "Pilih Tanggal & Detail", "Pick Date & Details",
        "选择日期和详情", "日付と詳細を選択", "날짜 및 세부사항 선택",
        "Pilih Tanggal & Detail", "Pilih Tanggal & Detail",
        "Elegir Fecha y Detalles", "Datum & Details auswählen")

    readonly property string simpanTugas: t(
        "Simpan Tugas", "Save Task",
        "保存任务", "タスクを保存", "과제 저장",
        "Simpan Ulaon", "Simpen Tugas",
        "Guardar Tarea", "Aufgabe speichern")
    readonly property string tanpaDeadline:   t("Tanpa Deadline",        "No Deadline",           "无截止日期",   "締め切りなし",    "마감 없음",     "Ndang Adong Batas",    "Tanpa Wates",          "Sin Fecha Límite",      "Ohne Frist")
    readonly property string yukTambahTugas:  t("Yuk tambah tugas dulu!","Add a task to start!",  "快来添加任务！", "タスクを追加！",  "과제를 추가해요!","Tambah ulaon dulu!",   "Ayo tambah tugas!",    "¡Agrega una tarea!",    "Füge eine Aufgabe hinzu!")
    readonly property string editTugas:        t("Edit Tugas",             "Edit Task",             "编辑任务",     "タスクを編集",    "과제 편집",     "Edit Ulaon",           "Sunting Tugas",        "Editar Tarea",          "Aufgabe bearbeiten")
    readonly property string simpanPerubahan:  t("Simpan Perubahan",       "Save Changes",          "保存更改",     "変更を保存",      "변경 저장",     "Simpan Parubahan",     "Simpen Owahan",        "Guardar Cambios",       "Änderungen speichern")
    readonly property string contohJudul:      t("Contoh: Buat laporan Fisika...", "Example: Write Physics report...", "例：写物理报告...", "例：物理レポート...", "예: 물리 보고서 쓰기...", "Contoh: Buat laporan Fisika...", "Tuladha: Gawe laporan Fisika...", "Ej: Escribir informe de Física...", "Bsp: Physikbericht schreiben...")
    readonly property string tidakBolehKosong: t("tidak boleh kosong!",    "cannot be empty!",      "不能为空！",    "空にできません！",  "비울 수 없습니다！","ndang boi kosong!",   "ora oleh kosong!",     "¡no puede estar vacío!","darf nicht leer sein!")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN TIMER BELAJAR
    // ══════════════════════════════════════════════════════════
    readonly property string mulai:         t("Mulai",           "Start",             "开始",          "スタート",        "시작",          "Mulai",            "Wiwit",            "Iniciar",          "Starten")
    readonly property string jeda:          t("Jeda",            "Pause",             "暂停",          "一時停止",        "일시 정지",     "Tangahan",         "Jedha",            "Pausar",           "Pausieren")
    readonly property string lanjutkan:     t("Lanjutkan",       "Resume",            "继续",          "再開",            "재개",          "Lanjutkon",        "Lanjutake",        "Reanudar",         "Fortsetzen")
    readonly property string resetTimer:    t("Reset",           "Reset",             "重置",          "リセット",        "초기화",        "Reset",            "Reset",            "Restablecer",      "Zurücksetzen")
    readonly property string modePomodoro:  t("Pomodoro",        "Pomodoro",          "番茄钟",        "ポモドーロ",      "포모도로",      "Pomodoro",         "Pomodoro",         "Pomodoro",         "Pomodoro")
    readonly property string sesiKe:        t("Sesi ke-",        "Session #",         "第",            "セッション #",    "세션 #",        "Sesi ke-",         "Sesi menyang-",    "Sesión #",         "Sitzung #")
    readonly property string targetHarian:  t("Target Harian",   "Daily Target",      "每日目标",      "デイリー目標",    "일일 목표",     "Target Sarian",    "Target Saben Dina","Objetivo Diario",  "Tagesziel")
    readonly property string tugasTerdekat:   t("Tugas Terdekat",         "Nearest Task",          "最近任务",    "最近のタスク",     "가장 가까운 과제","Ulaon Paling Jonok",   "Tugas Paling Cedhak",  "Tarea más próxima",     "Nächste Aufgabe")
    readonly property string stopTimer:       t("STOP",                   "STOP",                  "停止",        "停止",             "정지",           "STOP",                 "MANDHEG",             "PARAR",                 "STOPP")
    readonly property string skipTimer:       t("SKIP",                   "SKIP",                  "跳过",        "スキップ",         "건너뛰기",       "LEWATI",               "SKIP",                "SALTAR",                "ÜBERSPRINGEN")
    readonly property string dariSettings:    t("dari Settings",          "from Settings",         "来自设置",    "設定より",         "설정에서",       "Sian Pangaturan",      "Saka Setelan",        "desde Ajustes",         "aus Einstellungen")
    readonly property string totalFokus:      t("Total Fokus",            "Total Focus",           "总专注",      "総集中",           "총 집중",        "Total Fokus",          "Total Fokus",         "Enfoque Total",         "Gesamtfokus")
    readonly property string fokusAktif:      t("Fokus Terdeteksi!",      "Focus Detected!",       "检测到专注！", "集中検出！",       "집중 감지！",    "Fokus Diida!",         "Fokus Ketemu!",       "¡Enfoque Detectado!",   "Fokus Erkannt!")
    readonly property string fokusSubAktif:   t("Mantap! Pertahankan",    "Great! Keep it up",     "棒！继续保持", "素晴らしい！続けて","잘하고 있어！계속해","Maduma! Lanjutkon",  "Apik! Terusna",       "¡Genial! Continúa",     "Super! Weiter so")
    readonly property string fokusSubIdle:    t("Siapkan dirimu",         "Get yourself ready",    "准备好自己",  "準備しよう",       "준비하세요",     "Siapkon ho",           "Siapke awakmu",       "Prepárate",             "Mach dich bereit")
    readonly property string kembaliKeMenu:   t("KEMBALI KE MENU",        "BACK TO MENU",          "返回菜单",    "メニューへ戻る",   "메뉴로 돌아가기","MULAK TU MENU",        "BALIK KE MENU",       "VOLVER AL MENÚ",        "ZURÜCK ZUM MENÜ")
    readonly property string statistikFokus:   t("Statistik Fokus",       "Focus Statistics",      "专注统计",     "集中統計",        "집중 통계",     "Statistik Fokus",      "Statistik Fokus",      "Estadísticas de Enfoque","Fokusstatistiken")
    readonly property string progressTarget:   t("Progress Target",        "Target Progress",       "目标进度",     "目標の進捗",      "목표 진행률",   "Progress Target",      "Progress Target",      "Progreso del Objetivo", "Zielfortschritt")
    readonly property string timerBerjalan:    t("Timer berjalan",         "Timer running",         "计时器运行中", "タイマー作動中",  "타이머 실행 중","Timer Mangalehen",     "Timer Mlaku",          "Temporizador activo",   "Timer läuft")
    readonly property string timerTidakAktif:  t("Timer tidak aktif",      "Timer inactive",        "计时器未激活", "タイマー停止中",  "타이머 비활성", "Timer Ndang Aktif",    "Timer Ora Aktif",      "Temporizador inactivo", "Timer inaktiv")
    readonly property string bukaTimerPomodoro:t("Buka Timer Pomodoro",    "Open Pomodoro Timer",   "打开番茄钟",   "ポモドーロ開始",  "포모도로 열기", "Buka Timer Pomodoro",  "Buka Timer Pomodoro",  "Abrir Temporizador",    "Pomodoro öffnen")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN STATISTIK
    // ══════════════════════════════════════════════════════════
    readonly property string ringkasanBelajar:  t("Ringkasan Belajar",  "Study Summary",       "学习总结",      "学習サマリー",    "공부 요약",     "Ringkasan Parbelajaran","Ringkesan Sinau",  "Resumen de Estudio","Lernzusammenfassung")
    readonly property string totalWaktu:        t("Total Waktu",         "Total Time",          "总时间",        "合計時間",        "총 시간",       "Total Waktu",          "Total Wektu",       "Tiempo Total",      "Gesamtzeit")
    readonly property string rataRata:          t("Rata-rata",           "Average",             "平均",          "平均",            "평균",          "Rata-rata",            "Rata-rata",         "Promedio",          "Durchschnitt")
    readonly property string pencapaian:        t("Pencapaian",          "Achievements",        "成就",          "実績",            "업적",          "Pancapaian",           "Pencapaian",        "Logros",            "Errungenschaften")
    readonly property string grafik:            t("Grafik",              "Chart",               "图表",          "グラフ",          "그래프",        "Grafik",               "Grafik",            "Gráfico",           "Diagramm")
    readonly property string ringkasanAktivitas:  t("Ringkasan aktivitas sesi ini",    "This session's activity summary",   "本次活动摘要",     "今回のアクティビティ概要",  "이번 세션 활동 요약",   "Ringkasan aktivitas sesi on",  "Ringkesan aktivitas sesi iki", "Resumen de actividad",          "Aktivitätszusammenfassung")
    readonly property string totalWaktuBelajar:   t("Total Waktu Belajar",             "Total Study Time",                  "总学习时间",       "総学習時間",               "총 공부 시간",          "Total Waktu Parbelajaran",     "Total Wektu Sinau",            "Tiempo Total de Estudio",       "Gesamtlernzeit")
    readonly property string sesiPomodoroSelesai: t("Sesi Pomodoro Selesai",           "Pomodoro Sessions Done",            "完成的番茄钟",     "完了したポモドーロ",        "완료된 포모도로",       "Sesi Pomodoro Tamat",          "Sesi Pomodoro Rampung",        "Sesiones Pomodoro Completadas", "Abgeschlossene Pomodoro-Sitzungen")
    readonly property string tugasSelesaiLabel:   t("Tugas Selesai",                   "Tasks Completed",                   "已完成任务",       "完了したタスク",            "완료된 과제",           "Ulaon Tamat",                  "Tugas Rampung",                "Tareas Completadas",            "Abgeschlossene Aufgaben")
    readonly property string temanDitambahkan:    t("Teman Ditambahkan",               "Friends Added",                     "已添加好友",       "追加した友達",              "추가된 친구",           "Dongan Ditambai",              "Kanca Ditambah",               "Amigos Agregados",              "Hinzugefügte Freunde")
    readonly property string orang:               t("orang",                           "people",                            "人",              "人",                        "명",                   "halak",                        "wong",                         "personas",                      "Personen")
    readonly property string progressHariIni:     t("Progress Hari Ini",               "Today's Progress",                  "今日进度",         "今日の進捗",                "오늘의 진행 상황",      "Progress Ari On",              "Progress Dina Iki",            "Progreso de Hoy",               "Heutiger Fortschritt")
    readonly property string penyelesaianTugas:   t("Penyelesaian Tugas",              "Task Completion",                   "任务完成率",       "タスク完了率",              "과제 완료율",           "Penyelesaian Ulaon",           "Rampunge Tugas",               "Finalización de Tareas",        "Aufgabenabschluss")
    readonly property string waktuFokusPomodoro:  t("Waktu Fokus (Pomodoro)",          "Focus Time (Pomodoro)",             "专注时间（番茄钟）","集中時間（ポモドーロ）",   "집중 시간 (포모도로)",  "Waktu Fokus (Pomodoro)",       "Wektu Fokus (Pomodoro)",       "Tiempo de Enfoque (Pomodoro)",  "Fokuszeit (Pomodoro)")
    readonly property string motivasiAwal:        t("💪 Baru mulai! Konsistensi adalah kunci.",   "💪 Just started! Consistency is key.",        "💪 刚开始！坚持是关键。",     "💪 始めたばかり！継続が鍵です。",    "💪 막 시작했어요! 꾸준함이 핵심입니다.",  "💪 Baru mulai! Konsistensi kunci.",  "💪 Lagi miwiti! Konsistensi kuncine.",  "💪 ¡Recién empezando! La constancia es clave.",  "💪 Gerade begonnen! Konsequenz ist der Schlüssel.")
    readonly property string motivasiTengah:      t("🔥 Mantap! Terus pertahankan fokusmu.",      "🔥 Great! Keep maintaining your focus.",      "🔥 棒！继续保持专注。",         "🔥 素晴らしい！集中を維持してください。","🔥 멋져요! 집중력을 유지하세요.",         "🔥 Mantap! Lanjutkon fokusmu.",      "🔥 Apik! Terusna fokusmu.",             "🔥 ¡Genial! Mantén tu enfoque.",                 "🔥 Super! Behalte deinen Fokus.")
    readonly property string motivasiAkhir:       t("🏆 Luar biasa! Kamu sudah belajar lebih dari 2 jam!", "🏆 Amazing! You've studied for over 2 hours!", "🏆 太棒了！你已经学习超过2小时！", "🏆 素晴らしい！2時間以上勉強しました！", "🏆 대단해요! 2시간 이상 공부했어요!", "🏆 Luar biasa! Lehon bahat sian 2 jam!", "🏆 Luar biasa! Wis sinau luwih saka 2 jam!", "🏆 ¡Increíble! Has estudiado más de 2 horas.", "🏆 Großartig! Du hast über 2 Stunden gelernt!")
    readonly property string daftarTugas:         t("Daftar Tugas",                    "Task List",                         "任务列表",         "タスクリスト",              "과제 목록",             "Daftar Ulaon",                 "Daftar Tugas",                 "Lista de Tareas",               "Aufgabenliste")
    readonly property string pending:             t("Pending",                         "Pending",                           "待处理",          "保留中",                     "대기 중",              "Belum tamat",                  "Durung rampung",               "Pendiente",                     "Ausstehend")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN TEMAN
    // ══════════════════════════════════════════════════════════
    readonly property string cariTeman:     t("Cari Teman",      "Search Friends",    "搜索好友",      "友達を検索",      "친구 검색",     "Saru Dongan",      "Nggoleki Kanca",   "Buscar Amigos",    "Freunde suchen")
    readonly property string online:        t("Online",          "Online",            "在线",          "オンライン",      "온라인",        "Online",           "Online",           "En línea",         "Online")
    readonly property string offline:       t("Offline",         "Offline",           "离线",          "オフライン",      "오프라인",      "Offline",          "Offline",          "Sin conexión",     "Offline")
    readonly property string kirimPesan:    t("Kirim Pesan",     "Send Message",      "发消息",        "メッセージ送信",  "메시지 보내기", "Kirim Pesan",      "Kirim Pesen",      "Enviar Mensaje",   "Nachricht senden")
    readonly property string tambahTeman:   t("Tambah Teman",    "Add Friend",        "添加好友",      "フレンド追加",    "친구 추가",     "Tambah Dongan",    "Tambah Kanca",     "Agregar Amigo",    "Freund hinzufügen")
    readonly property string temanku:       t("Temanku",         "My Friends",        "我的好友",      "マイフレンド",    "내 친구",       "Donganku",         "Kancaku",          "Mis Amigos",       "Meine Freunde")
    readonly property string chat:          t("Chat",            "Chat",              "聊天",          "チャット",        "채팅",          "Chat",             "Chat",             "Chat",             "Chat")
    readonly property string kirim:         t("Kirim",           "Send",              "发送",          "送信",            "보내기",        "Kirim",            "Kirim",            "Enviar",           "Senden")
    readonly property string ketikPesan:    t("Ketik pesan...",  "Type a message...", "输入消息...",   "メッセージを入力...","메시지 입력...","Tulis pesan...",  "Tulis pesen...",   "Escribe un mensaje...","Nachricht eingeben...")
    readonly property string tambah:             t("Tambah",                        "Add",                           "添加",        "追加",            "추가",          "Tambai",                      "Tambah",                      "Agregar",                     "Hinzufügen")
    readonly property string cariTemanHint:      t("Cari nama teman untuk menambahkannya",   "Search a friend's name to add them",  "搜索好友名字以添加",   "友達の名前を検索して追加",   "친구 이름을 검색해서 추가하세요",  "Saru goar dongan",           "Goleki jeneng kanca",         "Busca un amigo para agregarlo",   "Freund suchen zum Hinzufügen")
    readonly property string userTidakDitemukan: t("User tidak ditemukan",          "User not found",                "用户不存在",  "ユーザーが見つかりません", "사용자를 찾을 수 없음", "User ndang jumpang",         "User ora ketemu",             "Usuario no encontrado",       "Benutzer nicht gefunden")
    readonly property string hasilPencarian:     t("Hasil pencarian:",              "Search results:",               "搜索结果：",  "検索結果：",      "검색 결과:",    "Hasil saru:",                 "Hasil goleki:",               "Resultados:",                 "Suchergebnisse:")
    readonly property string chatDengan:         t("Chat dengan",                   "Chat with",                     "与...聊天",   "とチャット",      "와 채팅",       "Chat tu",                     "Chat karo",                   "Chat con",                    "Chat mit")
    readonly property string sedangOffline:      t("sedang offline...",             "is offline...",                 "不在线...",   "はオフラインです...", "오프라인 중...", "lagi offline...",            "lagi offline...",             "está sin conexión...",        "ist offline...")
    readonly property string pesanOffline:       t("sedang offline. Pesan akan tersampaikan nanti.", "is offline. Message will be delivered later.", "不在线，消息稍后送达。", "はオフラインです。メッセージは後で届きます。", "오프라인입니다. 나중에 전달됩니다.", "lagi offline. Pesan dikirim nanti.", "lagi offline. Pesan dikirimke mengko.", "está offline. El mensaje se enviará luego.", "ist offline. Nachricht wird später zugestellt.")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN STUDY ROOM
    // ══════════════════════════════════════════════════════════
    readonly property string studyRoomJudul: t("Ruang Belajar",  "Study Room",        "自习室",        "自習室",          "스터디룸",      "Kamar Parbelajaran","Ruang Sinau",      "Sala de Estudio",  "Lernraum")
    readonly property string sedangBelajar:  t("Sedang Belajar", "Studying",          "正在学习",      "勉強中",          "공부 중",       "Lagi Manjaha",     "Lagi Sinau",       "Estudiando",       "Lernt gerade")
    readonly property string bergabung:      t("Bergabung",      "Join",              "加入",          "参加する",        "참가",          "Masuk",            "Gabung",           "Unirse",           "Beitreten")
    readonly property string tinggalkan:     t("Tinggalkan",     "Leave",             "离开",          "退出",            "나가기",        "Luar",             "Tinggalake",       "Salir",            "Verlassen")
    readonly property string kembali:         t("Kembali",               "Back",                  "返回",       "戻る",           "뒤로",          "Mulak",               "Balik",               "Volver",              "Zurück")
    readonly property string kamu:            t("Kamu",                  "You",                   "你",         "あなた",         "나",            "Ho",                  "Kowe",                "Tú",                  "Du")
    readonly property string waktuBelajarSesi:t("Waktu Belajar Sesi Ini","Study Time This Session","本次学习时间","今回の学習時間",  "이번 세션 공부 시간","Waktu Parbelajaran Sesi On","Wektu Sinau Sesi Iki","Tiempo de Estudio Esta Sesión","Lernzeit Diese Sitzung")
    readonly property string temanDiRoom:     t("Teman di Study Room",   "Friends in Study Room", "学习室好友",  "スタディルームの友達","스터디룸 친구",  "Dongan di Study Room","Kanca ing Study Room","Amigos en Sala de Estudio","Freunde im Lernraum")
    readonly property string peringkatSesi:   t("Peringkat Sesi Ini",    "This Session's Ranking","本次排名",    "今回のランキング","이번 세션 순위", "Ranking Sesi On",     "Peringkat Sesi Iki",  "Clasificación Esta Sesión","Rang Diese Sitzung")

    // ══════════════════════════════════════════════════════════
    //  HALAMAN PENGATURAN (Settings)
    // ══════════════════════════════════════════════════════════
    readonly property string profil:                t("Profil",             "Profile",             "个人资料",  "プロフィール",          "프로필",          "Profil",               "Profil",              "Perfil",              "Profil")
    readonly property string profilPengguna:        t("Profil Pengguna",    "User Profile",        "用户资料",  "ユーザープロフィール",  "사용자 프로필",   "Profil Pengguna",      "Profil Pangguna",     "Perfil de Usuario",   "Benutzerprofil")
    readonly property string namaUserLabel:         t("Nama Pengguna",      "Username",            "用户名",    "ユーザー名",            "사용자명",        "Goran",                "Jeneng",              "Nombre de Usuario",   "Benutzername")
    readonly property string namaTampilan:          t("Nama Tampilan",      "Display Name",        "显示名",    "表示名",                "표시 이름",       "Nama Tapian",          "Jeneng Tampilan",     "Nombre Visible",      "Anzeigename")
    readonly property string statusLabel:           t("Status",             "Status",              "状态",      "ステータス",            "상태",            "Status",               "Status",              "Estado",              "Status")
    readonly property string pilihAvatar:           t("Pilih Avatar",       "Choose Avatar",       "选择头像",  "アバターを選択",        "아바타 선택",     "Pilih Avatar",         "Pilih Avatar",        "Elegir Avatar",       "Avatar auswählen")
    readonly property string notifikasi:            t("Notifikasi",         "Notifications",       "通知",      "通知",                  "알림",            "Notifikasi",           "Notifikasi",          "Notificaciones",      "Benachrichtigungen")
    readonly property string pengingatBelajar:      t("Pengingat Belajar",  "Study Reminder",      "学习提醒",  "学習リマインダー",      "공부 알림",       "Pangingat Parbelajaran","Pengeling Sinau",    "Recordatorio Estudio","Lernerinnerung")
    readonly property string pengingatTugas:        t("Pengingat Tugas",    "Task Reminder",       "任务提醒",  "タスクリマインダー",    "과제 알림",       "Pangingat Ulaon",      "Pengeling Tugas",     "Recordatorio Tarea",  "Aufgabenerinnerung")
    readonly property string notifTeman:            t("Notifikasi Teman",   "Friend Notification", "好友通知",  "友達通知",              "친구 알림",       "Notifikasi Dongan",    "Notif Kanca",         "Notif. de Amigos",    "Freundbenachrichtigung")
    readonly property string suara:                 t("Suara",              "Sound",               "声音",      "サウンド",              "소리",            "Suara",                "Swara",               "Sonido",              "Ton")
    readonly property string tampilan:              t("Tampilan",           "Appearance",          "外观",      "外観",                  "외관",            "Tampilan",             "Tampilan",            "Apariencia",          "Erscheinungsbild")
    readonly property string temaWarna:             t("Tema Warna",         "Color Theme",         "颜色主题",  "カラーテーマ",          "색상 테마",       "Tema Rupa",            "Tema Warna",          "Tema de Color",       "Farbthema")
    readonly property string bahasa:                t("Bahasa",             "Language",            "语言",      "言語",                  "언어",            "Bahasa",               "Basa",                "Idioma",              "Sprache")
    readonly property string pomodoroLabel:         t("Pomodoro",           "Pomodoro",            "番茄钟",    "ポモドーロ",            "포모도로",        "Pomodoro",             "Pomodoro",            "Pomodoro",            "Pomodoro")
    readonly property string waktuFokus:            t("Waktu Fokus",        "Focus Time",          "专注时长",  "集中時間",              "집중 시간",       "Waktu Pakkokkon",      "Wektu Fokus",         "Tiempo de Enfoque",   "Fokuszeit")
    readonly property string waktuIstirahat:        t("Waktu Istirahat",    "Break Time",          "休息时长",  "休憩時間",              "휴식 시간",       "Waktu Istirahat",      "Wektu Ngaso",         "Tiempo de Descanso",  "Pausenzeit")
    readonly property string targetSesiHarian:      t("Target Sesi Harian", "Daily Session Target","每日目标次数","デイリー目標回数",   "일일 목표 횟수",  "Target Sesi Sarian",   "Target Sesi Saben Dina","Meta Diaria Sesiones","Tägliches Sitzungsziel")
    readonly property string akunKeamanan:          t("Akun & Keamanan",    "Account & Security",  "账号与安全","アカウントとセキュリティ","계정 및 보안",  "Akun & Keamanan",      "Akun & Keamanan",     "Cuenta y Seguridad",  "Konto & Sicherheit")
    readonly property string gantiPassword:         t("Ganti Password",     "Change Password",     "更改密码",  "パスワード変更",        "비밀번호 변경",   "Ganti Sandi",          "Ganti Sandi",         "Cambiar Contraseña",  "Passwort ändern")
    readonly property string passwordLama:          t("Password lama",      "Old password",        "旧密码",    "現在のパスワード",      "이전 비밀번호",   "Sandi Lama",           "Sandi Lawas",         "Contraseña actual",   "Altes Passwort")
    readonly property string passwordBaru:          t("Password baru",      "New password",        "新密码",    "新しいパスワード",      "새 비밀번호",     "Sandi Baru",           "Sandi Anyar",         "Nueva contraseña",    "Neues Passwort")
    readonly property string simpanPassword:        t("Simpan Password",    "Save Password",       "保存密码",  "パスワードを保存",      "비밀번호 저장",   "Simpan Sandi",         "Simpen Sandi",        "Guardar Contraseña",  "Passwort speichern")
    readonly property string resetSemuaData:        t("Reset Semua Data",   "Reset All Data",      "重置所有数据","全データをリセット",  "모든 데이터 초기화","Reset Saluhut Data", "Reset Kabeh Data",    "Restablecer Datos",   "Alle Daten zurücksetzen")
    readonly property string tentangAplikasi:       t("Tentang Aplikasi",   "About",               "关于应用",  "アプリについて",        "앱 정보",         "Tentang Aplikasi",     "Bab Aplikasi",        "Acerca de",           "Über die App")
    readonly property string aktif:                 t("AKTIF",              "ACTIVE",              "已选",      "選択中",                "활성",            "AKTIF",                "AKTIF",               "ACTIVO",              "AKTIV")
    readonly property string bahasaBerlaku:         t("🌐 Bahasa diterapkan!",  "🌐 Language applied!","🌐 语言已应用！","🌐 言語が適用されました！","🌐 언어가 적용되었습니다!","🌐 Bahasa dipakai!","🌐 Basa dianggo!","🌐 ¡Idioma aplicado!","🌐 Sprache angewendet!")
    readonly property string temaDiterapkan:        t("🎨 Tema diterapkan!", "🎨 Theme applied!",    "🎨 主题已应用！","🎨 テーマが適用されました！","🎨 테마가 적용되었습니다!","🎨 Tema dipakai!","🎨 Tema dianggo!","🎨 ¡Tema aplicado!","🎨 Design angewendet!")
    readonly property string infoLanguage:        t("✅ Perubahan bahasa langsung diterapkan","✅ Language changes applied instantly","✅ 语言立即生效","✅ 言語はすぐに反映されます","✅ 언어 변경이 즉시 적용됩니다","✅ Bahasa langsung berlaku","✅ Basa langsung diterapke","✅ El idioma se aplica al instante","✅ Sprache wird sofort übernommen")
    readonly property string pengingatBelajarSub: t("Notifikasi saat sesi pomodoro dimulai","Notify when pomodoro starts","番茄钟开始时通知","ポモドーロ開始時に通知","포모도로 시작 시 알림","Notifikasi mula sesi","Notif wiwit sesi","Notificar al iniciar pomodoro","Benachrichtigung bei Pomodoro-Start")
        readonly property string pengingatTugasSub:   t("Notifikasi deadline tugas mendekat","Notify when task deadline is near","任务截止日期临近通知","タスク期限が近い時に通知","과제 마감 임박 알림","Notifikasi deadline ro","Notif deadline cedak","Notificar cuando vence tarea","Benachrichtigung bei nahendem Abgabedatum")
        readonly property string notifTemanSub:       t("Notifikasi saat teman mengirim pesan","Notify when a friend messages you","好友发消息时通知","友達からメッセージが来た時に通知","친구 메시지 알림","Notifikasi dongan mangirim","Notif kanca kirim pesan","Notificar mensaje de amigo","Benachrichtigung bei Freundesnachricht")
    readonly property string suaraSub:            t("Suara notifikasi dan timer",            "Notification and timer sounds",     "通知和计时器声音", "通知とタイマーの音", "알림 및 타이머 소리", "Suara notifikasi dohot timer", "Swara notifikasi lan timer", "Sonidos de notificación y temporizador", "Benachrichtigungs- und Timer-Töne")
    readonly property string sesi:               t("sesi",         "sessions",    "节",      "セッション",  "세션",       "sesi",          "sesi",         "sesiones",      "Sitzungen")
    readonly property string waktuFokusSub:      t("Lama satu sesi belajar",          "Duration of one study session",    "每次学习时长",     "1回の学習時間",       "한 세션 공부 시간",   "Lama sada sesi parbelajaran", "Suwene siji sesi sinau",  "Duración de una sesión",        "Dauer einer Lernsitzung")
    readonly property string waktuIstirahatSub:  t("Jeda setelah tiap sesi",          "Break after each session",         "每节课后休息",     "各セッション後の休憩", "세션 후 휴식",        "Jeda dung tiap sesi",         "Jedah sawise saben sesi",  "Descanso tras cada sesión",     "Pause nach jeder Sitzung")
    readonly property string targetSesiHarianSub:t("Jumlah sesi pomodoro per hari",   "Number of pomodoro sessions/day",  "每日番茄钟次数",   "1日のポモドーロ回数",  "하루 포모도로 횟수",  "Jumlah sesi pomodoro sian",   "Cacahe sesi pomodoro saben dina","Sesiones de pomodoro por día","Pomodoro-Sitzungen pro Tag")
    readonly property string totalFokusStat:     t("Total waktu fokus per hari: {menit} menit ({jam} jam {sisa} menit)", "Total focus time per day: {menit} min ({jam} hr {sisa} min)", "每日总专注时间：{menit} 分钟（{jam} 小时 {sisa} 分钟）", "1日の総集中時間：{menit} 分（{jam} 時間 {sisa} 分）", "하루 총 집중 시간: {menit}분 ({jam}시간 {sisa}분)",
                                                   "Total waktu fokus sian: {menit} menit ({jam} jam {sisa} menit)",
                                                   "Total wektu fokus saben dina: {menit} menit ({jam} jam {sisa} menit)",
                                                   "Tiempo total de enfoque: {menit} min ({jam} h {sisa} min)",
                                                   "Gesamte Fokuszeit pro Tag: {menit} Min. ({jam} Std. {sisa} Min.)")
    property var langList: [
        { key: "Indonesia", flag: "🇮🇩", label: "Indonesia" },
        { key: "English",   flag: "🇬🇧", label: "English"   },
        { key: "中文",       flag: "🇨🇳", label: "中文"       },
        { key: "日本語",     flag: "🇯🇵", label: "日本語"     },
        { key: "한국어",     flag: "🇰🇷", label: "한국어"     },
        { key: "Batak",     flag: "🏔️",  label: "Batak"     },
        { key: "Jawa",      flag: "🌴",  label: "Jawa"      },
        { key: "Español",   flag: "🇪🇸", label: "Español"   },
        { key: "Deutsch",   flag: "🇩🇪", label: "Deutsch"   },
    ]
    readonly property string tentangDeskripsi: t(
        "Aplikasi tracker belajar dengan Pomodoro,\nmanajemen tugas, dan study room bersama teman.",
        "A study tracker app with Pomodoro,\ntask management, and a shared study room.",
        "学习追踪应用，包含番茄钟、\n任务管理和共同学习室。",
        "ポモドーロ、タスク管理、\n共同学習ルームを備えた学習トラッカー。",
        "포모도로, 과제 관리,\n스터디룸이 있는 공부 트래커 앱.",
        "Aplikasi pelacak parbelajaran dohot Pomodoro,\nmanajemen ulaon, dohot study room.",
        "Aplikasi tracker sinau karo Pomodoro,\nmanajemen tugas, lan study room bareng.",
        "App de seguimiento de estudio con Pomodoro,\ngestión de tareas y sala de estudio.",
        "Lern-Tracker-App mit Pomodoro,\nAufgabenverwaltung und gemeinsamem Lernraum.")

    // ══════════════════════════════════════════════════════════
    //  LOGIN & REGISTRASI
    // ══════════════════════════════════════════════════════════
    readonly property string masuk:         t("Masuk",           "Log In",            "登录",          "ログイン",        "로그인",        "Masuk",            "Mlebu",            "Iniciar Sesión",   "Anmelden")
    readonly property string daftar:        t("Daftar",          "Register",          "注册",          "登録",            "회원가입",      "Daftar",           "Daftar",           "Registrarse",      "Registrieren")
    readonly property string kataSandi:     t("Kata Sandi",      "Password",          "密码",          "パスワード",      "비밀번호",      "Sandi",            "Sandi",            "Contraseña",       "Passwort")
    readonly property string lupaKataSandi: t("Lupa Kata Sandi?","Forgot Password?",  "忘记密码？",    "パスワードを忘れた？","비밀번호 분실？","Lupa Sandi?",   "Lali Sandi?",      "¿Olvidé la clave?","Passwort vergessen?")
    readonly property string belumPunyaAkun:t("Belum punya akun?","Don't have an account?","还没账号？","アカウントお持ちでないですか？","계정이 없으신가요?","Ndang adong akun?","Durung duwe akun?","¿No tienes cuenta?","Noch kein Konto?")
    readonly property string sudahPunyaAkun:t("Sudah punya akun?","Already have an account?","已有账号？","アカウントお持ちですか？","계정이 있으신가요?","Alai ro akun?","Wis duwe akun?","¿Ya tienes cuenta?","Bereits ein Konto?")
    readonly property string buatAkunBaru:        t("Buat Akun Baru",           "Create New Account",     "创建新账号",    "新規アカウント",      "새 계정 만들기",   "Buat Akun Baru",           "Gawe Akun Anyar",          "Crear Cuenta Nueva",        "Neues Konto erstellen")
    readonly property string masukKeApp:          t("Masuk ke Study Tracker",   "Log in to Study Tracker","登录学习追踪器","Study Trackerにログイン","스터디트래커 로그인","Masuk tu Study Tracker",  "Mlebu Study Tracker",      "Iniciar en Study Tracker",  "Bei Study Tracker anmelden")
    readonly property string daftarkanAkun:       t("Daftarkan akun baru",      "Register a new account", "注册新账号",    "新規登録",            "새 계정 등록",     "Daftar akun baru",         "Daftarke akun anyar",      "Registrar cuenta nueva",    "Neues Konto registrieren")
    readonly property string emailUsername:       t("Email atau Username",       "Email or Username",      "邮箱或用户名",  "メールまたはユーザー名","이메일 또는 유저명","Email bage Username",      "Email utawa Username",     "Correo o Usuario",          "E-Mail oder Benutzername")
    readonly property string daftarSekarang:      t("Daftar Sekarang",          "Register Now",           "立即注册",      "今すぐ登録",          "지금 등록",        "Daftar Nuaeng",            "Daftar Saiki",             "Registrarse Ahora",         "Jetzt registrieren")
    readonly property string resetPasswordUntuk:  t("Reset Password untuk: ",   "Reset Password for: ",   "重置密码：",    "パスワードをリセット：","비밀번호 재설정：", "Reset Sandi tu: ",         "Reset Sandi kanggo: ",     "Restablecer para: ",        "Passwort zurücksetzen für: ")
    readonly property string masukkanPasswordBaru:t("Masukkan Password Baru",   "Enter New Password",     "输入新密码",    "新しいパスワード",     "새 비밀번호 입력",  "Pamasukkon Sandi Baru",    "Lebokke Sandi Anyar",      "Ingresa Nueva Contraseña",  "Neues Passwort eingeben")
    readonly property string isiUsernamePassword:  t("Isi dulu username dan passwordnya ya!",  "Please fill in your username and password!",  "请填写用户名和密码！",  "ユーザー名とパスワードを入力してください！",  "아이디와 비밀번호를 입력하세요！",  "Isi dulu username dohot sandi!",        "Isi disik username lan sandine!",       "¡Ingresa usuario y contraseña!",         "Bitte Benutzername und Passwort eingeben!")
    readonly property string akunBelumAda:         t("Akun belum ada. Klik 'Daftar Akun' di bawah! ➔",  "Account not found. Click 'Register' below! ➔",  "账号不存在，点击下方注册！➔",  "アカウントが見つかりません。下の登録をクリック！➔",  "계정 없음. 아래 가입 클릭！➔",  "Akun ndang adong. Klik 'Daftar' i toru! ➔",  "Akun durung ana. Klik 'Daftar' ing ngisor! ➔",  "Cuenta no encontrada. ¡Clic en Registrarse! ➔",  "Konto nicht gefunden. Unten registrieren! ➔")
    readonly property string lupaPasswordKlik:     t("Lupa password? Klik di bawah! ➔",        "Forgot password? Click below! ➔",             "忘记密码？点击下方！➔",         "パスワードを忘れた？下をクリック！➔",             "비밀번호 잊음? 아래 클릭！➔",          "Lupa sandi? Klik i toru! ➔",           "Lali sandi? Klik ing ngisor! ➔",       "¿Olvidaste? ¡Clic abajo! ➔",            "Passwort vergessen? Unten klicken! ➔")
    readonly property string passwordSalah:        t("Password salah, coba lagi!",              "Wrong password, try again!",                  "密码错误，请重试！",            "パスワードが違います。再試行！",                   "비밀번호 틀림, 다시 시도！",            "Sandi salah, coba muse!",               "Sandi salah, coba maneh!",              "Contraseña incorrecta, ¡inténtalo!",     "Falsches Passwort, nochmal versuchen!")
    readonly property string pendaftaranBerhasil:  t("Pendaftaran berhasil! Silakan login.",     "Registration successful! Please log in.",      "注册成功！请登录。",            "登録成功！ログインしてください。",                 "가입 성공！로그인 해주세요。",           "Pendaftaran las! Masuk nuaeng.",         "Pendaftaran kasil! Saiki mlebu.",       "¡Registro exitoso! Inicia sesión.",      "Registrierung erfolgreich! Bitte anmelden.")
    readonly property string gagalDaftar:          t("Gagal daftar. Username/Password tidak boleh kosong!",  "Registration failed. Username/Password cannot be empty!",  "注册失败，用户名/密码不能为空！",  "登録失敗。ユーザー名/パスワードは空にできません！",  "가입 실패. 아이디/비밀번호 비어있음！",  "Gagal daftar. Username/Sandi ndang boi kosong!",  "Gagal daftar. Username/Sandi ora oleh kosong!",  "Error al registrar. ¡Usuario/Contraseña no pueden estar vacíos!",  "Registrierung fehlgeschlagen. Benutzername/Passwort darf nicht leer sein!")
    readonly property string isiUsernameDulu:    t("Isi username di form login dulu!",         "Please fill in your username first!",          "请先填写用户名！",          "まずユーザー名を入力してください！",       "먼저 아이디를 입력하세요！",        "Isi username i form login!",           "Isi username ing form login disik!",        "¡Ingresa tu usuario primero!",           "Bitte zuerst Benutzernamen eingeben!")
    readonly property string passwordSalahNKali: t("x salah. Klik Reset → untuk ubah password.","x wrong. Click Reset → to change password.", "次错误，点击重置→更改密码。","回間違い。リセット→をクリック。",         "회 틀림. Reset → 클릭。",           "x salah. Klik Reset → ganti sandi.",   "x salah. Klik Reset → kanggo ganti sandi.", "veces mal. Clic Reset → para cambiar.","x falsch. Reset → zum Ändern klicken.")
    readonly property string passwordLamaSalah:  t("❌ Password lama salah.",                   "❌ Old password is wrong.",                    "❌ 旧密码错误。",            "❌ 現在のパスワードが違います。",           "❌ 이전 비밀번호가 틀립니다.",       "❌ Sandi lama salah.",                  "❌ Sandi lawas salah.",                     "❌ Contraseña actual incorrecta.",        "❌ Altes Passwort falsch.")
    readonly property string dekorasiSlogan:   t("Belajar lebih cerdas,\nbukan lebih keras.",          "Study smarter,\nnot harder.",                   "聪明学习，\n而非努力。",            "賢く学ぼう、\n頑張るだけじゃない。",      "더 똑똑하게,\n더 열심히 말고。",      "Mangaranto na denggan,\nndang holan gogong.",    "Sinau luwih pinter,\nbukan mung rekasa.",        "Estudia más inteligente,\nno más duro.",          "Lerne klüger,\nnicht härter.")
    readonly property string dekorasi1: t("✅  Lacak sesi belajarmu",        "✅  Track your study sessions",     "✅  追踪你的学习",       "✅  学習を記録しよう",       "✅  학습 세션 추적",      "✅  Lacak sesi parbelajaranmu",   "✅  Lacak sesi sinaume",          "✅  Rastrea tus sesiones",         "✅  Lerneinheiten verfolgen")
    readonly property string dekorasi2: t("⏱  Timer Pomodoro terintegrasi", "⏱  Built-in Pomodoro Timer",       "⏱  内置番茄钟",         "⏱  ポモドーロ内蔵",         "⏱  포모도로 타이머 내장", "⏱  Timer Pomodoro di hamu",      "⏱  Timer Pomodoro terintegrasi", "⏱  Temporizador Pomodoro",        "⏱  Integrierter Pomodoro-Timer")
    readonly property string dekorasi3: t("📋  Manajemen tugas harian",      "📋  Daily task management",        "📋  日常任务管理",       "📋  毎日のタスク管理",      "📋  일일 과제 관리",      "📋  Manajemen ulaon sarian",      "📋  Manajemen tugas saben dina",  "📋  Gestión de tareas diarias",   "📋  Tägliche Aufgabenverwaltung")
    readonly property string dekorasi4: t("👥  Study room bareng teman",     "👥  Study room with friends",      "👥  与朋友共同学习",     "👥  友達と勉強部屋",        "👥  친구랑 스터디룸",    "👥  Study room rap dongan",       "👥  Study room bareng kanca",     "👥  Sala de estudio con amigos",  "👥  Lernraum mit Freunden")
    readonly property string dekorasi5: t("🏆 Raih target belajarmu",        "🏆 Reach your study goals",        "🏆 达成学习目标",       "🏆 学習目標を達成しよう", "🏆 학습 목표 달성",       "🏆 Raih target parbelajaranmu",   "🏆 Raih target sinaume",          "🏆 Alcanza tus metas",            "🏆 Lernziele erreichen")
    readonly property string dekorasi6: t("📊 Pantau statistik harian",      "📊 Monitor daily statistics",      "📊 监控每日统计",       "📊 毎日の統計を確認",     "📊 일일 통계 확인",       "📊 Pantau statistik sarian",      "📊 Pantau statistik saben dina",  "📊 Monitorea estadísticas",       "📊 Tagesstatistiken überwachen")
    readonly property string dekorasi7: t("🎯 Fokus tanpa gangguan",         "🎯 Focus without distractions",    "🎯 专注无干扰",         "🎯 集中して邪魔なし",     "🎯 방해 없이 집중",       "🎯 Fokus ndang adong ganggu",     "🎯 Fokus tanpa gangguan",         "🎯 Enfócate sin distracciones",   "🎯 Fokus ohne Ablenkung")
    readonly property string akunBelumTerdaftar1: t("Akun ",       "Account ",      "账号 ",    "アカウント ", "계정 ",    "Akun ",       "Akun ",       "La cuenta ",    "Konto ")
    readonly property string akunBelumTerdaftar2: t(" belum terdaftar. Klik tombol Daftar →", " is not registered. Click Register →", " 未注册，点击注册→", " は未登録。登録→をクリック。", " 미등록. 가입 클릭→", " ndang terdaftar. Klik Daftar →", " durung kadaftar. Klik Daftar →", " no está registrada. Clic Registrarse →", " nicht registriert. Registrieren → klicken.")

    // ══════════════════════════════════════════════════════════
    //  PESAN UMUM
    // ══════════════════════════════════════════════════════════
    readonly property string ya:                t("Ya",                 "Yes",                "是",       "はい",       "예",         "Olo",                  "Ya",               "Sí",               "Ja")
    readonly property string tidak:             t("Tidak",              "No",                 "否",       "いいえ",     "아니오",     "Ndang",                "Ora",              "No",               "Nein")
    readonly property string konfirmasi:        t("Konfirmasi",         "Confirm",            "确认",     "確認",       "확인",       "Konfirmasi",           "Konfirmasi",       "Confirmar",        "Bestätigen")
    readonly property string peringatan:        t("Peringatan",         "Warning",            "警告",     "警告",       "경고",       "Peringatan",           "Peringatan",       "Advertencia",      "Warnung")
    readonly property string sukses:            t("Berhasil",           "Success",            "成功",     "成功",       "성공",       "Berhasil",             "Kasil",            "Éxito",            "Erfolg")
    readonly property string gagal:             t("Gagal",              "Failed",             "失败",     "失敗",       "실패",       "Sala",                 "Gagal",            "Fallido",          "Fehler")
    readonly property string menit:             t("menit",              "min",                "分钟",     "分",         "분",         "menit",                "menit",            "min",              "Min")
    readonly property string jam:               t("jam",                "hour",               "小时",     "時間",       "시간",       "jam",                  "jam",              "hora",             "Std")
    readonly property string detik:             t("detik",              "sec",                "秒",       "秒",         "초",         "detik",                "detik",            "seg",              "Sek")
    readonly property string hari:              t("hari",               "day",                "天",       "日",         "일",         "ari",                  "dina",             "día",              "Tag")
    readonly property string cariPlaceholder:   t("Cari...",            "Search...",          "搜索...",  "検索...",    "검색...",    "Saru...",              "Nggoleki...",      "Buscar...",        "Suchen...")
    readonly property string namaKamu:          t("Nama kamu...",       "Your name...",       "你的名字...", "あなたの名前...","이름을 입력...","Goranmu...",    "Jenengmu...",      "Tu nombre...",     "Dein Name...")
    readonly property string statusKamu:        t("Status kamu...",     "Your status...",     "你的状态...", "あなたのステータス...","상태 입력...","Statusmu...", "Statusmu...",     "Tu estado...",     "Dein Status...")
    readonly property string keluarKonfirm:     t("Keluar Akun?",       "Log Out?",           "退出登录？","ログアウト？",  "로그아웃？", "Luar Akun?",           "Medal Akun?",      "¿Cerrar Sesión?",  "Abmelden?")
    readonly property string yaLogout:          t("Ya, Logout",         "Yes, Log Out",       "确认退出", "はい、ログアウト","예, 로그아웃","Olo, Logout",        "Ya, Medal",        "Sí, Salir",        "Ja, Abmelden")
    readonly property string resetKonfirmasi:   t("Reset Semua Data?",  "Reset All Data?",    "重置所有数据？","全データリセット？","모든 데이터 초기화?","Reset Saluhut?","Reset Kabeh?","¿Restablecer Todo?","Alle Daten löschen?")
    readonly property string yaReset:           t("Ya, Reset!",         "Yes, Reset!",        "确认重置！","はい、リセット！","예, 초기화！", "Olo, Reset!",         "Ya, Reset!",       "¡Sí, Restablecer!","Ja, Löschen!")
    readonly property string dataResetBerhasil: t("🗑️ Semua data berhasil direset!", "🗑️ All data reset!", "🗑️ 所有数据已重置！", "🗑️ 全データがリセットされました！", "🗑️ 모든 데이터가 초기화되었습니다!", "🗑️ Saluhut data direset!", "🗑️ Kabeh data direset!", "🗑️ ¡Datos restablecidos!", "🗑️ Alle Daten zurückgesetzt!")
    readonly property string passwordBerhasil:  t("✅ Password berhasil diperbarui!", "✅ Password updated!", "✅ 密码更新成功！", "✅ パスワードが更新されました！", "✅ 비밀번호가 변경되었습니다!", "✅ Sandi berhasil diperbarui!", "✅ Sandi kasil diperbarui!", "✅ ¡Contraseña actualizada!", "✅ Passwort aktualisiert!")
    readonly property string sesiBelajarDihentikan: t("Sesi belajarmu akan dihentikan.", "Your study session will end.", "您的学习会话将结束。", "学習セッションを終了します。", "공부 세션이 종료됩니다.", "Sesi parbalearanmu dihentikon.", "Sesi sinau bakal dihentikan.", "Tu sesión de estudio finalizará.", "Deine Lernsitzung wird beendet.")
    readonly property string dataResetWarning:  t("Tugas, statistik, timer, dan chat akan dihapus. Aksi ini tidak bisa dibatalkan.", "Tasks, stats, timer, and chat will be deleted. This cannot be undone.", "任务、统计、计时器和聊天将被删除，此操作不可撤销。", "タスク、統計、タイマー、チャットが削除されます。この操作は元に戻せません。", "과제, 통계, 타이머, 채팅이 삭제됩니다. 되돌릴 수 없습니다.", "Ulaon, statistik, timer, dohot chat dihapus. Ndang boi dibatal.", "Tugas, statistik, timer, lan chat bakal dibusak. Ora bisa dibatal.", "Tareas, estadísticas, temporizador y chat serán eliminados. No se puede deshacer.", "Aufgaben, Statistiken, Timer und Chat werden gelöscht. Nicht rückgängig zu machen.")
}
