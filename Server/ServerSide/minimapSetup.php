<?php
# File name : minimapSetup.php
# Task 		: Move minimap from files/ to map's minimap folder.
# Coder 	: Raptor

include 'php/logger.php';

$data = json_decode( file_get_contents( 'php://input' ), true );
# Author and map name
$author = $data['id'];
$map_name = $data['lvl_name'];

# Minimap destination Directory 
$map_dir = "Data/$author/custom_maps/minimap/";
if( is_dir($map_dir) === false )
{
    $logger->addLog("Dir : ".$map_dir." does not exists", 'error');
    $logger->addLog('Creating directory');
    mkdir($map_dir, 0777, true);
}

# Minimap file in files/
$file_name = "Data/files/$map_name"."128.png";
# Move file to $map_dir
if (file_exists($file_name))
    rename($file_name, $map_dir.$map_name."128.png");
else
    $logger->addLog("Failed to transfer minimap. File $file_name does not exist", 'error');
?>