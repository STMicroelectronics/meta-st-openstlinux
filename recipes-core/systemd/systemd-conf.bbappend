FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-logind.conf-ignore-the-poweroff-key.patch \
    file://coredump-custom.conf \
    "

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/coredump.conf.d/
    install -m 644 ${WORKDIR}/coredump-custom.conf ${D}${sysconfdir}/systemd/coredump.conf.d/
}
