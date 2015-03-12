#!/bin/bash

if_name=$1
status=$2

logger -p user.debug "$if_name $status 95-ssh-tunnel"

if [[ "$if_name" == "enp0s25" ]]; then
  if [[ "$status" == "up" ]]; then
    logger -p user.notice "Starting service: showroom-ssh.service."
    systemctl start showroom-ssh.service
  elif [[ "$status" == "down" ]]; then
    logger -p user.notice "Stoppig service: showroom-ssh.service."
    systemctl stop showroom-ssh.service
  fi
fi
