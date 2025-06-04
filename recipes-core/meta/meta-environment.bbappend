do_install:append() {
    if [ -n "${MULTILIBS}" ]; then
        if [ "${MULTILIBS}" = "multilib:lib64" ]; then
            # remove aarch64 file, need to have only aarch32
            rm -f ${D}/${SDKPATH}/environment-setup-cortexa35*
            rm -f ${D}/${SDKPATH}/site-config-cortexa35*
            rm -f ${D}/${SDKPATH}/version-cortexa35*

            rm -f ${SDK_OUTPUT}/${SDKPATH}/environment-setup-cortexa35*
            rm -f ${SDK_OUTPUT}/${SDKPATH}/site-config-cortexa35*
            rm -f ${SDK_OUTPUT}/${SDKPATH}/version-cortexa35*
            rm -f ${SDK_OUTPUT}/${SDKPATH}/environment-setup
            ln -s environment-setup-${REAL_MULTIMACH_TARGET_SYS} ${SDK_OUTPUT}/${SDKPATH}/environment-setup
        fi
     else
         ln -s environment-setup-${REAL_MULTIMACH_TARGET_SYS} ${SDK_OUTPUT}/${SDKPATH}/environment-setup
    fi
}
