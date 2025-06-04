# Imports machine specific configs from staging to build
PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS = "virtual-optee-os"
DEPENDS:stm32mp2aarch32common = " ${@oe.utils.ifelse(d.getVar('MULTILIBS'), 'lib64-virtual-optee-os','')} "

DEPENDS:append = " optee-client python3-pycryptodomex-native libgcc "
DEPENDS:append = " openssl "
DEPENDS:append = " python3-cryptography-native "

inherit python3native cmake

OPTEE_CLIENT_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TEEC_EXPORT         = "${STAGING_DIR_HOST}${prefix}"
TA_DEV_KIT_DIR      = "${STAGING_INCDIR}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta', d)}"

TA_DEV_KIT_DIR_aarch32_aarch64 = "${WORKDIR}/lib64-recipe-sysroot${includedir}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta_arm32', d)}"
TA_DEV_KIT_DIR:stm32mp2aarch32common = "${@oe.utils.ifelse(d.getVar('MULTILIBS'), '${TA_DEV_KIT_DIR_aarch32_aarch64}','')}"

TEE_PLUGIN_LOAD_PATH = "${libdir}/tee-supplicant/plugins"

EXTRA_OEMAKE = " TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
                 OPTEE_CLIENT_EXPORT=${OPTEE_CLIENT_EXPORT} \
                 TEEC_EXPORT=${TEEC_EXPORT} \
                 CROSS_COMPILE_HOST=${TARGET_PREFIX} \
                 CROSS_COMPILE_TA=${TARGET_PREFIX} \
                 V=1 \
                 CFG_TEE_CLIENT_LOAD_PATH=${libdir} \
                 CFG_TEE_PLUGIN_LOAD_PATH=${TEE_PLUGIN_LOAD_PATH} \
                 DESTDIR=${D} \
               "
EXTRA_OECMAKE = "-DOPTEE_TEST_SDK=${TA_DEV_KIT_DIR} \
                 -DCFG_TEE_CLIENT_LOAD_PATH=${libdir} \
                 -DCFG_TEE_PLUGIN_LOAD_PATH=${TEE_PLUGIN_LOAD_PATH} \
                 "

do_compile:prepend() {
    export CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_HOST}"
    export OPENSSL_MODULES=${STAGING_LIBDIR_NATIVE}/ossl-modules/
}

do_compile:append() {
    cd ${S}
    oe_runmake ta
}

do_install:append () {
    # install path should match the value set in optee-client/tee-supplicant
    # default TEEC_LOAD_PATH is /lib
    mkdir -p ${D}${nonarch_base_libdir}/optee_armtz/
    install -D -p -m0444 ${S}/out/ta/*/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}

FILES:${PN} += "${nonarch_base_libdir}/optee_armtz/ ${libdir}"
FILES:${PN} += "${TEE_PLUGIN_LOAD_PATH}/"
INSANE_SKIP:${PN} += "host-user-contaminated"
