SUMMARY = "Linux libcamera framework"
SECTION = "libs"

LICENSE = "GPL-2.0-or-later & LGPL-2.1-or-later"

LIC_FILES_CHKSUM = "\
    file://LICENSES/GPL-2.0-or-later.txt;md5=fed54355545ffd980b814dab4a3b312c \
    file://LICENSES/LGPL-2.1-or-later.txt;md5=2a4f4fd2128ea2f65047ee63fbca9f68 \
"

include libcamera-stm32mp.inc

# 0.7.0
SRC_URI = "git://git.libcamera.org/libcamera/libcamera.git;protocol=https;branch=master"
SRCREV = "b7854fd07d42168f099b5ce30d1702e0e0875bf5"

SRC_URI += " \
    file://0001-0.7.0-stm32mp-r1.patch \
    "

PV = "0.7.0-stm32mp-r1"
