#!/bin/bash

config_file=$(dirname $0)/../config/auidromes
regexp="^([^:]+):*+"
i=0
while read line; do
  
  if [[ $line =~ $regexp ]]; then
    dromes[i]=${BASH_REMATCH[1]}
    ports[i]=${line#*:}
    ((i++))
  fi
done < $config_file

export DROME_NAMES=${dromes[@]}
export DROME_PORTS=${ports[@]}

echo "${#dromes[@]} dromes found in $config_file:"
echo " - drome names: ${DROME_NAMES}"
echo " - drome ports: ${DROME_PORTS}"
