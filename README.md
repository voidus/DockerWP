G11DockerWP
===========

A Docker-based solution for cloning existing WordPress sites.  For background, see the post on [Gear 11](http://gear11.com/2014/01/wordpress-docker/)

Thanks to [Eugene Ware](https://github.com/eugeneware/docker-wordpress-nginx)
and [jbfink](https://github.com/jbfink/docker-wordpress)

## Prerequisites
* Docker (requires 64-bit Linux, use VirtualBox for other OSes)
* Existing installer package of your WordPress site created with [Duplicator](http://wordpress.org/plugins/duplicator/)

## Installation

```
$ git clone https://github.com/gear11/G11DockerWP
$ cd G11DockerWP
$ sudo docker build -t="G11DockerWP" .
```

## Usage

To clone your wordpress site:
```
$ sudo docker run -i -p 80:80 -v (package dir):/wp-install -t G11DockerWP -u (new WP url)
 ```
 For example, to start a new copy of your site on your localhost, with
 your Duplicator package /home/me/pkg:
 ```
$ sudo docker run -i -p 80:80 -v /home/me/pkg:/wp-install -t G11DockerWP -u http://127.0.0.1
 ```
 
 Your site should now be cloned and available at http://127.0.0.1 .
 It is a fully independent clone, including:
 * All users and posts
 * All media
 * All links working properly
 * All plugins installed
 
If you'd like to have Docker start services in the background and yield a shell prompt,
start with the -s option:
 ```
$ sudo docker run -i -p 80:80 -v /home/me/pkg:/wp-install -t G11DockerWP -u http://127.0.0.1 -s
 ```
If you snapshot your running image, you can restart it without any options:
 ```
$ sudo docker commit <container id> G11DockerWP/snap1
...
$ sudo docker run -i -p 80:80 -v /home/me/pkg:/wp-install -t G11DockerWP/snap1
 ```
 It will start much faster since it doesn't have to do any setup.
