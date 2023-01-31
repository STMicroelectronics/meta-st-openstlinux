FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-basesink-Add-GST_BASE_SINK_FLOW_DROPPED-return-value.patch \
    "
