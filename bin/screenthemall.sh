#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'bin/dromeslib.sh'

if [ $# -eq 0 ]; then
  option=-r
else
  option=$1
fi

for drome in $DROME_NAMES; do
  echo 
  echo "Press [Enter] key to start $drome screen..."
  run_command "cd ../$drome"
  ask_and_run "screen $option $drome"
done
