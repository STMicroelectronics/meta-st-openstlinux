SUMMARY = "Writes build information to target filesystem on /etc/build"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit image-buildinfo

do_install(){
    install -d ${D}/$(dirname "${IMAGE_BUILDINFO_FILE}")
}
# Configure buildinfo() from image-buildinfo class to generate expected info
IMAGE_BUILDINFO_VARS = "${BUILDCFG_VARS}"
# Set path to output build info file on image dir
IMAGE_ROOTFS = "${D}"
# Generate build info file
do_install[postfuncs] += "buildinfo"
# Add specific var dependency to keep generating new build info file for any
# var update
do_install[vardeps] += "${IMAGE_BUILDINFO_VARS}"
do_packagedata_setscene[vardeps] += "${IMAGE_BUILDINFO_VARS}"
