# There is a conflict with 'wireless-regdb-static' package and 'dev-pkgs'
# IMAGE_FEATURES:
# This configuration creates an install dependency for 'wireless-regdb' package,
# while the 'wireless-regdb_%.bb' recipe set: RCONFLICTS_${PN} = "${PN}-static"
# This gives 'unmet dependencies' error.
# To avoid this issue, modify dependencies for ${PN}-dev to not require the
# ${PN} package by default.
RDEPENDS_${PN}-dev = ""
RRECOMMENDS_${PN}-dev_append = "${PN}"
