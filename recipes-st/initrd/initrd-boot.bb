SUMMARY = "Resize init script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
SRC_URI = "file://init-resize.sh"

S = "${WORKDIR}"

do_install() {
    install -d  ${D}/init.d
    install -m 0755 ${WORKDIR}/init-resize.sh ${D}/init.d/95-resize
}

inherit allarch

FILES_${PN} += "/init.d/"
