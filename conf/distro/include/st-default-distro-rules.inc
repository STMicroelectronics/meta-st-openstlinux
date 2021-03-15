#@DESCRIPTION: ST default distro rules

# Set common distrooverrides for all ST distro
DISTROOVERRIDES .= ":openstlinuxcommon"

#--------------------------
# Mirror settings
#
YOCTOPROJECT_MIRROR_URL = "http://downloads.yoctoproject.org/mirror/sources/"

MIRRORS =+ "\
ftp://.*/.*    ${YOCTOPROJECT_MIRROR_URL} \n \
http://.*/.*   ${YOCTOPROJECT_MIRROR_URL} \n \
https://.*/.*  ${YOCTOPROJECT_MIRROR_URL} \n"

INHERIT += "own-mirrors"
SOURCE_MIRROR_URL ??= "${YOCTOPROJECT_MIRROR_URL}"

#--------------------------
# The CONNECTIVITY_CHECK_URI's are used to test whether we can succesfully
# fetch from the network (and warn you if not).
# URI's to check can be set in the CONNECTIVITY_CHECK_URIS variable
# using the same syntax as for SRC_URI. If the variable is not set
# the check is skipped
#
CONNECTIVITY_CHECK_URIS ?= "https://www.example.com/"

#--------------------------
# OELAYOUT_ABI allows us to notify users when the format of TMPDIR changes in
# an incompatible way. Such changes should usually be detailed in the commit
# that breaks the format and have been previously discussed on the mailing list
# with general agreement from the core team.
#
OELAYOUT_ABI = "12"

#--------------------------
# Add the manifest and the licenses file on image generated
COPY_LIC_MANIFEST = "1"

#--------------------------
# Tune build config display
#
BUILDCFG_VARS += "DISTRO_CODENAME"
BUILDCFG_VARS += "${@'ACCEPT_EULA_' + d.getVar('MACHINE')}"
BUILDCFG_VARS += "GCCVERSION"
BUILDCFG_VARS += "PREFERRED_PROVIDER_virtual/kernel"
BUILDCFG_VARS += "PREFERRED_VERSION_${PREFERRED_PROVIDER_virtual/kernel}"

#--------------------------
# Writes build information to target filesystem on /etc/build
#
IMAGE_BUILDINFO_VARS = "${BUILDCFG_VARS}"
INHERIT += "image-buildinfo"

# FORCE to use libgpiod 1.6.2
PREFERRED_VERSION_libgpiod = "1.6.2"
