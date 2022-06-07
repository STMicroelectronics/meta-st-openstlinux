do_configure:append() {
    # add CONFIG_P2P
    sed -i "s/^#CONFIG_P2P=y/CONFIG_P2P=y/" wpa_supplicant/.config
}
