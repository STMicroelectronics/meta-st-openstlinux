inherit python3native

PACKAGECONFIG = "${@bb.utils.filter('DISTRO_FEATURES', 'wayland', d)}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += "wayland-native"

CTSDIR = "/usr/local/${BPN}"

do_configure:prepend() {
    # Used to download cmake dependencies when behind a proxy
    if [ -n "${http_proxy}" ]; then
        export HTTP_PROXY=${http_proxy}
    fi
    if [ -n "${https_proxy}" ]; then
        export HTTPS_PROXY=${https_proxy}
    fi
}
