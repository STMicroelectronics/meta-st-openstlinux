#@DESCRIPTION: ST GPLv3 exception

#--------------------------
# License settings
#
# We dont want (L)GPL-3.0+
INCOMPATIBLE_LICENSE = "GPLv3.0 GPLv3 GPL-3.0 GPLv3+ LGPLv3.0 LGPLv3 LGPL-3.0 LGPLv3+"

OPENSTLINUX_ALLOW_GPLv3 = "gettext"
# for alsa-utils:
OPENSTLINUX_ALLOW_GPLv3 =+ " gettext bash "
# for systemd
OPENSTLINUX_ALLOW_GPLv3 =+ " bash readline "
# for udev:
OPENSTLINUX_ALLOW_GPLv3 =+ " gawk coreutils gdbm m4 "
# for bluez
OPENSTLINUX_ALLOW_GPLv3 =+ " python3-pycairo "
# for framework-tools-ui
OPENSTLINUX_ALLOW_GPLv3 =+ " grep dosfstools elfutils cpio gzip which "

OPENSTLINUX_ALLOW_GPLv3 += "${@bb.utils.contains('DISTRO_FEATURES', 'tpm', 'nano msmtp', '', d)}"

INCOMPATIBLE_LICENSE_EXCEPTIONS:LGPL-3.0-or-later = "${OPENSTLINUX_ALLOW_GPLv3}"
INCOMPATIBLE_LICENSE_EXCEPTIONS:LGPL-3.0-only = "${OPENSTLINUX_ALLOW_GPLv3}"
INCOMPATIBLE_LICENSE_EXCEPTIONS:GPL-3.0-only = "${OPENSTLINUX_ALLOW_GPLv3}"
INCOMPATIBLE_LICENSE_EXCEPTIONS:GPL-3.0-or-later = "${OPENSTLINUX_ALLOW_GPLv3}"

