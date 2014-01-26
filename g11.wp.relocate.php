#!/usr/bin/php -q
<?php

/**
 * A command line PHP file for relocating the base URL for a WordPress database
 * Usage:
 * 
 *   $ php g11.wp.relocate.php wp_db_user orig_wp_base_url new_wp_base_url
 * 
 */
 
require_once( 'Search-Replace-DB-3.0.0/srdb.class.php' );

define("USAGE", "php g11.wp.relocate.php wp_db_user wp_db_pass orig_wp_base_url new_wp_base_url\n");

if ($argc > 1) {
	
	if ($argc !== 5) {
		die(USAGE);
	}
	
	$wp_db_user = $argv[1];
	$wp_db_pass = $argv[2];
    $orig_wp_base_url = $argv[3];
	$new_wp_base_url  = $argv[4];	

	// new args array
	$args = array(
		'verbose' => true,
		'dry_run' => false, // Gear11 - Need a value here or else dry_run is assumed true in srdb.class.php
		'host' => 'localhost',
		'name' => 'wordpress',
		'user' => $wp_db_user,
		'pass' => $wp_db_pass,
		'search' => $orig_wp_base_url,
		'replace' => $new_wp_base_url
	);
	
	$report = new icit_srdb( $args );
	
	if ( $report && ( $args[ 'dry_run' ] || empty( $report->errors[ 'results' ] ) ) ) {
		echo "\nAnd we're done!";
	} else {
		echo "\nCheck the output for errors. You may need to ensure verbose output is on by using -v or --verbose.";
	}
}
 
