#!/bin/bash

# Entry point for G11DockerWP images.
#
# Supports the following options:
#   -s         Shell out (start the services in the background and give you a bash prompt)
#   -u   url   Update the base URL in the WordPress database
#
#   Example:
#     sudo docker run -i -p 80:80 -v /duplicator-pkg-dir:/wp-install -t my_wordpress -u http://127.0.0.1 -s
#
# Initialize args
new_wp_base_url=""
shell_out=0

while getopts "su:" opt; do
  case "$opt" in
    s)  shell_out=1
       ;;
    u)  new_wp_base_url=$OPTARG
       ;;
  esac
done

echo "new_wp_base_url='$new_wp_base_url', shell_out='$shell_out', Leftovers: $@"

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
  started_mysql=1
  WORDPRESS_DB="wordpress"
  ROOT_DB_PASSWORD=`pwgen -c -n -1 12`
  WP_DB_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo MySQL root password: $ROOT_DB_PASSWORD
  echo MySQL wordpress password: $WP_DB_PASSWORD
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
fi

# If new URL provided, execute DB search and replace
if [ ! "$new_wp_base_url" == "" ]; then
  orig_wp_base_url=`/bin/bash /G11DockerWP/g11_get_installer_host.sh /wp-install/installer.php`
  echo "Updating DB links from '$orig_wp_base_url' to '$new_wp_base_url'"
  if [ "$orig_wp_base_url" == "" ]; then
    echo Could not identify original WordPress base URL from installer.php.
    echo No database search and replace will be executed.
  else
    if [ ! "$started_mysql" == "1" ]; then
      echo Starting MySQL for database updates
      /usr/bin/mysqld_safe & 
      sleep 10s
      started_mysql=1
    fi
    php /G11DockerWP/Search-Replace-DB-3.0.0/srdb.cli.php -h localhost -n wordpress -u wordpress \
		-p $WP_DB_PASSWORD -s "$orig_wp_base_url" -r "new_wp_base_url"
  fi
fi

if [ "$started_mysql" == "1" ]; then
  echo Stopping MySQL...will restart via supervisord momentarily
  killall mysqld
fi
  
echo Starting the services
if [ "$shell_out" == "1" ]; then
  /usr/local/bin/supervisord
  /bin/bash
else
  /usr/local/bin/supervisord -n
fi
