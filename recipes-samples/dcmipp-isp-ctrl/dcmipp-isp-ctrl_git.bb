SUMMARY = "DMCIPP ISP control tools"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://dcmipp-isp-ctrl/COPYING;md5=f8001cce2bab8ab39ddcb12684e4bdf4"

SRC_URI = "git://github.com/STMicroelectronics/st-openstlinux-application.git;protocol=https;branch=main"

# Modify these as desired
PV = "5.1+git-${@d.getVar("SRCREV")[0:8]}"
SRCREV = "31551e7487c2c014248462565383e3912c0f9ad5"

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

