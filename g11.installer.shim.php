<?php
/*
 * This PHP header inserted by G11DockerWP to allow a Duplicator installer package
 * to be invoked from the command line. To use it with your installer, enter:
 * 
 *     $ mv installer.php /tmp/. ; cat installer.shim.php /tmp/installer.php > installer.php
 * 
 * The resulting installer.php can still be accessed from the browser, but can also be executed
 * from the command line:
 * 
 *     $ php installer.php db_host db_user db_pass db_name pkg_file
*/
if (PHP_SAPI === 'cli' ) {
  define("COMMAND_LINE_USAGE", "Usage: php installer.php db_host db_user db_pass db_name pkg_file\n");
  print("Running in command line mode\n");
  if ($argc != 6) {
     die("Fatal error: Wrong number of arguments.\n" . COMMAND_LINE_USAGE);
  }

  # Populate MySQL DB Parameters for the WP install
  $_POST["dbhost"] = $argv[1];
  $_POST["dbuser"] = $argv[2];
  $_POST["dbpass"] = $argv[3];
  $_POST["dbname"] = $argv[4];
  $_POST["package_name"] = $argv[5];
  print("DB Host: ".$_POST["dbhost"]."\n");
  print("DB User: ".$_POST["dbuser"]."\n");
  print("DB Pass: ".$_POST["dbpass"]."\n");
  print("DB Name: ".$_POST["dbname"]."\n");

  # Fill in other POST parameters
  $_POST["action_ajax"] = 1;
  $_POST["action_step"] = 1;
  $_POST["logging"] = 1;
  $_POST["dbmake"] = 1;
  $_POST["dbcharset"] = "utf8";
  $_POST["dbcollate"] = "utf8_general_ci";

  function json_encode($s) {
    print_r($s);
    print("\n");
  }

}
?>
