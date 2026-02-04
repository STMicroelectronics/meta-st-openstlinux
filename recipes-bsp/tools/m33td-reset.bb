SUMMARY = "Service to reboot/poweroff from Rpmsg/M33"
HOMEPAGE = "www.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"
DEPENDS = "rpmsg-tools"

SRC_URI = " \
    file://remote_shutdown.service \
    file://remote_shutdown.sh \
"
S = "${WORKDIR}"

inherit systemd

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','remote_shutdown.service ','',d)}"

do_configure[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/remote_shutdown.sh ${D}${bindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -m 0755 ${S}/remote_shutdown.service ${D}${systemd_unitdir}/system/
    fi
}

FILES:${PN} += "${systemd_unitdir}/system"
RDEPENDS:${PN} += "bash"
