SUMMARY = "DMCIPP ISP control tools"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://dcmipp-isp-ctrl/COPYING;md5=f8001cce2bab8ab39ddcb12684e4bdf4"

SRC_URI = "git://github.com/STMicroelectronics/st-openstlinux-application.git;protocol=https;branch=main"

# Modify these as desired
PV = "6.1+git-${@d.getVar("SRCREV")[0:8]}"
SRCREV = "1ab21d8400036235771d70becdcf6f92b665025d"

S = "${WORKDIR}/git"

do_compile () {
	cd ${S}/dcmipp-isp-ctrl
	oe_runmake
}

do_install () {
	install -d ${D}${prefix}/local/demo/bin
	install -m 0755 ${B}/dcmipp-isp-ctrl/dcmipp-isp-ctrl ${D}${prefix}/local/demo/bin/
}
FILES:${PN} += "${prefix}/local/demo/bin"

