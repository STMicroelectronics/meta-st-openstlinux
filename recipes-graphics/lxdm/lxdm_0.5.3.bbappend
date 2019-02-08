FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI =+ " \
    file://0001-stop-splash-screen.patch \
    file://0001-use-openbox-as-default-session.patch"

