#!/bin/sh
. /usr/local/nagios/libexec/utils.sh

while [ "$1" != "" ]; do
    case $1 in
        -J | --jail )           shift
                                JAIL=$1
                                ;;
esac
shift
done

if [ -z $JAIL ]; then
	echo "UNKNOWN: no jail param"
	exit $STATE_UNKOWN
fi

#echo "$JAIL"
JAILIP=$(sudo jexec $JAIL curl -s icanhazip.com)
MYIP=$(curl -s icanhazip.com)
#JAILIP=$(curl -s icanhazip.com)

if [ "$JAILIP" = "$MYIP" ]; then
	echo "CRITICAL - my IP: $MYIP same as $JAIL jail: $JAILIP"
	exit $STATE_CRITICAL
else
	echo "OK - my IP: $MYIP differs than $JAIL jail: $JAILIP"
	exit $STATE_OK
fi

