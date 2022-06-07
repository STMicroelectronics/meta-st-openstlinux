FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG ??= "${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'alsa', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)} \
                   gstreamer \
                   "

SRC_URI += "file://0001-remove-gpu_vivante-test.patch"
