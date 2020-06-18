SUMMARY = "USB ip tools"
DESCRIPTION = "USB ip tools from linux kernel"
HOMEPAGE = "https://www.kernel.org"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PV = "2.0"
PR = "r1"

SRC_URI += " \
    file://99-usb-usbip.rules \
    file://stm32mp-usbip-bind-unbind.sh \
    file://usb.ids \
    file://usbip.service \
    file://usbip.conf \
    "

DEPENDS = " \
    tcp-wrappers \
    systemd \
    "

USBIP_SRC ?= "tools/usb/usbip"

do_configure[depends] += "virtual/kernel:do_shared_workdir"

inherit linux-kernel-base kernel-arch manpages

do_populate_lic[depends] += "virtual/kernel:do_patch"

inherit kernelsrc

S = "${WORKDIR}/tools/usb/usbip"

inherit autotools gettext pkgconfig systemd

SYSTEMD_SERVICE_${PN} = "usbip.service"
SYSTEMD_AUTO_ENABLE_${PN} = "disable"

EXTRA_OECONF += "--with-tcp-wrappers"

do_configure[prefuncs] += "copy_usbip_source_from_kernel"
do_configure[prefuncs] += "base_do_unpack"

python copy_usbip_source_from_kernel() {
    sources = (d.getVar("USBIP_SRC") or "").split()
    src_dir = d.getVar("STAGING_KERNEL_DIR")
    dest_dir = d.getVar("WORKDIR")
    bb.utils.mkdirhier(dest_dir)
    for s in sources:
        src = oe.path.join(src_dir, s)
        dest = oe.path.join(dest_dir, s)
        if not os.path.exists(src):
            bb.fatal("Path does not exist: %s. Maybe USBIP_SRC does not match the kernel version." % src)
        if os.path.isdir(src):
            oe.path.copyhardlinktree(src, dest)
        else:
            src_path = os.path.dirname(s)
            os.makedirs(os.path.join(dest_dir,src_path),exist_ok=True)
            bb.utils.copyfile(src, dest)
}

do_install_append() {
    install -d ${D}${datadir}/hwdata/
    install -m 0644 ${WORKDIR}/usb.ids ${D}${datadir}/hwdata/

    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/stm32mp-usbip-bind-unbind.sh ${D}${sbindir}/

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/99-usb-usbip.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${sysconfdir}/modprobe.d/
    install -m 0644 ${WORKDIR}/usbip.conf ${D}${sysconfdir}/modprobe.d/

    install -d ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/usbip.service ${D}${systemd_system_unitdir}/
}
FILES_${PN} += "${datadir}/hwdata/ ${sbindir} ${sysconfdir}/udev/rules.d/ ${systemd_system_unitdir}/ ${sysconfdir}/modprobe.d/"
