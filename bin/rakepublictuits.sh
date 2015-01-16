#!/bin/bash
source 'bin/dromeslib.sh'

if [ $# -eq 0 ]; then
  dromes=$DROME_NAMES
else
  dromes=$1
fi

for drome in $dromes; do
  run_command "cd ../$drome"
  run_command "cp public/tuits.json ../auidrome/data/public/$drome"
  run_command "cp public/tuits/* ../auidrome/data/public/$drome/tuits/"
  run_command "cp public/images/* ../auidrome/data/public/$drome/images/"
done
