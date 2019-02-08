LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${EULA_FILE_ST};md5=${EULA_FILE_ST_MD5SUM}"
LIC_FILES_CHKSUM[vardepsexclude] += "EULA_FILE_ST"

inherit st-image-license-summary
inherit st-sdk-license-summary

EULA_FILE_ST ?= "${OPENSTLINUX_BASE}/files/licenses/ST-Proprietary"
EULA_FILE_ST_MD5SUM ?= "7cb1e55a9556c7dd1a3cae09db9cc85f"

image_copy_image_license() {
    if [ -f ${EULA_FILE_ST} ]; then
        cp ${EULA_FILE_ST} ${IMGDEPLOYDIR}/${IMAGE_NAME}.license
        cd ${IMGDEPLOYDIR}; ln -sf ${IMAGE_NAME}.license ${IMAGE_LINK_NAME}.license
    else
        bbwarn "Missing 'EULA_FILE_ST' var : no image license copied..."
    fi
}
IMAGE_POSTPROCESS_COMMAND_prepend = "image_copy_image_license;"

sdk_copy_image_license() {
    mkdir -p ${SDKDEPLOYDIR}
    if [ -f ${EULA_FILE_ST} ]; then
        cp ${EULA_FILE_ST} ${SDKDEPLOYDIR}/${TOOLCHAIN_OUTPUTNAME}.license
    else
        bbwarn "Missing 'EULA_FILE_ST' var : no image license copied..."
    fi
}
SDK_POSTPROCESS_COMMAND_prepend = "sdk_copy_image_license;"

LSB_RELASE_TIMESTAMP = "${DATE}-${TIME}"
LSB_RELASE_TIMESTAMP[vardepsexclude] += "DATE"
LSB_RELASE_TIMESTAMP[vardepsexclude] += "TIME"

update_lsbreleasedate() {
    if [ -f ${IMAGE_ROOTFS}${sysconfdir}/lsb-release ]; then
        sed -i 's/^DISTRIB_RELEASE=\(.*\)-snapshot-.*$/DISTRIB_RELEASE=\1-snapshot-'"${LSB_RELASE_TIMESTAMP}"'/' ${IMAGE_ROOTFS}${sysconfdir}/lsb-release
        sed -i 's/^DISTRIB_DESCRIPTION=\(.*\)-snapshot-.*\"/DISTRIB_DESCRIPTION=\1-snapshot-'"${LSB_RELASE_TIMESTAMP}"'\"/' ${IMAGE_ROOTFS}${sysconfdir}/lsb-release
    fi
}
ROOTFS_POSTPROCESS_COMMAND_append = "update_lsbreleasedate;"
