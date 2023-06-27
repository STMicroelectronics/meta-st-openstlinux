FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = "libjitterentropy"

SRC_URI += " \
    file://71-hwrng.rules \
    file://rng-tools.service \
"

do_install:append() {
    # install udev rule
    install -D -p -m0644 ${WORKDIR}/71-hwrng.rules ${D}${sysconfdir}/udev/rules.d/71-hwrng.rules
}
FILES:${PN}-service += "${sysconfdir}/udev"
