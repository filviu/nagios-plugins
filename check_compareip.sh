#!/bin/sh
. /usr/local/nagios/libexec/utils.sh

while [ "$1" != "" ]; do
    case $1 in
        -H | --host )           shift
                                REMOTEHOST=$1
                                ;;
esac
shift
done

if [ -z $REMOTEHOST ]; then
        echo "UNKNOWN: no remote host param"
        exit $STATE_UNKOWN
fi

#echo "$REMOTEHOST"
REMOTEHOSTIP=$(ssh $REMOTEHOST curl -s icanhazip.com)
MYIP=$(curl -s icanhazip.com)
#REMOTEHOSTIP=$(curl -s icanhazip.com) # useful to debug

if [ "$REMOTEHOSTIP" = "$MYIP" ]; then
        echo "CRITICAL - my IP: $MYIP same as the $REMOTEHOST remote host: $REMOTEHOSTIP"
        exit $STATE_CRITICAL
else
        echo "OK - my IP: $MYIP differs than the $REMOTEHOST remote host: $REMOTEHOSTIP"
        exit $STATE_OK
fi

