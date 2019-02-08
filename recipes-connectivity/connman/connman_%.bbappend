# Disable connman service at startup
SYSTEMD_AUTO_ENABLE_${PN} = "disable"

# Set low alternative priority for resolv-conf to keep systemd by default
ALTERNATIVE_PRIORITY[resolv-conf] = "10"
