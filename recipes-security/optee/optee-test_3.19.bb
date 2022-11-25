SUMMARY = "OP-TEE sanity testsuite"
HOMEPAGE = "https://github.com/OP-TEE/optee_test"

LICENSE = "BSD-2-Clause & GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.md;md5=daa2bcccc666345ab8940aab1315a4fa"

SRC_URI = "git://github.com/OP-TEE/optee_test.git;protocol=https;branch=master"
SRCREV = "ab9863cc187724e54c032b738c28bd6e9460a4db"

SRC_URI += "file://0001-no-error-deprecated-declarations.patch"
SRC_URI += "file://0002-ta-os_test-skip-bget-test-when-pager-is-constrained-.patch"
SRC_URI += "file://0003-regression-1013-lower-number-of-loops-when-pager-is-.patch"
SRC_URI += "file://0004-ta-crypt-remove-CFG_SYSTEM_PTA-ifdef.patch"
SRC_URI += "file://0005-regression-4012-4016-remove-CFG_SYSTEM_PTA-dependenc.patch"
SRC_URI += "file://0006-xtest-remove-CFG_SECSTOR_TA_MGMT_PTA-dependency.patch"

PV = "3.19.0+git${SRCPV}"

S = "${WORKDIR}/git"

require optee-test.inc
