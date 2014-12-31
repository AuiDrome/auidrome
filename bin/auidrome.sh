#!/bin/bash
if [ $# -eq 0 ]; then
  DROME=config/dromes/${PWD##*/}.yml # Catch it from current directory
else
  DROME=$1
fi
CMD="bundle exec ruby app.rb $DROME"
echo $CMD
$CMD
