<?php
// Takes raw data from the request

// Converts it into a PHP object
$data = json_decode( file_get_contents( 'php://input' ), true );


// change the name below for the folder you want
$dir = "Data/".$data['id']."/messages/";

$file_to_write = $data['subject'];
$content_to_write = $data['message'];

if( is_dir($dir) === false )
	mkdir($dir, 0777, true);


$file = fopen($dir.$file_to_write,"a");
fwrite($file, $content_to_write);
fclose($file);

?>
