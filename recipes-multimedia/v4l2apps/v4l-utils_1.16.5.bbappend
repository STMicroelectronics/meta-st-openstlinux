FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/st-1.16.0:"

SRC_URI_append = " \
    file://0001-Add-autogen.sh.patch \
    file://0002-Correct-X11-dependency.patch \
"

