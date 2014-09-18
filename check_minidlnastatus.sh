#!/bin/bash
function usage {
    echo "Usage: check_minidlnastatus.sh -p twitter_username]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-H, --host"
    echo "   Hostname where minidlna runs"
    echo "-p, --port"
    echo "   Port for MiniDLNA status page"
    exit
}

if [ $# = 0 ]; then
    echo "UNKNOWN - missing parameters, see -h, --help"
    exit 3
fi

while [ "$1" != "" ]; do
    case $1 in
        -p | --port )           shift
                                PORT=$1
                                ;;
        -H | --host )           shift
                                HOST=$1
                                ;;
        -h | --help )           usage
                                exit 
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

STATUS=0

DATA=`curl -s ${HOST}:${PORT}` || STATUS=1

AUDIO=$(echo $DATA | egrep -o 'Audio files: [0-9]+' | egrep -o '[0-9]+')
VIDEO=$(echo $DATA | egrep -o 'Video files: [0-9]+' | egrep -o '[0-9]+')
IMAGE=$(echo $DATA | egrep -o 'Image files: [0-9]+' | egrep -o '[0-9]+')

if [ $((STATUS)) -eq 0 ]; then
    echo "MiniDLNA OK | audio=${AUDIO}files;;;; video=${VIDEO}files;;;; image=${IMAGE}files;;;;"
elif [ $((STATUS)) -eq 1 ]; then
    echo "MiniDLNA unreachable"
fi
exit $STATUS
