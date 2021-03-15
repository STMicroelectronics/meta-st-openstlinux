DESCRIPTION = "Add support of 3d Cube application on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "weston-cube demo-launcher"

PV = "3.0"
SRC_URI = " \
    file://100-3d-cube.yaml \
    file://101-3d-cube-shader.yaml \
    file://105-3d-cube-picture-shader.yaml \
    file://110-3d-cube-video.yaml \
    file://111-3d-cube-video-shader.yaml \
    file://115-3d_cube_camera.yaml \
    file://116-3d_cube_camera_shader.yaml \
    file://120-3d-cube-pictures-shader.yaml \
    file://launch_cube_3D_1_picture_shader.sh \
    file://launch_cube_3D_3_pictures_shader.sh \
    file://launch_cube_3D_camera.sh \
    file://launch_cube_3D_camera_shader.sh \
    file://launch_cube_3D_color.sh \
    file://launch_cube_3D_color_shader.sh \
    file://launch_cube_3D_video.sh \
    file://launch_cube_3D_video_shader.sh \
    file://ST153_cube_purple.png \
    \
    file://040-3d_cube.yaml \
    file://launch_cube_3D.sh \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/3d-cube/bin
    install -d ${D}${prefix}/local/demo/application/3d-cube/pictures
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/pictures

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install bin
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    install -m 0755 ${WORKDIR}/launch_cube_3D.sh ${D}${prefix}/local/demo/application/3d-cube/bin

    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/3d-cube-extra/pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/3d-cube/pictures
}

PACKAGES += "${PN}-extra"
FILES_${PN} = " \
    ${prefix}/local/demo/application/3d-cube \
    ${prefix}/local/demo/application/040-3d_cube.yaml \
    "
RDEPENDS_${PN} = "weston-cube demo-launcher"

FILES_${PN}-extra = " \
    ${prefix}/local/demo/application/3d-cube-extra \
    ${prefix}/local/demo/application/100-3d-cube.yaml \
    ${prefix}/local/demo/application/101-3d-cube-shader.yaml \
    ${prefix}/local/demo/application/105-3d-cube-picture-shader.yaml \
    ${prefix}/local/demo/application/110-3d-cube-video.yaml \
    ${prefix}/local/demo/application/111-3d-cube-video-shader.yaml \
    ${prefix}/local/demo/application/115-3d_cube_camera.yaml \
    ${prefix}/local/demo/application/116-3d_cube_camera_shader.yaml \
    ${prefix}/local/demo/application/120-3d-cube-pictures-shader.yaml \
    "
RDEPENDS_${PN}-extra = "${PN} weston-cube demo-launcher"
