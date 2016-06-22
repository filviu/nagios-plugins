#!/bin/sh
#
# check_apcupsd_ng 1.0
#
# Nagios plugin to monitor APC Smart-UPSes using apcupsd. 
# Modified from Martin Toft's check_apcupsd 1.2 by Ben Shephard
# http://bshephard.com/?p=1119
#
# Copyright (c) 2008 Martin Toft <mt@martintoft.dk>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
#
# Example configuration
#
# commands.cfg:
#
# define command {
#         command_name check_apcupsd
#         command_line $USER1$/check_apcupsd -w $ARG2$ -c $ARG3$ $ARG1$
#         }
# 
# define command {
#         command_name check_apcupsd_no_notify
#         command_line $USER1$/check_apcupsd $ARG1$
#         }
#
# ups1.cfg:
#
# define service {
#         use generic-service
#         host_name ups1
#         service_description CHARGE
#         check_command check_apcupsd!bcharge!95!50
#         }
# 
# define service {
#         use generic-service
#         host_name ups1
#         service_description TEMP
#         check_command check_apcupsd!itemp!35!40
#         }
# 
# define service {
#         use generic-service
#         host_name ups1
#         service_description LOAD
#         check_command check_apcupsd!loadpct!70!85
#         }
# 
# define service {
#         use generic-service
#         host_name ups1
#         service_description TIMELEFT
#         check_command check_apcupsd_no_notify!timeleft
#         }
#
#define service {
#        use generic-service
#        host_name ups1
#        service_description BATTERY VOLTAGE
#        check_command check_apcupsd!battv!25!24
#        }
#
#define service {
#        use generic-service
#        host_name ups1
#        service_description LINE VOLTAGE
#        check_command check_apcupsd!linev!245!250
#        }
#
#define service {
#        use generic-service
#        host_name ups1
#        service_description OUTPUT VOLTAGE
#        check_command check_apcupsd!outputv!245!250
#        }
#
#define service {
#        use generic-service
#        host_name ups1
#        service_description LINE FREQUENCY
#        check_command check_apcupsd!linefreq!51!52
#        }
#
#
APCACCESS=/sbin/apcaccess

usage()
{
	echo "usage: check_apcupsd [-c critical_value] [-h hostname] [-p port]"
	echo -n "                     [-w warning_value] "
	echo "<bcharge|itemp|loadpct|timeleft>"
	echo
	echo "hostname and port defaults to localhost and 3551, respectively."
	echo
	echo "checks:"
	echo "    bcharge  = battery charge, measured in percent."
	echo "    itemp    = internal temperature, measured in degree Celcius."
	echo "    loadpct  = load percent, measured in percent (do'h!)."
	echo "    timeleft = time left with current battery charge and load,"
	echo "               measured in minutes."
	echo "    linev    = Line Voltage"
        echo "    battv    = Battery Voltage"
	echo "    outputv  = UPS Output Voltage"
	echo "    linefreq = Line Frequency"
	exit 3
}

HOSTNAME=localhost
PORT=3551

while getopts c:h:p:w: OPTNAME; do
	case "$OPTNAME" in
	h)
		HOSTNAME="$OPTARG"
		;;
	p)
		PORT="$OPTARG"
		;;
	w)
		WARNVAL="$OPTARG"
		;;
	c)
		CRITVAL="$OPTARG"
		;;
	*)
		usage
		;;
	esac
done

ARG="$@"
while [ $OPTIND -gt 1 ]; do
	ARG=`echo "$ARG" | sed 's/^[^ ][^ ]* *//'`
	OPTIND=$(($OPTIND-1))
done

if [ "$ARG" != "bcharge" -a "$ARG" != "itemp" -a "$ARG" != "loadpct" \
	-a "$ARG" != "timeleft" -a "$ARG" != "linev" -a "$ARG" != "battv" \
	-a "$ARG" != "outputv" -a "$ARG" != "linefreq" ]; then
	usage
fi

if [ "`echo $PORT | grep '^[0-9][0-9]*$'`" = "" ]; then
	echo "Error: port must be a positive integer!"
	exit 3
fi

if [ "$WARNVAL" != "" -a "`echo $WARNVAL | grep '^[0-9][0-9]*$'`" = "" ]; then
	echo "Error: warning_value must be a positive integer!"
	exit 3
fi

if [ "$CRITVAL" != "" -a "`echo $CRITVAL | grep '^[0-9][0-9]*$'`" = "" ]; then
	echo "Error: critical_value must be a positive integer!"
	exit 3
fi

if [ "$WARNVAL" != "" -a "$CRITVAL" != "" ]; then
	if [ "$ARG" = "bcharge" -o "$ARG" = "battv" -o "$ARG" = "timeleft" ]; then
		if [ $WARNVAL -le $CRITVAL ]; then
			echo "Error: warning_value must be greater than critical_value!"
			exit 3
		fi
	else
		if [ $WARNVAL -ge $CRITVAL ]; then
			echo "Error: warning_value must be less than critical_value!"
			exit 3
		fi
	fi
fi

if [ ! -x "$APCACCESS" ]; then
	echo "Error: $APCACCESS must exist and be executable!"
	exit 3
