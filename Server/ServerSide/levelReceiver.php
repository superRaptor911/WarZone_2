<?php

# File name : levelReceiver.php
# Task 		: Receive level from user and save level in server.
# Coder 	: Raptor

include 'php/logger.php';

$data = json_decode( file_get_contents( 'php://input' ), true );

$user_id = $data['id'];
$dir = "Data/$user_id/custom_maps/";

if( is_dir($dir) === false )
    mkdir($dir, 0777, true);

# Create base map directory
$dir = "Data/$user_id/custom_maps/maps/";

if( is_dir($dir) === false )
    mkdir($dir);

# Trucate File
$file = fopen($dir.$data['lvl_name'].".tscn", "w");
fclose($file);
# Write Data
$file = fopen($dir.$data['lvl_name'].".tscn", "w");
fwrite($file, $data['map']);
fclose($file);

$logger->addLog("Got map ". $data['lvl_name']);

# Game mode TDM
if (array_key_exists('TDM', $data))
{
	$dir = "Data/$user_id/custom_maps/gameModes/TDM/";
	if( is_dir($dir) === false )
		mkdir($dir, 0777, true);
	# Trucate File	
	$file = fopen($dir.$data['lvl_name'].".tscn", "w");
	fclose($file);
	# Write Data
	$file = fopen($dir.$data['lvl_name'].".tscn", "w");
	fwrite($file, $data['TDM']);
	fclose($file);
}

# Game Mode Zombie mode
if (array_key_exists('Zombie', $data))
{
	$dir = "Data/$user_id/custom_maps/gameModes/Zombie/";
	if( is_dir($dir) === false )
		mkdir($dir, 0777, true);	
	# Trucate File
	$file = fopen($dir.$data['lvl_name'].".tscn", "w");
	fclose($file);
	# Write Data
	$file = fopen($dir.$data['lvl_name'].".tscn", "w");
	fwrite($file, $data['Zombie']);
	fclose($file);
}

$msg = "First line of text\nSecond line of text";
# use wordwrap() if lines are longer than 70 characters
$msg = wordwrap($msg,70);
# Mail
mail("raptor.inc2018@gmail.com", "Got new Map", $msg, "From : raptorINC");

$logger->addLog("Mail sent to raptor.inc2018@gmail.com");

?>
