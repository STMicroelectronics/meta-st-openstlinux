# Fix for commit: mesa: ship /etc/drirc in mesa-megadriver (SHA1 fbb688ab3eeca1bbfbaaaaffd8c81fd8052bcc68)
# mesa package is reset to null, so need to allow empty package
ALLOW_EMPTY_${PN} = "1"
