#
# Due to GPLv3 limitation, gdbserver are removed of package group
#
RDEPENDS_${PN}_remove = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', '', 'gdbserver', d)} \
    "
