<?php

function getClientIP() 
{
    $ipaddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    else if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_X_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    else if(isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    else if(isset($_SERVER['REMOTE_ADDR']))
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipaddress = 'UNKNOWN';
    return $ipaddress;
}

function clientHasPermission()
{
    $ip = getClientIP();
    if ($ip == 'UNKNOWN') 
        return false;
    
    $base =  $_SERVER['DOCUMENT_ROOT'];
    $admin_list = "$base/Data/admin/admin_list.dat";

    if (file_exists($admin_list)) 
    {
        $file = fopen($admin_list, 'r');
        $contents = fread($file, filesize($admin_list));
        $admins = json_decode($contents, true);
        fclose($file);
        
        if (array_key_exists($ip, $admins))
        {
            $admin_duration = 3600 ; # 1 hour
            $admin_login_timestamp = $admins[$ip]['time_stamp']; 
            if ($admin_login_timestamp + $admin_duration > time()) 
                return true;
        }
    }

    return false;
}

function addAdmin($ip)
{
    $base =  $_SERVER['DOCUMENT_ROOT'];
    $dir = "$base/Data/admin/";
    
    if (!is_dir($dir))
        mkdir($dir, 0777, true);

    $admin_list = "$base/Data/admin/admin_list.dat";
    $admins = array();
    if (file_exists($admin_list)) 
    {
        $file = fopen($admin_list, 'r');
        $contents = fread($file, filesize($admin_list));
        $admins = json_decode($contents, true);
        fclose($file);
    }

    $admin = array();
    $admin['time_stamp'] = time();

    $admins[$ip] = $admin;
    $file = fopen($admin_list, 'w');
    fwrite($file, json_encode($admins));
    fclose($file);
}

?>