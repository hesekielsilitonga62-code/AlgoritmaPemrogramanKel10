#include "taskscreen.h"
#include <QHBoxLayout>
#include <QScrollArea>
#include <QFrame>
#include <QMessageBox>
#include <QDateTime>
#include <QTime>
#include <QTimer>
#include <algorithm>

// ══════════════════════════════════════════════
//  TaskDialog
// ══════════════════════════════════════════════
TaskDialog::TaskDialog(QWidget* parent, const Task* edit)
    : QDialog(parent)
{
    setWindowTitle(edit ? "Edit Tugas" : "Tambah Tugas");
    setMinimumWidth(340);
    setModal(true);

    auto* lay = new QVBoxLayout(this);
    lay->setSpacing(14);
    lay->setContentsMargins(24, 24, 24, 24);

    // ── Judul ──────────────────────────────────
    auto* lbTitle = new QLabel("📝  Judul Tugas", this);
    lbTitle->setObjectName("dlgLabel");
    lay->addWidget(lbTitle);

    edtTitle = new QLineEdit(this);
    edtTitle->setPlaceholderText("Contoh: Tugas Algoritma Bab 3");
    edtTitle->setFixedHeight(48);
    lay->addWidget(edtTitle);

    // ── Mata Kuliah ────────────────────────────
    auto* lbMatkul = new QLabel("📚  Mata Kuliah", this);
    lbMatkul->setObjectName("dlgLabel");
    lay->addWidget(lbMatkul);

    edtMatkul = new QLineEdit(this);
    edtMatkul->setPlaceholderText("Contoh: Algoritma Pemrograman");
    edtMatkul->setFixedHeight(48);
    lay->addWidget(edtMatkul);

    // ── Deadline ───────────────────────────────
    auto* lbDeadline = new QLabel("📅  Deadline", this);
    lbDeadline->setObjectName("dlgLabel");
    lay->addWidget(lbDeadline);

    // Date-time picker
    dtDeadline = new QDateTimeEdit(this);
    dtDeadline->setDisplayFormat("dd/MM/yyyy  HH:mm");
    dtDeadline->setCalendarPopup(true);          // popup kalender
    dtDeadline->setDateTime(QDateTime::currentDateTime().addDays(3)); // default 3 hari ke depan
    dtDeadline->setMinimumDateTime(QDateTime::currentDateTime());     // tidak bisa pilih masa lalu
    dtDeadline->setFixedHeight(48);
    dtDeadline->setObjectName("dtPicker");
    lay->addWidget(dtDeadline);

    // Checkbox "Tidak ada deadline"
    chkNoDeadline = new QCheckBox("Tidak ada deadline", this);
    chkNoDeadline->setObjectName("chkNoDeadline");
    lay->addWidget(chkNoDeadline);

    // Toggle aktif/nonaktif picker saat checkbox berubah
    connect(chkNoDeadline, &QCheckBox::toggled, this, [this](bool checked){
        dtDeadline->setEnabled(!checked);
        dtDeadline->setStyleSheet(checked
            ? QString("background:%1; color:%2; border:1.5px solid %3; border-radius:12px; padding:4px 10px; font-size:14px;")
                .arg(AppState::instance().theme.bgCard,
                     AppState::instance().theme.textMuted,
                     AppState::instance().theme.border)
            : "");
        applyStyle(); // reapply agar warna picker benar
    });

    // ── Prioritas ──────────────────────────────
    auto* lbPri = new QLabel("🎯  Prioritas", this);
    lbPri->setObjectName("dlgLabel");
    lay->addWidget(lbPri);

    auto* priRow = new QHBoxLayout();
    priRow->setSpacing(8);

    btnHigh = new QPushButton("🔴  Tinggi", this); btnHigh->setObjectName("btnPriHigh");
    btnMed  = new QPushButton("🟡  Sedang", this); btnMed->setObjectName("btnPriMed");
    btnLow  = new QPushButton("🟢  Rendah", this); btnLow->setObjectName("btnPriLow");

    for (auto* b : {btnHigh, btnMed, btnLow}) {
        b->setFixedHeight(42);
        b->setCheckable(true);
    }

    connect(btnHigh, &QPushButton::clicked, this, [this]{ selectPriority(2); });
    connect(btnMed,  &QPushButton::clicked, this, [this]{ selectPriority(1); });
    connect(btnLow,  &QPushButton::clicked, this, [this]{ selectPriority(0); });

    priRow->addWidget(btnHigh);
    priRow->addWidget(btnMed);
    priRow->addWidget(btnLow);
    lay->addLayout(priRow);

    // ── Tombol aksi ────────────────────────────
    lay->addSpacing(4);
    auto* btnRow = new QHBoxLayout();
    btnRow->setSpacing(10);

    auto* btnCancel = new QPushButton("Batal", this);
    btnCancel->setObjectName("btnCancel");
    btnCancel->setFixedHeight(48);

    auto* btnSave = new QPushButton("💾  Simpan", this);
    btnSave->setObjectName("btnSave");
    btnSave->setFixedHeight(48);

    connect(btnCancel, &QPushButton::clicked, this, &QDialog::reject);
    connect(btnSave,   &QPushButton::clicked, this, [this]{
        if (edtTitle->text().trimmed().isEmpty()) {
            edtTitle->setFocus();
            edtTitle->setPlaceholderText("⚠️ Judul tidak boleh kosong!");
            return;
        }
        accept();
    });

    btnRow->addWidget(btnCancel);
    btnRow->addWidget(btnSave);
    lay->addLayout(btnRow);

    // ── Isi data edit (jika mode edit) ─────────
    if (edit) {
        edtTitle->setText(edit->title);
        edtMatkul->setText(edit->matkul);
        priority = edit->priority;

        if (edit->deadlineTs > 0) {
            dtDeadline->setDateTime(
                QDateTime::fromMSecsSinceEpoch(edit->deadlineTs));
            chkNoDeadline->setChecked(false);
        } else {
            chkNoDeadline->setChecked(true);
        }
    }

    selectPriority(priority);
    applyStyle();
}

