#!/bin/bash

if_name=$1
status=$2

ZONE_ID="Z1953JQSHZTTFW"

function writeChangeBatch () {
  local change_batch_fn=` mktemp /tmp/change_batch.json.XXXXXXXX `
  cat <<EOF >$change_batch_fn
    {
      "Comment": "Auto-update $( date +'%Y-%m-%d %H:%M:%S' )",
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

logger -p user.debug "$if_name $status"

if [[ $status == "up" ]] || [[ $status == "dhcp4-change" ]]; then
  if [[ $if_name == "enp0s25" ]]; then
    change_batch_fn=` writeChangeBatch $if_name `
    result_fn=` mktemp /tmp/aws-route53.log.XXXXXX `
    logger -p user.notice "Updating Route53 RecordSet for $( hostname )"
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch "file://$change_batch_fn" &>$result_fn
    if [[ $? != 0 ]]; then
      logger -p user.err "Update failed: $( cat $result_fn )"
      logger -p user.err "Change Batch JSON: $( cat $change_batch_fn )"
    fi
    rm -f $change_batch_fn
    rm -f $result_fn
  fi
fi
