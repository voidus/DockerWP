#!/bin/bash

# If wp-config.php doesn't exist, then WordPress has not yet been
# installed from the Duplicator installer package
if [ ! -f /usr/share/nginx/www/wp-config.php ]; then

  # Ensure that the Duplicator installer package exists
  echo Checking for /wp-install
  if [ ! -d /wp-install ]; then
	  echo The directory /wp-install does not exist.
	  echo You must invoke Docker with a -v option to mount the Duplicator installer directory to /wp-install
	  exit 1
  fi
  
  echo Starting MySQL and adding root and wordpress users
  /usr/bin/mysqld_safe & 
  sleep 10s
  WORDPRESS_DB="wordpress"
  ROOT_DB_PASSWORD=`pwgen -c -n -1 12`
  WP_DB_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo mysql root password: $ROOT_DB_PASSWORD
  echo $ROOT_DB_PASSWORD > /root-db-pw.txt
  echo $WP_DB_PASSWORD > /wordpress-db-pw.txt
  mysqladmin -u root password $ROOT_DB_PASSWORD 
  mysql -uroot -p$ROOT_DB_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD'; FLUSH PRIVILEGES;"
  
  echo Installing WordPress from host WordPress Duplicator package
  rm -rf /usr/share/nginx/www
  cp -R /wp-install /usr/share/nginx/www
  cd /usr/share/nginx/www
  cat /G11DockerWP/g11.installer.shim.php installer.php > installer.with.shim.php
  php installer.with.shim.php localhost wordpress $WP_DB_PASSWORD wordpress *.zip
  chown -R www-data:www-data /usr/share/nginx/www
  
  echo Installing the Nginx helper plugin
  wp plugin install nginx-helper --activate
  
  echo Making the WordPress directory writeable by Nginx
  chown -R www-data:www-data /usr/share/nginx/www
  
  echo Stopping MySQL...will restart via supervisord momentarily
  killall mysqld
fi

# If an argument is provided, the use it as the replacement value for the original base URL
if [ ! "$1" == "" ]; then
  NEW_WP_BASE_URL=$1
  echo Updating DB links from $ORIG_WP_BASE_URL to $NEW_WP_BASE_URL
  ORIG_WP_BASE_URL=`/bin/bash /G11DockerWP/g11_get_installer_host.sh /wp-install/installer.php`
  if [ "$ORIG_WP_BASE_URL" == "" ]; then
    echo Could not identify original WordPress base URL from installer.php.
    echo No database search and replace will be executed.
  else
    php g11.wp.relocate.php wordpress $WP_DB_PASSWORD $ORIG_WP_BASE_URL $NEW_WP_BASE_URL 
  fi
fi

echo Starting the services
/usr/local/bin/supervisord -n
