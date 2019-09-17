# Copyright (C) 2018, STMicroelectronics - All Rights Reserved

SUMMARY = "Python script which launch several use-cases"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "demo-hotspot-wifi"
DEPENDS += "ai-hand-char-reco-launcher"
DEPENDS += "qrenc"
DEPENDS += "weston-cube"

SRC_URI = " \
    file://demo_launcher.py \
    file://start_up_demo_launcher.sh \
    file://bin \
    file://pictures \
    file://media \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/
    install -d ${D}${prefix}/local/demo/bin
    install -d ${D}${prefix}/local/demo/pictures
    install -d ${D}${prefix}/local/demo/media
    install -m 0755 ${WORKDIR}/demo_launcher.py ${D}${prefix}/local/demo/
    install -m 0755 ${WORKDIR}/bin/* ${D}${prefix}/local/demo/bin
    install -m 0644 ${WORKDIR}/pictures/* ${D}${prefix}/local/demo/pictures/
    install -m 0644 ${WORKDIR}/media/* ${D}${prefix}/local/demo/media/

    # start at startup
    install -d ${D}${prefix}/local/weston-start-at-startup/
    install -m 0755 ${WORKDIR}/start_up_demo_launcher.sh ${D}${prefix}/local/weston-start-at-startup/
}

FILES_${PN} += "${prefix}/local/demo/ ${prefix}/local/weston-start-at-startup/"

RDEPENDS_${PN} += "python3 python3-pygobject gtk+3 gstreamer1.0-plugins-base python3-ptyprocess python3-pexpect python3-terminal python3-resource"
RDEPENDS_${PN} += "demo-hotspot-wifi ai-hand-char-reco-launcher weston-cube event-gtk-player"

