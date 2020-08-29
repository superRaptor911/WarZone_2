<!DOCTYPE HTML>  
<html>
<head>
<style>
	.error {color: #FF0000;}
</style>
</head>
<body>  

<?php
include('../php/authoriser.php');


if ($_SERVER["REQUEST_METHOD"] == "POST") 
{
  if (!empty($_POST["i_password"])) 
  {
	$pass = test_input($_POST["i_password"]);
	$hashed_password = crypt($pass, 'ZRsuP1Gi2112');
	$admin_code_hashed = 'ZR9Hrza4e8dJY';

	if ($admin_code_hashed == $hashed_password) 
	{
		$ip = getClientIP();
		if ($ip == 'UNKNOWN') 
		{
			echo "IP error";
		}
		else
		{
			addAdmin($ip);
		}
	}
	else
	{
		echo "Wrong Admin code. Plz try again.<br>";
	}
  }
}

function test_input($data) {
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

?>

<h2 style="text-shadow: 3px 3px 2px #90FF12;font-size: 32px;text-align: center;">Login</h2>


<form class="form-horizontal" method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>">
	<fieldset>

	<!-- Form Name -->
	<legend>Login</legend>

	<!-- Password input-->
	<div class="form-group">
	  <label class="col-md-4 control-label" for="i_password">Password </label>
	  <div class="col-md-4">
	    <input id="i_password" name="i_password" type="password" placeholder="Enter Admin code" class="form-control input-md" required="">
	  </div>
	</div> <br>


	<input type="submit" name="submit" value="Submit">
	</fieldset>
</form>

</body>
</html>
