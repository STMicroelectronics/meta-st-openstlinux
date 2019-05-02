FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'pulseaudio x11', d)} \
    bz2 cairo flac gdk-pixbuf gudev jpeg lame libpng mpg123 soup speex taglib v4l2 zlib \
    libv4l2 \
    ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk', '', d)} \
"

EXTRA_OECONF += " \
    --enable-v4l2-probe \
    "

do_configure_prepend() {
    ${S}/autogen.sh --noconfigure
}
