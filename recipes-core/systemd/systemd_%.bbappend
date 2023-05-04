PACKAGECONFIG:append = " \
    firstboot \
    coredump \
    iptc \
    "

PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'polkit', '', 'polkit_hostnamed_fallback', d)} "

WATCHDOG_TIMEOUT = "32"

NTP_SERVERS ??= ""
EXTRA_OEMESON += " ${@ '-Dntp-servers="${NTP_SERVERS}"' if '${NTP_SERVERS}' else ''}"

do_install:append() {
    #Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator
}

