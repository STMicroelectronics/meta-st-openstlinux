FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:class-nativesdk = " file://0001-STRING.H-aarch32.patch"
EXTRA_OECONF:append:class-nativesdk = " --disable-nls GL_COND_OBJ_MEMSET_EXPLICIT=yes "



