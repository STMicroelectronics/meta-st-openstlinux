# The goal of this class are to check if the layers are compatible with OpenSTLinux version.
# The verification are based on ST_OSTL_COMPATIBILTY_VERSION variable defined on layer.conf

def check_sanity_ostl(sanity_data):
    ref_layer = "st-openstlinux"
    ref_version = d.getVar("ST_OSTL_COMPATIBILITY_VERSION_%s" % ref_layer, None)

    #bb.warn("OSTL: reference version: %s" % ref_version)
    layerlist = set((d.getVar("BBFILE_COLLECTIONS") or "").split())
    for layername in layerlist:
        versions = d.getVar("ST_OSTL_COMPATIBILITY_VERSION_%s" % layername)
        if versions is None:
            versions = d.getVar("ST_OSTL_COMPATIBILTY_VERSION_%s" % layername)
        if versions is not None:
            if not ref_version in versions:
                raise_sanity_error("OSTL: layer %s (ver = %s) are not compatible with OpenSTlinux (Version = %s)" % (layername, versions, ref_version), sanity_data)
                os._exit(1)


addhandler check_sanity_ostl_version_eventhandler
check_sanity_ostl_version_eventhandler[eventmask] = "bb.event.SanityCheck"
python check_sanity_ostl_version_eventhandler() {
    check_sanity_ostl(e.data)
}
