#!/bin/bash

if_name=$1
status=$2

LOGFILE="/var/log/nm-sfv2-update.log"
DTS=` date +'%Y-%m-%d %H:%M:%S' `

logger -p user.debug "$if_name $status"

if [[ "$if_name $status" == "enp0s25 up" ]]; then
  logger -p user.notice "Restarting services: sfv2-sync, sfv2-update."
  systemctl restart sfv2-sync.service sfv2-update.service
fi
