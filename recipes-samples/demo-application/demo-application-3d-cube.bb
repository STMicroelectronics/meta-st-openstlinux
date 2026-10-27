SUMMARY = "Add support of 3d Cube application on Demo Launcher"
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
    file://120-3d-cube-pictures-shader.yaml \
    file://launch_cube_3D_1_picture_shader.sh \
    file://launch_cube_3D_3_pictures_shader.sh \
    file://launch_cube_3D_camera.sh \
    file://launch_cube_3D_camera_shader.sh \
    file://launch_cube_3D_color.sh \
    file://launch_cube_3D_color_shader.sh \
    file://launch_cube_3D_video.sh \
    file://launch_cube_3D_video_shader.sh \
    file://check_presence_gpu.sh \
    file://ST153_cube_purple.png \
    file://ST20578_Label_OpenSTlinux_V.png \
    file://ST13028_Linux_picto_13.png \
    file://ST4439_ST_logo.png \
    \
    file://040-3d_cube.yaml \
    file://launch_cube_3D.sh \
    \
    file://cube_3d.desktop \
    file://cube_3d.png \
    "

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/gtk-application/
    install -d ${D}${prefix}/local/demo/application/3d-cube/bin
    install -d ${D}${prefix}/local/demo/application/3d-cube/pictures
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    install -d ${D}${prefix}/local/demo/application/3d-cube-extra/pictures

    # desktop application
    install -d ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/cube_3d.desktop ${D}${datadir}/applications

    # picture for desktop application
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${UNPACKDIR}/cube_3d.png ${D}${datadir}/pixmaps

    # install yaml file
    install -m 0644 ${UNPACKDIR}/*.yaml ${D}${prefix}/local/demo/gtk-application/

    # install bin
    install -m 0755 ${UNPACKDIR}/*.sh ${D}${prefix}/local/demo/application/3d-cube-extra/bin
    install -m 0755 ${UNPACKDIR}/launch_cube_3D.sh ${D}${prefix}/local/demo/application/3d-cube/bin
    install -m 0755 ${UNPACKDIR}/check_presence_gpu.sh ${D}${prefix}/local/demo/application/3d-cube/bin

    # install pictures
    install -m 0644 ${UNPACKDIR}/*.png ${D}${prefix}/local/demo/application/3d-cube-extra/pictures
    install -m 0644 ${UNPACKDIR}/*.png ${D}${prefix}/local/demo/application/3d-cube/pictures
}

PACKAGES += "${PN}-extra"
FILES:${PN} = " \
    ${prefix}/local/demo/application/3d-cube \
    ${prefix}/local/demo/gtk-application/040-3d_cube.yaml \
    ${datadir}/applications ${datadir}/pixmaps \
    "
RDEPENDS:${PN} = "weston-cube demo-launcher"

FILES:${PN}-extra = " \
    ${prefix}/local/demo/application/3d-cube-extra \
    ${prefix}/local/demo/gtk-application/100-3d-cube.yaml \
    ${prefix}/local/demo/gtk-application/101-3d-cube-shader.yaml \
    ${prefix}/local/demo/gtk-application/105-3d-cube-picture-shader.yaml \
    ${prefix}/local/demo/gtk-application/110-3d-cube-video.yaml \
    ${prefix}/local/demo/gtk-application/111-3d-cube-video-shader.yaml \
    ${prefix}/local/demo/gtk-application/120-3d-cube-pictures-shader.yaml \
    "
RDEPENDS:${PN}-extra = "${PN} weston-cube demo-launcher"
