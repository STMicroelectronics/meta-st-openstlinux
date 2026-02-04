# Copyright (C) 2024, STMicroelectronics - All Rights Reserved
SUMMARY = "evision package to install AE an AWB algorithm libraries"
LICENSE = "SLA0044"
LIC_FILES_CHKSUM  = "file://evision-libs/LICENSE;md5=91fc08c2e8dfcd4229b69819ef52827c"

NO_GENERIC_LICENSE[SLA0044] = "evision-libs/LICENSE"
LICENSE:${PN} = "SLA0044"

SRC_URI = "file://evision-libs/;subdir=${BPN}-${PV}  \
"

COMPATIBLE_MACHINE = "^(aarch64)"

# Configure evision output library dir
ST_SPECIFIC_OUTPUT_LIBDIR ??= "${libdir}"

EVISION_LDCONF ?= "evision.conf"

S = "${WORKDIR}/${BPN}-${PV}"

do_configure[noexec] = "1"

do_compile() {
    # Generate specific conf file if required
    if [ "${ST_SPECIFIC_OUTPUT_LIBDIR}" = "${libdir}" ]; then
        bbnote "evision output libdir is default one (${libdir})"
        echo "" > ${B}/${EVISION_LDCONF}
    else
        bbnote "evision output libdir set to ${ST_SPECIFIC_OUTPUT_LIBDIR}: generate specific conf file for ldconfig"
        echo ${ST_SPECIFIC_OUTPUT_LIBDIR} > ${B}/${EVISION_LDCONF}
    fi
}

do_install() {
    # includes
    install -m 0755 -d ${D}${includedir}/evision
    install -m 0644 ${S}/evision-libs/*.h ${D}${includedir}/evision
    install -m 0644 ${S}/evision-libs/LICENSE ${D}${includedir}/evision

    # libraries
    install -m 0755 -d ${D}${ST_SPECIFIC_OUTPUT_LIBDIR}
    install -m 0755 ${S}/evision-libs/*.so.* ${D}${ST_SPECIFIC_OUTPUT_LIBDIR}/

    # ldconfig file
    if [ -s "${B}/${EVISION_LDCONF}" ]; then
        install -d ${D}${sysconfdir}/ld.so.conf.d/
        install -m 0644 "${B}/${EVISION_LDCONF}" ${D}${sysconfdir}/ld.so.conf.d/
    fi
}


PACKAGES += "\
    evision-ldconf \
    "
FILES:${PN}  = "${ST_SPECIFIC_OUTPUT_LIBDIR}/*.so.*"
FILES:evision-ldconf = "${sysconfdir}/ld.so.conf.d/*"
ALLOW_EMPTY:${evision-ldconf} = "1"

RDEPENDS:${PN} += "\
    evision-ldconf \
    "
