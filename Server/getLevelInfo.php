<?php
include "php/dataBase.php";
$data = readLevelsFromCache();
header('Content-Type: application/json');
echo json_encode($data);
?>