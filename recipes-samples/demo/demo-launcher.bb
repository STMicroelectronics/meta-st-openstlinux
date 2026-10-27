# Copyright (C) 2018, STMicroelectronics - All Rights Reserved

SUMMARY = "Script which start a launcher"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
    file://start_up_demo_launcher.sh \
    "

S = "${UNPACKDIR}"

PV = "2.3"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # start at startup
    install -d ${D}${prefix}/local/weston-start-at-startup/
    install -m 0755 ${UNPACKDIR}/start_up_demo_launcher.sh ${D}${prefix}/local/weston-start-at-startup/
}

FILES:${PN} += "${prefix}/local/weston-start-at-startup/"
