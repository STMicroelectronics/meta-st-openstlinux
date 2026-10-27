FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

SRC_URI:append = " file://python.d.conf "
SRC_URI:append = " file://charts.d.conf "

SRC_URI:append = " file://kill_netdata "
SRC_URI:append = " file://gpu.chart.py "

SRC_URI:append = " file://netdata.service "

SRC_URI:append:stm32mp1common = " file://stm32mp15.html "
SRC_URI:append:stm32mp1common = " file://stm32mp13.html "
SRC_URI:append:stm32mp2common = " file://stm32mp21.html "
SRC_URI:append:stm32mp2common = " file://stm32mp23.html "
SRC_URI:append:stm32mp2common = " file://stm32mp25.html "
SRC_URI:append:stm32mp2common = " file://fps.chart.py"

RDEPENDS:${PN}:append = " python3-multiprocessing "

PACKAGECONFIG ?= "openssl ${@bb.utils.filter('DISTRO_FEATURES', 'systemd', d)}"

PACKAGECONFIG:append = " webui_v1 "
#PACKAGECONFIG:append = " go "

EXTRA_OECMAKE += " \
    -DENABLE_LIBBACKTRACE=OFF \
    -DENABLE_LIBUNWIND=OFF \
    -DENABLE_WEBRTC=OFF \
    -DENABLE_NETDATA_JOURNAL_FILE_READER=OFF \
    -DENABLE_PLUGIN_OTEL=OFF \
    -DENABLE_PLUGIN_FREEIPMI=OFF \
    -DENABLE_PLUGIN_EBPF=OFF \
    -DENABLE_PLUGIN_LOCAL_LISTENERS=OFF \
    -DENABLE_PLUGIN_NFACCT=OFF \
    -DENABLE_PLUGIN_PERF=OFF \
    -DENABLE_PLUGIN_SLABINFO=OFF \
    -DENABLE_EXPORTER_PROMETHEUS_REMOTE_WRITE=OFF \
    -DENABLE_EXPORTER_MONGODB=OFF \
    -DENABLE_ML=OFF \
    \
    -DENABLE_DASHBOARD=OFF \
    "

# remove netdata-updater
SYSTEMD_SERVICE:${PN}:remove = "netdata-updater.service netdata-updater.timer"

# do_compile:prepend() {
#     # Used to download cmake dependencies when behind a proxy
#     if [ -n "${http_proxy}" ]; then
#         export HTTP_PROXY=${http_proxy}
#     fi
#     if [ -n "${https_proxy}" ]; then
#         export HTTPS_PROXY=${https_proxy}
#     fi
# }

do_install:append() {
    install -d ${D}${sysconfdir}/netdata
    install -d ${D}${datadir}/netdata/web
    install -d ${D}${bindir}/netdata/web

    install -m 0644 ${UNPACKDIR}/python.d.conf ${D}${sysconfdir}/netdata/
    install -m 0644 ${UNPACKDIR}/charts.d.conf ${D}${sysconfdir}/netdata/

    install -m 0755 ${UNPACKDIR}/kill_netdata ${D}${bindir}/

    install -d ${D}${libexecdir}/netdata/python.d/
    install -m 0644 ${UNPACKDIR}/gpu.chart.py ${D}${libexecdir}/netdata/python.d/

    install -m 0644 ${UNPACKDIR}/netdata.service ${D}${systemd_unitdir}/system

    # remove unused service: netdata-updater
    rm  ${D}${systemd_unitdir}/system/netdata-updater.service ${D}${systemd_unitdir}/system/netdata-updater.timer
}

do_install:append:stm32mp1common() {
    install -d ${D}${datadir}/netdata/web

    install -m 0644 ${UNPACKDIR}/stm32mp15.html ${D}${datadir}/netdata/web/
    install -m 0644 ${UNPACKDIR}/stm32mp13.html ${D}${datadir}/netdata/web/
}

do_install:append:stm32mp2common() {
    install -d ${D}${datadir}/netdata/web

    install -m 0644 ${UNPACKDIR}/stm32mp21.html ${D}${datadir}/netdata/web/
    install -m 0644 ${UNPACKDIR}/stm32mp23.html ${D}${datadir}/netdata/web/
    install -m 0644 ${UNPACKDIR}/stm32mp25.html ${D}${datadir}/netdata/web/

    install -d ${D}${libexecdir}/netdata/python.d/
    install -m 0644 ${UNPACKDIR}/fps.chart.py ${D}${libexecdir}/netdata/python.d/
}
INSANE_SKIP:${PN} += "buildpaths"