void TaskDialog::selectPriority(int p) {
    priority = p;
    btnHigh->setChecked(p == 2);
    btnMed->setChecked(p == 1);
    btnLow->setChecked(p == 0);
}

Task TaskDialog::getTask() const {
    Task t;
    t.title    = edtTitle->text().trimmed();
    t.matkul   = edtMatkul->text().trimmed();
    t.priority = priority;
    t.isDone   = false;
    t.color    = (priority == 2) ? "#ff5555" : (priority == 1 ? "#ffa500" : "#05d605");

    if (chkNoDeadline->isChecked()) {
        t.deadline   = "";
        t.deadlineTs = 0;
    } else {
        QDateTime dt = dtDeadline->dateTime();
        t.deadline   = dt.toString("dd/MM/yyyy HH:mm");
        t.deadlineTs = dt.toMSecsSinceEpoch();
    }
    return t;
}

void TaskDialog::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        QDialog {
            background: %1;
        }
        QLabel#dlgLabel {
            color: %5;
            font-size: 13px;
            font-weight: 700;
        }
        QLineEdit {
            background: %3;
            border: 1.5px solid %4;
            border-radius: 12px;
            padding: 8px 14px;
            color: %2;
            font-size: 14px;
        }
        QLineEdit:focus {
            border-color: %5;
            background: %6;
        }

        /* ── DateTimeEdit ── */
        QDateTimeEdit#dtPicker {
            background: %3;
            border: 1.5px solid %5;
            border-radius: 12px;
            padding: 4px 14px;
            color: %2;
            font-size: 14px;
            font-weight: 600;
        }
        QDateTimeEdit#dtPicker:focus {
            border-color: %5;
        }
        QDateTimeEdit#dtPicker::drop-down {
            subcontrol-origin: padding;
            subcontrol-position: center right;
            width: 36px;
            border: none;
        }
        QDateTimeEdit#dtPicker::down-arrow {
            image: none;
            width: 0;
        }

        /* ── Popup kalender ── */
        QCalendarWidget {
            background: %6;
            color: %2;
        }
        QCalendarWidget QToolButton {
            background: %5;
            color: %8;
            border-radius: 8px;
            padding: 4px 8px;
            font-weight: bold;
        }
        QCalendarWidget QMenu {
            background: %6;
            color: %2;
        }
        QCalendarWidget QSpinBox {
            background: %3;
            color: %2;
            border: 1px solid %4;
            border-radius: 6px;
        }
        QCalendarWidget QAbstractItemView {
            background: %6;
            color: %2;
            selection-background-color: %5;
            selection-color: %8;
        }
        QCalendarWidget QAbstractItemView:disabled {
            color: %7;
        }

        /* ── Checkbox ── */
        QCheckBox#chkNoDeadline {
            color: %7;
            font-size: 13px;
            spacing: 8px;
        }
        QCheckBox#chkNoDeadline::indicator {
            width: 20px;
            height: 20px;
            border-radius: 6px;
            border: 2px solid %4;
            background: %3;
        }
        QCheckBox#chkNoDeadline::indicator:checked {
            background: %5;
            border-color: %5;
        }

        /* ── Priority buttons ── */
        QPushButton#btnPriHigh {
            background: rgba(255,85,85,25);
            border: 1.5px solid rgba(255,85,85,76);
            color: #ff8080;
            border-radius: 10px;
            font-size: 12px; font-weight: 700;
        }
        QPushButton#btnPriHigh:checked {
            background: rgba(255,85,85,90);
            border-color: #ff5555;
            color: #ffffff;
        }
        QPushButton#btnPriMed {
            background: rgba(255,165,0,25);
            border: 1.5px solid rgba(255,165,0,76);
            color: #ffaa44;
            border-radius: 10px;
            font-size: 12px; font-weight: 700;
        }
        QPushButton#btnPriMed:checked {
            background: rgba(255,165,0,90);
            border-color: #ffa500;
            color: #ffffff;
        }
        QPushButton#btnPriLow {
            background: rgba(5,214,5,25);
            border: 1.5px solid rgba(5,214,5,76);
            color: #44cc44;
            border-radius: 10px;
            font-size: 12px; font-weight: 700;
        }
        QPushButton#btnPriLow:checked {
            background: rgba(5,214,5,90);
            border-color: #05d605;
            color: #ffffff;
        }

        /* ── Action buttons ── */
        QPushButton#btnSave {
            background: %5;
            color: %8;
            border-radius: 12px;
            font-size: 14px; font-weight: bold;
            border: none;
        }
        QPushButton#btnSave:pressed { background: %9; }

        QPushButton#btnCancel {
            background: %3;
            color: %7;
            border: 1px solid %4;
            border-radius: 12px;
            font-size: 14px;
        }
        QPushButton#btnCancel:pressed { background: %4; }
    )")
    .arg(t.bgPrimary)    // %1 bg dialog
    .arg(t.textPrimary)  // %2 text
    .arg(t.bgCard)       // %3 bg input
    .arg(t.border)       // %4 border
    .arg(t.accent)       // %5 accent/highlight
    .arg(t.bgSecondary)  // %6 bg secondary
    .arg(t.textMuted)    // %7 muted text
    .arg(t.bgDeep)       // %8 deep (text on accent)
    .arg(t.green));      // %9 green
}

