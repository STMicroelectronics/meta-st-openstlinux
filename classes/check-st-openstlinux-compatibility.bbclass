# The goal of this class are to check if the layers are compatible with OpenSTLinux version.
# The verification are based on ST_OSTL_COMPATIBILTY_VERSION variable defined on layer.conf

def check_sanity_ostl(sanity_data):
    ref_layer = "st-openstlinux"
    ref_version = d.getVar("ST_OSTL_COMPATIBILTY_VERSION_%s" % ref_layer)

    #bb.warn("OSTL: reference version: %s" % ref_version)
    layerlist = set((d.getVar("BBFILE_COLLECTIONS") or "").split())
    for layername in layerlist:
        version = d.getVar("ST_OSTL_COMPATIBILTY_VERSION_%s" % layername)
        if version is not None:
            if not version == ref_version:
                raise_sanity_error("OSTL: layer %s (ver = %s) are not compatible with OpenSTlinux (Version = %s)" % (layername, version, ref_version), sanity_data)
                os._exit(1)


addhandler check_sanity_ostl_version_eventhandler
check_sanity_ostl_version_eventhandler[eventmask] = "bb.event.SanityCheck"
python check_sanity_ostl_version_eventhandler() {
    check_sanity_ostl(e.data)
}
