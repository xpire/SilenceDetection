#!/bin/bash

# Justin 2019 December

# Rename the files made by write.py to have the code in the name for ease of access later.
# find -name filenames.csv
PATH=match/norm/cut_dc_hp10_halfpadding

find $PATH -name filenames.csv


find match -name filenames.csv -print0 | while read -d $'\0' line; do
  if [[ $line =~ ([0-9]{4}\A[14]) ]]; then
    echo "matched part is ${BASH_REMATCH[1]}"
  fi
done