// ══════════════════════════════════════════════
//  TaskScreen
// ══════════════════════════════════════════════
TaskScreen::TaskScreen(QWidget* parent) : QWidget(parent) {
    buildUi();
    applyStyle();
    connect(&AppState::instance(), &AppState::tasksChanged,
            this, &TaskScreen::renderTasks);
}

void TaskScreen::buildUi() {
    auto* root = new QVBoxLayout(this);
    root->setContentsMargins(0,0,0,0);
    root->setSpacing(0);

    // ── Status bar ──
    auto* sb  = new QWidget(this); sb->setObjectName("statusBar"); sb->setFixedHeight(44);
    auto* sbL = new QHBoxLayout(sb); sbL->setContentsMargins(20,0,20,0);
    auto* sbTime = new QLabel(QTime::currentTime().toString("HH:mm"), sb);
    sbTime->setObjectName("statusTime");
    auto* sbMid = new QLabel("Daftar Tugas", sb); sbMid->setObjectName("labelMuted");
    sbL->addWidget(sbTime); sbL->addStretch();
    sbL->addWidget(sbMid); sbL->addStretch();
    sbL->addWidget(new QLabel("📶 🔋", sb));
    root->addWidget(sb);

    // ── Page header ──
    auto* ph  = new QWidget(this); ph->setObjectName("pageHeader");
    auto* phL = new QHBoxLayout(ph); phL->setContentsMargins(20,12,20,12);
    auto* phIcon  = new QLabel("📋", ph); phIcon->setStyleSheet("font-size:22px;");
    auto* phTitle = new QLabel("Tugas", ph); phTitle->setObjectName("pageTitle");
    lblCount = new QLabel("", ph); lblCount->setObjectName("taskBadge");
    lblCount->setVisible(false);
    auto* btnAdd = new QPushButton("+ Tambah", ph);
    btnAdd->setObjectName("btnAddTask");
    connect(btnAdd, &QPushButton::clicked, this, &TaskScreen::openAddTask);
    phL->addWidget(phIcon);
    phL->addWidget(phTitle);
    phL->addWidget(lblCount);
    phL->addStretch();
    phL->addWidget(btnAdd);
    root->addWidget(ph);

    // ── Scrollable list ──
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    auto* inner = new QWidget();
    listLayout = new QVBoxLayout(inner);
    listLayout->setContentsMargins(16,12,16,24);
    listLayout->setSpacing(10);
    listLayout->addStretch();
    listContainer = inner;
    scroll->setWidget(inner);
    root->addWidget(scroll, 1);

    renderTasks();
}

