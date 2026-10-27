# Copyright (C) 2014, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Basic splash screen which display a picture on DRM/KMS"
LICENSE = "MIT"
DEPENDS = "libdrm pkgconfig-native libpng pixman"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
        file://image_header.h \
        file://basic_splash_drm.c \
        file://Makefile \
        file://psplash-drm-quit \
        file://pictures \
        file://pictures-animated \
    "

SRC_URI += " file://psplash-drm-start@.service file://psplash-drm-start.sh file://71-dev-dri-card0.rules"

S = "${UNPACKDIR}"

PV = "1.1"

PROVIDES = "virtual/psplash"
RPROVIDES:${PN} = "virtual-psplash virtual-psplash-support"

inherit systemd pkgconfig

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','psplash-drm-start@.service ','',d)}"

do_configure[noexec] = "1"

do_compile() {
    bbnote "EXTRA_OEMAKE=${EXTRA_OEMAKE}"
    oe_runmake clean
    oe_runmake psplash
}
do_install() {
    install -d ${D}${bindir}
    install -m 755 ${S}/psplash-drm ${D}${bindir}

    install -m 755 ${S}/psplash-drm-quit ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system ${D}${datadir}/splashscreen ${D}${sysconfdir}/udev/rules.d/
        install -m 644 ${S}/*.service ${D}/${systemd_unitdir}/system
        install -m 755 ${S}/psplash-drm-start.sh ${D}/${bindir}
        install -m 644 ${S}/pictures/* ${D}${datadir}/splashscreen/
        install -m 644 ${S}/71-dev-dri-card0.rules ${D}${sysconfdir}/udev/rules.d/

        # extra animation
        install -d ${D}${prefix}/local/splashscreen/animated
        install -m 644 ${S}/pictures-animated/* ${D}${prefix}/local/splashscreen/animated/
    fi
}
PACKAGES += "${PN}-extra"
FILES:${PN} += "${systemd_unitdir}/system ${datadir}"
FILES:${PN}-extra = "${prefix}/local/splashscreen/"

