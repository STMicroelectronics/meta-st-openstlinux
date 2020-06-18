# Copyright (C) 2019, STMicroelectronics - All Rights Reserved

SUMMARY = "Add apt configuration files for OpenSTLinux"
DESCRIPTION = "Add apt configuration files for OpenSTLinux"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} += " gnupg "

SRC_URI = "file://packages.openstlinux.st.com.list \
           file://packages.openstlinux.st.com.gpg \
           file://01-st-disclaimer \
           file://disclaimer \
          "

S = "${WORKDIR}"

inherit deploy

do_compile[noexec] = "1"

do_install() {
    install -d ${D}/${sysconfdir}/apt/sources.list.d
    install -d ${D}/${sysconfdir}/apt/trusted.gpg.d
    install -d ${D}/${sysconfdir}/apt/apt.conf.d
    install ${S}/packages.openstlinux.st.com.list ${D}/${sysconfdir}/apt/sources.list.d
    install ${S}/packages.openstlinux.st.com.gpg ${D}/${sysconfdir}/apt/trusted.gpg.d
    install ${S}/disclaimer ${D}/${sysconfdir}/apt/
    install ${S}/01-st-disclaimer ${D}/${sysconfdir}/apt/apt.conf.d
}
