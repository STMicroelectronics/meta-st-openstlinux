FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove:stm32mpcommon = "mozjs"
PACKAGECONFIG:append:stm32mpcommon = "duktape"
