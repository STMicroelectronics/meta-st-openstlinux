SUMMARY = "Framework core base components for display and mutlimedia"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-core-base            \
            packagegroup-framework-core-base-display    \
            packagegroup-framework-core-base-mm         \
            packagegroup-framework-core-base-fs         \
            "

# Manage to provide all framework core base packages with overall one
RDEPENDS_packagegroup-framework-core-base = "\
    packagegroup-framework-core-base-display    \
    packagegroup-framework-core-base-mm         \
    packagegroup-framework-core-base-fs         \
    "

SUMMARY_packagegroup-framework-core-base-display = "Framework core base components for display"
RDEPENDS_packagegroup-framework-core-base-display = "\
    libdrm          \
    libdrm-tests    \
    "

SUMMARY_packagegroup-framework-core-base-mm = "Framework core base components for multimedia"
RDEPENDS_packagegroup-framework-core-base-mm = "\
    "

SUMMARY_packagegroup-framework-core-base-fs = "Framework core base components for filesystem"
RDEPENDS_packagegroup-framework-core-base-fs = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-mount-partitions', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'userfs-cleanup-package', '', d)} \
    "
