DESCRIPTION = "Add support of netdata/hotspot wifi on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher demo-hotspot-wifi qrenc"

PV = "2.0"

SRC_URI = " \
    file://000-netdata.yaml \
    file://build_qrcode.sh \
    file://__init__.py \
    file://netdata.py \
    file://netdata-icon-192x192.png \
    file://hostapd \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/netdata/bin
    install -d ${D}${prefix}/local/demo/application/netdata/pictures

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install bin
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/netdata/bin
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/netdata/pictures
    # python script
    install -m 0755 ${WORKDIR}/*.py ${D}${prefix}/local/demo/application/netdata/

    # for wifi hotspot
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/hostapd ${D}${sysconfdir}/default
}
RDEPENDS_${PN} += "python3-core python3-pygobject gtk+3 python3-threading demo-launcher demo-hotspot-wifi qrenc"
FILES_${PN} += "${sysconfdir}/default ${prefix}/local/demo/application/"
