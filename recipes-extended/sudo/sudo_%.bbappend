# Allow weston user to run apt-get command for demo installer
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://weston-apt \
"

# whole ${sysconfdir} goes to package sudo-lib
CONFFILES:${PN}-lib:append = " \
    ${sysconfdir}/sudoers.d/weston-apt \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0644 ${WORKDIR}/weston-apt ${D}${sysconfdir}/sudoers.d

    # for sdk purpose
    chmod 4755 ${D}${bindir}/sudo
}

do_install:append:class-nativesdk() {
    # remove unnecessary sudo binaries on sdk
    rm ${D}${bindir}/sudo ${D}${bindir}/sudoedit
}
ALLOW_EMPTY:${PN}-sudo = "1"
