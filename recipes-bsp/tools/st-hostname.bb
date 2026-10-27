# Copyright (C) 2024, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)
SUMMARY = "Tools for set the hostname associated to ethernet"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " file://st-hostname.service file://st-hostname.sh"

S = "${UNPACKDIR}"

START_RESIZE_HELPER_SERVICE ?= "1"

inherit systemd

SYSTEMD_PACKAGES += " ${PN} "
SYSTEMD_SERVICE:${PN} = "st-hostname.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/system ${D}${bindir}
    install -m 0644 ${UNPACKDIR}/st-hostname.service ${D}${systemd_unitdir}/system
    install -m 0755 ${UNPACKDIR}/st-hostname.sh ${D}${bindir}

}
