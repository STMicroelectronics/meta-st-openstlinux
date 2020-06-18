SUMMARY = "INITRD able to resize the mmc paritions"
LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Reset IMAGE_LINGUAS to empty
IMAGE_LINGUAS = ""

# Disable partition image for InitRD image to avoid circular dependancy
# If we keep enable this feature, when building the InitRD image a dependancy
# will be added for the completion of bootfs image while we're just expecting
# to add the InitRD inside bootfs...
ENABLE_PARTITIONS_IMAGE = "0"

# Disable flashlayout generation for this particular image as this is supposed
# to be done only for complete image (bootloader binaries, bootfs, rootfs...))
ENABLE_FLASHLAYOUT_CONFIG = "0"

# Disable image license summary generation for this particular image as this is
# supposed to be done only for complete image
ENABLE_IMAGE_LICENSE_SUMMARY = "0"

# Disable generation of multi volume ubifs  for this particular image as this is
# supposed to be done only for complete image
ENABLE_MULTIVOLUME_UBI = "0"

PACKAGE_INSTALL = " \
    busybox \
    e2fsprogs \
    e2fsprogs-resize2fs \
    e2fsprogs-tune2fs \
    e2fsprogs-mke2fs \
    initramfs-module-rootfs \
    initramfs-module-udev \
    initrd-boot \
    "
