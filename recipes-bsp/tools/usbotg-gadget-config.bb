# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "The goal is to enable USB gadget configuration"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0"

SRC_URI = " file://stm32_usbotg_eth_config.sh \
    file://stm32_usbotg_eth_via_udev.sh \
    file://53-usb-otg.network \
    file://97-ustotg.rules \
    \
    file://stm32_usbotg_uvc_config.sh \
    file://default_usbotg \
    "

S = "${WORKDIR}/git"

# for uvc script, need to have uvc-gadget
DEPENDS += "uvc-gadget"

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/network
        install -m 0644 ${WORKDIR}/53-usb-otg.network ${D}${systemd_unitdir}/network
    fi

    install -d ${D}${base_sbindir}
    install -m 0755 ${WORKDIR}/stm32_usbotg_eth_via_udev.sh ${D}${base_sbindir}
    install -m 0755 ${WORKDIR}/stm32_usbotg_eth_config.sh ${D}${base_sbindir}
    install -m 0755 ${WORKDIR}/stm32_usbotg_uvc_config.sh ${D}${base_sbindir}

    # install udev rule
    install -D -p -m0644 ${WORKDIR}/97-ustotg.rules ${D}${sysconfdir}/udev/rules.d/97-ustotg.rules

    install -D -p -m0644 ${WORKDIR}/default_usbotg  ${D}${sysconfdir}/default/usbotg
}

FILES:${PN} += "${systemd_unitdir}/network ${sysconfdir}/udev ${sysconfdir}/default"
