DESCRIPTION = "Read one-dimensional barcodes and QR codes from Python 2 and 3 using the zbar library"
HOMEPAGE = "https://github.com/NaturalHistoryMuseum/pyzbar"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=c27c2135d76d2d03f4842d9c133f1ed4"

SECTION = "devel/python"
DEPENDS = "python3-pillow zbar-openstlinux"

SRC_URI = "git://github.com/NaturalHistoryMuseum/pyzbar.git;protocol=https"
SRCREV = "b6853df71aee4b38a9986af8565603a0115e81b7"
S = "${WORKDIR}/git"

BBCLASSEXTEND += "native nativesdk"

inherit setuptools3
