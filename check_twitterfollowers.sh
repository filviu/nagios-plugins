#!/bin/bash
function usage {
    echo "Usage: check_twitterfollowers [-u twitter_username]"
    echo
    echo "Options:"
    echo "-h, --help"
    echo "   Print detailed usage information"
    echo "-u, --user"
    echo "   Twitter username for which to report"
    exit
}

if [ $# = 0 ]; then
    echo "UNKNOWN - missing parameters, see -h, --help"
    exit 3
fi

while [ "$1" != "" ]; do
    case $1 in
        -u | --user )           shift
                                TWUSER=$1
                                ;;
        -h | --help )           usage
                                exit 
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

NOUSERS=`curl -s https://twitter.com/$TWUSER | grep 'data-nav="followers"' | sed -r 's/.*"([0-9]+) Followers".*/\1/'`

echo "Folowers OK: $NOUSERS followers | followers=${NOUSERS}F;;;;"
