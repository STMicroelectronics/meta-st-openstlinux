DESRIPTION = "2D barcode scanner toolkit."
SECTION = "graphics"
LICENSE = "LGPL-2.1"

DEPENDS = "pkgconfig intltool-native libpng jpeg"
DEPENDS += "xmlto-native"

LIC_FILES_CHKSUM = "file://COPYING;md5=4015840237ca7f0175cd626f78714ca8"

PV = "0.10+git${SRCPV}"

SRCREV = "67003d2a985b5f9627bee2d8e3e0b26d0c474b57"
SRC_URI = "git://github.com/ZBar/Zbar \
           file://0001-make-relies-GNU-extentions.patch \
           file://0002-support-of-ImageMagick-7.patch \
"

S = "${WORKDIR}/git"

inherit autotools pkgconfig python3native

PACKAGECONFIG = " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'x11', d)} \
    imagemagick video \
"

PACKAGECONFIG[x11] = "--with-x,-without-x,libxcb libx11 libsm libxau libxext libxv libice libxdmcp"
PACKAGECONFIG[imagemagick] = ",--without-imagemagick,imagemagick"
PACKAGECONFIG[video] = ",--disable-video,"

EXTRA_OECONF = " \
        --without-qt \
        --without-python \
        --without-gtk \
        "

CPPFLAGS += "-Wno-error"

do_install() {
    install -d ${D}${libdir} ${D}${bindir}

    # install library
    install -m 0755 ${B}/zbar/.libs/libzbar.so.0.2.0 ${D}${libdir}
    ln -s ${libdir}/libzbar.so.0.2.0 ${D}${libdir}/libzbar.so.0

    # install zbarcam
    install -m 0755 ${B}/zbarcam/.libs/zbarcam ${D}${bindir}

    # install zbarimg
    install -m 0755 ${B}/zbarimg/.libs/zbarimg ${D}${bindir}
}
