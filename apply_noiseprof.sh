# Justin 2019 December
# Applies noise profile to denoies audio

#!/bin/bash

INPUT_PROF=match/norm/denoised_noiseprof/
INPUT_FILE=match/norm/denoised_dc_hp10/
OUTPUT=match/norm/denoised_dc_hp10_actually_denoised/
PROFILE=noise.prof
SEARCH="${INPUT_FILE}"
for FILE2 in $SEARCH*; do
	echo "searched: $FILE2"
	BASE=$(basename $FILE2)
	BASEFOLD="${BASE%.*}"
	echo "base: $BASE, base folder: $BASEFOLD"
	BASEOUTPUT="$OUTPUT$BASEFOLD/"
	echo "checking if $BASEOUTPUT wav file exists:"
	ls $INPUT_FILE$BASEFOLD.wav
	if [[ $BASE =~ .wav$ ]]
	then
		BASEPROF=$INPUT_PROF$BASEFOLD.noise.wav
		echo "sox $BASEPROF -n noiseprof $PROFILE"
		echo "sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav noisered $PROFILE 0.21"

		sox $BASEPROF -n noiseprof $PROFILE
		sox $INPUT_FILE$BASEFOLD.wav $OUTPUT$BASEFOLD.wav noisered $PROFILE 0.21
	fi
done
