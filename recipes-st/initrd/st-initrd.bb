SUMMARY = "ST InitRD installation package for ${INITRD_IMAGE_ALL} image(s)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# We provide an InitRD specific to machine
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

S = "${WORKDIR}"

# Set InitRD image list
INITRD_IMAGE ??= ""
INITRD_IMAGE_ALL += "${INITRD_IMAGE}"

do_install() {
    if [ -z "${INITRD_IMAGE_ALL}" ]; then
        bbnote "No InitRD file set"
        return
    fi

    for img in ${INITRD_IMAGE_ALL}; do
        INITRD_IMAGE_FILE=$(find ${DEPLOY_DIR_IMAGE} -name ${img}*-${MACHINE}.${INITRAMFS_FSTYPES})
        if [ -e "${INITRD_IMAGE_FILE}" ]; then
            bbnote "Copying ${img} InitRD file into ./boot/ ..."
            install -d ${D}/boot
            install -m 0644 ${INITRD_IMAGE_FILE} ${D}/boot/${img}
        else
            bbfatal "Could not find ${img}*-${MACHINE}.${INITRAMFS_FSTYPES} image file in ${DEPLOY_DIR_IMAGE} folder"
        fi
    done
}
do_install[depends] += "${@' '.join([i + ':do_image_complete' for i in d.getVar('INITRD_IMAGE_ALL').split()])}"

do_deploy() {
    install -d ${DEPLOYDIR}
    echo "${SUMMARY}" > ${DEPLOYDIR}/${PN}-${DISTRO}-${MACHINE}
}
addtask deploy before do_build after do_compile

FILES_${PN} += "/boot"

# Provide empty package to allow direct use on image side even with none InitRD
ALLOW_EMPTY_${PN} = "1"
