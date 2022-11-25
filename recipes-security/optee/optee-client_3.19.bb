SUMMARY = "OPTEE Client"
HOMEPAGE = "https://github.com/OP-TEE/optee_client"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=69663ab153298557a59c67a60a743e5b"

inherit python3native systemd cmake pkgconfig

SRC_URI = "git://github.com/OP-TEE/optee_client.git;protocol=https;branch=master \
           file://tee-supplicant.service \
           file://create-tee-supplicant-env \
           file://optee-udev.rules \
    "

SRCREV = "140bf463046071d3ca5ebbde3fb21ee0854e1951"

PV = "3.19.0+git${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS += "util-linux-libuuid"

SYSTEMD_SERVICE:${PN} = "tee-supplicant.service"

EXTRA_OECMAKE = " \
    -DCFG_TEE_FS_PARENT_PATH='${localstatedir}/lib/tee' \
    -DCFG_WERROR=OFF \
    -DCFG_TEE_CLIENT_LOG_LEVEL=2 \
    -DCFG_TEE_CLIENT_LOG_FILE='/data/tee/teec.log' \
    -DBUILD_SHARED_LIBS=ON \
    -DRPMB_EMU=0 \
    "

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        sed -i -e s:/etc:${sysconfdir}:g \
            -e s:/usr/bin:${bindir}:g \
            ${WORKDIR}/tee-supplicant.service

        install -D -p -m0644 ${WORKDIR}/tee-supplicant.service ${D}${systemd_system_unitdir}/tee-supplicant.service
        install -D -p -m0755 ${WORKDIR}/create-tee-supplicant-env ${D}${sbindir}/
    fi
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/optee-udev.rules ${D}${sysconfdir}/udev/rules.d/optee.rules
    install -d -m770 -o root -g tee ${D}${localstatedir}/lib/tee
}
FILES:${PN} += "${sysconfdir} ${localstatedir}"

inherit useradd

USERADD_PACKAGES = "${PN}"
# Create groups 'tee' and 'teeclnt'. Permissions are set elsewhere on
# /dev/teepriv0 and /dev/tee0 so that tee-supplicant should run as a user that
# is a member of the 'tee' group, and TEE client applications should runs as a
# user that is a member of the 'teeclnt' group.
GROUPADD_PARAM:${PN} = "--system tee; --system teeclnt"
# Create user 'tee' member of group 'tee' to run tee-supplicant
USERADD_PARAM:${PN} = "--system -d / -M -s /bin/nologin -c 'User for tee-supplicant' -g tee tee"
