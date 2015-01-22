#!/bin/bash
function usage {
    echo "Usage: check_zero_folder [-u twitter_username]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-p, --path"
    echo "   Path to monitor for non zero files"
    exit
}

STATE_OK=0 # define the exit code if status is OK
STATE_WARNING=1 # define the exit code if status is Warning
STATE_CRITICAL=2 # define the exit code if status is Critical
STATE_UNKNOWN=3 # define the exit code if status is Unknown

if [ $# = 0 ]; then
    echo "UNKNOWN - missing parameters, see -h, --help"
    exit $STATE_UNKNOWN
fi

while [ "$1" != "" ]; do
    case $1 in
        -p | --path )           shift
                                CHKPATH=$1
                                ;;
        -h | --help )           usage
                                exit $STATE_UNKNOWN
                                ;;
        * )                     usage
                                exit $STATE_UNKNOWN
    esac
    shift
done

if [ ! -d "$CHKPATH" ]; then
    echo "Missing $CHKPATH or not sufficient permissions"
    exit $STATE_UNKNOWN
fi

MESSAGE=""
while read FILE; do
    echo $FILE
    if [ -s "${CHKPATH}/${FILE}" ]; then
	MESSAGE="${MESSAGE}${FILE}; "
    fi
done < <(ls -1 "$CHKPATH")

if [ -z "$MESSAGE" ]; then
    echo "OK: Path $CHKPATH has all files empty"
    exit $STATE_OK
else
    echo "WARNING: Non empty files at $CHKPATH $MESSAGE"
    exit $STATE_WARNING
fi
