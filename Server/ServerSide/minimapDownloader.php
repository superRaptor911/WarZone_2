<?php

# File name : levelDownloader.php
# Task 		: Sent requested level to user.
# Coder 	: Raptor

include 'php/logger.php';

$map_info = json_decode( file_get_contents( 'php://input' ), true );
clearstatcache();

$author = $map_info['author'];
$map_name = $map_info['name'];
$name = "Data/$author/custom_maps/minimap/$map_name"."128.png";
$fp = fopen($name, 'rb');

// send the right headers
header("Content-Type: image/png");
header("Content-Length: " . filesize($name));

// dump the picture and stop the script
fpassthru($fp);
exit;

?>