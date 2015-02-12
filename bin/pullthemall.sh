#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'dromeslib.sh'

if [ $# -eq 1 ]; then
  DROME_NAMES=$1
fi

for drome in $DROME_NAMES; do
  echo "**********************************"
  if [ $drome == "auidrome" ]
  then
  echo "------ AUIDROME => skipping ------"
    continue
  else
    echo "*** COPYING PUBLIC FILES IN $drome"
  fi
  echo "**********************************"

  run_command "cd ../$drome && cp ../auidrome/public/js/* public/js && cp ../auidrome/public/css/* public/css"
  echo
done
