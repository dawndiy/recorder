TEMPLATE = app
TARGET = Recorder

load(ubuntu-click)

QT += qml quick multimedia

SOURCES += main.cpp \
    audiorecorder.cpp

RESOURCES += Recorder.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  Recorder.apparmor \
               Recorder.png \
               Recorder-splash.png \
               Recorder-content.json

IMAGE_FILES += $$files(*.png,true)

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

#show all the files in QtCreator
OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               $${IMAGE_FILES} \
               Recorder.desktop

#specify where the config files are installed to
config_files.path = /Recorder
config_files.files += $${CONF_FILES}
INSTALLS+=config_files

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /Recorder
desktop_file.files = $$OUT_PWD/Recorder.desktop
desktop_file.CONFIG += no_check_exist
INSTALLS+=desktop_file

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

DISTFILES += \
    ui/HomePage.qml \
    ui/SettingsPage.qml \
    ui/RecordsPage.qml \
    ui/AboutPage.qml \
    ui/SelectionPage.qml \
    ui/DonatePage.qml \
    ui/IntroPage.qml \
    component/ListItemHeader.qml \
    component/HeaderButton.qml \
    component/SnackBar.qml

HEADERS += \
    audiorecorder.h
