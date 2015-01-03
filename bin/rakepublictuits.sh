#!/bin/bash

source 'bin/dromexports.sh'

for drome in $DROME_NAMES; do
  echo " > cd ../$drome"
  cd          ../$drome

  echo " > cp public/tuits.json ../auidrome/data/public/$drome"
  cp          public/tuits.json ../auidrome/data/public/$drome

  echo " > cp public/tuits/* ../auidrome/data/public/$drome/tuits/"
  cp          public/tuits/* ../auidrome/data/public/$drome/tuits/

  echo " > cp public/images/* ../auidrome/data/public/$drome/images/"
  cp          public/images/* ../auidrome/data/public/$drome/images/

  echo
done
