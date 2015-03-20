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
base_uri=""

case "$ENVIRONMENT" in
  dev|staging ) base_uri="https://$ENVIRONMENT.sfv2.cox.mxmcloud.com" ;;
  prod ) base_uri="https://sfv2.cox.mxmcloud.com" ;;
  * ) echo "Invalid environment" 1>&2 ; usage 1 ;;
esac

heartbeat_check=` curl -sS $base_uri/_status_/heartbeat `
if [[ $? != 0 ]] || [[ "$heartbeat_check" != "OK" ]]; then
  echo "Server heartbeat check failed." 1>&2
  exit 2
fi

showroom_md5_current=""
[ -f showroom.tar.md5 ] && showroom_md5_current=` cat showroom.tar.md5 `
showroom_md5_new=` curl -sS $base_uri/uploads/showroom.tar.md5 `

if [[ "$showroom_md5_current" == "$showroom_md5_new" ]]; then
  echo "Tarball not changed.  Not updating."
  exit 0
fi

curl -sS --compressed -o tmp/showroom.tar "$base_uri/uploads/showroom.tar"
if [[ $? != 0 ]]; then
  echo "Failed to download tarball." 1>&2
  rm -f tmp/showroom.tar
  exit 3
fi

tar -C tmp/ -xf tmp/showroom.tar
if [[ $? != 0 ]]; then
  echo "Failed to extract tarball." 1>&2
  rm -f tmp/showroom.tar
  exit 4
else
  rm -f tmp/showroom.tar
fi

mv -f tmp/public public-$DTS
rm -f public
ln -s public-$DTS public
for dn in ` find -name 'public-*' `; do
  [[ $dn != "./public-$DTS" ]] && rm -rf $dn
done
echo "$showroom_md5_new" > showroom.tar.md5
