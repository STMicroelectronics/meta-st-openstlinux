SUMMARY = "STM32 tool to convert the 'perf' tool counters into understandable MB/s"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

RDEPENDS_${PN} += " python3-core "

SRC_URI += " \
    file://stm32_ddr_pmu.py \
"

do_install() {
       install -d ${D}/${bindir}
       install -m 0755 ${WORKDIR}/stm32_ddr_pmu.py ${D}/${bindir}
}

FILES_${PN} = "${bindir}/stm32_ddr_pmu.py"
