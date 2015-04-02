#!/bin/bash

if_name=$1
status=$2

logger -p user.debug "$if_name $status 90-sfv2"

if [[ "$if_name $status" == "enp0s25 up" ]]; then
  logger -p user.notice "Restarting services: sfv2-sync, sfv2-update."
  systemctl restart sfv2-sync.service sfv2-update.service
fi
