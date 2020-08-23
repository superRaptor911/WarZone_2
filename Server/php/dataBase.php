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

			$tdm_mode = "$base/Data/$user_name/custom_maps/gameModes/TDM/$map_name";
			$zm_mode  = "$base/Data/$user_name/custom_maps/gameModes/Zombie/$map_name";
			
			if (file_exists($tdm_mode))
				$map['tdm']	= $tdm_mode;

			if (file_exists($zm_mode))
				$map['zm']	= $zm_mode;

			$Levels[$user_name . $map['name']] = $map;
		}
	}

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