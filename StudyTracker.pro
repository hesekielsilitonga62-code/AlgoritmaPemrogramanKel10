QT += core gui widgets

CONFIG += c++17
TARGET = StudyTracker
TEMPLATE = app

SOURCES += \
    src/main.cpp \
    src/mainwindow.cpp \
    src/loginscreen.cpp \
    src/homescreen.cpp \
    src/taskscreen.cpp \
    src/timerscreen.cpp \
    src/statsscreen.cpp \
    src/friendscreen.cpp \
    src/settingsscreen.cpp \
    src/appstate.cpp \
    src/navigationbar.cpp \
    src/notificationbanner.cpp

HEADERS += \
    src/mainwindow.h \
    src/loginscreen.h \
    src/homescreen.h \
    src/taskscreen.h \
    src/timerscreen.h \
    src/statsscreen.h \
    src/friendscreen.h \
    src/settingsscreen.h \
    src/appstate.h \
    src/navigationbar.h \
    src/notificationbanner.h \
    src/styles.h

RESOURCES += resources/resources.qrc

# Android config (opsional, aktifkan jika build ke Android)
# android {
#     ANDROID_MIN_SDK_VERSION = 21
#     ANDROID_TARGET_SDK_VERSION = 33
# }
