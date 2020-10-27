SUMMARY = "ST example of image based on Qt framework over Weston/Wayland."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image features_check populate_sdk_qt5

# let's make sure we have a good image...
REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += "\
    splash              \
    package-management  \
    ssh-server-dropbear \
    hwcodecs            \
    tools-profile       \
    eclipse-debug       \
    "

# Define ROOTFS_MAXSIZE to 3GB
IMAGE_ROOTFS_MAXSIZE = "3145728"

# Set ST_EXAMPLE_IMAGE property to '1' to allow specific use in image creation process
ST_EXAMPLE_IMAGE = "1"

#
# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    resize-helper \
    \
    packagegroup-framework-core-base    \
    packagegroup-framework-tools-base   \
    \
    packagegroup-framework-core         \
    packagegroup-framework-tools        \
    \
    packagegroup-framework-core-extra   \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)} \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-st-demo \
    \
    packagegroup-framework-sample-qtwayland     \
    packagegroup-framework-sample-qt-examples   \
    "

# IMAGE_INSTALL_append += "qtbase qtwayland qtbase-plugins qtwayland-plugins"

# NOTE:
#   packagegroup-st-demo are installed on rootfs to populate the package
#   database.
