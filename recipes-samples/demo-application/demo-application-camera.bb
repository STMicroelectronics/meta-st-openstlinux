DESCRIPTION = "Add support of camera preview on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher event-gtk-player"

PV = "2.0"

SRC_URI = " \
    file://launch_camera_preview.sh \
    file://stop_camera.sh \
    file://edge_InvertLuma.fs \
    file://ST1077_webcam_dark_blue.png \
    file://010-camera.yaml \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/camera/bin
    install -d ${D}${prefix}/local/demo/application/camera/pictures
    install -d ${D}${prefix}/local/demo/application/camera/shaders

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/camera/pictures
    # script
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/camera/bin
    # shaders
    install -m 0644 ${WORKDIR}/*.fs ${D}${prefix}/local/demo/application/camera/shaders
}

FILES_${PN} += "${prefix}/local/demo/application/"
RDEPENDS_${PN} += "event-gtk-player demo-launcher"
