#!/usr/bin/env bash
if [ $# -eq 0 ]; then
    ddate | figlet
  else
    figlet "$@"
fi
