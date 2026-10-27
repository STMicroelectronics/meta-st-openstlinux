FILESEXTRAPATHS:prepend:stm32mpcommon := "${THISDIR}/${PN}:"

SRC_URI_AB = " \
    file://fstab.emmc_a \
    file://fstab.emmc_b \
    \
    file://fstab.sdcard_a \
    file://fstab.sdcard_b \
    "

SRC_URI:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'fw-update-ab', '${SRC_URI_AB}', '', d)} "

do_install:append () {
    if [ -e ${UNPACKDIR}/fstab.emmc_a ]; then
        # emmc A
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/boot\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_BOOTFS_A:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_a
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/vendor\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_VENDORFS_A:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_a
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/userfs\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_USERFS_A:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_a
        install -m 0644 ${S}/fstab.emmc_a ${D}${sysconfdir}
    fi

    if [ -e ${UNPACKDIR}/fstab.emmc_b ]; then
        # emmc B
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/boot\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_BOOTFS_B:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_b
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/vendor\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_VENDORFS_B:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_b
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/userfs\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_USERFS_B:mmc1}"'\t\1|" -i ${UNPACKDIR}/fstab.emmc_b
        install -m 0644 ${S}/fstab.emmc_b ${D}${sysconfdir}
    fi

    if [ -e ${UNPACKDIR}/fstab.sdcard_a ]; then
        # sdcard A
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/boot\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_BOOTFS_A:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_a
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/vendor\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_VENDORFS_A:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_a
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/userfs\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_USERFS_A:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_a
        install -m 0644 ${S}/fstab.sdcard_a ${D}${sysconfdir}
    fi

    if [ -e ${UNPACKDIR}/fstab.sdcard_b ]; then
        # sdcard B
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/boot\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_BOOTFS_B:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_b
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/vendor\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_VENDORFS_B:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_b
        sed "s|^#/dev/disk/by-partuuid/.*\(\S*/userfs\)|#/dev/disk/by-partuuid/'"${DEVICE_PARTUUID_USERFS_B:mmc0}"'\t\1|" -i ${UNPACKDIR}/fstab.sdcard_b
        install -m 0644 ${S}/fstab.sdcard_b ${D}${sysconfdir}
    fi
}
