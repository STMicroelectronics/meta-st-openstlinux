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
# <partition_label1>,<partition_mountpoint1> <partition_label2>,<partition_mountpoint2>
MOUNT_PARTITIONS_LIST ?= ""
PARTITIONS_CONFIG ?= ""

# Update MOUNT_PARTITIONS_LIST var with input from PARTITIONS_CONFIG enabled
python set_partitions_list() {
    partitionsconfig = (d.getVar('PARTITIONS_CONFIG') or "").split()

    if len(partitionsconfig) > 0:
        partitionsconfigflags = d.getVarFlags('PARTITIONS_CONFIG')
        # The "doc" varflag is special, we don't want to see it here
        partitionsconfigflags.pop('doc', None)

        for config in partitionsconfig:
            for f, v in partitionsconfigflags.items():
                if config == f:
                    items = v.split(',')
                    # Make sure a mount point is available
                    if len(items) > 2 and items[1] and items[2]:
                        bb.debug(1, "Appending '%s,%s' to MOUNT_PARTITIONS_LIST." % (items[1], items[2]))
                        d.appendVar('MOUNT_PARTITIONS_LIST', ' ' + items[1] + ',' + items[2])
                    break
}
do_install[prefuncs] += "set_partitions_list"

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
