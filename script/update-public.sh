#!/bin/bash

SHOWROOM_MD5=` cat showroom.tar.gz.md5 `
showroom_md5=` curl -sS https://dev.sfv2.cox.mxmcloud.com/uploads/showroom.tar.gz.md5 `

if [[ $SHOWROOM_MD5 != $showroom_md5 ]]; then
  curl -sS -O https://dev.sfv2.cox.mxmcloud.com/uploads/showroom.tar.gz
  tar -xzf showroom.tar.gz
  rm showroom.tar.gz
  echo $showroom_md5 > showroom.tar.gz.md5
fi
