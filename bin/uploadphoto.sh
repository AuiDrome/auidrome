#!/bin/bash

if [ $# -eq 2 ]; then
  drome=$1
  image=$2

  echo "scp $image otaony.com:dromes/$drome/public/images/"
  scp       $image otaony.com:dromes/$drome/public/images/
  echo "scp $image otaony.com:dromes/auidrome/data/$drome/images/"
  scp       $image otaony.com:dromes/auidrome/data/$drome/images/
else
  echo 'Usage: deployphoto.sh DROME FILE'
fi
