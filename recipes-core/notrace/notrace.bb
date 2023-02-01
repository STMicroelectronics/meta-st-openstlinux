# Copyright (C) 2023, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Add script in case no trace was asked"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://${NOTRACE_SCRIPT}"

NOTRACE_SCRIPT = "notrace.sh"

inherit linux-kernel-base
KERNEL_VERSION = "${@get_kernelversion_file("${STAGING_KERNEL_BUILDDIR}") or '0.0'}"

do_configure[depends] += "virtual/kernel:do_shared_workdir"
do_configure() {
    cp "${WORKDIR}/${NOTRACE_SCRIPT}" "${S}/${NOTRACE_SCRIPT}"
    sed -i 's/<KERNEL_VERSION>/'"${KERNEL_VERSION}"'/' "${S}/${NOTRACE_SCRIPT}"
}

do_install() {
    install -d ${D}${sysconfdir}/profile.d
    if ${@bb.utils.contains('ST_DEBUG_TRACE','0','true','false',d)}; then
        install -m 0755 ${S}/${NOTRACE_SCRIPT} ${D}${sysconfdir}/profile.d/
    fi
}
