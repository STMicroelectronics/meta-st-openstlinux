SUMMARY = "OP-TEE sanity testsuite"
HOMEPAGE = "https://github.com/OP-TEE/optee_test"

LICENSE = "BSD-2-Clause & GPLv2"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.md;md5=daa2bcccc666345ab8940aab1315a4fa"

SRC_URI = "git://github.com/OP-TEE/optee_test.git;protocol=https"
SRCREV = "7be42398e8848f09995abf8a9e9d8bb8840cc19a"

PV = "3.12.0+git${SRCPV}"

S = "${WORKDIR}/git"

require optee-test.inc
