#
# Due to GPLv3 limitation, gdbserver are removed of package group
#
RDEPENDS:${PN}:remove = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', '', 'gdbserver', d)} \
    "
