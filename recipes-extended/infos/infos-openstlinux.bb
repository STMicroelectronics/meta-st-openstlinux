SUMMARY = "Information for support"

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-or-later;md5=fed54355545ffd980b814dab4a3b312c"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PV = "1.1"

do_install() {
	if [ "${TARGET_ARCH}" = "arm" ]; then
		mkdir -p ${D}${sysconfdir}/st-info.d
		touch ${D}${sysconfdir}/st-info.d/graphics-${PV}
		printf "LIBGLES1=${PREFERRED_PROVIDER_virtual/libgles1}\n" > ${D}${sysconfdir}/st-info.d/graphics-${PV}
	fi
}

# Make sure to update package as soon as EULA is accepted or not
do_install[vardeps] += "${@d.getVar('ACCEPT_EULA_'+d.getVar('MACHINE'))}"

FILES:${PN} = "${sysconfdir}/st-info.d"
ALLOW_EMPTY:${PN} = "1"
