FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://coredump-custom.conf \
    "

do_install:prepend() {
    install -d ${D}${sysconfdir}/systemd/coredump.conf.d/
    install -m 644 ${WORKDIR}/coredump-custom.conf ${D}${sysconfdir}/systemd/coredump.conf.d/

    # ignore poweroff key on logind
    install -d ${D}${systemd_unitdir}/logind.conf.d/
    echo "[Login]" > ${D}${systemd_unitdir}/logind.conf.d/01-openstlinux.conf
    echo "HandlePowerKey=ignore" >> ${D}${systemd_unitdir}/logind.conf.d/01-openstlinux.conf

    # Journal, do not store journald on filesystem (syslog make it already)
    install -d ${D}${systemd_unitdir}/journald.conf.d/
    echo "[Journal]" > ${D}${systemd_unitdir}/journald.conf.d/01-openstlinux.conf
    echo "Storage=volatile" >> ${D}${systemd_unitdir}/journald.conf.d/01-openstlinux.conf
    echo "ForwardToSyslog=no" >> ${D}${systemd_unitdir}/journald.conf.d/01-openstlinux.conf

    # for iptable usage with wifi
    install -d ${D}${systemd_unitdir}/system.conf.d
    echo "[Manager]" > ${D}${systemd_unitdir}/system.conf.d/03-openstlinux.conf
    echo "DefaultEnvironment=\"SYSTEMD_FIREWALL_BACKEND=iptables\"" >> ${D}${systemd_unitdir}/system.conf.d/03-openstlinux.conf
}
FILES:${PN} += " ${sysconfdir}/systemd/coredump.conf.d/ "
