DEPENDS:append = " cairo "

do_install:append() {
    # Hack: the directory are not present and at image creation, sysprof post installation failed
    install -d ${D}${datadir}/glib-2.0/schemas
    touch ${D}${datadir}/glib-2.0/schemas/sysprof.txt
}
