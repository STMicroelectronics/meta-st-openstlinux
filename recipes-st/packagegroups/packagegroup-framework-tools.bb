DESCRIPTION = "Frameworks components"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

PACKAGES = "\
    packagegroup-framework-tools-core-base \
    packagegroup-framework-tools-kernel-base \
    packagegroup-framework-tools-network-base \
    packagegroup-framework-tools-audio-base \
    packagegroup-framework-tools-ui-base \
    packagegroup-framework-tools-python2-base \
    packagegroup-framework-tools-python3-base \
    \
    packagegroup-framework-tools-core \
    packagegroup-framework-tools-kernel \
    packagegroup-framework-tools-network \
    packagegroup-framework-tools-audio \
    packagegroup-framework-tools-ui \
    packagegroup-framework-tools-python2 \
    packagegroup-framework-tools-python3 \
    \
    packagegroup-framework-tools-core-extra \
    packagegroup-framework-tools-kernel-extra \
    packagegroup-framework-tools-network-extra \
    packagegroup-framework-tools-audio-extra \
    packagegroup-framework-tools-ui-extra \
    packagegroup-framework-tools-python2-extra \
    packagegroup-framework-tools-python3-extra \
    "

PROVIDES = "${PACKAGES}"

RDEPENDS_packagegroup-framework-tools-core-base = "\
    ckermit         \
    coreutils       \
    libiio-iiod     \
    libiio-tests    \
    lrzsz           \
    lsb             \
    libgpiod        \
    ${@bb.utils.contains('DISTRO_FEATURES', 'usbgadget', 'usbotg-gadget-config', '', d)} \
    "
RDEPENDS_packagegroup-framework-tools-core = "\
    grep            \
    util-linux      \
    util-linux-lscpu \
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
    lsb-openstlinux \
    rng-tools       \
    "
RDEPENDS_packagegroup-framework-tools-core-extra = "\
    tslib-calibrate \
    pointercal      \
    \
    acl             \
    bzip2           \
    cronie          \
    ltrace          \
    "

RDEPENDS_packagegroup-framework-tools-kernel-base = "\
    can-utils       \
    i2c-tools       \
    strace          \
    usbutils        \
    \
    evtest          \
    memtester       \
    mtd-utils       \
    v4l-utils       \
    "
RDEPENDS_packagegroup-framework-tools-kernel = "\
    pciutils        \
    cpufrequtils    \
    sysfsutils      \
    dosfstools      \
    mmc-utils       \
    blktool         \
    mtd-utils-ubifs \
    "
RDEPENDS_packagegroup-framework-tools-kernel-extra = "\
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
    lirc \
    "

RDEPENDS_packagegroup-framework-tools-network-base = "\
    ethtool         \
    iproute2        \
    "
RDEPENDS_packagegroup-framework-tools-network = "\
    tcpdump         \
    packagegroup-core-full-cmdline-extended \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'iw', '', d)}              \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wpa-supplicant', '', d)}  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'hostapd', '', d)}         \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wireless-regdb-static', '', d)}         \
    openssh-sftp    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'dhcp-client', '', d)} \
    curl \
    "
RDEPENDS_packagegroup-framework-tools-network-extra = "\
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

RDEPENDS_packagegroup-framework-tools-audio-base = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'libasound alsa-conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-utils', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-plugins', '', d)} \
    "
RDEPENDS_packagegroup-framework-tools-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-server', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-misc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-module-combine-sink', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-discover', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-policy', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-device', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-discover', '', d)} \
    "
RDEPENDS_packagegroup-framework-tools-audio-extra = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa-utils-aplay', '', d)} \
    "

RDEPENDS_packagegroup-framework-tools-ui-base = "\
    "
RDEPENDS_packagegroup-framework-tools-ui = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xvinfo', '', d)}    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'glmark2', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'netdata', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', 'lmsensors-libsensors lmsensors-sensors', '', d)} \
    "
RDEPENDS_packagegroup-framework-tools-ui-extra = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xvideo-tests', '', d)}  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11perf', '', d)}   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'gtkperf', '', d)}   \
    "

RDEPENDS_packagegroup-framework-tools-python2-base = "\
    "
RDEPENDS_packagegroup-framework-tools-python2 = "\
      \
    "
RDEPENDS_packagegroup-framework-tools-python2-extra = "\
    python-lxml         \
    python-modules      \
    python-nose         \
    python-pip          \
    python-pkgutil      \
    python-pytest       \
    python-setuptools   \
    python-unittest     \
    "

RDEPENDS_packagegroup-framework-tools-python3-base = "\
    "
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
RDEPENDS_packagegroup-framework-tools-python3-extra = "\
    python3-pip         \
    python3-pytest      \
    "

