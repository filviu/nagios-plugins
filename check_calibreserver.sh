#!/bin/bash
function usage {
    echo "Usage: check_calibre-serverstatus.sh -p twitter_username]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-H, --host"
    echo "   Hostname where calibre-server runs"
    echo "-p, --port"
    echo "   Port for calibre-server status page"
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

BKS=$(curl -s ${HOST}:${PORT}/ajax/search?num=0 | grep total_num| egrep -o '[0-9]+') || STATUS=1
AUTHORS_URL=$(curl -s ${HOST}:${PORT}/ajax/categories | grep -B2 Authors | grep url | awk -F\" '{print $4}') || STATUS=1
SERIES_URL=$(curl -s ${HOST}:${PORT}/ajax/categories | grep -B2 "\"Series\"" | grep url | awk -F\" '{print $4}') || STATUS=1
AUTHORS=$(curl -s ${HOST}:${PORT}${AUTHORS_URL}?num=0 | grep total_num| egrep -o '[0-9]+') || STATUS=1
SERIES=$(curl -s ${HOST}:${PORT}${SERIES_URL}?num=0 | grep total_num| egrep -o '[0-9]+') || STATUS=1
if [ $((STATUS)) -eq 0 ]; then
    echo "calibre-server OK - ${BKS} books by ${AUTHORS} authors in ${SERIES} series | books=${BKS}books;; authors=${AUTHORS}authors;; series=${SERIES}series;;"
elif [ $((STATUS)) -eq 1 ]; then
    echo "calibre-server unreachable"
fi

exit $STATUS
