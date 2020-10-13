<?php

# File name : getServerInfo.php
# Task 		: get serverInfo.
# Coder 	: Raptor

$servers = scandir("Data/servers");
$output = array();

foreach ($servers as $s)
{
    if ($s == "." or $s == ".." or $s == "") 
        continue;
    
    $fname = "Data/servers/".$s;
    $date = new DateTime();

    if ($date->getTimestamp() - filemtime($fname) < 120)
    {
        $file = fopen($fname, 'r');
        $data = fread($file, filesize($fname));

        $data = json_decode($data, true);
        $output["$s"] = $data;
    }
}

echo json_encode($output);
?>