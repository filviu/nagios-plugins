#!/bin/bash
function usage {
    echo "Usage: check_sshwl.sh -H host -W warn -C crit"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-H, --host"
    echo "   Hostname where to run wl"
    echo "-W, --warn"
    echo "   Warning temperature level"
    echo "-C, --crit"
    echo "   Critical temperature level"
    echo
    echo "Example: check_sshpftemp -H pfsense.example.com -W 50 -C 55"
    echo
    echo "Note: since most routers can't have a nagios user you should set the user in .ssh/config"
    echo
    exit
}

STATE_OK=0 # define the exit code if status is OK
STATE_WARNING=1 # define the exit code if status is Warning
STATE_CRITICAL=2 # define the exit code if status is Critical
STATE_UNKNOWN=3 # define the exit code if status is Unknown
numre='^[0-9]+$'
while [ "$1" != "" ]; do
    case $1 in
        -H | --host )           shift
                                HOST=$1
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

if [ -z "$HOST" ]; then 
	echo "Missing host parameter"
	echo "See $0 --help for usage information"
	exit ${STATE_UNKNOWN}
fi
if [ -z "$CRIT" ]; then 
	echo "Missing critical parameter"
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
if ! [[ $CRIT =~ $numre ]]; then
	echo "Critical level $CRIT is not an integer"
	exit ${STATE_UNKNOWN}
fi
if [ $CRIT -lt $WARN ]; then
	echo "Critical level $CRIT is lower than the warning level $WARN"
	exit ${STATE_UNKNOWN}
fi

RES=$(ssh $HOST "sysctl dev.amdtemp.0.core0.sensor0")
if [ $? -ne 0 ]; then
	echo "SSH connection failed"
	exit ${STATE_UNKNOWN}
fi
CTMP=$(echo $RES |awk '{ print $2 }'|tr -d C)
CTMPINT=$(echo $CTMP | awk -F. '{print $1}')

if [ $CTMPINT -lt $WARN ]; then
	echo "Temperature OK: ${CTMP}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$CTMP;$WARN;$CRIT;;"
	exit ${STATE_OK}
elif [ $CTMPINT -ge $WARN ]&&[ $CTMPINT -lt $CRIT ]; then
	echo "Temperature WARNING: ${CTMP}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$CTMP;$WARN;$CRIT;;"
	exit ${STATE_WARNING}
else
	echo "Temperature CRITICAL: ${CTMP}$(awk 'BEGIN { print "\xc2\xb0"; }')C | temp=$CTMP;$WARN;$CRIT;;"
	exit ${STATE_CRITICAL}
fi
echo "Something went wrong. Debug: crit $CRIT, warn $WARN, temp $CTMP, ssh $RES"
exit ${STATE_UNKNOWN}
