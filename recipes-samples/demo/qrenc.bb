SUMMARY = "qrenc which uses libqrencode to generate QR-code"

LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/LGPL-2.1;md5=1a6d268fd218675ffea8be556788b780"

DEPENDS += "qrencode"
DEPENDS += "libpng"

inherit pkgconfig

SRC_URI = " file://qrenc.c \
            file://Makefile \
          "

S = "${WORKDIR}"

do_install() {
    install -d ${D}${prefix}/bin/
    install -m 0755 ${B}/qrencode  ${D}${prefix}/bin/
}

FILES_${PN} += "${prefix}/bin/"

RDEPENDS_${PN} += "qrencode libpng"
