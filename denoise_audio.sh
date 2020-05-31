#!/bin/bash
# denoises audio with sox using output from get_noise_profile.py 

INPUT_TIME=match/norm/cutwsilence_padded/
INPUT_FILE=match/norm/denoised_dc/
OUTPUT=match/norm/cut_denoised_dc/
SEARCH="${INPUT_TIME}"
for FILE2 in $SEARCH*; do
	echo "searched: $FILE2"
	BASE=$(basename $FILE2)
	BASEFOLD="${BASE%.*}"
	echo "base: $BASE, base folder: $BASEFOLD"
	BASEOUTPUT="$OUTPUT$BASEFOLD/"
	echo "checking if $BASEOUTPUT wav file exists:"
	ls $INPUT_FILE$BASEFOLD.wav
	if [[ $BASE =~ .txt$ ]]
	then
		i=1
		FINAL=0
		while IFS=, read START END
		do
			# echo "This is start: ...$START..."
			# echo "This is end: ...$END..."
			# CLEANING START AND END
			START=`echo "${START//[$'\t\r\n ']}"`
			END=`echo "${END//[$'\t\r\n ']}"`
			FINAL=$END
			# echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD/$BASEFOLD.$i.wav trim $START =$END"
			# trim silences as well
			i=$((i+1))
		done < $FILE2
		echo "this is the last end: $FINAL"
		echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav trim 0 $END"
		sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav trim 0 $END
	fi
done
