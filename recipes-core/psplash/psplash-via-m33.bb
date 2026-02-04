# Copyright (C) 2014, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Basic script to stop splash screen which is managed by M33 coprocessor"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
        file://psplash-drm-quit \
    "

PROVIDES = "virtual/psplash"
RPROVIDES:${PN} = "virtual-psplash virtual-psplash-support"

S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/psplash-drm-quit ${D}${bindir}
}
