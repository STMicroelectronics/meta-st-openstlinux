SUMMARY = "Add udev rules to set GPIO to dialout group"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS = "udev"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://99-gpio-group.rules"

do_install() {
    install -D -p -m0664 ${WORKDIR}/99-gpio-group.rules \
        ${D}${sysconfdir}/udev/rules.d/99-gpio-group.rules
}
