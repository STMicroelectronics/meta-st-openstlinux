require python3-bluepy.inc

inherit setuptools3
SRC_URI[sha256sum] = "2a71edafe103565fb990256ff3624c1653036a837dfc90e1e32b839f83971cec"
DEPENDS += "glib-2.0"

inherit pkgconfig

INSANE_SKIP:${PN} += "ldflags"
