FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"


DEPENDS += "${@oe.utils.conditional('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)}"

# weston-start and weston-autologin must be provided by recipe on openembedded-core
SRC_URI += " \
            file://weston.ini \
            file://utilities-terminal.png \
            file://ST13345_Products_light_blue_24x24.png \
            file://space.png \
            file://weston-checkgpu.service \
            file://weston_profile.sh \
            file://README-CHECK-GPU \
            file://72-galcore.rules \
            \
            file://73-pulseaudio-hdmi.rules \
            file://default_pulseaudio_profile \
            file://pulseaudio_hdmi_switch.sh \
            \
            file://weston-graphical-session.service \
            file://systemd-graphical-weston-session.sh \
            file://weston.service \
            file://weston.socket \
            file://seatd-weston.service \
            "
SRC_URI:append:stm32mpcommon = " file://check-gpu "

# backgrounds
SRC_URI:append:stm32mp1common = " file://ST30739_background-1280x720.png "
SRC_URI:append:stm32mp2common = " file://ST30739_background-1920x1080.png "
DEFAULT_WESTON_BACKGROUND ??= "ST30739_background-1280x720.png"
DEFAULT_WESTON_BACKGROUND:stm32mp2common ??= "ST30739_background-1920x1080.png"

WESTON_HDMI_MODE ??= "1280x720"

# due to different size of screen following the ship, need to force PACKAGE_ARCH
PACKAGE_ARCH := "${MACHINE_ARCH}"

FILES:${PN} += " ${datadir}/weston \
         ${sysconfdir}/etc/default \
         ${sbindir}/ \
         ${sysconfdir}/etc/default \
         ${sysconfdir}/etc/profile.d \
         ${sysconfdir}/xdg/weston/weston.ini \
         /home/root \
         ${systemd_user_unitdir} \
         ${systemd_system_unitdir} \
         "

CONFFILES:${PN} += "${sysconfdir}/xdg/weston/weston.ini"

do_install() {
    install -d ${D}${sysconfdir}/xdg/weston/
    install -d ${D}${datadir}/weston/backgrounds
    install -d ${D}${datadir}/weston/icon

    install -m 0644 ${WORKDIR}/utilities-terminal.png ${D}${datadir}/weston/icon/utilities-terminal.png
    install -m 0644 ${WORKDIR}/ST13345_Products_light_blue_24x24.png ${D}${datadir}/weston/icon/ST13345_Products_light_blue_24x24.png

    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'pam', d)}" ]; then
        install -D -p -m0644 ${WORKDIR}/weston-autologin ${D}${sysconfdir}/pam.d/weston-autologin
    fi


    # backgrounds & weston.ini
    install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston
    sed -i -e "s:##DEFAULT_BACKGROUND##:${DEFAULT_WESTON_BACKGROUND}:g" ${D}${sysconfdir}/xdg/weston/weston.ini
    sed -i -e "s:##HDMI_MODE##:${WESTON_HDMI_MODE}:g" ${D}${sysconfdir}/xdg/weston/weston.ini

    install -m 0644 ${WORKDIR}/${DEFAULT_WESTON_BACKGROUND} ${D}${datadir}/weston/backgrounds/

    install -m 0644 ${WORKDIR}/space.png ${D}${datadir}/weston/icon/

    install -d ${D}${systemd_system_unitdir} ${D}${sbindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -D -p -m0644 ${WORKDIR}/weston-graphical-session.service ${D}${systemd_system_unitdir}/weston-graphical-session.service
        sed -i -e s:/etc:${sysconfdir}:g \
            -e s:/usr/bin:${bindir}:g \
            -e s:/var:${localstatedir}:g \
            ${D}${systemd_unitdir}/system/weston-graphical-session.service
        install -D -m 0755 ${WORKDIR}/systemd-graphical-weston-session.sh ${D}${bindir}/systemd-graphical-weston-session.sh
        install -D -p -m0644 ${WORKDIR}/weston-checkgpu.service ${D}${systemd_system_unitdir}/weston-checkgpu.service

        install -d ${D}${systemd_user_unitdir}
        install -D -p -m0644 ${WORKDIR}/weston.service ${D}${systemd_user_unitdir}/weston.service
        install -D -p -m0644 ${WORKDIR}/weston.socket ${D}${systemd_user_unitdir}/weston.socket

        install -D -p -m0644 ${WORKDIR}/seatd-weston.service ${D}${systemd_system_unitdir}/seatd-weston.service
    fi

    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 ${WORKDIR}/weston_profile.sh ${D}${sysconfdir}/profile.d/

    if ${@bb.utils.contains('DISTRO_FEATURES','xwayland','true','false',d)}; then
        # uncomment modules line for support of xwayland
        sed -i -e 's,#xwayland=true,xwayland=true,g' ${D}${sysconfdir}/xdg/weston/weston.ini
    fi

    install -Dm755 ${WORKDIR}/weston-start ${D}${bindir}/weston-start
    sed -i 's,@DATADIR@,${datadir},g' ${D}${bindir}/weston-start
    sed -i 's,@LOCALSTATEDIR@,${localstatedir},g' ${D}${bindir}/weston-start

    # /etc/default/weston
    install -d ${D}${sysconfdir}/default
    echo "WESTON_USER=weston" > ${D}${sysconfdir}/default/weston

    # check GPU
    install -d ${D}/home/root/
    install -m 644 ${WORKDIR}/README-CHECK-GPU ${D}/home/root/
    if ! test -f ${D}${base_sbindir}/check-gpu; then
        install -d ${D}${base_sbindir}
        echo '#!/bin/sh' > ${WORKDIR}/check-gpu.empty
        echo '/bin/true' >> ${WORKDIR}/check-gpu.empty
        install -m 755 ${WORKDIR}/check-gpu.empty ${D}${base_sbindir}/check-gpu
    fi

    # udev rules for galcore
    install -D -p -m0644 ${WORKDIR}/72-galcore.rules ${D}${sysconfdir}/udev/rules.d/72-galcore.rules

    # AUDIO: swith between analog stero and HDMI
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/default_pulseaudio_profile ${D}${sysconfdir}/default/pulseaudio_profile
    install -d ${D}${sysconfdir}/udev/rules.d
    install -p -m 0644 ${WORKDIR}/73-pulseaudio-hdmi.rules ${D}${sysconfdir}/udev/rules.d/73-pulseaudio-hdmi.rules
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/pulseaudio_hdmi_switch.sh ${D}${bindir}/
}

do_install:append:stm32mpcommon() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${base_sbindir}
        install -m 755 ${WORKDIR}/check-gpu ${D}${base_sbindir}
    fi
}

SYSTEMD_SERVICE:${PN}:remove = "weston.service weston.socket"
SYSTEMD_SERVICE:${PN} += "weston-graphical-session.service weston-checkgpu.service seatd-weston.service"
#inherit useradd
USERADD_PARAM:${PN} = "--home /home/weston --shell /bin/sh --user-group -G video,input,tty,audio,dialout,render,rpmsg weston"
GROUPADD_PARAM:${PN} = "-r wayland; -r rpmsg; -r render"
