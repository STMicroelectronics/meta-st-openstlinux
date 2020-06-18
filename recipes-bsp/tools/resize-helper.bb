# Copyright (C) 2016, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

# Tools extracted from 96boards-tools https://github.com/96boards/96boards-tools
DESCRIPTION = "Tools for resizing the file system"
SECTION = "devel"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

# e2fsprogs for resize2fs
RDEPENDS_${PN} += " e2fsprogs-resize2fs "

SRC_URI = " file://resize-helper.service file://resize-helper file://resize-helper.sh.in"

S = "${WORKDIR}/git"

START_RESIZE_HELPER_SERVICE ?= "1"

inherit systemd update-rc.d

SYSTEMD_PACKAGES += " resize-helper "
SYSTEMD_SERVICE_${PN} = "resize-helper.service"
SYSTEMD_AUTO_ENABLE_${PN} = "${@bb.utils.contains('START_RESIZE_HELPER_SERVICE','1','enable','disable',d)}"

do_install() {
    install -d ${D}${systemd_unitdir}/system ${D}${base_sbindir}
    install -m 0644 ${WORKDIR}/resize-helper.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/resize-helper ${D}${base_sbindir}

    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/resize-helper.sh.in ${D}${sysconfdir}/init.d/resize-helper.sh

    sed -i -e "s:@sbindir@:${base_sbindir}:; s:@sysconfdir@:${sysconfdir}:" \
${D}${sysconfdir}/init.d/resize-helper.sh
    if [ "${START_RESIZE_HELPER_SERVICE}" -eq 0 ]; then
        rm ${D}${sysconfdir}/init.d/resize-helper.sh
        echo "#!/bin/sh" > ${D}${sysconfdir}/init.d/resize-helper.sh
        chmod +x ${D}${sysconfdir}/init.d/resize-helper.sh
    fi
}

INITSCRIPT_NAME = "resize-helper.sh"
INITSCRIPT_PARAMS = "start 22 5 3 ."
