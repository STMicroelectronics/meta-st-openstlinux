RDEPENDS:${PN} += " \
    ${@bb.utils.contains('COMBINED_FEATURES', 'initrd', '${INITRD_PACKAGE}', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'fw-update', 'u-boot-fwumdata-config-stm32mp', '', d)}   \
    ${@bb.utils.contains('MACHINE_FEATURES', 'fw-update', 'bootcount', '', d)}   \
    "
