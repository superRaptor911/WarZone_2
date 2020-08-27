<?php

function readLevels()
{
    $base =  $_SERVER['DOCUMENT_ROOT'];
	$users = scandir("Data");
	$Levels = array();

	foreach ($users as $user_name)
	{
		if ($user_name == "." or $user_name == ".." or $user_name == "") 
			continue;

		$map_dir = "$base/Data/$user_name/custom_maps/maps/";
		if (!is_dir($map_dir))
			continue;

		$maps = scandir($map_dir);

		foreach ($maps as $map_name)
		{
			if ($map_name == "." or $map_name == ".." or $map_name == "") 
				continue;
			
			$map = array();
			$map['name']		= basename($map_name, '.tscn');
            $map['base_map']	= $map_dir . $map_name;
            $map['author']		= $user_name;
            $map['time']        = filemtime($map['base_map']);

			$tdm_mode = "$base/Data/$user_name/custom_maps/gameModes/TDM/$map_name";
			$zm_mode  = "$base/Data/$user_name/custom_maps/gameModes/Zombie/$map_name";
            
            $game_modes = array();
            
			if (file_exists($tdm_mode))
				$game_modes['TDM']	= $tdm_mode;

			if (file_exists($zm_mode))
                $game_modes['Zombie']	= $zm_mode;

            $map['game_modes'] = $game_modes;
			$Levels[$user_name . $map['name']] = $map;
		}
	}

    # Save cache
    $file = fopen("$base/Data/Levels.json", 'w');
    fclose($file);
    $file = fopen("$base/Data/Levels.json", 'w');
    fwrite($file, json_encode($Levels));
    fclose($file);

	return $Levels;
}


function readLevelsFromCache()
{
    $base =  $_SERVER['DOCUMENT_ROOT'];
    $json = file_get_contents("$base/Data/Levels.json");
    $Levels = json_decode($json, true);
    return $Levels;
}


function readMessages()
{
    $base =  $_SERVER['DOCUMENT_ROOT'];
    $users = scandir("$base/Data");
    $Data_Base = array();
    
    foreach ($users as $user_name) 
    {
        if ($user_name == "." or $user_name == "..") 
            continue;
    
        if (!is_dir("$base/Data/$user_name/messages"))
            continue;
    
        $messages = scandir("$base/Data/$user_name/messages");
        
        foreach ($messages as $msg_file) 
        {	
            if ($msg_file == "." or $msg_file == "..") 
                continue;
    
            $filename = "$base/Data/$user_name/messages/$msg_file";
            $myfile = fopen($filename, "r");
    
            $msg_data = array();
            $msg_data['title'] = $msg_file;
            $msg_data['content'] = fread($myfile, filesize($filename));
            $msg_data['time'] = filemtime($filename);
            $msg_data['author'] = $user_name;
            $Data_Base[$user_name . $msg_file] = $msg_data;
            fclose($myfile);
        }		
    }

    return $Data_Base;
}

?>