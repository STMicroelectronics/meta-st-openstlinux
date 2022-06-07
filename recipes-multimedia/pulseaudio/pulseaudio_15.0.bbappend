FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG ?= "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'zeroconf', 'avahi', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', '3g', 'ofono', '', d)} \
                   ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6 systemd x11', d)} \
                   dbus gsettings \
                   "

# Pulse audio configuration files
SRC_URI += "file://pulse_profile.sh \
            file://10001-deamon-conf-disable-volume-flat.patch \
            file://10003-dbus-authorize-to-communicate-with-bluez.patch \
            file://10004-deamon-conf-disable-exit.patch \
            "

# Pulse audio configuration files installation
do_install:append() {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/pulse_profile.sh ${D}${sysconfdir}/profile.d/
}

FILES:${PN} += "/etc/profile.d"
