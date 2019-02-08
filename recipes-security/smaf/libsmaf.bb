DESCRIPTION = "SMAF library"

LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=d749e86a105281d7a44c2328acebc4b0"

DEPENDS = "virtual/kernel"

inherit autotools gettext pkgconfig

SRC_URI = "git://git.linaro.org/people/benjamin.gaignard/libsmaf.git;protocol=http"
SRCREV = "fc6a8b2b29aceb375aaed226820b50bc3716d6fc"

PV = "1.0+git${SRCPV}"

S = "${WORKDIR}/git"
