SUMMARY = "OP-TEE examples"
HOMEPAGE = "https://github.com/linaro-swg/optee_examples"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=cd95ab417e23b94f381dafc453d70c30"

DEPENDS = "optee-client virtual/optee-os python3-pycryptodomex-native python3-pycrypto-native"

inherit python3native

SRC_URI = "git://github.com/linaro-swg/optee_examples.git"
SRCREV = "9a755dcf4d8ef6117af59dfd1b1a82315cee58ca"

S = "${WORKDIR}/git"

OPTEE_CLIENT_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TEEC_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TA_DEV_KIT_DIR = "${STAGING_INCDIR}/optee/export-user_ta"

EXTRA_OEMAKE = " TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
                 OPTEE_CLIENT_EXPORT=${OPTEE_CLIENT_EXPORT} \
                 TEEC_EXPORT=${TEEC_EXPORT} \
                 HOST_CROSS_COMPILE=${TARGET_PREFIX} \
                 TA_CROSS_COMPILE=${TARGET_PREFIX} \
                 V=1 \
                 LIBGCC_LOCATE_CFLAGS='--sysroot=${STAGING_DIR_HOST}' \
               "

do_compile() {
    oe_runmake
}

do_install () {
    mkdir -p ${D}${nonarch_base_libdir}/optee_armtz
    mkdir -p ${D}${bindir}
    install -D -p -m0755 ${S}/out/ca/* ${D}${bindir}
    install -D -p -m0444 ${S}/out/ta/* ${D}${nonarch_base_libdir}/optee_armtz
}

# Avoid QA Issue: No GNU_HASH in the elf binary
INSANE_SKIP_${PN} += "ldflags"

FILES_${PN} += "${nonarch_base_libdir}/optee_armtz/"

# Imports machine specific configs from staging to build
PACKAGE_ARCH = "${MACHINE_ARCH}"
