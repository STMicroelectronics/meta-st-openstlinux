# Imports machine specific configs from staging to build
PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS = "virtual-optee-os"
DEPENDS:stm32mp2aarch32common = " ${@oe.utils.ifelse(d.getVar('MULTILIBS'), 'lib64-virtual-optee-os','')} "

DEPENDS:append = " optee-client python3-pycryptodomex-native libgcc "
DEPENDS:append = " openssl "
DEPENDS:append = " python3-cryptography-native "

inherit python3native

OPTEE_CLIENT_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TA_DEV_KIT_DIR      = "${STAGING_INCDIR}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta', d)}"

TA_DEV_KIT_DIR_aarch32_aarch64 = "${WORKDIR}/lib64-recipe-sysroot${includedir}/optee/${@bb.utils.contains('TUNE_FEATURES', 'aarch64', 'export-user_ta_arm64', 'export-user_ta_arm32', d)}"
TA_DEV_KIT_DIR:stm32mp2aarch32common = "${@oe.utils.ifelse(d.getVar('MULTILIBS'), '${TA_DEV_KIT_DIR_aarch32_aarch64}','')}"

TEE_PLUGIN_LOAD_PATH = "${libdir}/tee-supplicant/plugins"

EXTRA_OEMAKE = " TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
                 OPTEE_OPENSSL_EXPORT=${STAGING_INCDIR} \
                 CROSS_COMPILE_HOST=${HOST_PREFIX} \
                 CROSS_COMPILE_TA=${HOST_PREFIX} \
                 O=${B} \
                 \
                 OPTEE_CLIENT_EXPORT=${OPTEE_CLIENT_EXPORT} \
                 V=1 \
                 CFG_TEE_PLUGIN_LOAD_PATH=${TEE_PLUGIN_LOAD_PATH} \
                 DESTDIR=${D} \
               "

# python3-cryptography needs the legacy provider, so set OPENSSL_MODULES to the
# right path until this is relocated automatically.
export OPENSSL_MODULES = "${STAGING_LIBDIR_NATIVE}/ossl-modules"

CFLAGS += "--sysroot=${STAGING_DIR_HOST}"

#CFLAGS += "-Wno-error=unterminated-string-initialization -Wno-error=deprecated-declarations"

B = "${WORKDIR}/build"

do_compile() {
    cd ${S}
    # Top level makefile doesn't seem to handle parallel make gracefully
    oe_runmake xtest
    oe_runmake ta
    oe_runmake test_plugin
}
do_compile[cleandirs] = "${B}"

do_install() {
    install -D -p -m0755 ${B}/xtest/xtest ${D}${bindir}/xtest

    # install path should match the value set in optee-client/tee-supplicant
    # default TEEC_LOAD_PATH is /lib
    mkdir -p ${D}${nonarch_base_libdir}/optee_armtz/
    install -D -p -m0444 ${B}/ta/*/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
    mkdir -p ${D}${libdir}/tee-supplicant/plugins
    install -D -p -m0444 ${B}/supp_plugin/*.plugin ${D}${libdir}/tee-supplicant/plugins/
}

FILES:${PN} += "${nonarch_base_libdir}/optee_armtz/ ${libdir}"
FILES:${PN} += "${TEE_PLUGIN_LOAD_PATH}/"

INSANE_SKIP:${PN} += "host-user-contaminated"
INSANE_SKIP:${PN}-dbg += "buildpaths"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# See the rationale in https://github.com/f-secure-foundry/advisories/blob/master/Security_Advisory-Ref_FSC-HWSEC-VR2021-0001-OP-TEE_TrustZone_bypass.txt.
CVE_STATUS[CVE-2021-36133] = "disputed: devices shipped open for development purposes"
