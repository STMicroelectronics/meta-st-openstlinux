SUMMARY = "Framework tools base components (core,kernel,network,audio,ui,python2,python3)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-tools-base           \
            packagegroup-framework-tools-base-core      \
            packagegroup-framework-tools-base-kernel    \
            packagegroup-framework-tools-base-network   \
            packagegroup-framework-tools-base-audio     \
            packagegroup-framework-tools-base-ui        \
            packagegroup-framework-tools-base-python3   \
            "

# Manage to provide all framework tools base packages with overall one
RDEPENDS_packagegroup-framework-tools-base = "\
    packagegroup-framework-tools-base-core      \
    packagegroup-framework-tools-base-kernel    \
    packagegroup-framework-tools-base-network   \
    packagegroup-framework-tools-base-audio     \
    packagegroup-framework-tools-base-ui        \
    packagegroup-framework-tools-base-python3   \
    "

SUMMARY_packagegroup-framework-tools-base-core = "Framework tools base components for core"
RDEPENDS_packagegroup-framework-tools-base-core = "\
    ckermit         \
    coreutils       \
    libiio-iiod     \
    libiio-tests    \
    lrzsz           \
    libgpiod        \
    libgpiod-tools  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'usbgadget', 'usbotg-gadget-config', '', d)} \
    "

SUMMARY_packagegroup-framework-tools-base-kernel = "Framework tools base components for kernel"
RDEPENDS_packagegroup-framework-tools-base-kernel = "\
    can-utils       \
    i2c-tools       \
    strace          \
    usbutils        \
    \
    evtest          \
    memtester       \
    mtd-utils       \
    v4l-utils       \
    util-linux      \
    util-linux-fdisk\
    pciutils        \
    "

SUMMARY_packagegroup-framework-tools-base-network = "Framework tools base components for network"
RDEPENDS_packagegroup-framework-tools-base-network = "\
    ethtool         \
    iproute2        \
    curl            \
    "

SUMMARY_packagegroup-framework-tools-base-audio = "Framework tools base components for audio"
RDEPENDS_packagegroup-framework-tools-base-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'libasound alsa-conf', '', d)}  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-utils', '', d)}           \
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-plugins', '', d)}         \
    "

SUMMARY_packagegroup-framework-tools-base-ui = "Framework tools base components for ui"
RDEPENDS_packagegroup-framework-tools-base-ui = "\
    "

SUMMARY_packagegroup-framework-tools-base-python3 = "Framework tools base components for python3"
RDEPENDS_packagegroup-framework-tools-base-python3 = "\
    "
