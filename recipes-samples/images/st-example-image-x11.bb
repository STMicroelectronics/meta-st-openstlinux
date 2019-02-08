SUMMARY = "ST example of image based on X11."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image distro_features_check

# let's make sure we have a good image..
REQUIRED_DISTRO_FEATURES = "x11"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += "splash package-management x11-base x11-sato ssh-server-dropbear hwcodecs tools-profile"

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
# Display part addons: X11
#
IMAGE_X11_DISPLAY_PART = " \
    xf86-video-modesetting \
    xkbcomp \
    libxcb \
    libxcursor \
    xf86-input-mouse \
    xf86-input-keyboard \
    xterm \
    xinput \
    xeyes \
    xclock \
    xorg-minimal-fonts \
    xinit \
    \
    encodings \
    font-alias \
    font-util \
    mkfontdir \
    mkfontscale \
    \
    libxkbfile \
    "

#
# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    systemd-networkd-configuration \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
    \
    packagegroup-framework-tools-core-base      \
    packagegroup-framework-tools-kernel-base    \
    packagegroup-framework-tools-network-base   \
    packagegroup-framework-tools-audio-base     \
    packagegroup-framework-tools-ui-base        \
    packagegroup-framework-tools-python2-base   \
    packagegroup-framework-tools-python3-base   \
    \
    packagegroup-framework-tools-core    \
    packagegroup-framework-tools-kernel  \
    packagegroup-framework-tools-network \
    packagegroup-framework-tools-audio   \
    packagegroup-framework-tools-ui      \
    packagegroup-framework-tools-python2 \
    packagegroup-framework-tools-python3 \
    \
    packagegroup-core-eclipse-debug      \
    \
    packagegroup-core-x11-sato-games     \
    \
    ${IMAGE_DISPLAY_PART}               \
    ${IMAGE_MM_PART}                    \
    \
    ${IMAGE_X11_DISPLAY_PART}           \
    "
