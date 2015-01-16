#!/bin/bash

# Read the dromes from config/dromes file names... 
dromes=()
for drome in $(dirname $0)/../config/dromes/*.yml
do
  if [[ $drome =~ config/dromes/(.+).yml$ ]]; then
    dromes+=(${BASH_REMATCH[1]})
  fi
done
export DROME_NAMES=${dromes[@]}

echo "Found ${#dromes[@]} dromes in config/dromes:"
for drome in $DROME_NAMES
do
  echo " - "$drome
  
done

function run {
  cmd="$1"
  eval "$cmd"
  echo " => DONE!"
}

function ask_and_run {
  cmd="$1"
  echo ">>> $cmd"
  read -p "Should I run it?"
  run "$cmd"
}

function run_command {
  cmd="$1"
  echo ">>> $cmd"
  run "$cmd"
}
