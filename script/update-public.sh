#!/bin/bash

SHOWROOM_MD5=` cat showroom.tar.md5 `
showroom_md5=` curl -sS https://dev.sfv2.cox.mxmcloud.com/uploads/showroom.tar.md5 `
DTS=$( date +'%Y%m%d%H%M%S' )

if [[ $SHOWROOM_MD5 != $showroom_md5 ]]; then
  curl -sS -o tmp/showroom.tar https://dev.sfv2.cox.mxmcloud.com/uploads/showroom.tar
  if [[ "$?" == "0" ]]; then
    tar -C tmp/ -xf tmp/showroom.tar
    if [[ "$?" == "0" ]]; then
      mv -f tmp/public public-$DTS
      rm -f public
      ln -s public-$DTS public
      chown -R sfv2:www public
      for dn in ` find -name 'public-*' `; do
        [[ $dn != "./public-$DTS" ]] && rm -rf $dn
      done
      echo $showroom_md5 > showroom.tar.md5
    fi
    rm -f tmp/showroom.tar
  else
    rm -f tmp/showroom.tar
  fi
fi
