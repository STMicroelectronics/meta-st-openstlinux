DESCRIPTION = "Add support of 3d Cube application on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "weston-cube demo-launcher"

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
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/pictures

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install bin
    install -m 0755 ${WORKDIR}/*.sh ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/3d-cube-extra/pictures
}

FILES_${PN} += "${prefix}/local/demo/application/"
