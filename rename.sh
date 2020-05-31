# Justin 2019
# Script using bash to rename the Files.
#!/bin/bash

DIR_1=match/norm/w1/
DIR_2=match/norm/w4/
SEARCH="${DIR_2}"
for FILE2 in $SEARCH*; do
	echo "finding $FILE2"
	# get file name
	FILE1="${FILE2##*/}"
	#echo "$FILE1"
 	# remove extension
	FILE1="${FILE1%.*}"
	#echo "$FILE1"
	# change wave4 to wave1
	FILE1="${FILE1//M_w/}"
	#echo "$FILE1"

	# get the wave number
	NUMBER="${FILE1:0:1}" #0th index, 1 long
	FILE1="${FILE1#?}"

	#remove other useless words in id
	FILE1="${FILE1//_NARTaudio_/}"

	# add wave number to the end
	FILE1="${FILE1}$NUMBER"

	## add directory, and extension back
	DIRFILE="${SEARCH}${FILE1}.wav"
	echo "$DIRFILE"
	mv "$FILE2" "$DIRFILE"
done
