#!/bin/bash

if_name=$1
status=$2

ZONE_ID="Z1953JQSHZTTFW"
LOGFILE="/var/log/nm-route53-update.log"
DTS=` date +'%Y-%m-%d %H:%M:%S' `

function writeChangeBatch () {
  local change_batch_fn=` mktemp /tmp/change_batch.json.XXXXXXXX `
  cat <<EOF >$change_batch_fn
    {
      "Comment": "Auto-update $DTS",
      "Changes": [
        {
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "ResourceRecords": [
              { "Value": "$DHCP4_IP_ADDRESS" }
            ],
            "Name": "$(hostname).",
            "Type": "A",
            "TTL": 60
          }
        }
      ]
    }
EOF
  echo $change_batch_fn
}

echo "[$DTS] $if_name $status" >> $LOGFILE

if [[ $status == "up" ]] || [[ $status == "dhcp4-change" ]]; then
  if [[ $if_name == "enp0s25" ]]; then
    change_batch_fn=` writeChangeBatch $if_name `
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch "file://$change_batch_fn" 2>>$LOGFILE >>$LOGFILE
    if [[ $? != 0 ]]; then
      echo $change_batch_fn >>$LOGFILE
      cat $change_batch_fn >>$LOGFILE
    fi
    rm $change_batch_fn
  fi
fi
