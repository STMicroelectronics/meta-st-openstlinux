FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://coredump-custom.conf \
    "

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/coredump.conf.d/
    install -m 644 ${WORKDIR}/coredump-custom.conf ${D}${sysconfdir}/systemd/coredump.conf.d/

    # ignore poweroff key on logind
    sed -e 's|^[#]*HandlePowerKey.*|HandlePowerKey=ignore|g' -i ${D}${sysconfdir}/systemd/logind.conf
}
