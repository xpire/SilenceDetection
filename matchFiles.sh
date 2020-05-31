# Justin 2019
# find files matching in both directories Wave_X_NART/ and rename
# Run this before using readlink. But this shouldn't be necessary
#!/bin/bash

DIR_1=Wave_1_NART/
DIR_2=Wave_4_NART/
ODIR_1=match/w1/
ODIR_2=match/w4/
SEARCH="${DIR_2}*"
for FILE2 in $SEARCH; do
	echo "finding $FILE2"
	# get file name
	FILE2="${FILE2##*/}"
	#echo "$FILE1"
 	# remove extension
	#FILE1="${FILE1%.*}"
	#echo "$FILE1"
	# change wave4 to wave1
	FILE1="${FILE2//M_w4/M_w1}"
	#echo "$FILE1"

	## add directory, and extension back
	DIRFILE1="${DIR_1}${FILE1}"
	echo "$DIRFILE1"
	if [[ -f "$DIRFILE1" ]]; then
		echo "FOUND MATCH^"
		cp "${DIR_2}$FILE2" "${ODIR_2}$FILE2"
		cp "$DIRFILE1" "${ODIR_1}$FILE1"
	fi
done
