# Justin 2019 December
# Cuts out the sounds and silences based from the output from silence_cutter.py

#!/bin/bash

INPUT_TIME=match/norm/split_dc_hp10/IN_USE/
INPUT_FILE=match/norm/denoised_dc_hp10_actually_denoised_shortened/
#create this folder before running
OUTPUT=match/norm/cut_dc_hp10_halfpadding/

SEARCH="${INPUT_TIME}"
for FILE2 in $SEARCH*; do
	echo "searched: $FILE2"
	BASE=$(basename $FILE2)
	BASEFOLD="${BASE%.*}"
	echo "base: $BASE, base folder: $BASEFOLD"
	BASEOUTPUT="$OUTPUT$BASEFOLD/"
	echo "checking if $BASEOUTPUT wav file exists:"
	ls $INPUT_FILE$BASEFOLD.wav
	if [[ $BASE =~ 8743A1.txt$ ]] #change this to only change one directory, e.g. 9182A4.txt
	then
		(cd $OUTPUT; mkdir $BASEFOLD)
		i=1
		PREVEND=0
		PREVSTART=0
		MIDDLESTART=0
		while IFS=, read START END
		do
			echo "This is start: ...$START..."
			echo "This is end: ...$END..."
			# CLEANING START AND END
			START=`echo "${START//[$'\t\r\n ']}"`
			END=`echo "${END//[$'\t\r\n ']}"`

			if [[ "$j" == 1 ]]
			then
				PREVEND=$END
				PREVSTART=$START
				MIDDLESTART=`bc <<< "scale=15; $START/2"`
				i=$((i+1))
				continue
			fi
			MIDDLEEND=`bc <<< "scale=15; ($START+$PREVEND)/2"`
			echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD/$BASEFOLD.$i.wav trim $MIDDLESTART =$MIDDLEEND"
			sox "$INPUT_FILE$BASEFOLD.wav" "$OUTPUT$BASEFOLD/$BASEFOLD.$i.wav" trim "$MIDDLESTART" "=$MIDDLEEND"
			PREVEND=$END
			PREVSTART=$START
			MIDDLESTART=$MIDDLEEND
			i=$((i+1))
		done < $FILE2
		# cut final word
		echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD/$BASEFOLD.$i.wav trim $MIDDLESTART =$PREVEND"
		sox "$INPUT_FILE$BASEFOLD.wav" "$OUTPUT$BASEFOLD/$BASEFOLD.$i.wav" trim "$MIDDLESTART" "=$PREVEND"
	fi
done
