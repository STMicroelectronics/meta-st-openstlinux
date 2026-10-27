SUMMARY = "OpenVX sample applications"
DESCRIPTION = "Simple applications to use with any conformant implementation of OpenVX"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=becaaa9e60734aab413b4f0605e1ec0b"

SRC_URI = "git://github.com/KhronosGroup/openvx-samples.git;protocol=https;branch=main \
           file://0001-Use-V4L2-configurable-camera-device.patch \
           "

PV = "1.0+git${SRCPV}"
SRCREV = "458c983626ed2d574ccd1058a203f999e132131e"

inherit cmake features_check

REQUIRED_MACHINE_FEATURES = "openvx"

DEPENDS = " \
    virtual/libopenvx \
    opencv            \
    "

EXTRA_OECMAKE = " \
    -DOPENVX_INCLUDES=${STAGING_INCDIR}                 \
    -DOPENVX_LIBRARIES=${STAGING_LIBDIR}/libOpenVX.so.1 \
    "

SOLIBS = ".so"
FILES_SOLIBSDEV = ""
