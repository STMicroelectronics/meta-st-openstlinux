FILESEXTRAPATHS_prepend_stm32mpcommon := "${THISDIR}/${PN}:"

SRC_URI_append_stm32mpcommon = " \
    file://0001-Allow-to-get-hdmi-output-with-several-outputs.patch \
    file://0002-Force-to-close-all-output.patch \
    "
