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
RDEPENDS_packagegroup-framework-tools = "\
    packagegroup-framework-tools-core       \
    packagegroup-framework-tools-kernel     \
    packagegroup-framework-tools-network    \
    packagegroup-framework-tools-audio      \
    packagegroup-framework-tools-ui         \
    packagegroup-framework-tools-python3    \
    "

SUMMARY_packagegroup-framework-tools-core = "Framework tools components for core"
RDEPENDS_packagegroup-framework-tools-core = "\
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
    ntp             \
    systemtap       \
    gptfdisk        \
    rng-tools       \
    apt-openstlinux \
    bzip2           \
    tar             \
    wget            \
    xz              \
    cracklib        \
    db              \
    sqlite3         \
    rt-tests        \
    "

SUMMARY_packagegroup-framework-tools-kernel = "Framework tools components for kernel"
RDEPENDS_packagegroup-framework-tools-kernel = "\
    pciutils        \
    cpufrequtils    \
    sysfsutils      \
    dosfstools      \
    mmc-utils       \
    blktool         \
    mtd-utils-ubifs \
    sysprof         \
    "

SUMMARY_packagegroup-framework-tools-network = "Framework tools components for network"
RDEPENDS_packagegroup-framework-tools-network = "\
    tcpdump         \
    packagegroup-core-full-cmdline-extended \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'iw', '', d)}                       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wpa-supplicant', '', d)}           \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'hostapd', '', d)}                  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wireless-regdb-static', '', d)}    \
    openssh-sftp    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'dhcp-client', '', d)}                       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-networkd-configuration', '', d)}    \
    usbip uhubctl   \
    bridge-utils    \
    "

SUMMARY_packagegroup-framework-tools-audio = "Framework tools components for audio"
RDEPENDS_packagegroup-framework-tools-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)}                     \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-server', '', d)}              \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-misc', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-module-combine-sink', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-discover', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-policy', '', d)}   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-device', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-discover', '', d)}    \
    "

SUMMARY_packagegroup-framework-tools-ui = "Framework tools components for ui"
RDEPENDS_packagegroup-framework-tools-ui = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xvinfo', '', d)}    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'glmark2', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'netdata', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'lmsensors-libsensors lmsensors-sensors', '', d)} \
    "

SUMMARY_packagegroup-framework-tools-python3 = "Framework tools components for python3"
RDEPENDS_packagegroup-framework-tools-python3 = "\
    python3-datetime    \
    python3-dateutil    \
    python3-distutils   \
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
    "
