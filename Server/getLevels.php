<?php
include "php/dataBase.php";
$data = readLevels();
header('Content-Type: application/json');
echo json_encode($data);
?>