SUMMARY = "OpenSTLinux weston image with basic Wayland support (if enable in distro)."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image distro_features_check

# let's make sure we have a good image...
REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += "\
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
    tools-profile \
    eclipse-debug \
    "

#
# Multimedia part addons
#
IMAGE_MM_PART = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gstreamer', 'packagegroup-gstreamer1-0', '', d)} \
    tiff \
    libv4l \
    rc-keymaps \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'kmscube', '', d)} \
    "

#
# Display part addons
#
IMAGE_DISPLAY_PART = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston weston-conf weston-init weston-examples', '', d)} \
    fb-test         \
    libdrm          \
    libdrm-tests    \
    \
    gtk+3 \
    gtk+3-demo \
    "

#
# Display part addons: X11 via Xwayland
#
IMAGE_X11_XWAYLAND_DISPLAY_PART = " \
    weston-xwayland \
    xserver-xorg-xwayland \
    xkbcomp \
    libxcb \
    libxcursor \
    xf86-input-evdev \
    xf86-input-mouse \
    xf86-input-keyboard \
    xterm \
    xinput \
    xeyes \
    xclock \
    xorg-minimal-fonts \
    libx11 libx11-locale \
    "

IMAGE_X11_DISPLAY_PART = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', '${IMAGE_X11_XWAYLAND_DISPLAY_PART}', '', d)} \
    "

#
# Optee part addons
#
IMAGE_OPTEE_PART = " \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)} \
    "

#
# TPM part addons
#
IMAGE_TPM_PART = " \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    "


#
# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-networkd-configuration', '', d)} \
    \
    packagegroup-framework-tools-core-base      \
    packagegroup-framework-tools-kernel-base    \
    packagegroup-framework-tools-network-base   \
    packagegroup-framework-tools-audio-base     \
    packagegroup-framework-tools-ui-base        \
    packagegroup-framework-tools-python2-base   \
    packagegroup-framework-tools-python3-base   \
    \
    packagegroup-framework-tools-core           \
    packagegroup-framework-tools-kernel         \
    packagegroup-framework-tools-network        \
    packagegroup-framework-tools-audio          \
    packagegroup-framework-tools-ui             \
    packagegroup-framework-tools-python2        \
    packagegroup-framework-tools-python3        \
    \
    ${IMAGE_DISPLAY_PART}                       \
    ${IMAGE_MM_PART}                            \
    \
    ${IMAGE_X11_DISPLAY_PART}                   \
    \
    ${IMAGE_OPTEE_PART}                         \
    \
    ${IMAGE_TPM_PART}                           \
    "
