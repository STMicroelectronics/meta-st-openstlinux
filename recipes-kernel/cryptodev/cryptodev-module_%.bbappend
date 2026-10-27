FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Fix build for Linux 6.18-rc1
SRCREV = "08644db02d43478f802755903212f5ee506af73b"

INSANE_SKIP:${PN} += "buildpaths"
INSANE_SKIP:${kernel-module-cryptodev} += "buildpaths"
