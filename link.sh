# Justin 2019
# Soft link all the files from a directory to another directory, eventually decided
# to copy them since we have enough space.
#!/bin/bash

DIR_1=match/norm/w1/
DIR_2=match/norm/w4/
ODIR_1=match/norm/unified/
SEARCH="${DIR_2}"
for FILE2 in $SEARCH*; do
	echo "finding $FILE2"
	# get file name
	FILE1="${FILE2##*/}"

	# link to output dir
	ln -s "$FILE2" "${ODIR_1}${FILE1}"

done
