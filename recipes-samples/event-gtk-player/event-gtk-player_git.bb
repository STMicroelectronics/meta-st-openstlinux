SUMMARY = "GTK player with touch screen management"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "git://github.com/STMicroelectronics/st-openstlinux-application.git;protocol=https;branch=main"

# Modify these as desired
PV = "5.0+git-${@d.getVar("SRCREV")[0:8]}"
SRCREV = "e2f4fc8c493f992ff1dbaf6ee2b117107c5aad15"

DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gtk+3"

inherit meson pkgconfig

S = "${WORKDIR}/git/touch-event-gtk-player"

do_install () {
	install -d ${D}${prefix}/local/demo/bin
	install -m 0755 ${B}/touch-event-gtk-player ${D}${prefix}/local/demo/bin/
	install -m 0755 ${B}/play_pause-gtk-player ${D}${prefix}/local/demo/bin/
}
FILES:${PN} += "${prefix}/local/demo/bin"

