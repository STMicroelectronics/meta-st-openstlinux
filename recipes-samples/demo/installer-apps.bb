# Copyright (C) 2024, STMicroelectronics - All Rights Reserved

SUMMARY = "Demos and X-Linux Expansion Packages Individual Installers and Uninstallers"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
    file://common \
    file://install \
    file://uninstall \
"

S = "${UNPACKDIR}"

PV = "1.0"

inherit python3-dir

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # install common resources
    install -d ${D}${prefix}/local/demo/gtk-installer/common
    LIST=$(ls ${UNPACKDIR}/common/*)
    if [ -n "$LIST" ]; then
        cp -r ${UNPACKDIR}/common/* ${D}${prefix}/local/demo/gtk-installer/common
    fi
    # install application installers
    install -d ${D}${prefix}/local/demo/gtk-installer/install
    LIST=$(ls ${UNPACKDIR}/install/*)
    if [ -n "$LIST" ]; then
        cp -r ${UNPACKDIR}/install/* ${D}${prefix}/local/demo/gtk-installer/install
    fi
    # install application uninstallers
    install -d ${D}${prefix}/local/demo/gtk-installer/uninstall
    LIST=$(ls ${UNPACKDIR}/uninstall/*)
    if [ -n "$LIST" ]; then
        cp -r ${UNPACKDIR}/uninstall/* ${D}${prefix}/local/demo/gtk-installer/uninstall
    fi
}

FILES:${PN} += " \
    ${prefix}/local/demo/ \
"

RDEPENDS:${PN} += " \
    ${PYTHON_PN}-core \
"
