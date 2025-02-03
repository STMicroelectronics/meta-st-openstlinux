RDEPENDS:${PN}:remove = "${LTTNGTOOLS}"

RRECOMMENDS:${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'gplv3', '', '${PERF}', d)}"

#RDEPENDS:append += "oprofile"
