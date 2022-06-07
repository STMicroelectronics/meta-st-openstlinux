FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "${XORG_CRYPTO} "

DEPENDS += "libxshmfence"
