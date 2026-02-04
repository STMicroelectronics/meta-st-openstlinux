SUMMARY = "STM32MP sysctl addons configuration"
HOMEPAGE = "www.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = "file://72-openstlinux.conf"

do_install() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/72-openstlinux.conf ${D}${sysconfdir}/sysctl.d
}

