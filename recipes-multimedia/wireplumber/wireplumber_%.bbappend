FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "  \
    file://50-alsa-config.conf \
    file://11-bluetooth-monitor.conf \
    file://90-custom-wireplumber.conf \
"

PACKAGECONFIG ??= " dbus \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd systemd-system-service systemd-user-service', '', d)} \
    ${@bb.utils.contains('PTEST_ENABLED', '1', 'test', '', d)} \
"

do_install:append() {
    # create directory for system-wide wireplumber configuration
    install -d "${D}${sysconfdir}/wireplumber/wireplumber.conf.d"

    install -m 0644 "${UNPACKDIR}/50-alsa-config.conf" "${D}${sysconfdir}/wireplumber/wireplumber.conf.d"
    install -m 0644 "${UNPACKDIR}/11-bluetooth-monitor.conf" "${D}${sysconfdir}/wireplumber/wireplumber.conf.d"
    install -m 0644 "${UNPACKDIR}/90-custom-wireplumber.conf" "${D}${sysconfdir}/wireplumber/wireplumber.conf.d"
}

FILES:${PN} += " \
    ${sysconfdir}/wireplumber \
"
