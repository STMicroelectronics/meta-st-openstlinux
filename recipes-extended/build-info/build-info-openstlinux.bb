SUMMARY = "Writes build information to target filesystem on /etc/build"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit image-buildinfo

IMAGE_BUILDINFO_FILE = "${sysconfdir}/build"
do_install(){
    install -d ${D}/$(dirname "${IMAGE_BUILDINFO_FILE}")
}
BUILDINFODEST = "${D}"
# Configure buildinfo() from image-buildinfo class to generate expected info
IMAGE_BUILDINFO_VARS = "${BUILDCFG_VARS}"
# Set path to output build info file on image dir
IMAGE_ROOTFS = "${D}"
# Generate build info file
do_install[postfuncs] += "buildinfo"
# Always rebuild that recipe to avoid cache issue
do_install[nostamp] = "1"
