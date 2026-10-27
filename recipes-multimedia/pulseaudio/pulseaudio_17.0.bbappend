FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG ?= "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'zeroconf', 'avahi', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', '3g', 'ofono', '', d)} \
                   ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6 systemd x11', d)} \
                   dbus gsettings \
                   "

PACKAGES =+ "${PN}-profile ${PN}-tools"
FILES:${PN}-profile += "/etc/profile.d"
FILES:${PN}-server:remove = "${bindir}/pactl"
FILES:${PN}-tools = "${bindir}/pactl"
RDEPENDS:pulseaudio-server += "${PN}-tools"
