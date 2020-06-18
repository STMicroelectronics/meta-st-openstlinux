# Copyright (C) 2017, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Basic networkd configuration"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
DEPENDS = "systemd"

SRC_URI = " \
    file://50-wired-nfs.network \
    file://52-static.network.static \
    file://51-wireless.network.sample \
    "

do_install() {
    install -d ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/50-wired-nfs.network ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/52-static.network.static ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/51-wireless.network.sample ${D}${systemd_unitdir}/network
}

FILES_${PN} = "${systemd_unitdir}/network"