fi

$APCACCESS status $HOSTNAME:$PORT > /dev/null
if [ $? -ne 0 ]; then
	# The error message from apcaccess will do fine.
	exit 3
fi

VALUE=`$APCACCESS status $HOSTNAME:$PORT | grep -i ^$ARG | \
	sed 's/.*:  *\([0-9.][0-9.]*\)[^0-9.].*/\1/'`
if [ "$VALUE" != "0" ]; then
	VALUE=`echo $VALUE | sed 's/^0*//'`
fi
ROUNDED=`echo $VALUE | sed 's/\..*//'`

case "$ARG" in
bcharge)
	if [ "$CRITVAL" != "" ]; then
		if [ $ROUNDED -lt $CRITVAL ]; then
			echo "CRITICAL - Battery Charge: ${VALUE}% |charge=${VALUE}"
			exit 2
		fi
	fi
	if [ "$WARNVAL" != "" ]; then
		if [ $ROUNDED -lt $WARNVAL ]; then
			echo "WARNING - Battery Charge: ${VALUE}% |charge=${VALUE}"
			exit 1
		fi
	fi
	echo "OK - Battery Charge: ${VALUE}% |charge=${VALUE}"
	;;
itemp)
	if [ "$CRITVAL" != "" ]; then
		if [ $ROUNDED -ge $CRITVAL ]; then
			echo "CRITICAL - Internal Temperature: $VALUE C |temp=$VALUE"
			exit 2
		fi
	fi
	if [ "$WARNVAL" != "" ]; then
		if [ $ROUNDED -ge $WARNVAL ]; then
			echo "WARNING - Internal Temperature: $VALUE C |temp=$VALUE"
			exit 1
		fi
	fi
	echo "OK - Internal Temperature: $VALUE C |temp=$VALUE"
	;;
loadpct)
	if [ "$CRITVAL" != "" ]; then
		if [ $ROUNDED -ge $CRITVAL ]; then
			echo "CRITICAL - Load: ${VALUE}% |load=${VALUE}%"
			exit 2
		fi
	fi
	if [ "$WARNVAL" != "" ]; then
		if [ $ROUNDED -ge $WARNVAL ]; then
			echo "WARNING - Load: ${VALUE}% |load=${VALUE}%"
			exit 1
		fi
	fi
	echo "OK - Load: ${VALUE}% | load=${VALUE}%"
	;;
timeleft)
	if [ "$CRITVAL" != "" ]; then
		if [ $ROUNDED -lt $CRITVAL ]; then
			echo "CRITICAL - Time Left: $VALUE Minutes |min=$VALUE"
			exit 2
		fi
	fi
	if [ "$WARNVAL" != "" ]; then
		if [ $ROUNDED -lt $WARNVAL ]; then
			echo "WARNING - Time Left: $VALUE Minutes |min=$VALUE"
			exit 1
		fi
	fi
	echo "OK - Time Left: $VALUE Minutes |min=$VALUE"
	;;
linev)
        if [ "$CRITVAL" != "" ]; then
                if [ $ROUNDED -ge $CRITVAL ]; then
                        echo "CRITICAL - Line Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 2
                fi
        fi
        if [ "$WARNVAL" != "" ]; then
                if [ $ROUNDED -ge $WARNVAL ]; then
                        echo "WARNING - Line Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 1
                fi
        fi
        echo "OK - Line Voltage: ${VALUE} Volts |volts=${VALUE}"
        ;;
battv)
        if [ "$CRITVAL" != "" ]; then
                if [ $ROUNDED -le $CRITVAL ]; then
                        echo "CRITICAL - Battery Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 2
                fi
        fi
        if [ "$WARNVAL" != "" ]; then
                if [ $ROUNDED -le $WARNVAL ]; then
                        echo "WARNING - Battery Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 1
                fi
        fi
        echo "OK - Battery Voltage: ${VALUE} Volts |volts=${VALUE}"
        ;;
outputv)
        if [ "$CRITVAL" != "" ]; then
                if [ $ROUNDED -ge $CRITVAL ]; then
                        echo "CRITICAL - Output Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 2
                fi
        fi
        if [ "$WARNVAL" != "" ]; then
                if [ $ROUNDED -ge $WARNVAL ]; then
                        echo "WARNING - Output Voltage: ${VALUE} Volts |volts=${VALUE}"
                        exit 1
                fi
        fi
        echo "OK - Output Voltage: ${VALUE} Volts |volts=${VALUE}"
        ;;
linefreq)
        if [ "$CRITVAL" != "" ]; then
                if [ $ROUNDED -ge $CRITVAL ]; then
                        echo "CRITICAL - Line Frequency: ${VALUE}Hz |freq=${VALUE}"
                        exit 2
                fi
        fi
        if [ "$WARNVAL" != "" ]; then
                if [ $ROUNDED -ge $WARNVAL ]; then
                        echo "WARNING - Line Frequency: ${VALUE}Hz |freq=${VALUE}"
                        exit 1
                fi
        fi
        echo "OK - Line Frequency: ${VALUE}Hz |freq=${VALUE}"
        ;;


esac

exit 0
