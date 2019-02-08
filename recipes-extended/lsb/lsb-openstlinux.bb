SUMMARY = "LSB support to check gpu provider"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

# need lsb_release
RDEPENDS_${PN} += "lsb"

PV="1.0"

do_install() {
	if [ "${TARGET_ARCH}" = "arm" ]; then
		mkdir -p ${D}${sysconfdir}/lsb-release.d
		touch ${D}${sysconfdir}/lsb-release.d/graphics-${PV}
		printf "LIBGLES1=${PREFERRED_PROVIDER_virtual/libgles1}\n" > ${D}${sysconfdir}/lsb-release.d/graphics-${PV}
	fi
}

ALLOW_EMPTY_${PN} = "1"
