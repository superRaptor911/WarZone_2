<?php
ob_start();

include 'php/dataBase.php';

function displayLevels($Levels)
{
	echo "<h1>Custom Maps</h2>";
	echo "<ol>";
	foreach ($Levels as $key => $map)
	{
		$game_modes = "[ ";
		foreach ($map['game_modes'] as $mode => $mode_file)
		{
			$game_modes = $game_modes . $mode . " ";
		}
		$game_modes = $game_modes . "]";
		
		$btn = "<form method=\"post\" ><button type=\"submit\" name=\"download\" value =\"".$key."\">Download</button> ";
		$btn = $btn . "<button type=\"submit\" name=\"delete\" value =\"".$key."\">Delete</button></form>";
		echo "<li>".$map['name']." ".$game_modes. $btn. "</li>";

	}
	echo "</ol>";
}

$Levels = readLevels();

displayLevels($Levels);

# Download Zip
if (array_key_exists("download",$_POST)) 
{
	$map = $Levels[$_POST["download"]];
	$z = new ZipArchive();
	$zip_name = $map['name'] . ".zip";
	$z->open($zip_name, ZIPARCHIVE::CREATE);
	$z->addEmptyDir("maps");
	$z->addFile($map['base_map'], "maps/".$map['name'].".tscn");
	$z->addEmptyDir("gameModes");

	foreach ($map['game_modes'] as $mode => $mode_file)
	{
		$z->addEmptyDir("gameModes/$mode");
		$z->addFile($mode_file, "gameModes/$mode/".$map['name'].".tscn");
	}


	$z->close();

	$filename = $zip_name;
	
	if (file_exists($filename)) 
	{
		ob_clean();
		ob_end_flush();
		header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
		header('Content-Type: application/zip;\n');
		header("Content-Transfer-Encoding: Binary");
		header("Content-Disposition: attachment; filename=\"".basename($filename)."\"");


	  # ob_end_flush();
	   readfile($filename);
	   // delete file
	   unlink($filename);
	 }
}

# Delete Map
if (array_key_exists("delete",$_POST)) 
{
	$map = $Levels[$_POST["delete"]];
	
	unlink($map['base_map']);
	foreach ($map['game_modes'] as $mode => $mode_file)
	{
		unlink($mode_file);
	}

	header("Refresh:0");
}

?>