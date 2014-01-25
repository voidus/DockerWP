#!/usr/bin/php -q
<?php

/**
 * A command line PHP file for starting WordPress services.
 * Optionally updates the WordPress database to a new base URL, which should be done the first time it is used
 * 
 *   $ php g11.wp.start.php --update_wp_base_url new_wp_base_url
 *   $ php g11.wp.start.php
 *
 * php srdb.cli.php -h localhost -n wordpress -u root -p Ubuntu-64-WP -s http://gear11.com -r http://127.0.0.1/G11DockerWP/Duplicator
 * 
 */
 
require_once( 'Search-Replace-DB-3.0.0/srdb.cli.php' );

define("USAGE", "Usage: php g11.wp.start.php [--update_wp_base_url new_wp_base_url]\n");
define("NEED_WP_PASS", "You must set the environment variable WP_DB_PASSWORD to the WordPress database user password\n");
define("NEED_WP_PASS", "You must set the environment variable ORIG_WP_BASE_URL to the  original WordPress base URL\n");
if ($argc > 1) {
	
	if ($argc !== 3) {
		die(USAGE);
	}
	
	$argv[1] == "--update_wp_base_url" or die(USAGE);
	$new_wp_base_url = $argv[2];
	
	$pass = $ENV['WP_DB_PASSWORD'] or die(NEED_WP_PASS);
	$orig_wp_base_url = $ENV['ORIG_WP_BASE_URL'] or die(NEED_WP_BASE_URL);
	
	// new args array
	$args = array(
		'verbose' => true,
		'dry_run' => false, // Gear11 - Need a value here or else dry_run is assumed true in srdb.class.php
		'host' => 'localhost',
		'name' => 'wordpress',
		'user' => 'wordpress',
		'pass' => $pass,
		'search' => $orig_wp_base_url,
		'replace' => $new_wp_base_url
	);

	
	$report = new icit_srdb_cli( $args );
	
	if ( $report && ( $args[ 'dry_run' ] || empty( $report->errors[ 'results' ] ) ) ) {
		echo "\nAnd we're done!";
	} else {
		echo "\nCheck the output for errors. You may need to ensure verbose output is on by using -v or --verbose.";
	}
}

exec("/usr/local/bin/supervisord -n");
 
 
