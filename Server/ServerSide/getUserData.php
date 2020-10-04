<?php
# File name : getUserData.php
# Task 		: Get existing user data.
# Coder 	: Raptor

$data = json_decode( file_get_contents( 'php://input' ), true );

$user_id = $data['id'];
$dir = "Data/$user_id/";

if( is_dir($dir) === false || !file_exists($dir . 'userdata.dat'))
{
    echo "";
    exit(0);
}

$file = fopen($dir . 'userdata.dat', 'r');
fread($file, $out_data);
fclose($file);
echo $out_data;
?>