<?php
# File name : userDataReceiver.php
# Task 		: Receive user data from user and save in server.
# Coder 	: Raptor

$data = json_decode( file_get_contents( 'php://input' ), true );

$user_id = $data['id'];
$dir = "Data/$user_id/";

if( is_dir($dir) === false )
    mkdir($dir, 0777, true);

$file = fopen($dir . 'userdata.dat', 'w');
fwrite($file, json_encode($data));
fclose($file);
?>