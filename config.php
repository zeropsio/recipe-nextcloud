<?php
$CONFIG = array (
  'version' => '{{ .NEXTCLOUD_EXACT_VERSION }}',
  'installed' => true,
  'instanceid' => '{{ .NEXTCLOUD_INSTANCE_ID }}',
  'passwordsalt' => '{{ .NEXTCLOUD_PASSWORD_SALT }}',
  'secret' => '{{ .NEXTCLOUD_SECRET }}',
  'datadirectory' => '/var/www/nextcloud/data',
  'overwrite.cli.url' => 'http://localhost',
  'dbtype' => 'pgsql',
  'dbname' => 'pg',
  'dbhost' => 'pg:5432',
  'dbtableprefix' => 'oc_',
  'dbuser' => 'pg',
  'dbpassword' => '{{ .DATABASE_PASSWORD }}',
);
