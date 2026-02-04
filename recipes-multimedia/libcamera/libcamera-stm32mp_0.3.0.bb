SUMMARY = "Linux libcamera framework"
SECTION = "libs"

LICENSE = "GPL-2.0-or-later & LGPL-2.1-or-later"

LIC_FILES_CHKSUM = "\
    file://LICENSES/GPL-2.0-or-later.txt;md5=fed54355545ffd980b814dab4a3b312c \
    file://LICENSES/LGPL-2.1-or-later.txt;md5=2a4f4fd2128ea2f65047ee63fbca9f68 \
"

include libcamera-stm32mp.inc

# 0.3.0
SRC_URI = "git://git.libcamera.org/libcamera/libcamera.git;protocol=https;branch=master"
SRCREV = "aee16c06913422a0ac84ee3217f87a9795e3c2d9"

SRC_URI += " \
    file://0001-media_device-Add-bool-return-type-to-unlock.patch \
    file://0002-options-Replace-use-of-VLAs-in-C.patch \
    file://0001-rpi-Use-alloca-instead-of-variable-length-arrays.patch \
    \
    file://0001-v0.3.0-stm32mp.patch \
    "

PV = "0.3.0"
