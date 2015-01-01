#!/bin/bash
if [ $# -eq 0 ]; then
  source 'dromexports.sh'
else
  DROME_NAMES=$1
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
for drome in $DROME_NAMES; do
  echo "**********************************"
  echo "*** $drome"
  echo "**********************************"
  
  echo "cd ../$drome"
  cd ../$drome
  
  echo "git status"
  git status
  
  echo "Press [Enter] key to PULL & OVERWRITE $drome data from the repo."
  read -p "ARE YOU SURE??? (Press Ctrl+C if not) "
  
  echo "cp public/tuits.json . ; checkout public/tuits.json"
  cp public/tuits.json .
  git checkout public/tuits.json

  echo "git pull"
  git pull

  echo "cp public/tuits.json public/tuits.commited.json"
  cp public/tuits.json public/tuits.commited.json

  echo "cp stuff from data/$drome to public"
  cp data/$drome/tuits.json public
  cp data/$drome/images/* public/images
  cp data/$drome/tuits/* public/tuits

  echo 
done
killall ssh-agent
