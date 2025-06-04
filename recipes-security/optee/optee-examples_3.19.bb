SUMMARY = "OP-TEE examples"
HOMEPAGE = "https://github.com/linaro-swg/optee_examples"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=cd95ab417e23b94f381dafc453d70c30"

DEPENDS = "virtual-optee-os"
DEPENDS:stm32mp2aarch32common = " ${@oe.utils.ifelse(d.getVar('MULTILIBS'), 'lib64-virtual-optee-os','')} "

DEPENDS:append = " optee-client python3-pycryptodomex-native "
DEPENDS:append = " python3-cryptography-native "

inherit python3native

SRC_URI = "git://github.com/linaro-swg/optee_examples.git;branch=master;protocol=https"
SRCREV = "f301ee9df2129c0db683e726c91dc2cefe4cdb65"

PV = "3.19.0+git${SRCPV}"

S = "${WORKDIR}/git"

OPTEE_CLIENT_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TEEC_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TA_DEV_KIT_DIR = "${STAGING_INCDIR}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta', d)}"
TA_DEV_KIT_DIR_aarch32_aarch64 = "${WORKDIR}/lib64-recipe-sysroot${includedir}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta_arm32', d)}"
TA_DEV_KIT_DIR:stm32mp2aarch32common = "${@oe.utils.ifelse(d.getVar('MULTILIBS'), '${TA_DEV_KIT_DIR_aarch32_aarch64}','')}"

EXTRA_OEMAKE = " TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
                 OPTEE_CLIENT_EXPORT=${OPTEE_CLIENT_EXPORT} \
                 TEEC_EXPORT=${TEEC_EXPORT} \
                 HOST_CROSS_COMPILE=${TARGET_PREFIX} \
                 TA_CROSS_COMPILE=${TARGET_PREFIX} \
                 V=1 \
               "

do_compile() {
    export CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_HOST}"
    export OPENSSL_MODULES=${STAGING_LIBDIR_NATIVE}/ossl-modules/
    oe_runmake
}

do_install () {
    mkdir -p ${D}${nonarch_base_libdir}/optee_armtz
    mkdir -p ${D}${bindir}
    install -D -p -m0755 ${S}/out/ca/* ${D}${bindir}
    install -D -p -m0444 ${S}/out/ta/* ${D}${nonarch_base_libdir}/optee_armtz
}

# Avoid QA Issue: No GNU_HASH in the elf binary
INSANE_SKIP:${PN} += "ldflags"

FILES:${PN} += "${nonarch_base_libdir}/optee_armtz/"

# Imports machine specific configs from staging to build
PACKAGE_ARCH = "${MACHINE_ARCH}"
