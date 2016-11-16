#!/bin/bash
################################################################################
# This file is written by Vamsi Krishna
# License : MIT License
# you can redistribute this and make changes to it as long as you acknowledge the author
# please feel free to suggest any changes that can improve this file
#
# Maintainer : Vamsi Krishna
################################################################################

ROOT_UID=0   # Only users with $UID 0 have root privileges.
E_NOTROOT=65
E_OTHER=66
E_ROOT=15
UID=`id -u`

TEMP_OUT=/tmp/avr.o
TEMP_HEX=/tmp/avr.hex

# EXIT_MESSAGE='Thankyou for using using atmega.sh from Vamsi Krishna'
EXIT_MESSAGE='Bye..Bye...!'

print_usage (){
	echo "sh $0 [ -m|--mmcu  Microcontroller ] [ ( -w | --write ) || ( -r | --read )    path_to_file ] "
	exit 1
}

# read the options
TEMP=`getopt -o m:w:r: --long mmcu:,write:,read:  -n "$0" -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
	case "$1" in
		-m|--mmcu)
			case "$2" in   #   "") ARG_A='some default value' ; shift 2 ;;
				"") print_usage ; shift 2 ;;
				*)  MCU=$2 ;      shift 2 ;;
			esac ;;
		-r|--read)
			READ_WRITE=r;
			case "$2" in
				"") print_usage ; shift 2 ;;
				*) FILE_NAME=$2 ; shift 2 ;;
			esac ;;
		-w|--write)
			READ_WRITE=w;
			case "$2" in
				"") print_usage ; shift 2 ;;
				*) FILE_NAME=$2 ; shift 2 ;;
			esac ;;
		--) shift ; break ;;
		#       *) echo "Internal error!" ; exit 1 ;;
		*) print_usage
	esac
done

if [ ! $MCU ] ; then
	echo input a microcontroller
	print_usage
fi

if [ ! $FILE_NAME ] ; then
	echo input a file name
	print_usage
fi

#checking that the file exists
if [ ! -f "$FILE_NAME" ] ; then
	echo the file doesnot exist. please check the file path
	echo $EXIT_MESSAGE
	exit $E_OTHER
fi

#checking if the user is root
if [ "$UID" -ne "$ROOT_UID" ] ; then
	# 	echo  you donot have enough rights to upload the code
	echo  Not running as root. you cannot upload the code
	echo  if you want to burn the code use sudo or upload as root user
	E_ROOT=10
fi

#compile the code
avr-gcc -mmcu=$MCU -Os -std=c11 -o $TEMP_OUT $FILE_NAME

#checking that the compiled output file exists; The other way to check the compilation is done successfully is to check the exit value of the previously run command
if [ ! -f $TEMP_OUT ] ; then
	# 	echo compilation errors prevent from proceeding further
	echo you have messed up somewhere in your code. go handle that first
	echo $EXIT_MESSAGE
	exit $E_OTHER
fi

#convert the .o file to hex file
avr-objcopy -j .text -j .data -O ihex  $TEMP_OUT  $TEMP_HEX  && echo hex file available at $TEMP_HEX

if [ "$E_ROOT" -ne 10 ] ; then
	echo do you want to upload the code  yes/no ?
	read INP

	case $INP in
		yes)
			avrdude -c usbasp -p "$MCU" -v -U flash:$READ_WRITE:$TEMP_HEX
			;;
		no)
			echo OK.. fine with me
			exit 0
			;;
		*)
			echo please use a valid input
			echo "It's really not that difficult. Choose either yes or no"
			;;
	esac
fi

#removing the temporary files and exiting
rm $TEMP_OUT
rm $TEMP_HEX
echo $EXIT_MESSAGE

exit 0
