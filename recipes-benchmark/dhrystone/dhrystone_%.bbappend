FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Force to not use "fstack-protector-strong" for better performance
SECURITY_STACK_PROTECTOR = ""
