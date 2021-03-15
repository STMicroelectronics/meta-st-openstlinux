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
    \
    file://98-net-alias-stm32mp.rules \
    file://stm32mp-net-alias-udev.sh \
    "

do_install() {
    install -d ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/50-wired-nfs.network ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/52-static.network.static ${D}${systemd_unitdir}/network
    install -m 644 ${WORKDIR}/51-wireless.network.sample ${D}${systemd_unitdir}/network

    # install link creation
    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/98-net-alias-stm32mp.rules ${D}${sysconfdir}/udev/rules.d/
    install -d ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/stm32mp-net-alias-udev.sh ${D}${sbindir}/

}

FILES_${PN} += "${systemd_unitdir}/network"
