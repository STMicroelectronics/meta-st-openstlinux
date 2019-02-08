# Copyright (C) 2017, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Basic networkd configuration"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
DEPENDS = "systemd"

SRC_URI = " \
    file://50-wired.network.all \
    file://50-wired.network.nfs \
    file://51-wireless.network.sample \
    \
    file://verify_eth0.sh \
    file://st-check-nfs.service \
    "

inherit systemd

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE_${PN} = "st-check-nfs.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/50-wired.network.all ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/50-wired.network.nfs ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/51-wireless.network.sample ${D}${systemd_unitdir}/network

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -m 644 ${WORKDIR}/st-check-nfs.service ${D}${systemd_unitdir}/system
    fi

    install -d ${D}${base_sbindir}/
    install -m 755 ${WORKDIR}/verify_eth0.sh ${D}${base_sbindir}/verify_eth0.sh

}

FILES_${PN} = "${systemd_unitdir}/network ${systemd_unitdir}/system ${base_sbindir}"
