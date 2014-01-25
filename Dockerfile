FROM ubuntu
MAINTAINER Andy Jenkins <andy@gear11.com>, with thanks to github.com/eugeneware

RUN echo Updating Ubuntu
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y upgrade
# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN echo Installing dependencies via Yum
# Basic Requirements
RUN apt-get -y install mysql-server mysql-client nginx php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip
# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl

RUN echo Configuring MySQL and creating the WordPress DB user
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN /usr/bin/mysqld_safe &
RUN sleep 10
RUN export MYSQL_PASSWORD=`pwgen -c -n -1 12`
RUN export WP_DB_PASSWORD=`pwgen -c -n -1 12`
#This is so the passwords show up in logs. 
RUN echo MySQL root password: $MYSQL_PASSWORD
RUN echo WordPress password: $WP_DB_PASSWORD
RUN echo $MYSQL_PASSWORD > /mysql-root-pw.txt
RUN echo $WP_DB_PASSWORD > /wordpress-db-pw.txt
RUN mysqladmin -u root password $MYSQL_PASSWORD 
RUN mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD'; FLUSH PRIVILEGES;"
RUN killall mysqld

RUN echo Configuring Nginx and PHP-FPM
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
# since 'upload_max_filesize = 2M' in /etc/php5/fpm/php.ini
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 3m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

RUN echo Adding G11DockerWP project assets and examining WordPress Duplicator pkg
ADD . /G11DockerWP
RUN export ORIG_WP_BASE_URL=`/G11DockerWP/g11.installer.host.sh /wp-install/installer.php`

RUN echo Installing WordPress from host WordPress Duplicator package
RUN rm -rf /usr/share/nginx/www
RUN cp -R /wp-install /usr/share/nginx/www/.
WORKDIR /usr/share/nginx/www
RUN cat /G11DockerWP/g11.installer.shim.php installer.php > installer.with.shim.php
RUN php installer.with.shim.php localhost wordpress $WP_DB_PASSWORD wordpress *.zip
RUN chown -R www-data:www-data /usr/share/nginx/www

RUN echo Installing the Nginx helper plugin
RUN curl -L "https://github.com/wp-cli/wp-cli/releases/download/v0.13.0/wp-cli.phar" > /usr/bin/wp
RUN chmod +x /usr/bin/wp
RUN wp plugin install nginx-helper --activate

RUN echo Installing services via supervisord
RUN /usr/bin/easy_install supervisor
RUN cp /G11DockerWP/docker-wordpress-nginx/supervisord.conf /etc/supervisord.conf

RUN echo Starting services
# We use ENTRYPOINT rather than CMD so that args after the image name go to us.
# The first time you run this, pass in the additional arguments:
# --update_wp_base_url (your new base URL)
ENTRYPOINT ["/usr/bin/php", "/G11DockerWP/g11.wp.start.php" ]

# private expose
EXPOSE 80