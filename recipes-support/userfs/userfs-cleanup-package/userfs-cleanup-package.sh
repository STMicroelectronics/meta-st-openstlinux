#! /bin/sh
### BEGIN INIT INFO
# remove package which are present on the database but not present on userfs
### END INIT INFO

DESC="cleanup apt database"

get_type() {
    local  __resultvar=$1
    ROOT_TYPE="unknown"
    if [ -f /usr/bin/findmnt ];
    then
        ROOT_DEVICE=$(findmnt --noheadings --output=SOURCE / | cut -d'[' -f1)
        case $ROOT_DEVICE in
        ubi*)
            ROOT_TYPE="nand"
            ;;
        /dev/mmcblk0*)
            ROOT_TYPE="sdmmc"
            ;;
        /dev/mmcblk1*)
            ROOT_TYPE="mmc"
            ;;
        esac
    else
        if [ `cat /proc/cmdline | sed "s/.*mmcblk0.*/mmcblk0/" ` == "mmcblk0" ]; then
            ROOT_TYPE="sdmmc"
        elif [ `cat /proc/cmdline | sed "s/.*mmcblk1.*/mmcblk1/" ` == "mmcblk1" ]; then
            ROOT_TYPE="mmc"
        elif [ `cat /proc/cmdline | sed "s/.*ubi0.*/ubi0/" ` == "ubi0" ]; then
            ROOT_TYPE="nand"
        elif [ `cat /proc/cmdline | sed "s/.*nfsroot.*/nfs/" ` == "nfs" ]; then
            ROOT_TYPE="nfs"
        fi
    fi
    eval $__resultvar="'$ROOT_TYPE'"
}

found_devices() {
    local __resultvar=$1
    local __resultopt=$2
    local _type=$3
    local _search=$4
    local _device="unknown"
    local _option=" "
    case $_type in
        nand)
            local ubi_volumes=$(ls -1 -d /sys/class/ubi/ubi0_*)
            for f in $ubi_volumes;
            do
                if [ -r $f/name ];
                then
                    cat $f/name | grep -sq "^${_search}"
                    if [ "$?" -eq 0 ];
                    then
                        _device="/dev/$(basename $f)"
                        _option="-t ubifs"
                        break;
                    fi
                fi
            done
            ;;
        sdmmc)
            local sdmmc_parts=$(ls -1 -d /sys/block/mmcblk0/mmcblk0p*)
            for f in $sdmmc_parts;
            do
                if [ -r $f/uevent ];
                then
                    cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}"
                    if [ "$?" -eq 0 ];
                    then
                        _device="/dev/$(basename $f)"
                        break;
                    fi
                fi
            done
            ;;
        mmc)
            local mmc_parts=$(ls -1 -d /sys/block/mmcblk1/mmcblk1p*)
            for f in $mmc_parts;
            do
                if [ -r $f/uevent ];
                then
                    cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}"
                    if [ "$?" -eq 0 ];
                    then
                        _device="/dev/$(basename $f)"
                        break;
                    fi
                fi
            done
            ;;
        nfs)
            $_device="/dev/nfs"
            ;;
    esac
    eval $__resultvar="'$_device'"
    eval $__resultopt="'$_option'"
}

case $1 in
    start)
        echo "Starting $DESC"
        get_type TYPE
        found_devices DEVICE DEVICE_OPTION $TYPE userfs
        if [ "$DEVICE" = "/dev/null" ];
        then
            # nfs file system, do nothing
            exit 0
        fi
        case $DEVICE in
        unknown)
            # userfs partition are not present
            # we need to cleanup apt database
            grep -l "^/usr/local/" /var/lib/dpkg/info/* | sed -e "s|/var/lib/dpkg/info/\(.*\).list|\1|" | xargs apt-get purge -y
            echo "USERFS NOT PRESENT: CLEAN DPKG DATABASE" > /dev/kmsg
            ;;
        /dev/nfs)
             # nfs file system, do nothing
            exit 0
            ;;
        /dev/*)
            # userfs are present, do nothing
            ;;
        esac
        ;;
    *)
        echo "Usage: @sysconfdir@/init.d/userfs-cleanup-package.sh {start}" >&2
        exit 1
    ;;
esac

exit 0

# vim:noet
