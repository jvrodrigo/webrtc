<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<link rel="icon" href="/webrtc/images/icon-16x16.png" type="image/png" sizes="16x16">
<link rel="icon" href="/webrtc/images/icon-190x190.png" type="image/png" sizes="190x190">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link href="/webrtc/css/style.css" rel="stylesheet" type="text/css">
<meta name="theme-color" content="#999999">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bienvenido a WEBRTC</title>
</head>
<body onload="acceptField()">
<div id="content">
<div class="header">
<h1>Bienvenido a WEBRTC</h1>

</div>
<h2>Introduce un nombre de usuario para conectacte a la Sala Principal</h2>
	<form  action="hall" method="post" id="form-to-hall" accept-charset="ISO-8859-1">
	<label for="userName">Nombre de usuario</label>
		<input id="userName" onkeyup="acceptField()" name="userName" autofocus="autofocus"/>
		<input id="submit-button" type="submit" disabled="disabled" value="Entrar"/>
	</form>
	<p id="alert-message">El nombre de usuario debe de tener más de 2 carácteres</p>
	</div>
</body>
<script type="text/javascript">
var userName = document.getElementById("userName");
function acceptField(){
	if(userName.value.length < 3){
		document.getElementById("alert-message").style.display = "block";
		document.getElementById("submit-button").disabled = true;
		document.getElementById('form-to-hall').style.border = "1px solid #F00";
	}else{
		document.getElementById("alert-message").style.display = "none";
		document.getElementById("submit-button").disabled = false;
		document.getElementById('form-to-hall').style.border = "1px solid #666";
	}
	
};
</script>
</html>
