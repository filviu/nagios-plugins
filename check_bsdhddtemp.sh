#!/bin/bash
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
. $PROGPATH/utils.sh

function usage {
    echo "Usage: check_bsdhddtemp.sh d /dev/ada0 -c 43 -w 40 ]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-c, --crit"
    echo "   Critical temperature"
    echo "-w, --warn"
    echo "   Warning temperature"
    echo
    echo "If multiple cores the highest core temperature will be considered for alerting"
    exit
}


TEXTOUT=""
PERFOUT=""
MAXTEMP=0

while [ "$1" != "" ]; do
    case $1 in
        -d | --disk )           shift
                                DISK=$1
                                ;;
        -c | --crit )           shift
                                CRIT=$1
                                ;;
        -w | --warn )           shift
                                WARN=$1
                                ;;
	-t | --tmin )		shift
				TMIN=$1
				;;
	-m | --tmax )		shift
				TMAX=$1
				;;
        -h | --help )           usage
                                exit
                                ;;
    esac
    shift
done

if [ $((WARN)) -gt $((CRIT)) ]; then
	echo "Mismatch, warning temperature greater than critical temperature or one of them is missing"
	exit $STATE_UNKNOWN
fi


if [ -z $WARN ] && [ -z $CRIT ]; then
	echo "OK ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_OK
fi

HDDTEMP=$(sudo smartctl -a $DISK | grep Temperature| awk '{ print $10 }')
TEXTOUT="${DISK}: ${HDDTEMP} deg. C"
PERFOUT="$(basename $DISK)=${HDDTEMP};${WARN};${CRIT};${TMIN};${TMAX} "

if [ $((HDDTEMP)) -lt $((WARN)) ]; then
	echo "OK ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_OK
elif [ $((HDDTEMP)) -gt $((CRIT)) ]; then
	echo "CRITICAL ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_CRITICAL
else
	echo "WARNING ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_WARNING
fi
