#!/bin/sh

#add stm32_eth_config script to enable USB Ethernet & MSC gadget This script configures USB Gadget
#configfs to use USB OTG as a USB Ethernet Gadget with Remote NDIS (RNDIS), well supported by Microsoft
#Windows and Linux.

configfs="/sys/kernel/config/usb_gadget"
g=g1
c=c.1
d="${configfs}/${g}"
func_eth=rndis.0
func_ms=mass_storage.0

VENDOR_ID="0x1d6b"
PRODUCT_ID="0x0104"

IP="192.168.7.2"
NETMASK="255.255.255.0"

#MAC address for ethernet-over-USB can be defined here
MAC_HOST_CUST=""
MAC_DEV_CUST=""

get_mac_address_from_serial_number(){
    sha1sum /proc/device-tree/serial-number \
    | fold -1 \
    | sed -n '1{h;d};2{y/1235679abdef/000444888ccc/;H;d};13{g;s/\n//g;p;q};s/^/:/;N;H;d'
}

do_start() {
    if [ ! -d ${configfs} ]; then
        modprobe libcomposite
        if [ ! -d ${configfs} ]; then
        exit 1
        fi
    fi

    if [ -d ${d} ]; then
        exit 0
    fi

    udc=$(ls -1 /sys/class/udc/)
    if [ -z $udc ]; then
        echo "No UDC driver registered"
        exit 1
    fi

    mkdir "${d}"
    echo ${VENDOR_ID} > "${d}/idVendor"
    echo ${PRODUCT_ID} > "${d}/idProduct"
    echo 0x0200 > "${d}/bcdUSB"
    echo "0xEF" > "${d}/bDeviceClass"
    echo "0x02" > "${d}/bDeviceSubClass"
    echo "0x01" > "${d}/bDeviceProtocol"
    echo "0x0100" > "${d}/bcdDevice"

    mkdir -p "${d}/strings/0x409"
    tr -d '\0' < /proc/device-tree/serial-number > "${d}/strings/0x409/serialnumber"
    echo "STMicroelectronics" > "${d}/strings/0x409/manufacturer"
    echo "STM32MP1" > "${d}/strings/0x409/product"

    # Config
    mkdir -p "${d}/configs/${c}"
    mkdir -p "${d}/configs/${c}/strings/0x409"
    echo "Config 1: RNDIS" > "${d}/configs/${c}/strings/0x409/configuration"
    echo 250 > "${d}/configs/${c}/MaxPower"
    echo 0xC0 > "${d}/configs/${c}/bmAttributes" # self powered device

    # Windows extension to force RNDIS config
    mkdir -p "${d}/os_desc"
    echo "1" > "${d}/os_desc/use"
    echo "0xbc" > "${d}/os_desc/b_vendor_code"
    echo "MSFT100" > "${d}/os_desc/qw_sign"

    mkdir -p "${d}/functions/${func_eth}"
    mkdir -p "${d}/functions/${func_eth}/os_desc/interface.rndis"
    echo "RNDIS" > "${d}/functions/${func_eth}/os_desc/interface.rndis/compatible_id"
    echo "5162001" > "${d}/functions/${func_eth}/os_desc/interface.rndis/sub_compatible_id"

    if [ "$MAC_HOST_CUST" != "" ]; then
        echo $MAC_HOST_CUST > "${d}/functions/${func_eth}/host_addr"
    else
        mac_host=$(get_mac_address_from_serial_number)
        echo $mac_host > "${d}/functions/${func_eth}/host_addr"
    fi
    if [ "$MAC_DEV_CUST" != "" ]; then
        echo $MAC_DEV_CUST > "${d}/functions/${func_eth}/dev_addr"
    fi


    # Set up the rndis device only first
    ln -s "${d}/functions/${func_eth}" "${d}/configs/${c}"
    ln -s "${d}/configs/${c}" "${d}/os_desc"

    echo "${udc}" > "${d}/UDC"

    sleep 0.2

    interfacename=$(cat ${d}/functions/${func_eth}/ifname 2> /dev/null)
    if [ -z "${interfacename}" ];
    then
        interfacename=usb0
    fi
    # ifconfig ${interfacename} $IP netmask $NETMASK
    ifconfig ${interfacename} up
}

do_stop() {
    interfacename=$(cat ${d}/functions/${func_eth}/ifname 2> /dev/null)
    if [ -z "${interfacename}" ];
    then
        echo "Nothing to do"
        return
    fi
    ifconfig ${interfacename} down

    sleep 0.2

    echo "" > "${d}/UDC"

    rm -f "${d}/os_desc/${c}"
    [ -d "${d}/configs/${c}/${func_eth}" ] &&rm -f "${d}/configs/${c}/${func_eth}"

    [ -d "${d}/strings/0x409/" ] && rmdir "${d}/strings/0x409/"
    [ -d "${d}/configs/${c}/strings/0x409" ] && rmdir "${d}/configs/${c}/strings/0x409"
    [ -d "${d}/configs/${c}" ] && rmdir "${d}/configs/${c}"
    [ -d "${d}/functions/${func_eth}" ] && rmdir "${d}/functions/${func_eth}"
    [ -d "${d}" ] && rmdir "${d}"
}

case $1 in
    start)
        echo "Start usb gadget"
        do_start $2
        ;;
    stop)
        echo "Stop usb gadget"
        do_stop
        ;;
    *)
        echo "Usage: $0 (stop | start)"
        ;;
esac
