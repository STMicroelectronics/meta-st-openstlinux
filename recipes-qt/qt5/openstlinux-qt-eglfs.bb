# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
DESCRIPTION = "add script and material to help with eglfs qt configuration"
HOMEPAGE = "www.st.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
DEPENDS = ""

SRC_URI = " \
    file://qt-eglfs.sh \
    file://cursor.json \
    "

S = "${WORKDIR}"

inherit allarch

do_install() {
    install -d ${D}/${sysconfdir}/profile.d
    install -d ${D}${datadir}/qt5

    install -m 0755 ${WORKDIR}/qt-eglfs.sh ${D}/${sysconfdir}/profile.d/
    install -m 0664 ${WORKDIR}/cursor.json ${D}${datadir}/qt5/
}
RDEPENDS_${PN} = "qtbase"
FILES_${PN} += "${datadir}/qt5"
