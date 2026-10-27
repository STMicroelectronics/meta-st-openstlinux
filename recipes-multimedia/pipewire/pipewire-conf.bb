SUMMARY = "List of sciprt configuration for pipepwire"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

PV = "1.0"

SRC_URI = " \
    file://73-audio-hdmi.rules \
    \
    file://dbus_profile.sh \
    file://pulse_profile.sh \
    file://pipewire_profile.sh \
    \
    file://default_audio_profile \
    \
    file://pipewire_hdmi_switch.sh \
    file://st_pipewire_switch.sh \
    "

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -p -m 0644 ${UNPACKDIR}/73-audio-hdmi.rules ${D}${sysconfdir}/udev/rules.d/73-audio-hdmi.rules

    install -d ${D}${sysconfdir}/default
    install -m 0644 ${UNPACKDIR}/default_audio_profile ${D}${sysconfdir}/default/default_audio_profile

    install -d ${D}${sysconfdir}/profile.d/
    install -m 0755 ${UNPACKDIR}/dbus_profile.sh ${D}${sysconfdir}/profile.d/
    install -m 0755 ${UNPACKDIR}/pulse_profile.sh ${D}${sysconfdir}/profile.d/
    install -m 0755 ${UNPACKDIR}/pipewire_profile.sh ${D}${sysconfdir}/profile.d/

    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/pipewire_hdmi_switch.sh ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/st_pipewire_switch.sh ${D}${bindir}/
}

RDEPENDS:${PN} += "jq wireplumber bash"

