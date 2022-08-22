#@DESCRIPTION: openstlinux default distro naming

# Init OPENSTLINUX_RELEASE flag to snapshot
OPENSTLINUX_RELEASE ??= "snapshot"

DISTRO = "openstlinux"
DISTRO_NAME = "ST OpenSTLinux (A Yocto Project Based Distro)"
DISTRO_VERSION = "4.0.4-${@bb.utils.contains('OPENSTLINUX_RELEASE', 'snapshot', 'snapshot-${DATE}', '${OPENSTLINUX_RELEASE}', d)}"
# Don't include the DATE variable in the sstate package signatures
DISTRO_VERSION[vardepsexclude] = "DATE"
DISTRO_CODENAME = "kirkstone"

# Warning: SDK_VENDOR does not contains a valid OS/ARCH name like : linux, arm
SDK_VENDOR = "-ostl_sdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
# Don't include the DATE variable in the sstate package signatures
SDK_VERSION[vardepsexclude] = "DATE"

MAINTAINER = "Christophe Priouzeau <christophe.priouzeau@st.com>"

# Warning: TARGET_VENDOR does not contains a valid OS/ARCH name like : linux, arm
TARGET_VENDOR = "-ostl"

# Append distro name to each image name
IMAGE_BASENAME:append = "-${DISTRO}"

# Add image name for generated SDK and set default SDK install folder
SDK_NAME = "${IMAGE_LINK_NAME}-${SDK_ARCH}"
SDKPATHINSTALL = "/opt/st/${MACHINE}/${SDK_VERSION}"
# Don't include the DATE variable in the sstate package signatures
SDKPATHINSTALL[vardepsexclude] = "DATE"
