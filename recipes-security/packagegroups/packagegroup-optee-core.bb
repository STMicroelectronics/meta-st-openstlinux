SUMMARY = "OPTEE core packagegroup"
DESCRIPTION = "Provide optee-client package"
LICENSE = "LGPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/LGPL-2.0-or-later;md5=6d2d9952d88b50a51a5c73dc431d06c7"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

PACKAGES = "packagegroup-optee-core"

PROVIDES = "${PACKAGES}"

RDEPENDS:packagegroup-optee-core = "\
    optee-client \
    optee-stm32mp-addons \
"
# RDEPENDS:packagegroup-optee-core:stm32mp2aarch32common = "\
#     ${@oe.utils.ifelse(d.getVar('MULTILIBS'), ' \
#         optee-client \
#         optee-stm32mp-addons \
#     ','')} \
#     "
