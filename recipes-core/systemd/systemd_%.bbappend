PACKAGECONFIG:append = " \
    firstboot \
    coredump \
    iptc \
    oomd \
    "


NTP_SERVERS ??= ""
EXTRA_OEMESON += " ${@ '-Dntp-servers="${NTP_SERVERS}"' if '${NTP_SERVERS}' else ''}"

do_install:append() {
    #Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator
}

