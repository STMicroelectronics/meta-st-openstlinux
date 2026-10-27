SUMMARY = "Add support of audio bluetooth speaker on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher"

PV = "2.1"

SRC_URI = " \
    file://060-bluetooth_audio_output.yaml \
    file://launch_bluetooth.sh \
    file://bluetooth_audio.py \
    file://wrap_blctl.py \
    file://__init__.py \
    file://ST11012_bluetooth_speaker_light_green.png \
    file://check_ble.sh \
    file://audio_sink_a2dp.sh \
    \
    file://bluetooth_audio.desktop \
    file://bluetooth_audio.png \
    "

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/gtk-application
    install -d ${D}${prefix}/local/demo/application/bluetooth/bin
    install -d ${D}${prefix}/local/demo/application/bluetooth/pictures

    # desktop application
    install -d ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/bluetooth_audio.desktop ${D}${datadir}/applications

    # picture for desktop application
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${UNPACKDIR}/bluetooth_audio.png ${D}${datadir}/pixmaps

    # install yaml file
    install -m 0644 ${UNPACKDIR}/*.yaml ${D}${prefix}/local/demo/gtk-application/
    # install pictures
    install -m 0644 ${UNPACKDIR}/*.png ${D}${prefix}/local/demo/application/bluetooth/pictures
    # python script
    install -m 0755 ${UNPACKDIR}/*.py ${D}${prefix}/local/demo/application/bluetooth/
    # install check script
    install -m 0755 ${UNPACKDIR}/*.sh ${D}${prefix}/local/demo/application/bluetooth/bin/
}
RDEPENDS:${PN} += "python3-core python3-pexpect python3-pickle python3-pygobject gtk+3 demo-launcher"
FILES:${PN} += "${prefix}/local/demo ${datadir}/applications ${datadir}/pixmaps"
