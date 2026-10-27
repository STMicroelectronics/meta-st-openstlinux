# Copyright (C) 2024, STMicroelectronics - All Rights Reserved

SUMMARY = "Demo and X-Linux Expansion Packages Installer and Uninstaller"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
    file://9990-x-linux-installer.yaml \
    file://9991-x-linux-uninstaller.yaml \
    file://launch_x_linux_installer.sh \
    file://common \
    file://pictures \
"

S = "${UNPACKDIR}"

PV = "1.0"

inherit python3-dir

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # install the x-linux installer into the demo launcher
    install -d ${D}${prefix}/local/demo/gtk-application
    install -m 0755 ${UNPACKDIR}/9990-x-linux-installer.yaml ${D}${prefix}/local/demo/gtk-application
    install -m 0755 ${UNPACKDIR}/9991-x-linux-uninstaller.yaml ${D}${prefix}/local/demo/gtk-application

    # install the x-linux installer / uninstaller
    install -d ${D}${prefix}/local/demo/bin/
    install -m 0755 ${UNPACKDIR}/launch_x_linux_installer.sh ${D}${prefix}/local/demo/bin

    # install the common resources when installing / uninstalling applications
    install -d ${D}${prefix}/local/demo/common
    install -m 0755 ${UNPACKDIR}/common/* ${D}${prefix}/local/demo/common

    # install the icons for the demo launcher
    install -d ${D}${prefix}/local/demo/pictures
    install -m 0755 ${UNPACKDIR}/pictures/* ${D}${prefix}/local/demo/pictures
}

FILES:${PN} += " \
    ${prefix}/local/demo/ \
"

RDEPENDS:${PN} += " \
    demo-gtk \
    installer-apps \
    sudo \
    ${PYTHON_PN}-core \
"
