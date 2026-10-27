SUMMARY = "Add support of camera preview on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

LICENSE:stm32mp2common = "BSD-3-Clause"

DEPENDS = "demo-launcher event-gtk-player wayland-utils"
DEPENDS:append:stm32mp2common = " dcmipp-isp-ctrl "

PV = "2.0"

SUFFIX_FOR_FILE ?= "_mp1"
SUFFIX_FOR_FILE:stm32mp1common = "_mp1"
SUFFIX_FOR_FILE:stm32mp2common = "_mp25"

SRC_URI = " \
    file://launch_camera.sh \
    file://launch_camera_preview${SUFFIX_FOR_FILE}.sh \
    file://launch_camera_control${SUFFIX_FOR_FILE}.sh \
    file://stop_camera.sh \
    file://edge_InvertLuma.fs \
    file://ST1077_webcam_dark_blue.png \
    file://010-camera${SUFFIX_FOR_FILE}.yaml \
    file://check_camera_preview${SUFFIX_FOR_FILE}.sh \
    \
    file://camera_preview.desktop \
    file://camera_preview.png \
    "

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/gtk-application
    install -d ${D}${prefix}/local/demo/application/camera/bin
    install -d ${D}${prefix}/local/demo/application/camera/pictures
    install -d ${D}${prefix}/local/demo/application/camera/shaders

    # update the launch_camera.sh script with correct ${SUFFIX_FOR_FILE} value
    sed -i -e 's,@suffix_for_file@,${SUFFIX_FOR_FILE},g' ${UNPACKDIR}/launch_camera.sh

    # desktop application
    install -d ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/camera_preview.desktop ${D}${datadir}/applications

    # picture for desktop application
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${UNPACKDIR}/camera_preview.png ${D}${datadir}/pixmaps

    # install yaml file
    install -m 0644 ${UNPACKDIR}/*.yaml ${D}${prefix}/local/demo/gtk-application/
    # install pictures
    install -m 0644 ${UNPACKDIR}/*.png ${D}${prefix}/local/demo/application/camera/pictures
    # script
    install -m 0755 ${UNPACKDIR}/*.sh ${D}${prefix}/local/demo/application/camera/bin
    # shaders
    install -m 0644 ${UNPACKDIR}/*.fs ${D}${prefix}/local/demo/application/camera/shaders
}

FILES:${PN} += "${prefix}/local/demo ${datadir}/applications ${datadir}/pixmaps"
RDEPENDS:${PN} += "event-gtk-player demo-launcher bash"
RDEPENDS:${PN}:append:stm32mp2common = " dcmipp-isp-ctrl "

