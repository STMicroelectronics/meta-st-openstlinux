# Copyright (C) 2018, STMicroelectronics - All Rights Reserved

SUMMARY = "Python script which launch several use-cases"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
    file://demo_launcher.py \
    file://start_up_demo_launcher.sh \
    file://pictures \
    file://application \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/
    install -d ${D}${prefix}/local/demo/bin
    install -d ${D}${prefix}/local/demo/pictures
    install -d ${D}${prefix}/local/demo/media
    install -d ${D}${prefix}/local/demo/application

    install -m 0755 ${WORKDIR}/demo_launcher.py ${D}${prefix}/local/demo/
    LIST=$(ls ${WORKDIR}/pictures/*)
    if [ -n "$LIST" ]; then
        install -m 0644 ${WORKDIR}/pictures/* ${D}${prefix}/local/demo/pictures/
    fi
    LIST=$(ls ${WORKDIR}/application/*)
    if [ -n "$LIST" ]; then
        cp -r ${WORKDIR}/application/* ${D}${prefix}/local/demo/application/
    fi

    # start at startup
    install -d ${D}${prefix}/local/weston-start-at-startup/
    install -m 0755 ${WORKDIR}/start_up_demo_launcher.sh ${D}${prefix}/local/weston-start-at-startup/
}

FILES_${PN} += "${prefix}/local/demo/ ${prefix}/local/weston-start-at-startup/"

RDEPENDS_${PN} += "python3-pygobject gtk+3 python3-resource python3-threading"
#since zeus
RDEPENDS_${PN} += " python3-core "
