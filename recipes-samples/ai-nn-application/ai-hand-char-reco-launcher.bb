DESCRIPTION = "Hand writing character recognition launcher based on HCR Neural Network"

LICENSE = "GPLv2 & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "gtk+3 "
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
          "

S = "${WORKDIR}"

do_configure[noexec] = "1"

#Provides the firmware location for DK2 and EV1 boards
EXTRA_OEMAKE  = 'FIRMWARE_PATH_DK2="${STM32MP_USERFS_MOUNTPOINT_IMAGE}/Cube-M4-examples/STM32MP157C-DK2/Demonstrations/AI_Character_Recognition/lib/firmware"'
EXTRA_OEMAKE += 'FIRMWARE_PATH_EV1="${STM32MP_USERFS_MOUNTPOINT_IMAGE}/Cube-M4-examples/STM32MP157C-EV1/Demonstrations/AI_Character_Recognition/lib/firmware"'

#Provides the firmware name
EXTRA_OEMAKE += 'FIRMWARE_NAME="AI_Character_Recognition.elf"'

do_install() {
    install -d ${D}${prefix}/local/demo/bin/
    install -d ${D}${prefix}/local/demo/media/

    install -m 0755 ${B}/ai_char_reco_launcher      ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/demo/bin/
    install -m 0755 ${B}/apps_launcher_example.sh   ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/demo/bin/
    install -m 0644 ${B}/media/*                    ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/demo/media/
}

FILES_${PN} += "${prefix}/local/demo/bin/"
FILES_${PN} += "${prefix}/local/demo/media/"
FILES_${PN} += "${prefix}/local/demo/lib/"
RDEPENDS_${PN} += "gtk+3 gstreamer1.0-plugins-base"
