DESCRIPTION = "Add support of audio bluetooth speaker on Demo Launcher"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "demo-launcher"

PV = "2.0"

SRC_URI = " \
    file://060-bluetooth_audio_output.yaml \
    file://bluetooth_audio.py \
    file://wrap_blctl.py \
    file://__init__.py \
    file://ST11012_bluetooth_speaker_light_green.png \
    "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${prefix}/local/demo/application/bluetooth/bin
    install -d ${D}${prefix}/local/demo/application/bluetooth/pictures

    # install yaml file
    install -m 0644 ${WORKDIR}/*.yaml ${D}${prefix}/local/demo/application/
    # install pictures
    install -m 0644 ${WORKDIR}/*.png ${D}${prefix}/local/demo/application/bluetooth/pictures
    # python script
    install -m 0755 ${WORKDIR}/*.py ${D}${prefix}/local/demo/application/bluetooth/
}
RDEPENDS_${PN} += "python3-core python3-pexpect python3-pickle python3-pygobject gtk+3 demo-launcher"
FILES_${PN} += "${prefix}/local/demo/application/"
