SUMMARY = "Framework tools extra components (core,kernel,network,audio,ui,python3)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-tools-extra          \
            packagegroup-framework-tools-extra-core     \
            packagegroup-framework-tools-extra-kernel   \
            packagegroup-framework-tools-extra-network  \
            packagegroup-framework-tools-extra-audio    \
            packagegroup-framework-tools-extra-ui       \
            packagegroup-framework-tools-extra-python3  \
            "

# Manage to provide all framework tools extra packages with overall one
RDEPENDS:packagegroup-framework-tools-extra = "\
    packagegroup-framework-tools-extra-core     \
    packagegroup-framework-tools-extra-kernel   \
    packagegroup-framework-tools-extra-network  \
    packagegroup-framework-tools-extra-audio    \
    packagegroup-framework-tools-extra-ui       \
    packagegroup-framework-tools-extra-python3  \
    "

SUMMARY:packagegroup-framework-tools-extra-core = "Framework tools extra components for core"
RDEPENDS:packagegroup-framework-tools-extra-core = "\
    tslib-calibrate \
    pointercal      \
    \
    acl             \
    bzip2           \
    cronie          \
    ltrace          \
    "

SUMMARY:packagegroup-framework-tools-extra-kernel = "Framework tools extra components for kernel"
RDEPENDS:packagegroup-framework-tools-extra-kernel = "\
    powertop        \
    fio             \
    \
    lmbench         \
    nbench-byte     \
    iozone3         \
    bonnie++        \
    bonnie-scripts  \
    ltp             \
    elfutils        \
    formfactor      \
    \
    lirc            \
    \
    dhrystone       \
    "

RDEPENDS:packagegroup-framework-tools-extra-kernel:append:arm = "\
    cpuburn-arm     \
    "
RDEPENDS:packagegroup-framework-tools-extra-kernel:append:aarch64 = "\
    cpuburn-arm     \
    "

SUMMARY:packagegroup-framework-tools-extra-network = "Framework tools extra components for network"
RDEPENDS:packagegroup-framework-tools-extra-network = "\
    iperf3          \
    netperf         \
    bridge-utils    \
    vlan            \
    libnl           \
    connman         \
    connman-client  \
    net-snmp        \
    \
    neard           \
    "

SUMMARY:packagegroup-framework-tools-extra-audio = "Framework tools extra components for audio"
RDEPENDS:packagegroup-framework-tools-extra-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-utils-aplay', '', d)} \
    "

SUMMARY:packagegroup-framework-tools-extra-ui = "Framework tools extra components for ui"
RDEPENDS:packagegroup-framework-tools-extra-ui = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11perf', '', d)}       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'gtkperf', '', d)}       \
    "

SUMMARY:packagegroup-framework-tools-extra-python3 = "Framework tools extra components for python3"
RDEPENDS:packagegroup-framework-tools-extra-python3 = "\
    python3-pip         \
    python3-pytest      \
    python3-lxml        \
    python3-setuptools  \
    "