void TaskScreen::refresh() { renderTasks(); }

// ── Hitung sisa waktu ──────────────────────────
static QString sisaWaktu(qint64 deadlineTs) {
    qint64 now  = QDateTime::currentMSecsSinceEpoch();
    qint64 diff = deadlineTs - now;

    if (diff <= 0) return "⚠️ Sudah lewat!";

    int totalMins = (int)(diff / 60000);
    int d = totalMins / 1440;
    int h = (totalMins % 1440) / 60;
    int m = totalMins % 60;

    if (d > 0) return QString("⏳ %1 hari %2 jam lagi").arg(d).arg(h);
    if (h > 0) return QString("⏳ %1 jam %2 menit lagi").arg(h).arg(m);
    return QString("🔥 %1 menit lagi!").arg(m);
}

void TaskScreen::renderTasks() {
    // Bersihkan layout
    QLayoutItem* ch;
    while ((ch = listLayout->takeAt(0)) != nullptr) {
        if (ch->widget()) ch->widget()->deleteLater();
        delete ch;
    }

    auto& app = AppState::instance();
    auto& t   = app.theme;

    // Sort: belum selesai dulu, lalu deadline terdekat
    auto tasks = app.tasks;
    std::sort(tasks.begin(), tasks.end(), [](const Task& a, const Task& b){
        if (a.isDone != b.isDone) return !a.isDone;
        if (a.deadlineTs && b.deadlineTs) return a.deadlineTs < b.deadlineTs;
        if (a.deadlineTs) return true;
        return a.id < b.id;
    });

    // Badge count
    int pending = app.tasksPending();
    lblCount->setText(QString::number(pending));
    lblCount->setVisible(pending > 0);

    if (tasks.isEmpty()) {
        auto* empty = new QLabel("🎯  Belum ada tugas.\nTekan '+ Tambah' untuk mulai!",
                                 listContainer);
        empty->setObjectName("labelMuted");
        empty->setAlignment(Qt::AlignCenter);
        empty->setStyleSheet("padding:40px; font-size:14px;");
        listLayout->addWidget(empty);
        listLayout->addStretch();
        return;
    }

    for (const auto& task : tasks) {
        auto* card = new QFrame(listContainer);
        card->setObjectName("taskFullCard");

        QString urg = task.priority == 2 ? t.red
                    : task.priority == 1 ? "#ffa500"
                    : t.green;

        // Warna berbeda jika sudah selesai
        QString cardBg = task.isDone
            ? QString("rgba(10,42,67,180)")
            : t.bgSecondary;

        card->setStyleSheet(QString(R"(
            QFrame#taskFullCard {
                background: %1;
                border: 1.5px solid %2;
                border-radius: 14px;
                border-left: 5px solid %3;
            }
        )").arg(cardBg, t.border, urg));

        auto* cl = new QHBoxLayout(card);
        cl->setContentsMargins(16,14,14,14);
        cl->setSpacing(12);

        // ── Isi kartu ──
        auto* body = new QWidget(card);
        auto* bl   = new QVBoxLayout(body);
        bl->setContentsMargins(0,0,0,0);
        bl->setSpacing(5);

        // Judul
        auto* lbTitle = new QLabel(task.title, card);
        lbTitle->setObjectName(task.isDone ? "taskTitleDone" : "taskTitleActive");

        // Info deadline + sisa waktu
        QString deadlineInfo;
        if (!task.isDone && task.deadlineTs > 0) {
            deadlineInfo = task.deadline + "  ·  " + sisaWaktu(task.deadlineTs);
        } else if (task.deadlineTs > 0) {
            deadlineInfo = task.deadline;
        } else {
            deadlineInfo = "Tidak ada deadline";
        }
        if (!task.matkul.isEmpty())
            deadlineInfo = task.matkul + "  |  " + deadlineInfo;

        auto* lbDeadline = new QLabel(deadlineInfo, card);
        lbDeadline->setObjectName("labelMuted");
        lbDeadline->setWordWrap(true);

        // Priority badge
        QString pBg, pColor, pBorder, pText;
        if (task.priority == 2) {
            pBg="#ff555538"; pColor="#ff8080"; pBorder="rgba(255,85,85,76)"; pText="🔴 TINGGI";
        } else if (task.priority == 1) {
            pBg="rgba(255,165,0,38)"; pColor="#ffaa44"; pBorder="rgba(255,165,0,76)"; pText="🟡 SEDANG";
        } else {
            pBg="rgba(5,214,5,30)"; pColor="#44cc44"; pBorder="rgba(5,214,5,64)"; pText="🟢 RENDAH";
        }
        auto* priBadge = new QLabel(pText, card);
        priBadge->setStyleSheet(QString(
            "font-size:9px; font-weight:800; padding:2px 8px; border-radius:8px;"
            "background:%1; color:%2; border:1px solid %3;")
            .arg(pBg, pColor, pBorder));

        auto* priRow = new QHBoxLayout();
        priRow->setContentsMargins(0,0,0,0);
        priRow->addWidget(priBadge);
        priRow->addStretch();

        bl->addWidget(lbTitle);
        bl->addWidget(lbDeadline);
        bl->addLayout(priRow);

        // ── Tombol aksi ──
        auto* actW = new QWidget(card);
        auto* al   = new QVBoxLayout(actW);
        al->setContentsMargins(0,0,0,0);
        al->setSpacing(6);
        al->setAlignment(Qt::AlignTop | Qt::AlignHCenter);

        int id = task.id;

        // Tombol centang
        auto* btnCheck = new QPushButton(task.isDone ? "✅" : "○", card);
        btnCheck->setFixedSize(32, 32);
        btnCheck->setStyleSheet(task.isDone
            ? QString("background:%1; border:none; border-radius:16px; font-size:14px;").arg(t.green)
            : QString("background:%1; border:2px solid %2; border-radius:16px; font-size:14px;")
                .arg(t.bgCard, t.border));
        connect(btnCheck, &QPushButton::clicked, this, [this, id]{ toggleDone(id); });

        // Tombol edit
        auto* btnEdit = new QPushButton("✏️", card);
        btnEdit->setFixedSize(28, 28);
        btnEdit->setObjectName("taskMiniBtn");
        connect(btnEdit, &QPushButton::clicked, this, [this, id]{ editTask(id); });

        // Tombol hapus
        auto* btnDel = new QPushButton("🗑", card);
        btnDel->setFixedSize(28, 28);
        btnDel->setObjectName("taskMiniBtn");
        connect(btnDel, &QPushButton::clicked, this, [this, id]{ deleteTask(id); });

        al->addWidget(btnCheck);
        al->addWidget(btnEdit);
        al->addWidget(btnDel);

        cl->addWidget(body, 1);
        cl->addWidget(actW);

        listLayout->addWidget(card);
    }
    listLayout->addStretch();

    // Auto-refresh sisa waktu setiap menit
    QTimer::singleShot(60000, this, [this]{ renderTasks(); });
}

