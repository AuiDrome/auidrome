#!/bin/bash

source 'dromexports.sh'

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
  
  read -p "Press [Enter] key to PULL & OVERWRITE $drome from the repo..."
  
  echo "cp public/tuits.json . ; checkout public/tuits.json"
  cp public/tuits.json .
  git checkout public/tuits.json

  echo "git pull"
  git pull

  echo "cp public/tuits.json public/tuits.commited.json"
  cp public/tuits.json public/tuits.commited.json

  echo "cp tuits.json public"
  cp data/$drome/tuits.json public
  echo "cp data/$drome/images/* public/images"
  cp data/$drome/images/* public/images

  echo 
done
killall ssh-agent
