#!/bin/bash
function usage {
    echo "Usage: check_copsserver.sh -U cops_server_url"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-U, --url"
    echo "   URL where COPS is to be found"
    echo "   (e.g. http://yourserver.com/cops) no trailing slash!"
    exit
}

if [ $# = 0 ]; then
    echo "UNKNOWN - missing parameters, see -h, --help"
    exit 3
fi

while [ "$1" != "" ]; do
    case $1 in
        -U | --url )            shift
                                URL=$1
                                ;;
        -h | --help )           usage
                                exit 
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [[ -z "${URL}" ]]; then
    echo "UNKNOWN - missing URL parameter, see --help"
    exit 3
fi

STATUS=0

AUTHORS=$(curl -s ${URL}/getJSON.php | grep -Po '"content":.*?[^\\]",' | grep "authors" | egrep -o '[0-9]+')
  BOOKS=$(curl -s ${URL}/getJSON.php | grep -Po '"content":.*?[^\\]",' | grep "index of" | grep "books" | egrep -o '[0-9]+')
 SERIES=$(curl -s ${URL}/getJSON.php | grep -Po '"content":.*?[^\\]",' | grep "series" | egrep -o '[0-9]+')

if [ $((STATUS)) -eq 0 ]; then
    echo "calibre-server OK - ${BOOKS} books by ${AUTHORS} authors in ${SERIES} series | books=${BOOKS}books;; authors=${AUTHORS}authors;; series=${SERIES}series;;"
elif [ $((STATUS)) -eq 1 ]; then
    echo "calibre-server unreachable"
fi

exit $STATUS
