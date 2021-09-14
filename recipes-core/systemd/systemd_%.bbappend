PACKAGECONFIG_append = " \
    firstboot \
    coredump \
    iptc \
    "

do_install_append() {
    #Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator
}

