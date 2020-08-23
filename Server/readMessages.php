<!DOCTYPE html>
<html>
<head>
	<title>Messages</title>
</head>
<body>

<?php

include "php/dataBase.php";

$Data_Base = readMessages();

function msg_sort($a, $b)
{
	return $b['time'] - $a['time'];
}

usort($Data_Base, "msg_sort");

?>

<h1>Messages</h1>
<?php
	
foreach ($Data_Base as $key => $msg) 
{
	echo "<h2>".$msg['title']."</h2>";
	echo "<p>".$msg['content']."</p><br>";
}
?>

</body>
</html> 
