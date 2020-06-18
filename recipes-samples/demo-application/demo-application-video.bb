DESCRIPTION = "Add support of camera preview on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher event-gtk-player"

PV = "2.0"

SRC_URI = " \
    file://Video_playback_logo.png \
    file://ST2297_visionv3.webm \
    file://launch_video.sh \
    file://020-video.yaml \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/video/bin
    install -d ${D}${prefix}/local/demo/application/video/pictures
    install -d ${D}${prefix}/local/demo/media

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/video/pictures
    # script
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/video/bin
    # shaders
    install -m 0644 ${WORKDIR}/ST2297_visionv3.webm ${D}${prefix}/local/demo/media
}

FILES_${PN} += "${prefix}/local/demo/application/ ${prefix}/local/demo/media"
RDEPENDS_${PN} += "demo-launcher event-gtk-player"
