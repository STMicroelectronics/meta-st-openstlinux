FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://xinitrc "

do_install_append() {
    install -d ${D}/etc/X11/xinit
    install -m 0644 ${WORKDIR}/xinitrc ${D}/etc/X11/xinit/xinitrc
}