void TaskScreen::openAddTask() {
    TaskDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) {
        auto& app = AppState::instance();
        Task task = dlg.getTask();
        task.id = app.nextTaskId++;
        app.tasks.append(task);
        app.streakCount = qMin(app.streakCount + 1, 7);
        emit app.tasksChanged();
        emit app.statsChanged();
    }
}

void TaskScreen::editTask(int taskId) {
    auto& app = AppState::instance();
    for (int i = 0; i < app.tasks.size(); i++) {
        if (app.tasks[i].id == taskId) {
            TaskDialog dlg(this, &app.tasks[i]);
            if (dlg.exec() == QDialog::Accepted) {
                Task updated    = dlg.getTask();
                updated.id      = taskId;
                updated.isDone  = app.tasks[i].isDone;
                app.tasks[i]    = updated;
                emit app.tasksChanged();
            }
            return;
        }
    }
}

void TaskScreen::toggleDone(int taskId) {
    for (auto& t : AppState::instance().tasks) {
        if (t.id == taskId) {
            t.isDone = !t.isDone;
            emit AppState::instance().tasksChanged();
            emit AppState::instance().statsChanged();
            return;
        }
    }
}

void TaskScreen::deleteTask(int taskId) {
    AppState::instance().tasks.removeIf(
        [taskId](const Task& t){ return t.id == taskId; });
    emit AppState::instance().tasksChanged();
    emit AppState::instance().statsChanged();
}

