# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
DESCRIPTION = "Shell script to enable/disable hotsopt wifi configuration"
HOMEPAGE = "www.st.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://st-hotspot-wifi-service.sh"

do_install() {
    install -d ${D}${prefix}/local/demo/bin

    install -m 755 ${WORKDIR}/st-hotspot-wifi-service.sh ${D}${prefix}/local/demo/bin
}

FILES_${PN} += "${prefix}/local/demo/bin"
