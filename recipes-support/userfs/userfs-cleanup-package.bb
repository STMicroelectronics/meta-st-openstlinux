# Copyright (C) 2019, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Tools for cleaning apt databse"
SECTION = "devel"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

RDEPENDS_${PN} += " apt "

SRC_URI = " file://userfs-cleanup-package.service  file://userfs-cleanup-package.sh"

S = "${WORKDIR}/git"

inherit systemd update-rc.d

ST_USERFS ?= "1"

SYSTEMD_PACKAGES += " ${@bb.utils.contains('ST_USERFS', '1', 'userfs-cleanup-package', '', d)} "
SYSTEMD_SERVICE_${PN} = "userfs-cleanup-package.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/system ${D}${base_sbindir}
    install -m 0644 ${WORKDIR}/userfs-cleanup-package.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/userfs-cleanup-package.sh ${D}${base_sbindir}

    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/userfs-cleanup-package.sh ${D}${sysconfdir}/init.d/userfs-cleanup-package.sh

    sed -i -e "s:@sbindir@:${base_sbindir}:; s:@sysconfdir@:${sysconfdir}:" ${D}${sysconfdir}/init.d/userfs-cleanup-package.sh
    sed -i -e "s:@sbindir@:${base_sbindir}:; s:@sysconfdir@:${sysconfdir}:" ${D}${systemd_unitdir}/system/userfs-cleanup-package.service
}

INITSCRIPT_NAME = "userfs-cleanup-package.sh"
INITSCRIPT_PARAMS = "start 22 5 3 ."
