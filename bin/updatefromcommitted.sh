#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'dromeslib.sh'

if [ $# -eq 0 ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
else
  echo "Running only for $1"
  DROME_NAMES=$1
fi

for drome in $DROME_NAMES; do
  echo "**********************************"
  echo "*** $drome"
  echo "**********************************"
  
  run_command "cd ../$drome"
  run_command "git status"

  echo "Copia de seguridad de $drome's public/tuits.json:"
  echo "cp public/tuits.json ."
  run_command "cp public/tuits.json ."
  echo "WARNING: Pressing [Enter] you'll PULL & OVERWRITE $drome uncommited data."
  echo "         Please, think it twice and press Ctrl+C if you're not sure about it."
  
  ask_and_run "git checkout public/tuits.json"
  ask_and_run "git pull"
  run_command "cp public/tuits.json public/tuits.commited.json"
  ask_and_run "cp data/public/$drome/tuits.json public"
  ask_and_run "cp data/public/$drome/tuits/* public/tuits"
  ask_and_run "cp data/public/$drome/images/* public/images"
done
if [ $# -eq 0 ]; then
  killall ssh-agent
fi
