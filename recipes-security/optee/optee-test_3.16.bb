SUMMARY = "OP-TEE sanity testsuite"
HOMEPAGE = "https://github.com/OP-TEE/optee_test"

LICENSE = "BSD-2-Clause & GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.md;md5=daa2bcccc666345ab8940aab1315a4fa"

SRC_URI = "git://github.com/OP-TEE/optee_test.git;protocol=https;branch=master"
SRCREV = "1cf0e6d2bdd1145370033d4e182634458528579d"

PV = "3.16.0+git${SRCPV}"

S = "${WORKDIR}/git"

require optee-test.inc
