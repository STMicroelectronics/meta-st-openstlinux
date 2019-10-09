SUMMARY = "Framework sample xfce components"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup distro_features_check

REQUIRED_DISTRO_FEATURES = "x11"

RDEPENDS_${PN} = "\
    packagegroup-xfce-base  \
    \
    gnome-bluetooth         \
    \
    lxdm                    \
    xfce4-netload-plugin    \
    xfce4-wavelan-plugin    \
    xfce4-cpugraph-plugin   \
    xfce4-cpufreq-plugin    \
    xfce4-systemload-plugin \
    \
    xclock                  \
    xterm                   \
    \
    openbox                 \
    openbox-theme-clearlooks\
    "
