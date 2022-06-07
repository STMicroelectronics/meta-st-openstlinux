RDEPENDS:${PN}:remove = "${PN}-scp ${PN}-ssh ${PN}-sshd ${PN}-keygen"
#the dependency are put on packagegroup
RRECOMMENDS:${PN}-dev:remove = "openssh-keygen-dev update-alternatives-opkg-dev libcrypto-dev pam-plugin-keyinit-dev pam-plugin-loginuid-dev shadow-sysroot-dev"
RDEPENDS:${PN}-dev = ""
RRECOMMENDS:${PN}-dev:append = "openssh"
