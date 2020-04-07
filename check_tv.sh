#!/bin/bash
#
# A simple script thought to monitor TV usage.

function usage {
    echo "Usage: check_tv.sh -H TV_HOST_OR_IP ]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-H --host"
    echo "   Remote host to monitor"
    exit
}

if [ $# = 0 ]; then
    echo "UNKNOWN - missing parameters, see -h, --help"
    exit 3
fi

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit 
                                ;;
        -H | --host )           shift
                                HOST=$1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

ping -c1 -w1 $1 $HOST > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Tv is ON | usage=100;;;"
    exit 0
else
    echo "Tv is OFF | usage=0;;;"
    exit 0
fi
