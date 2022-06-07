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

LOCALCONF_VERSION = "2"
LAYER_CONF_VERSION ?= "7"

# =========================================================================
# Set default distro naming
# =========================================================================
require openstlinux-default-naming.inc

# =========================================================================
# Enable uninative support
# =========================================================================
require conf/distro/include/no-static-libs.inc
require conf/distro/include/yocto-uninative.inc
INHERIT += "uninative"

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
DISTRO_FEATURES += "pci"
DISTRO_FEATURES += "wifi"
DISTRO_FEATURES += "nfs"
DISTRO_FEATURES += "usbgadget"
DISTRO_FEATURES += "usbhost"
DISTRO_FEATURES += "xattr"
DISTRO_FEATURES += "zeroconf"
DISTRO_FEATURES += "bluetooth"
DISTRO_FEATURES += "bluez5"

# add support of gstreamer
DISTRO_FEATURES:append = " gstreamer "

# add support of optee
DISTRO_FEATURES:append = " optee "

# add support of splashscreen
DISTRO_FEATURES:append = " splashscreen "

# add support of wayland
DISTRO_FEATURES:append = " wayland pam "

# add support of X11
DISTRO_FEATURES:append = " x11 "

# add support of KDE (since OE thud version)
DISTRO_FEATURES:append = " kde "

# add support of systemd
DISTRO_FEATURES:append = " systemd polkit "

# add support of efi
DISTRO_FEATURES:append = " efi "

# add support of InitRD installation package
DISTRO_FEATURES:append = " initrd "

# add support of autoresize through InitRD
DISTRO_FEATURES:append = " autoresize "

# add support of tpm2
#DISTRO_FEATURES:append = " tpm2 "

# Disabling pulseaudio
#DISTRO_FEATURES_BACKFILL_CONSIDERED += "pulseaudio"
DISTRO_FEATURES:append = "pulseaudio"

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
IMAGE_LINGUAS = "en-us en-gb"

LICENSE_FLAGS_ACCEPTED += " non-commercial commercial"

# X11 addons
DISTRO_EXTRA_RDEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xf86-video-modesetting', '', d)} "

# INITRD addons to image
DISTRO_EXTRA_RRECOMMENDS:append = " ${@bb.utils.contains('COMBINED_FEATURES', 'initrd', '${INITRD_PACKAGE}', '', d)} "
