#!/bin/bash

set -e


if id "$GIT_USER" >/dev/null 2>&1; then
        echo "user $GIT_USER already exists"
else
        useradd $GIT_USER
        usermod -p NP $GIT_USER
        echo "$GIT_USER ALL=(daemon) SETENV: NOPASSWD: /bin/ls, /usr/bin/git, /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/ssh" >> /etc/sudoers
        chown -R $GIT_USER /var/repo
        /var/www/phorge/phorge/bin/config set phd.user $GIT_USER
        /var/www/phorge/phorge/bin/config set diffusion.ssh-user $GIT_USER
fi

#SSH Configuration
/var/www/phorge/phorge/bin/config set files.enable-imagemagick true
#DB configuration
/var/www/phorge/phorge/bin/config set mysql.host $MYSQL_HOST
/var/www/phorge/phorge/bin/config set mysql.port $MYSQL_PORT
/var/www/phorge/phorge/bin/config set mysql.user $MYSQL_USER
/var/www/phorge/phorge/bin/config set mysql.pass $MYSQL_PASSWORD
/var/www/phorge/phorge/bin/config set diffusion.allow-http-auth true

if [ "$PROTOCOL" == "https" ]
then
    echo '<?php

$_SERVER['"'"'HTTPS'"'"'] = true;' > /var/www/phorge/phorge/support/preamble.php
fi

#Large file storage configuration
if [ ! -z "$MINIO_SERVER" ]
then
    /var/www/phorge/phorge/bin/config set storage.s3.bucket $MINIO_SERVER
    /var/www/phorge/phorge/bin/config set amazon-s3.secret-key $MINIO_SERVER_SECRET_KEY
    /var/www/phorge/phorge/bin/config set amazon-s3.access-key $MINIO_SERVER_ACCESS_KEY
    /var/www/phorge/phorge/bin/config set amazon-s3.endpoint $MINIO_SERVER:$MINIO_PORT
    # /var/www/phorge/phorge/bin/config set amazon-s3.region us-west-1
fi

if [ ! -z "$SMTP_SERVER" ] && [ ! -z "$SMTP_PORT" ] && [ ! -z "$SMTP_USER" ] && [ ! -z "$SMTP_PASSWORD" ] &&  [ ! -z "$SMTP_PROTOCOL" ]
then
    echo "[
  {
    \"key\": \"smtp-mailer\",
    \"type\": \"smtp\",
    \"options\": {
      \"host\": \"$SMTP_SERVER\",
      \"port\": $SMTP_PORT,
      \"user\": \"$SMTP_USER\",
      \"password\": \"$SMTP_PASSWORD\",
      \"protocol\": \"$SMTP_PROTOCOL\"
    }
  }
]" > /tmp/mailers.json
    /var/www/phorge/phorge/bin/config set cluster.mailers --stdin < /tmp/mailers.json
    rm /tmp/mailers.json
fi


echo setting "$PROTOCOL://$BASE_URI/"

# Update base uri
/var/www/phorge/phorge/bin/config set phabricator.base-uri "$PROTOCOL://$BASE_URI/"
sed -i "s/  server_name phorge.local;/  server_name $BASE_URI;/g" /etc/nginx/sites-available/phorge.conf
#sed "s/    return 301 \$scheme:\/\/phorge.local$request_uri;"
#general parameters configuration
/var/www/phorge/phorge/bin/config set pygments.enabled true
#setup db in not exists
/var/www/phorge/phorge/bin/storage upgrade --force
#start supervisord
/usr/bin/supervisord -n -c /etc/supervisord.conf
