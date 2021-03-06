#!/bin/bash

#  Created by Sujay Davalgi
#
# Captures the bugreport from the selected device and saves the file (using specified filename)
# in the specified bugs folder
#
# Usage: ./myBR.sh [<filename>] 
# Arguments (Optional):
#	$1 - File name to be saved as.
#		No necessary to give the extension, by default it will save as ".txt"
#		If not mentioned, it will prompt you later.

. ./library/mainFunctions.sh
. ./library/textFormatting.sh
. ./library/deviceOperations.sh
. ./library/logFunctions.sh

getDeviceChoice
displaySelectedDevice $deviceSerial

function curlLog() {
#$ - deviceSerial
	echo -e -n " Do you want to enalbe the CURL logs Temporary(T) or Permanent(P) ? : "
	read verboseLogTypeChoice
	
	case $verboseLogTypeChoice in
		[tT])
			adb -s ${1} wait-for-device shell setprop log.tag.MusicHttp VERBOSE
			;;
		[pP])
			adb -s ${1} wait-for-device root
			adb -s ${1} wait-for-device shell 'echo log.tag.MusicHttp=VERBOSE >> /data/local.prop'
			adb -s ${1} wait-for-device shell chmod 644 /data/local.prop
			;;
	esac
	echo -e -n "\n"
}

function eventLog() {
#$1 - deviceSerial
	adb -s ${1} wait-for-device -d shell setprop log.tag.MusicEventLog VERBOSE

	restartDeviceApp ${1} "com.google.android.music"

	adb -s ${1} wait-for-device logcat -s MusicLogger
}

function otherLog() {
#$1 - deviceSerial
	adb -s ${1} wait-for-device shell setprop log.tag.MusicWoodstock VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicPlaybackService VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicSyncAdapter VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicStore VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicDownload VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicStreaming VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MplayHandler VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicHttp VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicCloudClient VERBOSE
	adb -s ${1} wait-for-device shell setprop log.tag.MusicCastRemote VERBOSE
}

if [ $( isAdbDevice $deviceSerial ) == "true" ]; then
	formatMessage " Do you want to enable CURL  logging ? [Y/N] : " "Q"
	stty -echo && read -n 1 curlLogChoice && stty echo
	formatYesNoOption $curlLogChoice
	
	formatMessage " Do you want to enable EVENT logging ? [Y/N] : " "Q"
	stty -echo && read -n 1 eventLogChoice && stty echo
	formatYesNoOption $eventLogChoice

	formatMessage " Do you want to enable OTHER logging ? [Y/N] : " "Q"
	stty -echo && read -n 1 otherLogChoice && stty echo
	formatYesNoOption $otherLogChoice

	echo -e -n "\n"
	
	if [ "$( checkYesNoOption $curlLogChoice )" == "yes" ]; then
		curlLog $deviceSerial
	fi

	if [ "$( checkYesNoOption $eventLogChoice )" == "yes" ]; then
		eventLog $deviceSerial
	fi

	if [ "$( checkYesNoOption $otherLogChoice )" == "yes" ]; then
		otherLog $deviceSerial
	fi
else
	echo -e -n " Device is not in 'adb' mode\n\n"
fi