void TaskScreen::applyStyle() {
    auto& t = AppState::instance().theme;
    setStyleSheet(QString(R"(
        TaskScreen { background: %1; }
        QWidget#statusBar   { background: %1; border-bottom: 1px solid %2; }
        QLabel#statusTime   { font-family:'Courier New'; font-size:13px; font-weight:700; color:%3; }
        QWidget#pageHeader  { background: %4; border-bottom: 1px solid %2; }
        QLabel#pageTitle    { font-size:20px; font-weight:900; color:%3; margin-left:8px; }
        QLabel#taskBadge    {
            background:%5; color:%6;
            border-radius:10px; padding:2px 8px;
            font-size:12px; font-weight:700; margin-left:4px;
        }
        QLabel#taskTitleActive { font-size:15px; font-weight:700; color:%3; }
        QLabel#taskTitleDone   {
            font-size:15px; font-weight:700; color:%7;
            text-decoration: line-through;
        }
        QLabel#labelMuted { font-size:11px; color:%7; }
        QPushButton#taskMiniBtn {
            background: transparent; border: none;
            font-size:13px; color:%7; border-radius:8px;
        }
        QPushButton#taskMiniBtn:hover { color:%3; }
    )").arg(t.bgPrimary, t.border, t.textPrimary, t.bgSecondary,
            t.accent, t.bgDeep, t.textMuted));
}
