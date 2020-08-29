<?php

class Logger 
{
    private $logs = array();

    function __construct()
    {
        date_default_timezone_set('Asia/Kolkata');   
    }
   
    function addLog($msg, $type = 'i')
    {
        $finalMsg = date("h:i:s") . "=>[" . $type . "] ". $msg . "\n";
        array_push($this->logs, $finalMsg);
    }

    function __destruct() 
    {
        $base =  $_SERVER['DOCUMENT_ROOT'];
        $file = fopen("$base/logs.txt", 'a');
        foreach ($this->logs as $log)
            fwrite($file, $log);
        fclose($file);
    }
}

$logger = new Logger();

?>