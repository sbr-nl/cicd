#!/bin/bash

if [ -s "$1" ]; then
  echo "Arelle has something to say about this"
  cat "$1"
  exit 1
else
  echo "Arelle thinks you're a star!"
fi

