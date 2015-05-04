#!/bin/bash

function usage () {
  cat <<EOF
Usage: $PROGNAME dev|prod1|prod2|prod3|prod4
Deploys the application to the given NUC
    NUC   dev|prod1|prod2
EOF
  exit $( [ $# -ne 0 ] && echo "$1" || echo 0 )
}

[ -z "$1" ] && usage 1

APP_NAME="sfv2"
if [[ $1 == "dev" ]]; then
  # NUC_ID="$1" && shift 1 && [ "$1" ] && usage 1
  TARGET_HOST="nuc.showroom.dev.sfv2.cox.mxmcloud.com"
  # or dev.sfv2.cox.mxmcloud.com port 2122
elif [[ $1 == "prod1" ]]; then
  # NUC_ID="$1" && shift 1 && [ "$1" ] && usage 1
  TARGET_HOST="nuc1.showroom.sfv2.cox.mxmcloud.com"
  # or staging.sfv2.cox.mxmcloud.com port 2122
elif [[ $1 == "prod2" ]]; then
  # NUC_ID="$1" && shift 1 && [ "$1" ] && usage 1
  TARGET_HOST="nuc2.showroom.sfv2.cox.mxmcloud.com"
  # or staging.sfv2.cox.mxmcloud.com port 2222
elif [[ $1 == "prod3" ]]; then
  # NUC_ID="$1" && shift 1 && [ "$1" ] && usage 1
  TARGET_HOST="nuc3.showroom.sfv2.cox.mxmcloud.com"
  # or staging.sfv2.cox.mxmcloud.com port 2322
elif [[ $1 == "prod4" ]]; then
  # NUC_ID="$1" && shift 1 && [ "$1" ] && usage 1
  TARGET_HOST="nuc4.showroom.sfv2.cox.mxmcloud.com"
  # or staging.sfv2.cox.mxmcloud.com port 2422
else
  usage 1
fi
APP_ROOT="/srv/$APP_NAME"

run() {
  cmd=""
  for arg in "$@" ; do
    cmd="$cmd $arg"
  done
  echo ">$cmd"
  cmd="sh -c 'cd $APP_ROOT ; $cmd'"
  ssh "$APP_NAME@$TARGET_HOST" "$cmd"
}

# notify_slack() {
#   curl -sS --data-binary @- \
#       -H 'Content-Type: application/json' \
#       -H 'Accept: application/json' \
#       -XPOST https://hooks.slack.com/services/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 <<EOJSON
# { "channel": "#csfdev", "text": "$@" }
# EOJSON
# }

###
# Create release
rel_tag=$( git tag --points-at=HEAD )
[ -z "$rel_tag" ] && rel_tag=$( git rev-parse --short HEAD )
git ls-files -z | xargs -0 tar -czf "tmp/release-$rel_tag.tar.gz"

echo "Release: tmp/release-$rel_tag.gz"

# notify_slack "Starting deployment: $rel_tag to $NUC_ID"

###
# Upload release
run mkdir "releases/$rel_tag"
scp "tmp/release-$rel_tag.tar.gz" "$APP_NAME@$TARGET_HOST:$APP_ROOT/releases/$rel_tag/archive.tar.gz"
run tar -C "releases/$rel_tag" -xf "releases/$rel_tag/archive.tar.gz"
run rm "releases/$rel_tag/archive.tar.gz"

###
# Setup links
run rm -Rf "releases/$rel_tag/log" "releases/$rel_tag/tmp" "releases/$rel_tag/archive" \
    "releases/$rel_tag/data" "releases/$rel_tag/settings"
run ln -s "$APP_ROOT/shared/log" "releases/$rel_tag/log"
run ln -s "$APP_ROOT/shared/tmp" "releases/$rel_tag/tmp"
run ln -s "$APP_ROOT/shared/system/archive" "releases/$rel_tag/archive"
run ln -s "$APP_ROOT/shared/system/data" "releases/$rel_tag/data"
run ln -s "$APP_ROOT/shared/system/settings" "releases/$rel_tag/settings"
run ln -s "$APP_ROOT/shared/config/.env" "releases/$rel_tag/.env"

###
# NPM install
run "cd releases/$rel_tag ; npm install"

###
# Update public
run "cd releases/$rel_tag ; ./script/update-public.sh"

###
# Change current
run rm current
run ln -s "$APP_ROOT/releases/$rel_tag" current

###
# Restart
# run touch current/tmp/restart.txt

echo "You need to restart the application on the server with:"
echo "    sudo systemctl restart sfv2-app.service"

# notify_slack "Finished deployment: $rel_tag to $ENVIRONMENT"
