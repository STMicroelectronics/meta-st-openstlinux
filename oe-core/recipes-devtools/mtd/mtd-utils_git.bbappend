FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PV = "2.1.2"

SRCREV = "54d68799b73e755923def1306b4da607ad45bd60"
SRC_URI = "git://git.infradead.org/mtd-utils.git \
           file://0001-add-exclusion-to-mkfs-jffs2-git.patch \
"

