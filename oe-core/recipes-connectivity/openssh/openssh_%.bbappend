RDEPENDS_${PN}_remove = "${PN}-scp ${PN}-ssh ${PN}-sshd ${PN}-keygen"
#the dependency are put on packagegroup
RRECOMMENDS_${PN}-dev_remove = "openssh-keygen-dev update-alternatives-opkg-dev libcrypto-dev pam-plugin-keyinit-dev pam-plugin-loginuid-dev shadow-sysroot-dev"
RDEPENDS_${PN}-dev = ""
RRECOMMENDS_${PN}-dev_append = "openssh"
