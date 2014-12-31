#!/bin/bash

source 'bin/dromexports.sh'

for drome in $DROME_NAMES; do
  echo " > cd ../$drome"
  cd          ../$drome

  echo " > cp public/tuits.json ../auidrome/data/$drome"
  cp          public/tuits.json ../auidrome/data/$drome

  echo " > cp public/tuits/* ../auidrome/data/$drome/tuits/"
  cp          public/tuits/* ../auidrome/data/$drome/tuits/
done
