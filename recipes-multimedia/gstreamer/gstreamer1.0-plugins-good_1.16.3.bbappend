FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'pulseaudio x11', d)} \
    bz2 cairo flac gdk-pixbuf gudev jpeg lame libpng mpg123 soup speex taglib v4l2 \
    libv4l2 \
    ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk', '', d)} \
"

EXTRA_OEMESON += " \
    -Dv4l2-probe=enabled \
    -Dv4l2-libv4l2=enabled \
    "

do_configure_prepend() {
    ${S}/autogen.sh --noconfigure
}
