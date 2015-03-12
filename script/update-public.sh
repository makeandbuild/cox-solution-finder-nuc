#!/bin/bash

function usage () {
  cat <<EOF
Usage: $PROGNAME ENVIRONMENT
Updates the public file from the static showroom tarball
    ENVIRONMENT   dev|staging|prod
EOF
  exit $( [ $# -ne 0 ] && echo $1 || echo 0 )
}
[ -z "$1" ] && usage 1

ENVIRONMENT=$1
DTS=$( date +'%Y%m%d%H%M%S' )
source_uri=""

case "$ENVIRONMENT" in
  dev|staging ) source_uri="https://$ENVIRONMENT.sfv2.cox.mxmcloud.com/uploads/showroom.tar" ;;
  prod ) source_uri="https://sfv2.cox.mxmcloud.com/uploads/showroom.tar" ;;
  * ) echo "Invalid environment" 1>&2 ; usage 1 ;;
esac

showroom_md5_current=""
[ -f showroom.tar.md5 ] && showroom_md5_current=` cat showroom.tar.md5 `
showroom_md5_new=` curl -sS $source_uri.md5 `

if [[ $showroom_md5_current != $showroom_md5_new ]]; then
  curl -sS --compressed -o tmp/showroom.tar $source_uri
  if [[ "$?" == "0" ]]; then
    tar -C tmp/ -xf tmp/showroom.tar
    if [[ "$?" == "0" ]]; then
      mv -f tmp/public public-$DTS
      rm -f public
      ln -s public-$DTS public
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
