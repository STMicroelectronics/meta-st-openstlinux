# With this image, we want to generate additionnal packages that could be
# used to populate a package repository server.
# The default st-image-weston is "extended" with extra IMAGE_FEATURES, and is also
# extended with as much as possible 'packagegroup-framework-*'.

SUMMARY = "OpenSTLinux image based on ST weston image to generate all packages supported by ST."
LICENSE = "Proprietary"

include recipes-st/images/st-image-weston.bb

# let's make sure we have a good image...
REQUIRED_DISTRO_FEATURES = "wayland"

# Define ROOTFS_MAXSIZE to unlimited size
IMAGE_ROOTFS_MAXSIZE = ""
IMAGE_FSTYPES = "tar"
ENABLE_FLASHLAYOUT_CONFIG = "0"

#
# IMAGE_FEATURES addons
#
IMAGE_FEATURES_append = " \
    x11-base        \
    x11-sato        \
    tools-debug     \
    tools-sdk       \
    dbg-pkgs        \
    dev-pkgs        \
    doc-pkgs        \
    nfs-server      \
    staticdev-pkgs  \
    "

#
# INSTALL addons (manage to add all available openstlinux packages)
#
CORE_IMAGE_EXTRA_INSTALL_append = " \
    packagegroup-framework-tools-extra              \
    \
    packagegroup-framework-sample-x11               \
    packagegroup-framework-sample-xfce              \
    packagegroup-framework-sample-qt                \
    packagegroup-framework-sample-qt-examples       \
    packagegroup-framework-sample-qt-extra          \
    packagegroup-framework-sample-qt-extra-examples \
    "

