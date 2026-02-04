SUMMARY = "Add support of M33 shutdown/reset on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher"

PV = "1.0"

SRC_URI = " \
    file://linux_black.png \
    file://linux_black_shutdown.png \
    file://pc_gui_shutdown.png \
    file://launch_m33_reboot.sh \
    file://075-m33-reboot.yaml \
    \
    file://m33_shutdown.desktop \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/gtk-application
    install -d ${D}${prefix}/local/demo/application/m33/bin
    install -d ${D}${prefix}/local/demo/application/m33/pictures

    # desktop application
    install -d ${D}${datadir}/applications
    install -m 0644 ${WORKDIR}/m33_shutdown.desktop ${D}${datadir}/applications

    # picture for desktop application
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${WORKDIR}/linux_black_shutdown.png ${D}${datadir}/pixmaps

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/gtk-application/
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/m33/pictures
    # script
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/m33/bin
}

FILES:${PN} += "${prefix}/local/demo ${datadir}/applications ${datadir}/pixmaps"
RDEPENDS:${PN} += "demo-launcher"
