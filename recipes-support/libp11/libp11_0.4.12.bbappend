FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PV = "0.4.12+${SRCPV}"
# need to have commit 74497e0fa5b69b15790d6697e1ebce13af842d4c "configure: treat all openssl-3.x releases the same"
SRC_URI = "git://github.com/OpenSC/libp11.git;branch=master;protocol=https"
SRCREV = "dd0a8c63c0311674cabfd781753e8374ff531409"
