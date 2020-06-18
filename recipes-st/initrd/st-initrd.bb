SUMMARY = "ST InitRD installation package for ${INITRD_IMAGE} image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# We provide an InitRD specific to machine
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

S = "${WORKDIR}"

INITRD_IMAGE ?= ""
INITRD_SHORTNAME ?= "uInitrd"

do_install() {
    if [ -z "${INITRD_IMAGE}" ]; then
        bbnote "No InitRD file set"
        return
    fi

    echo "Copying InitRD file into ./boot/ ..."
    INITRD_IMAGE_FILE=$(find ${DEPLOY_DIR_IMAGE} -name ${INITRD_IMAGE}*-${MACHINE}.${INITRAMFS_FSTYPES})
    if [ -e "${INITRD_IMAGE_FILE}" ]; then
        install -d ${D}/boot
        install -m 0644 ${INITRD_IMAGE_FILE} ${D}/boot/${INITRD_SHORTNAME}
    else
        bbfatal "Could not find ${INITRD_IMAGE}*-${MACHINE}.${INITRAMFS_FSTYPES} image file in ${DEPLOY_DIR_IMAGE} folder"
    fi
}
do_install[depends] += "${@['${INITRD_IMAGE}:do_image_complete', '']['${INITRD_IMAGE}' == ""]}"

do_deploy() {
    install -d ${DEPLOYDIR}
    echo "${SUMMARY}" > ${DEPLOYDIR}/${PN}-${DISTRO}-${MACHINE}
}
addtask deploy before do_build after do_compile

FILES_${PN} += "/boot"
