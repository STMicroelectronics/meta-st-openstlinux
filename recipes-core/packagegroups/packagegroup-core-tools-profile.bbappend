RDEPENDS_${PN}_remove = "${LTTNGMODULES}"

RRECOMMENDS_${PN}_remove = "${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', '', '${PERF}', d)}"

#RDEPENDS_append += "oprofile"
