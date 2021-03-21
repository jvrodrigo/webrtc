<!-- BEGIN: main -->
<!DOCTYPE html>
<html>
<head>
<link rel="icon" href="/webrtc/images/icon-16x16.png" type="image/png" sizes="16x16">
<link rel="icon" href="/webrtc/images/icon-190x190.png" type="image/png" sizes="190x190">
<!-- <link href="/webrtc/css/style.css" rel="stylesheet" type="text/css"> -->
<link href="/webrtc/css/style.min.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="theme-color" content="rgb(172, 187, 231)">
<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bienvenido a la Sala Principal</title>
</head>
<body>
	<div id="content">
	<div class="header">
		<h1>Sala Principal</h1>
		<div onclick="location.href='/webrtc'" class="logo-icon">
		</div>
		</div>
		<h2>Estas en la Sala Principal donde puedes contactar con los
			demas usuarios</h2>
		<ul>
			<li><span id="myName">{myName}</span></li>
			<li><span id="myToken">{myToken}</span></li>
		</ul>

		
		<div id="calling-on">
			Te llama:
			<span id="caller"></span>
			<button onclick="acceptCall()" id="lift"></button><button onclick="hangUp()" id="hang-up"></button>
		</div>
		<div class="users-list-div">{userList}</div>
	</div>
</body>
<script type="text/javascript">
	
	var host = "http://{server_name}";
	var port = 8080;
	var wsPort = 8000;
	var myToken = document.getElementById("myToken");
	console.log(myToken.innerHTML);

	var myName = document.getElementById("myName");
// 	console.log(myName.innerHTML);

	function calling(toUser) {
		console.log("User ->" + toUser.id);

		channel.send('{"type":"calling", "from":"' + myToken.innerHTML
				+ '", "username":"' + myName.innerHTML + '", "to":"'
				+ toUser.id + '"}');
 		window.location.assign("http://webrtc-jvrodrigo.rhcloud.com/webrtc/?r=" + toUser.id + myToken.innerHTML+"&userName=" + myName.innerHTML);
	}
	function acceptCall() {
		var url = document.getElementById("caller-url");
		window.location.assign(url.getAttribute("href"));
	}
	function hangUp() {
		document.getElementById("calling-on").style.display = "none";

	}

	function initialize() {
		//resetStatus();
		openChannel();
	};
	function openChannel() {
		console.log("Abriendo el canal.");
		var location = "ws://"+ window.location.host  +":" + wsPort + "/webrtc/";
// 		var location = "ws://"+ window.location  +":" + wsPort + "/webrtc/";
		console.log(location);
		channel = new WebSocket(location);
		channel.onopen = onChannelOpened;

		channel.onmessage = onChannelMessage;
		channel.onclose = onChannelClosed;
		channel.onerror = onChannelError;
	}
	function onChannelOpened() {
		console.log('Conectado a la app');
		channel.send('{"type":"connect", "username":"' + myName.innerHTML
				+ '","token":"' + myToken.innerHTML + '"}');
	}
	function onChannelMessage(message) {

		console.log('S -> C: ' + message.data);
		processSignalingMessage(message.data);

	}
	function onChannelError() {

		console.log('Error del canal');
	}
	function onChannelClosed() {

		console.log('Canal cerrado para el usuario');
		//alert('Canal cerrado para el usuario');
	}

	var userList = document.getElementById("userList");
	function processSignalingMessage(message) {
		//console.log(message);

		if (message) {
			var msg = JSON.parse(message);
			//console.log("Processing signaling message:\n Msg type: " + msg.type); 
			//console.log(msg);
			if (msg.type == "newuser") {
				//var msg = JSON.parse(message);
				//console.log(msg);

				var user = document.createElement("li");
				user.setAttribute("id", msg.usertoken);
				user.setAttribute("onclick", "calling(this)");
				user.setAttribute("class", "users-list-li");
				user.setAttribute("title", "Pulse para llamar al usuario "
						+ msg.username);
				var userToken = document.createTextNode("Usuario: "
						+ msg.username);
// 				var hiperLink = document.createElement("a");
// 				hiperLink.setAttribute('href', host + ":" + port
// 						+ "/webrtc/?r=" + msg.usertoken
// 						+ myToken.innerHTML);
// 				hiperLink.setAttribute('title', "Pulse para llamar al usuario "
// 						+ msg.username);
// 				hiperLink.appendChild(userToken);
// 				user.appendChild(hiperLink);
				var paragrap = document.createElement("p");
				paragrap.appendChild(userToken);
				user.appendChild(paragrap);
				userList.appendChild(user);
			}
			if (msg.type == "deleteuser") {
				//console.log(msg.usertoken);
				//console.log(document.getElementById(msg.usertoken));
				userList.removeChild(document.getElementById(msg.usertoken));

			}
			if (msg.type == "calling") {
				//console.log("Te llama el usuario " +  msg.username);
				document.getElementById("calling-on").style.display = "block";
				document.getElementById("caller").innerHTML = '<a id="caller-url" href="/webrtc/?r='
						+ myToken.innerHTML
						+ ''
						+ msg.sender
						+ "&userName="
						+ myName.innerHTML
						+ '">'
						+ msg.username + '</a>';
			}

		}
	}

	initialize();	
</script>
</html>
<!-- END: main -->