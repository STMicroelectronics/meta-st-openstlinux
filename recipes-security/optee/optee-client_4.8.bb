SUMMARY = "OPTEE Client"
HOMEPAGE = "https://github.com/OP-TEE/optee_client"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=69663ab153298557a59c67a60a743e5b"

inherit python3native systemd cmake pkgconfig

SRC_URI = "git://github.com/OP-TEE/optee_client.git;protocol=https;branch=master \
           file://tee-supplicant@.service.in \
           file://create-tee-supplicant-env \
           file://default.tee-supplicant \
           file://optee-udev.rules \
    "
# Advisorie: https://github.com/OP-TEE/optee_client/security/advisories/GHSA-h8c5-c6gf-mgqj
SRC_URI += "file://0001-libckteec-fix-CKA_ALLOWED_MECHANISMS-size-on-64-bit.patch"

SRCREV = "9d6f69844ff60ec0966cf3659abcc38eda8b31ea"

PV = "4.8.0-git${@ d.getVar("SRCREV")[0:8] }"

DEPENDS += "util-linux-libuuid"

SYSTEMD_SERVICE:${PN} = "tee-supplicant@.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

# libts uses /dev/tee devices too. Add a common variable to allow configuring the same group.
TEE_GROUP_NAME ?= "tee"

EXTRA_OECMAKE = " \
    -DCFG_TEE_FS_PARENT_PATH='${localstatedir}/lib/tee' \
    -DCFG_WERROR=OFF \
    -DCFG_TEE_CLIENT_LOG_LEVEL=2 \
    -DCFG_TEE_CLIENT_LOG_FILE='${localstatedir}/lib/tee/teec.log' \
    \
    -DBUILD_SHARED_LIBS=ON \
    -DCFG_USE_PKGCONFIG=ON \
    \
    -DRPMB_EMU=0 \
    \
    -DCFG_ENABLE_SYSTEMD=On -DSYSTEMD_UNIT_DIR=${systemd_system_unitdir}/ \
    -DCFG_ENABLE_UDEV=On -DUDEV_UDEV_DIR=${nonarch_base_libdir}/udev/rules.d/ \
    -DCFG_TEE_GROUP=${TEE_GROUP_NAME} -DCFG_TEEPRIV_GROUP=teepriv \
    "

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        sed -e s:/etc:${sysconfdir}:g \
            -e s:/usr/bin:${bindir}:g \
            -e s:@CFG_TEE_SUPPL_USER@:teesuppl:g \
            -e s:@CFG_TEE_SUPPL_GROUP@:teesuppl:g \
              ${UNPACKDIR}/tee-supplicant@.service.in > ${UNPACKDIR}/tee-supplicant@.service

        install -D -p -m0644 ${UNPACKDIR}/tee-supplicant@.service ${D}${systemd_system_unitdir}/tee-supplicant@.service
        install -D -p -m0755 ${UNPACKDIR}/create-tee-supplicant-env ${D}${sbindir}/
        install -D -p -m0644 ${UNPACKDIR}/default.tee-supplicant ${D}${sysconfdir}/default/tee-supplicant
    fi
    install -d ${D}${sysconfdir}/udev/rules.d
    if [ ! -e ${D}${sysconfdir}/udev/rules.d/optee-udev.rules ]; then
        install -m 0644 ${UNPACKDIR}/optee-udev.rules ${D}${sysconfdir}/udev/rules.d/optee-udev.rules
    fi
    install -d -m770 -o teesuppl -g teesuppl ${D}${localstatedir}/lib/tee
}
FILES:${PN} += "${sysconfdir} ${localstatedir}"

inherit useradd

USERADD_PACKAGES = "${PN}"
# Users and groups:
# TEE_GROUP_NAME group to access /dev/tee*
# teepriv group to acess /dev/teepriv*, only tee-supplicant
# teesuppl user and group teesuppl to run tee-supplicant
GROUPADD_PARAM:${PN} = "--system ${TEE_GROUP_NAME}; --system teepriv; --system teesuppl"
USERADD_PARAM:${PN} = "--system -g teesuppl --groups teepriv --home-dir ${localstatedir}/lib/tee -M --shell /sbin/nologin -c 'User for tee-supplicant' teesuppl;"
