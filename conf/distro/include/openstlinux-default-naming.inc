#@DESCRIPTION: openstlinux default distro naming

# Init OPENSTLINUX_RELEASE flag to snapshot
OPENSTLINUX_RELEASE ??= "snapshot"

DISTRO = "openstlinux"
DISTRO_NAME = "ST OpenSTLinux (A Yocto Project Based Distro)"
DISTRO_VERSION = "5.0.8-${@bb.utils.contains('OPENSTLINUX_RELEASE', 'snapshot', 'snapshot-${DATE}', '${OPENSTLINUX_RELEASE}', d)}"
# Don't include the DATE variable in the sstate package signatures
DISTRO_VERSION[vardepsexclude] = "DATE"
DISTRO_CODENAME = "scarthgap"

# Warning: SDK_VENDOR does not contains a valid OS/ARCH name like : linux, arm
SDK_VENDOR = "-ostl_sdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
# Don't include the DATE variable in the sstate package signatures
SDK_VERSION[vardepsexclude] = "DATE"
SDKIMAGE_FEATURES ?= "dev-pkgs dbg-pkgs src-pkgs staticdev-pkgs ${@bb.utils.contains('DISTRO_FEATURES', 'api-documentation', 'doc-pkgs', '', d)}"


MAINTAINER = "Christophe Priouzeau <christophe.priouzeau@st.com>"

# Warning: TARGET_VENDOR does not contains a valid OS/ARCH name like : linux, arm
STM32MP_TARGETVENDOR ?= "-ostl"
TARGET_VENDOR = "${STM32MP_TARGETVENDOR}"

# Append distro name to each image name
IMAGE_BASENAME:append = "-${DISTRO}"

# Add image name for generated SDK and set default SDK install folder
SDK_NAME = "${IMAGE_LINK_NAME}-${SDK_ARCH}"
SDKPATHINSTALL = "/opt/st/${MACHINE}/${SDK_VERSION}"
# Don't include the DATE variable in the sstate package signatures
SDKPATHINSTALL[vardepsexclude] = "DATE"
