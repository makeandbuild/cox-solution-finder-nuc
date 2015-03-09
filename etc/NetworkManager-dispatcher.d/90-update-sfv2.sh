#!/bin/bash

if_name=$1
status=$2

LOGFILE="/var/log/nm-sfv2-update.log"
DTS=` date +'%Y-%m-%d %H:%M:%S' `

echo "[$DTS] $if_name $status" >> $LOGFILE

if [[ $status == "up" ]]; then
  if [[ $if_name == "enp0s25" ]]; then
    pwd_orig=`pwd`
    cd /srv/sfv2/current/
    ./script/sync.rb
    ./script/update-public.sh
    cd $pwd_orig
  fi
fi
