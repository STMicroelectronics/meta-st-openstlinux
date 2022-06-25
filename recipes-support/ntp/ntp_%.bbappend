
SYSTEMD_AUTO_ENABLE:ntp = "disable"
SYSTEMD_AUTO_ENABLE:ntpdate = "disable"
SYSTEMD_AUTO_ENABLE:sntp = "disable"

do_configure:prepend() {
    for ns in ${NTP_SERVERS}; do
        grep -q ${ns} ${WORKDIR}/ntp.conf || echo "server ${ns}" >> ${WORKDIR}/ntp.conf
    done
}

