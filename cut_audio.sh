# Justin 2019 December
# Cuts audio to size based on the latest sound recognised by algorithm.

#!/bin/bash

INPUT_TIME=match/norm/split_padded/
INPUT_FILE=match/norm/denoised_dc_hp10_actually_denoised/
OUTPUT=match/norm/denoised_dc_hp10_actually_denoised_shortened/
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
		echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav trim 0 $FINAL"
		sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav trim 0 $FINAL
	fi
done
