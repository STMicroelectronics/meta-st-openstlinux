# Copyright (C) 2014, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Basic splash screen which display a picture on DRM/KMS"
LICENSE = "MIT"
DEPENDS = "libdrm pkgconfig-native"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
        file://image_header.h \
        file://basic_splash_drm.c \
        file://Makefile \
        file://psplash-drm-quit \
    "

SRC_URI += " file://psplash-drm-start.service "

inherit systemd

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','psplash-drm-start.service','',d)}"

S = "${WORKDIR}"

do_configure[noexec] = "1"


do_compile() {
    bbnote "EXTRA_OEMAKE=${EXTRA_OEMAKE}"
    oe_runmake clean
    oe_runmake psplash
}
do_install() {
    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/psplash-drm ${D}${bindir}

    install -m 755 ${WORKDIR}/psplash-drm-quit ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -m 644 ${WORKDIR}/*.service ${D}/${systemd_unitdir}/system
    fi
}

