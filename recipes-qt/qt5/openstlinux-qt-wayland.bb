# Copyright (C) 2020, STMicroelectronics - All Rights Reserved
DESCRIPTION = "add script and material to help with qt-wayland configuration"
HOMEPAGE = "www.st.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
DEPENDS = ""

SRC_URI = " \
    file://qt-wayland.sh \
    "

S = "${WORKDIR}"

inherit allarch

do_install() {
    install -d ${D}/${sysconfdir}/profile.d

    install -m 0755 ${WORKDIR}/qt-wayland.sh ${D}/${sysconfdir}/profile.d/
}
RDEPENDS_${PN} = "qtwayland"
FILES_${PN} += "${datadir}/qt5"
