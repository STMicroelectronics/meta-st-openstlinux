FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " \
    firstboot \
    coredump elfutils \
    "

PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'polkit', '', 'polkit_hostnamed_fallback', d)} "

PACKAGECONFIG:remove = "userdb"
PACKAGECONFIG:remove = "efi"
PACKAGECONFIG:remove = "osc-context"

WATCHDOG_TIMEOUT = "32"

NTP_SERVERS ??= ""
EXTRA_OEMESON += " ${@ '-Dntp-servers="${NTP_SERVERS}"' if '${NTP_SERVERS}' else ''}"


SRC_URI =+ "file://serial-getty@.service"

do_install:append() {
    #Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator

    # serial-getty: overwrite default file to add autologin
    install -d  ${D}${systemd_system_unitdir}/
    install -m 0644 ${UNPACKDIR}/serial-getty@.service ${D}${systemd_system_unitdir}/

    sed -i 's/WatchdogSec=3min/WatchdogSec=30min/' "${D}${systemd_unitdir}/system/systemd-journald.service"

    # add timeout to systemd-networkd-wait-oneline
    sed -i "s|systemd/systemd-networkd-wait-online|systemd/systemd-networkd-wait-online -i end0:no-carrier|" "${D}${systemd_unitdir}/system/systemd-networkd-wait-online.service"
}

