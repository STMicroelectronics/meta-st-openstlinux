# Same PACKAGECONFIG than community except that GTK backend is used when DISTRO_FEATURES also contains "wayland"
PACKAGECONFIG = "gapi python3 eigen jpeg png tiff v4l libv4l gstreamer samples tbb gphoto2 \
    ${@bb.utils.contains("DISTRO_FEATURES", "x11", "gtk", "", d)} \
    \
    ${@bb.utils.contains("DISTRO_FEATURES", "wayland", "gtk", "", d)} \
    "
