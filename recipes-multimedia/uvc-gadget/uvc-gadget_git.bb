SUMMARY = "UVC gadget userspace sample application"
HOMEPAGE = "https://gitlab.freedesktop.org/camera/uvc-gadget"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://src/main.c;beginline=1;endline=8;md5=656482e4ce61e8180e9dd76204e77e53"

SRC_URI = "git://gitlab.freedesktop.org/camera/uvc-gadget.git;protocol=https;nobranch=1"
SRCREV = "04c18aa6c4a7017957e2dfe88c3ff7ef34a1b3a0"

PV = "0.4.0"

S = "${WORKDIR}/git"

DEPENDS += "libcamera-stm32mp jpeg"
inherit meson pkgconfig
