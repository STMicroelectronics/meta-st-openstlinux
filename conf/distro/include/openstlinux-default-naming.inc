#@DESCRIPTION: openstlinux default distro naming

# Init OPENSTLINUX_RELEASE flag to snapshot
OPENSTLINUX_RELEASE ??= "snapshot"

DISTRO = "openstlinux"
DISTRO_NAME = "ST OpenSTLinux (A Yocto Project Based Distro)"
DISTRO_VERSION = "4.0.11-${@bb.utils.contains('OPENSTLINUX_RELEASE', 'snapshot', 'snapshot-${DATE}', '${OPENSTLINUX_RELEASE}', d)}"
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

#FIXME force keeping 3.9 uninative version instead of 4.0
UNINATIVE_VERSION:forcevariable = "3.9"

UNINATIVE_CHECKSUM[aarch64] ?= "de35708c95c34573af140da910132c3291ba4fd26ebf7b74b755ada432cdf07b"
UNINATIVE_CHECKSUM[i686] ?= "adac07b08adb88eb26fc7fd87fee0cec9d5be167bf7c5ffd3a549a2a6699c29c"
UNINATIVE_CHECKSUM[x86_64] ?= "3dd82c3fbdb59e87bf091c3eef555a05fae528eeda3083828f76cd4deaceca8b"
