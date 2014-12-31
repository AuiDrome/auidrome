#!/bin/bash

source 'dromexports.sh'

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
for drome in $DROME_NAMES; do
  echo "**********************************"
  echo "*** $drome"
  echo "**********************************"

  echo "Nos vamos a su directorio:"   
  echo " > cd ../$drome"
  cd ../$drome
  
  echo "Vemos que ha cambiado (normalmente tuits.json):"   
  echo " > git status"
  git status
  
  read -p "Press [Enter] key to start pulling $drome..."
  
  echo "Guardamos una copia de los tuits en actualmente en producción..."
  echo " > cp public/tuits.json ."
  cp public/tuits.json .

  echo "Checkout previo para evitar problemas..."
  echo " > git checkout public/tuits.json"
  git checkout public/tuits.json

  echo "Hacemos el pull (machacando los cambios locales)"
  echo " > git pull"
  git pull

  echo "Guardamos dichos tuits como los comiteados actualmente..."
  echo " > cp public/tuits.json public/tuits.commited.json"
  cp public/tuits.json public/tuits.commited.json

  echo "Y restauramos los que teníamos:"
  echo " > cp tuits.json public"
  cp tuits.json public
done
killall ssh-agent
