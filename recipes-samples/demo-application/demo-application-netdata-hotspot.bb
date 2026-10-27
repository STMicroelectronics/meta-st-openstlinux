SUMMARY = "Add support of netdata/hotspot wifi on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher demo-hotspot-wifi qrenc"

PV = "2.0"

SRC_URI = " \
    file://000-netdata.yaml \
    file://launch_netdata.sh \
    file://build_qrcode.sh \
    file://__init__.py \
    file://netdata.py \
    file://netdata-icon-192x192.png \
    file://hostapd \
    file://wifi_start.sh \
    file://wifi_stop.sh \
    file://get_wlan_name.sh \
    file://get_wlan_state.sh \
    file://get_ethernet_ip.sh \
    \
    file://netdata.desktop \
    file://netdata.png \
    "

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/gtk-application
    install -d ${D}${prefix}/local/demo/application/netdata/bin
    install -d ${D}${prefix}/local/demo/application/netdata/pictures

    # desktop application
    install -d ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/netdata.desktop ${D}${datadir}/applications

    # picture for desktop application
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${UNPACKDIR}/netdata.png ${D}${datadir}/pixmaps

    # install yaml file
    install -m 0644 ${UNPACKDIR}/*.yaml ${D}${prefix}/local/demo/gtk-application/
    # install bin
    install -m 0755 ${UNPACKDIR}/*.sh ${D}${prefix}/local/demo/application/netdata/bin
    # install pictures
    install -m 0644 ${UNPACKDIR}/*.png ${D}${prefix}/local/demo/application/netdata/pictures
    # python script
    install -m 0755 ${UNPACKDIR}/*.py ${D}${prefix}/local/demo/application/netdata/

    # for wifi hotspot
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${UNPACKDIR}/hostapd ${D}${sysconfdir}/default
}
RDEPENDS:${PN} += "python3-core python3-pygobject gtk+3 python3-threading demo-launcher demo-hotspot-wifi qrenc"
FILES:${PN} += "${sysconfdir}/default ${prefix}/local/demo ${datadir}/applications ${datadir}/pixmaps"
