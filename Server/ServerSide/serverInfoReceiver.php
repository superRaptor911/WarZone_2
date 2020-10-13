<?php

# File name : serverInfoReceiver.php
# Task 		: Receive serverInfo from warzone server.
# Coder 	: Raptor

include 'php/logger.php';

$data = json_decode( file_get_contents( 'php://input' ), true );

$svr_dir = "Data/servers/";
if( is_dir($svr_dir) === false )
{
    $logger->addLog("Dir : ".$svr_dir." does not exists", 'error');
    $logger->addLog('Creating directory');
    mkdir($svr_dir, 0777, true);
}

# Trucate File
$file = fopen($svr_dir.$data['name'], "w");
fclose($file);
# Write Data
$file = fopen($svr_dir.$data['name'], "w");
fwrite($file, json_encode($data));
fclose($file);

?>