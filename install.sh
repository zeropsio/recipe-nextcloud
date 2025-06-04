#!/bin/bash

set -e -x

cd /var/www/nextcloud

if [ "$NEXTCLOUD_INSTALLED" = "1" ]; then
    zsc envReplace ../config.php /var/www/nextcloud/config/config.php
    echo "# Nextcloud data directory" > /var/www/nextcloud/data/.ncdata
else
    php occ maintenance:install \
        --database="$DATABASE" --database-name="$DATABASE_NAME" \
        --database-host="$DATABASE_HOST" --database-port="$DATABASE_PORT" \
        --database-user="$DATABASE_USER" --database-pass="$DATABASE_PASSWORD" \
        --admin-user="$ADMIN_USER" --admin-pass="$ADMIN_PASSWORD"
    
    zsc setSecretEnv NEXTCLOUD_INSTANCE_ID $(php -r "include '/var/www/nextcloud/config/config.php'; echo \$CONFIG['instanceid'];")
    zsc setSecretEnv NEXTCLOUD_PASSWORD_SALT $(php -r "include '/var/www/nextcloud/config/config.php'; echo \$CONFIG['passwordsalt'];")
    zsc setSecretEnv NEXTCLOUD_SECRET $(php -r "include '/var/www/nextcloud/config/config.php'; echo \$CONFIG['secret'];")
    zsc setSecretEnv NEXTCLOUD_EXACT_VERSION $(php -r "include '/var/www/nextcloud/config/config.php'; echo \$CONFIG['version'];")
    zsc setSecretEnv NEXTCLOUD_INSTALLED 1
    
    rm -r /var/www/nextcloud/data/admin
fi

php occ config:system:set trusted_domains 0 --value="localhost"
php occ config:system:set trusted_domains 1 --value="${SERVER_DOMAIN#*://}"

php occ config:system:set maintenance_window_start --type=integer --value=1

php occ config:system:set objectstore class --value="\OC\Files\ObjectStore\S3"
php occ config:system:set objectstore arguments bucket --value="$STORAGE_BUCKET"
php occ config:system:set objectstore arguments hostname --value="$STORAGE_HOSTNAME"
php occ config:system:set objectstore arguments key --value="$STORAGE_ACCESS_KEY"
php occ config:system:set objectstore arguments secret --value="$STORAGE_SECRET_KEY"
php occ config:system:set objectstore arguments port --type=integer --value="443"
php occ config:system:set objectstore arguments use_path_style --type=boolean --value="true"

zsc scale ram +0.5GB 10m
php occ app:disable richdocumentscode || true
php occ app:disable richdocuments || true
php occ app:enable richdocuments
php occ app:enable richdocumentscode

php occ maintenance:repair --include-expensive
php occ db:add-missing-indices

sudo -E zsc action run reloading