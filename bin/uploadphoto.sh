#!/bin/bash

if [ $# -eq 2 ]; then
  drome=$1
  image=$2

  echo "scp $image otaony.com:dromes/$drome/public/images/"
  scp       $image otaony.com:dromes/$drome/public/images/
else
  echo 'Usage: uploadphoto.sh DROME FILE'
fi
