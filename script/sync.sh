#!/bin/bash

function usage () {
  cat <<EOF
Usage: $PROGNAME ENVIRONMENT
Syncs the records to the given ENVIRONMENT
    ENVIRONMENT   dev|staging|prod
EOF
  exit $( [ $# -ne 0 ] && echo $1 || echo 0 )
}
[ -z "$1" ] && usage 1

ENVIRONMENT=$1
DTS=$( date +'%Y%m%d%H%M%S' )
RECORDS_PATH="/stats/records.json"
RECORDS_HOST="showroom.mxm"
base_uri=""

case "$ENVIRONMENT" in
  dev|staging ) base_uri="https://$ENVIRONMENT.sfv2.cox.mxmcloud.com" ;;
  prod ) base_uri="https://sfv2.cox.mxmcloud.com" ;;
  * ) echo "Invalid environment" 1>&2 ; usage 1 ;;
esac

function json_get () {
  local key="$1"
  local fn="$2"
  python -c "import json,sys;obj=json.load(sys.stdin);print obj['$key']" < "$fn"
}

function json_dump () {
  local key="$1"
  local fn="$2"
  python -c "import json,sys;obj=json.load(sys.stdin);print json.dumps(obj['$key'])" < "$fn"
}

heartbeat_check=` curl -sS $base_uri/_status_/heartbeat `
if [[ $? != 0 ]] || [[ "$heartbeat_check" != "OK" ]]; then
  echo "Server heartbeat check failed." 1>&2
  exit 2
fi

records_fn=` mktemp /tmp/records.json.XXXXXX `
curl -sS -H "Host: $RECORDS_HOST" -G "http://localhost:80$RECORDS_PATH" > "$records_fn"
records_status=` json_get 'status' "$records_fn" `

if [[ "$records_status" != "success" ]]; then
  echo "Error getting records" 1>&2
  cat "$records_fn" 1>&2
  rm -f "$records_fn"
  exit 3
fi

records_data_fn=` mktemp /tmp/records_data.json.XXXXXX `
json_dump 'data' "$records_fn" > "$records_data_fn"
curl -sS --data-binary "@$records_data_fn" \
    -H 'Content-Type: application/json' \
    -XPOST "$base_uri/showroom-sync"
rm -f "$records_fn" "$records_data_fn"
