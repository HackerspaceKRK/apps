#!/bin/bash
set -ex
IMAGES_DIR=/tmp/images

ZONEMINDER_LOGIN=$(cat /run/secrets/zoneminder_login)
ZONEMINDER_PASSWORD=$(cat /run/secrets/zoneminder_password)

mkdir -p ${IMAGES_DIR}

declare -A rooms

rooms[3]="hardroom"
rooms[2]="elelab"
rooms[5]="korytarz"
rooms[8]="netlab"
rooms[1]="softroom"

ZONEMINDER_URL="https://lustereczko.at.hskrk.pl/cgi-bin-zm/nph-zms?mode=single&monitor=3&scale=100&user=$ZONEMINDER_LOGIN&pass=$ZONEMINDER_PASSWORD"

function download(){
  for CAMERA_ID in "${!rooms[@]}"; do
    	curl -k "https://lustereczko.at.hskrk.pl/cgi-bin-zm/nph-zms?mode=single&monitor=$CAMERA_ID&scale=100&user=$ZONEMINDER_LOGIN&pass=$ZONEMINDER_PASSWORD"  > ${IMAGES_DIR}/${rooms[$CAMERA_ID]}.jpg

      echo "ID: $CAMERA_ID, Room: ${rooms[$CAMERA_ID]}"
  done

  curl 'https://grafana.apps.hskrk.pl/render/d-solo/efd454c7-2714-4507-b5b5-188e1feceeb7/public-network-stats?orgId=1&panelId=2&width=1000&height=500&tz=Europe%2FWarsaw' > ${IMAGES_DIR}/public-network-stats.png
  curl 'https://grafana.apps.hskrk.pl/render/d-solo/cc375ef7-341d-4ded-9a3d-73b886f46c08/power-consumption?orgId=1&panelId=1&width=1000&height=500&tz=Europe%2FWarsaw' > ${IMAGES_DIR}/power-consumption.png

  aws s3 --endpoint-url=${S3_ENDPOINT} cp ${IMAGES_DIR}/* s3://${IMAGES_BUCKET}/
}

download
