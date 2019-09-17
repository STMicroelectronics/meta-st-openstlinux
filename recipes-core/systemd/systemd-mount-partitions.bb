# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Mount partitions"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} += " util-linux "

MOUNT_BASENAME = "mount-partitions"

SRC_URI = " \
    file://${MOUNT_BASENAME}.service    \
    file://${MOUNT_BASENAME}.sh         \
    "

inherit systemd update-rc.d

INITSCRIPT_NAME = "${MOUNT_BASENAME}.sh"
INITSCRIPT_PARAMS = "start 22 5 3 ."

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE_${PN} = "${MOUNT_BASENAME}.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

# This list should be set with partition label and associated mountpoint
# <partition_label1>;<partition_mountpoint1> <partition_label2>;<partition_mountpoint2>
MOUNT_PARTITIONS_LIST ?= ""

do_install() {
    if [ -n "${MOUNT_PARTITIONS_LIST} " ] ; then
        for part in ${MOUNT_PARTITIONS_LIST}
        do
            part_label=$(echo ${part} | cut -d',' -f1)
            mountpoint=$(echo ${part} | cut -d',' -f2)
            # Check that list is properly feed
            [ -z "${part_label}" ] && bbfatal "MOUNT_PARTITIONS_LIST parsing error: ${part} does not contain partition label"
            [ -z "${mountpoint}" ] && bbfatal "MOUNT_PARTITIONS_LIST parsing error: ${part} does not contain partition mountpoint"
        done

        if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
            install -d ${D}${systemd_unitdir}/system ${D}/${base_sbindir}
            install -m 644 ${WORKDIR}/${MOUNT_BASENAME}.service ${D}/${systemd_unitdir}/system
            install -m 755 ${WORKDIR}/${MOUNT_BASENAME}.sh ${D}/${base_sbindir}/

            # Update script
            sed 's:^MOUNT_PARTITIONS_LIST=.*$:MOUNT_PARTITIONS_LIST=\"'"${MOUNT_PARTITIONS_LIST}"'\":' -i ${D}/${base_sbindir}/${MOUNT_BASENAME}.sh
            # Update service
            for part in ${MOUNT_PARTITIONS_LIST}
            do
                mountpoint=$(echo ${part} | cut -d',' -f2)
                # Append line with mountpoint
                sed '/^ConditionPathExists=##mountpoint##/ i ConditionPathExists='"${mountpoint}"'' -i ${D}/${systemd_unitdir}/system/${MOUNT_BASENAME}.service
            done
            # Clean pattern insertion
            sed 's/^ConditionPathExists=##mountpoint##//' -i ${D}/${systemd_unitdir}/system/${MOUNT_BASENAME}.service
        fi
        install -d ${D}/${INIT_D_DIR}
        install -m 755 ${WORKDIR}/${MOUNT_BASENAME}.sh ${D}/${INIT_D_DIR}/
        # Update script
        sed 's:^MOUNT_PARTITIONS_LIST=.*$:MOUNT_PARTITIONS_LIST=\"'"${MOUNT_PARTITIONS_LIST}"'\":' -i ${D}/${INIT_D_DIR}/${MOUNT_BASENAME}.sh
    else
        bbfatal "Please set MOUNT_PARTITIONS_LIST with expected partition labels and mount point."
    fi
}

FILES_${PN} += " ${systemd_unitdir} ${base_sbindir} ${INIT_D_DIR}"
