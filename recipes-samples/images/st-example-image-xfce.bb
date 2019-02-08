SUMMARY = "ST example of image based on XFCE framework."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image distro_features_check extrausers

# let's make sure we have a good image..
CONFLICT_DISTRO_FEATURES = "wayland"
REQUIRED_DISTRO_FEATURES = "x11"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += "splash package-management ssh-server-dropbear hwcodecs"

# Define to null ROOTFS_MAXSIZE to avoid partition size restriction
IMAGE_ROOTFS_MAXSIZE = ""

# make sure we boot to desktop
# by default and without x11-base in IMAGE_FEATURES we default to multi-user.target
SYSTEMD_DEFAULT_TARGET = "graphical.target"

#
# Multimedia part addons
#
IMAGE_MM_PART = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gstreamer', 'packagegroup-gstreamer1-0', '', d)} \
    tiff \
    libv4l \
    rc-keymaps \
    "

#
# Display part addons
#
IMAGE_DISPLAY_PART = " \
    fb-test         \
    libdrm          \
    libdrm-tests    \
    "

#
# XFCE part addons
#
#
IMAGE_XFCE_PART = " \
    packagegroup-xfce-base \
    \
    gnome-bluetooth \
    \
    lxdm \
    xfce4-netload-plugin \
    xfce4-wavelan-plugin \
    xfce4-cpugraph-plugin \
    xfce4-cpufreq-plugin \
    xfce4-systemload-plugin \
    "

IMAGE_X11_PART = " \
    openbox \
    openbox-theme-clearlooks \
    xclock \
    xterm \
    "

#
# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-core-x11           \
    systemd-networkd-configuration  \
    \
    packagegroup-core-boot          \
    \
    packagegroup-framework-tools-core-base      \
    packagegroup-framework-tools-kernel-base    \
    packagegroup-framework-tools-network-base   \
    packagegroup-framework-tools-audio-base     \
    packagegroup-framework-tools-ui-base        \
    packagegroup-framework-tools-python2-base   \
    packagegroup-framework-tools-python3-base   \
    \
    packagegroup-framework-tools-core       \
    packagegroup-framework-tools-kernel     \
    packagegroup-framework-tools-network    \
    packagegroup-framework-tools-audio      \
    packagegroup-framework-tools-ui         \
    packagegroup-framework-tools-python2    \
    packagegroup-framework-tools-python3    \
    \
    packagegroup-core-eclipse-debug         \
    \
    \
    ${IMAGE_DISPLAY_PART}   \
    ${IMAGE_MM_PART}        \
    ${IMAGE_X11_PART}       \
    ${IMAGE_XFCE_PART}      \
    "

EXTRA_USERS_PARAMS = "\
useradd -p '' st; \
"
