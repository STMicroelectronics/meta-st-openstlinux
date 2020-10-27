DESCRIPTION = "Hand writing character recognition launcher based on HCR Neural Network"

LICENSE = "GPLv2 & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "gtk+3 gstreamer1.0-plugins-base demo-launcher"
DEPENDS_append_stm32mpcommon += " m4projects-stm32mp1 "

inherit pkgconfig

SRC_URI = " file://ai_char_reco_launcher.c \
            file://apps_launcher_example.sh \
            file://copro.c \
            file://copro.h \
            file://Makefile \
            file://timer.c \
            file://timer.h \
            \
            file://media \
            \
            file://demo \
          "

PV = "2.1"

S = "${WORKDIR}"

do_configure[noexec] = "1"

#Provides the firmware location for DK2 and EV1 boards
EXTRA_OEMAKE  = 'FIRMWARE_PATH_DK2="${STM32MP_USERFS_MOUNTPOINT}/Cube-M4-examples/STM32MP157C-DK2/Demonstrations/AI_Character_Recognition/lib/firmware"'
EXTRA_OEMAKE += 'FIRMWARE_PATH_EV1="${STM32MP_USERFS_MOUNTPOINT}/Cube-M4-examples/STM32MP157C-EV1/Demonstrations/AI_Character_Recognition/lib/firmware"'

#Provides the firmware name
EXTRA_OEMAKE += 'FIRMWARE_NAME="AI_Character_Recognition.elf"'

do_install() {
    install -d ${D}${prefix}/local/demo/bin/
    install -d ${D}${prefix}/local/demo/media/
    install -d ${D}${prefix}/local/demo/application/m4_ai/bin
    install -d ${D}${prefix}/local/demo/application/m4_ai/pictures

    install -m 0755 ${B}/ai_char_reco_launcher      ${D}${prefix}/local/demo/bin/
    install -m 0755 ${B}/apps_launcher_example.sh   ${D}${prefix}/local/demo/bin/
    install -m 0644 ${B}/media/*                    ${D}${prefix}/local/demo/media/
    install -m 0755 -D ${WORKDIR}/demo/application/m4_ai/bin/* ${D}${prefix}/local/demo/application/m4_ai/bin/
    install -m 0755 -D ${WORKDIR}/demo/application/m4_ai/pictures/* ${D}${prefix}/local/demo/application/m4_ai/pictures/
    install -m 0644 -D ${WORKDIR}/demo/application/*.yaml ${D}${prefix}/local/demo/application/
}

FILES_${PN} += "${prefix}/local/demo/"
RDEPENDS_${PN} += "gtk+3 gstreamer1.0-plugins-base demo-launcher"
RDEPENDS_${PN}_append_stm32mpcommon += " m4projects-stm32mp1-userfs "
