# look for files in the layer first
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-NV12-format-support.patch"
