SUMMARY = "OP-TEE STM32MP examples"
HOMEPAGE = "www.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = "git://github.com/STMicroelectronics/optee-stm32mp-addons;protocol=https;branch=main"
SRCREV = "3c3cb0ed91055d3ea23864264fa71bcc6151af56"

PV = "3.16.0.${SRCPV}"

DEPENDS = "optee-client virtual/optee-os python3-pycryptodomex-native"
DEPENDS += "python3-cryptography-native"
DEPENDS += "openssl"

inherit python3native systemd

S = "${WORKDIR}/git"

EXTRA_OEMAKE += " \
    TA_DEV_KIT_DIR=${STAGING_INCDIR}/optee/export-user_ta \
    OPTEE_CLIENT_EXPORT=${STAGING_DIR_HOST}${prefix} \
    HOST_CROSS_COMPILE=${TARGET_PREFIX} \
    TA_CROSS_COMPILE=${TARGET_PREFIX} \
"

do_compile:prepend() {
    export CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_HOST}"
    export OPENSSL_MODULES=${STAGING_LIBDIR_NATIVE}/ossl-modules/
}

do_install() {
    if [ -d "${S}/out/ca" ]; then
        if [ $(find ${S}/out/ca -type f| wc -l) -gt 0 ]; then
            install -d ${D}${bindir}
            install -D -p -m 0755 ${S}/out/ca/* ${D}${bindir}
        fi
    fi

    if [ -d "${S}/out/ta" ]; then
        if [ $(find ${S}/out/ta -type f| wc -l) -gt 0 ]; then
            install -d ${D}${nonarch_base_libdir}/optee_armtz
            install -D -p -m0444 ${S}/out/ta/* ${D}${nonarch_base_libdir}/optee_armtz
        fi
    fi

    if [ -d "${S}/out/scripts" ]; then
        if [ $(find ${S}/out/scripts -type f| wc -l) -gt 0 ]; then
            install -d ${D}${systemd_system_unitdir}
            install -D -p -m0644 ${S}/out/scripts/* ${D}${systemd_system_unitdir}/
        fi
    fi
}

# for Feature calibration
SYSTEMD_SERVICE:{PN} = "stm32mp-calibration.service stm32mp-calibration.timer"

FILES:${PN} += "${systemd_system_unitdir} ${nonarch_base_libdir}"
