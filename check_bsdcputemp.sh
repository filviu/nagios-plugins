#!/bin/bash
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
. $PROGPATH/utils.sh

function usage {
    echo "Usage: check_bsdcputemp.sh -c 800 -w 700 ]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-c, --crit"
    echo "   Critical temperature without coma or symbol. "
    echo "   e.g. 64.5 deg. C is -c 645"
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

while read TEMPLINE; do
	CPU=$(echo $TEMPLINE | awk -F. '{ print $3 }')
	TEMPDEG=$(echo $TEMPLINE | awk '{ print $2 }')
	TEMPNUM=$(echo $TEMPDEG | cut -c 1,2,4)
	TEXTOUT=${TEXTOUT}"CPU"${CPU}": "$TEMPDEG", "
	PERFOUT="${PERFOUT}cpu${CPU}=${TEMPNUM};${WARN};${CRIT};${TMIN};${TMAX} "
	if [ $((TEMPNUM)) -gt $((MAXTEMP)) ]; then
		MAXTEMP=$((TEMPNUM))
	fi
done < <(sysctl -a | grep temperature|sort)

if [ -z $WARN ] && [ -z $CRIT ]; then
	echo "OK ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_OK
fi

if [ $((MAXTEMP)) -lt $((WARN)) ]; then
	echo "OK ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_OK
elif [ $((MAXTEMP)) -gt $((CRIT)) ]; then
	echo "CRITICAL ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_CRITICAL
else
	echo "WARNING ${TEXTOUT} | ${PERFOUT}"
	exit $STATE_WARNING
fi
