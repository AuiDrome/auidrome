#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'dromeslib.sh'

if [ $# -eq 1 ]; then
  echo "Updating only $1"
  DROME_NAMES=$1
fi

for drome in $DROME_NAMES; do
  echo "**********************************"
  echo "*** $drome"
  echo "**********************************"
 
  ask_and_run "cd ../$drome"
  # backup current data
  run_command "cp public/tuits.json public_ant"
  run_command "cp public/tuits/* public_ant/tuits"
  run_command "cp public/images/* public_ant/images"
  # update from committed
  cp ../auidrome/data/public/$drome/tuits.json public
  cp ../auidrome/data/public/$drome/tuits/* public/tuits
  cp ../auidrome/data/public/$drome/images/* public/images

#  ask_and_run 'ls'
#  echo "Copia de seguridad de $drome's public/tuits.json:"
#  run_command "cp public/tuits.json ."
#  echo "WARNING: Pressing [Enter] you'll PULL & OVERWRITE $drome uncommited data."
#  echo "         Please, think it twice and press Ctrl+C if you're not sure about it."
#  
#  ask_and_run "git checkout public/tuits.json"
#  ask_and_run "git pull"
#  run_command "cp public/tuits.json public/tuits.commited.json"
#  ask_and_run "cp data/public/$drome/tuits.json public"
#  ask_and_run "cp data/public/$drome/tuits/* public/tuits"
#  ask_and_run "cp data/public/$drome/images/* public/images"
done
