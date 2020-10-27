FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://coredump-custom.conf \
    "

do_install_prepend() {
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
}
FILES_${PN} += " ${sysconfdir}/systemd/coredump.conf.d/ "
