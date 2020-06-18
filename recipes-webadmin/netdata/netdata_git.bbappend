FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI_append = " file://stm32.html "
SRC_URI_append = " file://python.d.conf "
SRC_URI_append = " file://kill_netdata "
SRC_URI_append = " file://charts.d.conf "
SRC_URI_append = " file://dashboard_info.js "
SRC_URI_append = " file://gpu.chart.py "

RDEPENDS_${PN}_append = " python3-multiprocessing "

do_install_append() {
    install -d ${D}${sysconfdir}/netdata
    install -d ${D}${datadir}/netdata/web
    install -d ${D}${bindir}/netdata/web

    install -m 0644 ${WORKDIR}/stm32.html ${D}${datadir}/netdata/web/
    install -m 0644 ${WORKDIR}/python.d.conf ${D}${sysconfdir}/netdata/
    install -m 0755 ${WORKDIR}/kill_netdata ${D}${bindir}/

    install -m 0644 ${WORKDIR}/charts.d.conf ${D}${sysconfdir}/netdata/
    install -m 0644 ${WORKDIR}/dashboard_info.js ${D}${datadir}/netdata/web/

    install -d ${D}${libexecdir}/netdata/python.d/
    install -m 0644 ${WORKDIR}/gpu.chart.py ${D}${libexecdir}/netdata/python.d/
}
