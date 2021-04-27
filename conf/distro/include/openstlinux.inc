# Distribution definition for openstlinux

# from dev manual:
# Your configuration file needs to set the following variables:
#
#      DISTRO_NAME [required]
#      DISTRO_VERSION [required]
#      DISTRO_FEATURES [required if creating from scratch]
#      DISTRO_EXTRA_RDEPENDS [optional]
#      DISTRO_EXTRA_RRECOMMENDS [optional]
#      TCLIBC [required if creating from scratch]

# =========================================================================
# Enable uninative support
# =========================================================================
require conf/distro/include/no-static-libs.inc
require conf/distro/include/yocto-uninative.inc
INHERIT += "uninative"

# Init OPENSTLINUX_RELEASE flag to snapshot
OPENSTLINUX_RELEASE ??= "snapshot"

DISTRO = "openstlinux"
DISTRO_NAME = "ST OpenSTLinux (A Yocto Project Based Distro)"
DISTRO_VERSION = "3.1-${@bb.utils.contains('OPENSTLINUX_RELEASE', 'snapshot', 'snapshot-${DATE}', '${OPENSTLINUX_RELEASE}', d)}"
# Don't include the DATE variable in the sstate package signatures
DISTRO_VERSION[vardepsexclude] = "DATE"
DISTRO_CODENAME = "dunfell"

# Warning: SDK_VENDOR does not contains a valid OS/ARCH name like : linux, arm
SDK_VENDOR = "-ostl_sdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
# Don't include the DATE variable in the sstate package signatures
SDK_VERSION[vardepsexclude] = "DATE"

MAINTAINER = "Christophe Priouzeau <christophe.priouzeau@st.com>"

# Warning: TARGET_VENDOR does not contains a valid OS/ARCH name like : linux, arm
TARGET_VENDOR = "-ostl"

# Append distro name to each image name
IMAGE_BASENAME_append = "-${DISTRO}"

# Add image name for generated SDK and set default SDK install folder
SDK_NAME = "${IMAGE_LINK_NAME}-${SDK_ARCH}"
SDKPATH = "/opt/st/${MACHINE}/${SDK_VERSION}"
# Don't include the DATE variable in the sstate package signatures
SDKPATH[vardepsexclude] = "DATE"

LOCALCONF_VERSION = "1"
LAYER_CONF_VERSION ?= "7"

IMAGE_LINGUAS = "en-us en-gb"

# =========================================================================
# DISTRO features
# =========================================================================
DISTRO_FEATURES  = "alsa"
DISTRO_FEATURES += "argp"
DISTRO_FEATURES += "ext2"
DISTRO_FEATURES += "ext4"
DISTRO_FEATURES += "largefile"
DISTRO_FEATURES += "ipv4"
DISTRO_FEATURES += "ipv6"
DISTRO_FEATURES += "multiarch"
DISTRO_FEATURES += "wifi"
DISTRO_FEATURES += "nfs"
DISTRO_FEATURES += "usbgadget"
DISTRO_FEATURES += "usbhost"
DISTRO_FEATURES += "xattr"
DISTRO_FEATURES += "zeroconf"
DISTRO_FEATURES += "bluetooth"
DISTRO_FEATURES += "bluez5"
DISTRO_FEATURES += "${DISTRO_FEATURES_LIBC}"

# add support of gstreamer
DISTRO_FEATURES_append = " gstreamer "

# add support of optee
DISTRO_FEATURES_append = " optee "

# add support of splashscreen
DISTRO_FEATURES_append = " splashscreen "

# add support of wayland
DISTRO_FEATURES_append = " wayland pam "

# add support of X11
DISTRO_FEATURES_append = " x11 "

# add support of KDE (since OE thud version)
DISTRO_FEATURES_append = " kde "

# add support of systemd
DISTRO_FEATURES_append = " systemd polkit "

# add support of efi
DISTRO_FEATURES_append = " efi "

# add support of InitRD installation package
DISTRO_FEATURES_append = " initrd "

# add support of autoresize through InitRD
DISTRO_FEATURES_append = " autoresize "

# add support of tpm2
#DISTRO_FEATURES_append = " tpm2 "

# Disabling pulseaudio
#DISTRO_FEATURES_BACKFILL_CONSIDERED += "pulseaudio"
DISTRO_FEATURES_append = "pulseaudio"

# Disabling sysvinit
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"

VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"

# =========================================================================
# Preferred version
# =========================================================================

# v4l-utils
#PREFERRED_VERSION_v4l-utils ?= "1.6.2"

# =========================================================================
# IMAGE addons
# =========================================================================
LICENSE_FLAGS_WHITELIST += " non-commercial commercial"

# X11 addons
DISTRO_EXTRA_RDEPENDS_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xf86-video-modesetting', '', d)} "

# INITRD addons to image
DISTRO_EXTRA_RRECOMMENDS_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'initrd', '${INITRD_PACKAGE}', '', d)} "
