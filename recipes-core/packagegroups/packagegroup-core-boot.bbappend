RDEPENDS:${PN} += " \
    ${@bb.utils.contains('COMBINED_FEATURES', 'initrd', '${INITRD_PACKAGE}', '', d)} \
    "
