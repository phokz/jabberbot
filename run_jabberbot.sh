#!/bin/bash

cd $(dirname $0)

while (true); do
  ./jabberbot.rb || git pull
  sleep 2
done
