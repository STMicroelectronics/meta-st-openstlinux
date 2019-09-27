SUMMARY = "Framework sample qt extra components"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup distro_features_check

REQUIRED_DISTRO_FEATURES = "opengl"

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-sample-qt-extra          \
            packagegroup-framework-sample-qt-extra-examples \
            "

RDEPENDS_packagegroup-framework-sample-qt-extra = "\
    qtcanvas3d                  \
    \
    qt3d                        \
    qt3d-qmlplugins             \
    \
    qtsvg                       \
    qtsvg-plugins               \
    \
    qtlocation                  \
    qtlocation-qmlplugins       \
    qtlocation-plugins          \
    \
    qtwebkit                    \
    \
    qtquickcontrols             \
    qtquickcontrols-qmlplugins  \
    qtquickcontrols2            \
    qtquickcontrols2-qmlplugins \
    \
    qtsensors                   \
    qtserialport                \
    \
    qtcharts                    \
    qtcharts-qmlplugins         \
    \
    qtlocation                  \
    qtlocation-plugins          \
    qtlocation-qmlplugins       \
    "

SUMMARY_packagegroup-framework-sample-qt-extra-examples = "Framework sample qt extra components for examples"
RDEPENDS_packagegroup-framework-sample-qt-extra-examples = "\
    qtcanvas3d-examples         \
    \
    qtquickcontrols-examples    \
    qtwebkit-examples           \
    \
    qtsensors-examples          \
    qtserialport-examples       \
    \
    qtcharts-examples           \
    \
    qt3d-examples               \
    \
    qtlocation-examples         \
    \
    qt5nmapcarousedemo          \
    cinematicexperience         \
    qtsmarthome                 \
    "
