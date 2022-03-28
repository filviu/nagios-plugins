#!/bin/bash
. /usr/local/nagios/libexec/utils.sh

function usage {
    echo "Usage: check_isdcttemp.sh -H host -W warn -C crit"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-D, --disk"
    echo "   Device to check temperature"
    echo "-W, --warn"
    echo "   Warning temperature level"
    echo "-C, --crit"
    echo "   Critical temperature level"
    echo
    echo "Example: check_sshwltemp -H router.example.com -W 50 -C 55"
    echo
    echo "Note: since most routers can't have a nagios user you should set the user in .ssh/config"
    echo
    exit
}

while [ "$1" != "" ]; do
    case $1 in
        -D | --disk )           shift
                                DISKDEV=$1
                                ;;
        -C | --crit )           shift
                                CRIT=$1
                                ;;
        -W | --warn )           shift
                                WARN=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
esac
shift
done

if [ -z "$DISKDEV" ]; then
        echo "Missing disk parameter"
        echo "See $0 --help for usage information"
        exit ${STATE_UNKNOWN}
fi

if [ -z "$WARN" ]; then
        echo "Missing warning parameter"
        echo "See $0 --help for usage information"
        exit ${STATE_UNKNOWN}
fi
if ! [[ $WARN =~ $numre ]]; then
        echo "Warning level $WARN is not an integer"
        exit ${STATE_UNKNOWN}
fi

if [ -z "$CRIT" ]; then
        echo "Missing critical parameter"
        echo "See $0 --help for usage information"
        exit ${STATE_UNKNOWN}
fi
if ! [[ $CRIT =~ $numre ]]; then
        echo "Critical level $CRIT is not an integer"
        exit ${STATE_UNKNOWN}
fi
if [ $CRIT -lt $WARN ]; then
        echo "Critical level $CRIT is lower than the warning level $WARN"
        exit ${STATE_UNKNOWN}
fi

TEMPDEG=$(sudo nvme smart-log /dev/nvme0|grep "^temperature"|cut -d " " -f 2)

if [ $TEMPDEG -lt $WARN ]; then
        echo "Temperature OK: ${TEMPDEG}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$TEMPDEG;$WARN;$CRIT;;"
        exit ${STATE_OK}
elif [ $TEMPDEG -ge $WARN ]&&[ $TEMPDEG -lt $CRIT ]; then
        echo "Temperature WARNING: ${TEMPDEG}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$TEMPDEG;$WARN;$CRIT;;"
        exit ${STATE_WARNING}
else
        echo "Temperature CRITICAL: ${TEMPDEG}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$TEMPDEG;$WARN;$CRIT;;"
        exit ${STATE_CRITICAL}
fi
