FROM ubuntu
MAINTAINER Andy Jenkins <andy@gear11.com>, with thanks to github.com/eugeneware

# This is a base image for installing Ubuntu and the main WordPress dependencies.
# The G11DockerWP image builds off of this one.
# Start by running:
# sudo docker build -t "ubuntu_mysql_php" ubuntu_mysql_php

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