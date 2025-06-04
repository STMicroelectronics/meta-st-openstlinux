SUMMARY = "Framework tools components (core,kernel,network,audio,ui,python3)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-tools            \
            packagegroup-framework-tools-core       \
            packagegroup-framework-tools-kernel     \
            packagegroup-framework-tools-network    \
            packagegroup-framework-tools-audio      \
            packagegroup-framework-tools-ui         \
            packagegroup-framework-tools-python3    \
            "

# Manage to provide all framework tools packages with overall one
RDEPENDS:packagegroup-framework-tools = "\
    packagegroup-framework-tools-core       \
    packagegroup-framework-tools-kernel     \
    packagegroup-framework-tools-network    \
    packagegroup-framework-tools-audio      \
    packagegroup-framework-tools-ui         \
    packagegroup-framework-tools-python3    \
    "

SUMMARY:packagegroup-framework-tools-core = "Framework tools components for core"
RDEPENDS:packagegroup-framework-tools-core = "\
    grep            \
    util-linux      \
    util-linux-lscpu\
    procps          \
    kbd             \
    file            \
    bc              \
    e2fsprogs       \
    e2fsprogs-resize2fs \
    sysstat         \
    minicom         \
    systemtap       \
    gptfdisk        \
    rng-tools       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'rng-tools-service', '', d)}    \
    apt-openstlinux \
    bzip2           \
    tar             \
    wget            \
    xz              \
    cracklib        \
    db              \
    sqlite3         \
    rt-tests        \
    stm32-ddr-tools \
    "

SUMMARY:packagegroup-framework-tools-kernel = "Framework tools components for kernel"
RDEPENDS:packagegroup-framework-tools-kernel = "\
    cpufrequtils    \
    sysfsutils      \
    dosfstools      \
    mmc-utils       \
    blktool         \
    mtd-utils-ubifs \
    sysprof         \
    "

SUMMARY:packagegroup-framework-tools-network = "Framework tools components for network"
RDEPENDS:packagegroup-framework-tools-network = "\
    tcpdump         \
    packagegroup-core-full-cmdline-extended \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'iw', '', d)}                       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wpa-supplicant', '', d)}           \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'hostapd', '', d)}                  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wireless-regdb-static', '', d)}    \
    openssh-sftp    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-networkd-configuration', '', d)}    \
    usbip uhubctl   \
    bridge-utils    \
    "

SUMMARY:packagegroup-framework-tools-audio = "Framework tools components for audio"
RDEPENDS:packagegroup-framework-tools-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'pipewire', '', d)}                     \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'pulseaudio-tools', '', d)}             \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'pipewire-tools', '', d)}               \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'wireplumber', '', d)}                  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'pulseaudio-tools pipewire-spa-tools', '', d)}             \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'libcamera-stm32mp', '', d)}            \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pipewire', 'libcamera-stm32mp-gst', '', d)}        \
    "

SUMMARY:packagegroup-framework-tools-ui = "Framework tools components for ui"
RDEPENDS:packagegroup-framework-tools-ui = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xvinfo', '', d)}    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'glmark2', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'netdata', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'lmsensors-libsensors lmsensors-sensors', '', d)} \
    "

SUMMARY:packagegroup-framework-tools-python3 = "Framework tools components for python3"
RDEPENDS:packagegroup-framework-tools-python3 = "\
    python3-datetime    \
    python3-dateutil    \
    python3-distutils-extra \
    python3-email       \
    python3-fcntl       \
    python3-io          \
    python3-logging     \
    python3-misc        \
    python3-numbers     \
    python3-pycairo     \
    python3-pygobject   \
    python3-pyparsing   \
    python3-shell       \
    python3-stringold   \
    python3-threading   \
    python3-unittest    \
    python3-pyyaml      \
    python3-pexpect     \
    python3-evdev       \
    python3-compile     \
    "
