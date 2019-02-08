# Copyright (C) 2018, STMicroelectronics - All Rights Reserved

DESCRIPTION = "Python script which monitor temperature from sensor on Nucleo extension board iks01a2a"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${OPENSTLINUX_BASE}/files/licenses/ST-Proprietary;md5=7cb1e55a9556c7dd1a3cae09db9cc85f"

SRC_URI = " \
    file://sensors_temperature.py \
    \
    file://pictures \
    file://README.txt\
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${prefix}/local/demo/pictures


    install -m 0755 ${WORKDIR}/sensors_temperature.py ${D}${prefix}/local/demo/

    install -m 0644 ${WORKDIR}/pictures/* ${D}${prefix}/local/demo/pictures
    install -m 0644 ${WORKDIR}/README.txt ${D}${prefix}/local/demo/README_sensor_iks01a2.txt
}

FILES_${PN} += "${datadir}/sensors_temperature/"
RDEPENDS_${PN} += "python3 python3-pygobject python3-pycairo gtk+3 "
