cmake_minimum_required(VERSION 3.16)

project(StudyTrackerApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Multimedia)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appStudyTrackerApp
    main.cpp
)

qt_add_qml_module(appStudyTrackerApp
    URI StudyTrackerApp
    QML_FILES
        Main.qml
        SOURCES authmanager.h authmanager.cpp
        RESOURCES
        QML_FILES MainMenu.qml
        QML_FILES InputTugas.qml
        QML_FILES TimerBelajar.qml
        QML_FILES TemanPage.qml
        QML_FILES StudyRoomPage.qml
        QML_FILES StatistikPage.qml
        QML_FILES SettingsPage.qml
        QML_FILES
        QML_FILES Languange.qml
        QML_FILES Login.qml
)

set_target_properties(appStudyTrackerApp PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appStudyTrackerApp
    PRIVATE Qt6::Quick Qt6::Core Qt6::Multimedia
)

install(TARGETS appStudyTrackerApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)