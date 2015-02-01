#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'bin/dromeslib.sh'

run_command "pwd"
echo "This script assumes this directory is called 'auidrome'"

for drome in $DROME_NAMES; do
  echo
  if [ $drome == "auidrome" ]
  then
    echo "'auidrome' drome, skipping..."
    continue
  fi
  ask_and_run "mkdir ../$drome && cp -Rf ../auidrome/public/ ../$drome/"
  cd ../$drome
  mkdir public_ant/tuits -p
  mkdir public_ant/images
  ln -s ../auidrome/config .
  ln -s ../auidrome/data .
  ln -s ../auidrome/views .
  ln -s ../auidrome/lib .
  ln -s ../auidrome/bin .
  ln -s ../auidrome/app.rb .
  ln -s ../auidrome/Gemfile .
  ln -s ../auidrome/.ruby-version .
done
