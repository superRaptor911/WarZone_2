
<?php

include 'php/logger.php';

$target_dir = "Data/files/";
$target_file = $target_dir . basename($_FILES["file"]["name"]);


$logger->addLog("File is " . $target_file);
    
if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) 
    $logger->addLog("File ". basename( $_FILES["file"]["name"]). " was uploaded.");
else
    $logger->addLog("Failed to save file. Data : " . json_encode($_FILES));
?>
