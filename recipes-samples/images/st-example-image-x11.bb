SUMMARY = "ST example of image based on X11."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image distro_features_check

# let's make sure we have a good image..
REQUIRED_DISTRO_FEATURES = "x11"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += " \
    splash              \
    package-management  \
    ssh-server-dropbear \
    hwcodecs            \
    tools-profile       \
    eclipse-debug       \
    x11-base            \
    x11-sato            \
    "

# Define ROOTFS_MAXSIZE to 3GB
IMAGE_ROOTFS_MAXSIZE = "3145728"

# Set ST_EXAMPLE_IMAGE property to '1' to allow specific use in image creation process
ST_EXAMPLE_IMAGE = "1"

# make sure we boot to desktop
# by default and without x11-base in IMAGE_FEATURES we default to multi-user.target
SYSTEMD_DEFAULT_TARGET = "graphical.target"

# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-framework-core-base    \
    packagegroup-framework-tools-base   \
    \
    packagegroup-framework-core         \
    packagegroup-framework-tools        \
    \
    packagegroup-framework-sample-x11   \
    "
