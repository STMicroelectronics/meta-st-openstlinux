#@DESCRIPTION: ST default distro providers

PREFERRED_PROVIDER_libevent = "libevent-fb"
PREFERRED_PROVIDER_jpeg = "libjpeg-turbo"
PREFERRED_PROVIDER_jpeg-native = "libjpeg-turbo-native"

#--------------------------
# Preferred provider
# for openvt tools
PREFERRED_PROVIDER_console-tools = "kbd"

#--------------------------
# Preferred provider
# splash
SPLASH = "${@bb.utils.contains('COMBINED_FEATURES', 'splashscreen', 'psplash-drm', '', d)}"
PREFERRED_PROVIDER_virtual/psplash = "${@bb.utils.contains('COMBINED_FEATURES', 'splashscreen', 'psplash-drm', '', d)}"

#--------------------------
# Autoresize file system through InitRD
AUTORESIZE = "st-initrd"
INITRD_IMAGE = "st-image-resize-initrd"
INITRD_SHORTNAME = "uInitrd"
