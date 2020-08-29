<?php
# File name : getLevelInfo.php
# Task 		: Sent available Level list to user.
# Coder 	: Raptor

include "php/dataBase.php";
$data = readLevelsFromCache();
header('Content-Type: application/json');
echo json_encode($data);
?>