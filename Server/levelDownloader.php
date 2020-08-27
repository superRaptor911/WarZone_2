<?php

$map_info = json_decode( file_get_contents( 'php://input' ), true );
$map      = array();
clearstatcache();

if (file_exists($map_info['base_map']))
{
    $filename        = $map_info['base_map'];
    $myfile          = fopen($filename, "r");
    $map['base_map'] = fread($myfile, filesize($filename));
    fclose($myfile);
}

$game_modes = array();

foreach ($map_info['game_modes'] as $mode => $filename)
{
    if (file_exists($filename))
    {
        $myfile            = fopen($filename, "r");
        $game_modes[$mode] = fread($myfile, filesize($filename));
        fclose($myfile);
    }
}

$map['game_modes'] = $game_modes;

header('Content-Type: application/json');
echo json_encode($map);
?>