#!/bin/bash

RESOLVED="$(readlink /proc/$$/fd/255 && echo X)" && RESOLVED="${RESOLVED%$'\nX'}"

cd $RESOLVED

while (true); do
  ./jabberbot.rb || git pull
  sleep 2
done
