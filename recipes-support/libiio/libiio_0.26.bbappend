FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

#Fixed invalid IIOD_EXTRA_OPTS assignment
SRCREV = "1ae8815858d7ca07da2cb7db76ec3fbb1a84588a"

SRC_URI:append = " file://iiod"
SRC_URI:append = " file://0001-Adapt-to-etc-init.d-functions.patch"

do_install:append() {
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${UNPACKDIR}/iiod ${D}${sysconfdir}/default/
}
