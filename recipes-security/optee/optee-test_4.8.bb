SUMMARY = "OP-TEE sanity testsuite"
HOMEPAGE = "https://github.com/OP-TEE/optee_test"

LICENSE = "BSD-2-Clause & GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.md;md5=a8fa504109e4cd7ea575bc49ea4be560"

SRC_URI = " \
    git://github.com/OP-TEE/optee_test.git;protocol=https;branch=master \
    "
SRCREV = "6569cd7b13e1b37b37069e090d592adca7d3926d"

PV = "4.8.0-git${@ d.getVar("SRCREV")[0:8] }"

require optee-test.inc
