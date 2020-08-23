<?php
ob_start();

include 'php/dataBase.php';

function displayLevels($Levels)
{
	echo "<h1>Custom Maps</h2>";
	echo "<ol>";
	foreach ($Levels as $key => $map)
	{
		$game_modes = "[";
		if (array_key_exists('tdm', $map))
			$game_modes = $game_modes . "TDM ";
		if (array_key_exists('zm', $map))
			$game_modes = $game_modes . "ZM";

		$game_modes = $game_modes . "]";
		
		$btn = "<form method=\"post\"><input type=\"submit\" name=\"". $key ."\" value =\"Download\"><br></form>";
		echo "<li>".$map['name']." ".$game_modes. $btn. "</li>";

	}
	echo "</ol>";
}

$Levels = readLevels();

displayLevels($Levels);



foreach ($Levels as $key => $map)
{
	#spaces in _post are coverted into _
	$m_key = str_replace(' ', '_', $key);
	
	if (array_key_exists($m_key,$_POST)) 
	{
		$z = new ZipArchive();
		$zip_name = $map['name'] . ".zip";
		$z->open($zip_name, ZIPARCHIVE::CREATE);
		$z->addEmptyDir("maps");
		$z->addFile($map['base_map'], "maps/".$map['name'].".tscn");
		$z->addEmptyDir("gameModes");

		if (array_key_exists("tdm", $map)) 
		{
			$z->addEmptyDir("gameModes/TDM");
			$z->addFile($map['tdm'], "gameModes/TDM/".$map['name'].".tscn");
		}
		if (array_key_exists("zm", $map)) 
		{
			$z->addEmptyDir("gameModes/Zombie");
			$z->addFile($map['zm'], "gameModes/Zombie/".$map['name'].".tscn");
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
}

?>