<!-- BEGIN: main -->
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="icon" href="/webrtc/images/icon-16x16.png" type="image/png" sizes="16x16">
<link rel="icon" href="/webrtc/images/icon-190x190.png" type="image/png" sizes="190x190">
<meta name="theme-color" content="rgb(172, 187, 231)">
<!-- <link rel="stylesheet" type="text/css" href="/webrtc/css/style.css"> -->
<link href="/webrtc/css/style.min.css" rel="stylesheet" type="text/css">
<link rel="stylesheet"
	href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<!-- <script type="text/javascript" src="js/ambilight.js"></script> -->
<script type="text/javascript" src="/webrtc/js/RecordRTC.min.js"></script>
<script type="text/javascript" src="/webrtc/js/mediaControls.min.js"></script>
<!-- <script type="text/javascript" src="/webrtc/js/mediaControls.js"></script> -->
<!-- <script type="text/javascript" src="/webrtc/js/bootstrap.js"></script> -->

<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<title>Aplicacion WebRTC</title>
</head>
<body onLoad="javascript:preLoader()">
	<div id="panelInfo">Iniciando...</div>
	<div id="container">
		<div id="hall-form">
		<form  action="hall" method="post" id="form-to-hall-rtc" accept-charset="ISO-8859-1">
			<input id="formUserName" name="userName" type="hidden" value="{userName}"/>
			<input id="submit-button" type="submit"  value="Volver a la Sala Principal"/>
		</form>
		</div>
		<div id="card">
			<div id="chat" class="ui-widget-content ui-draggable ui-draggable-handle ui-resizable">
				<div id="chatControls">
					<button title="Cerrar Chat" id="closeChat" onclick="closeChat()"></button>
					<button title="Bajar Opacidad" id="downOpacity" onclick="downOpacity()"></button>
					<button title="Subir Opacidad" id="upOpacity" onclick="upOpacity()"></button>
				</div>
				<h3 class="ui-widget-header">Chat</h3>
				<div id="chatList"></div>
				<div id="chatSender">
					<input type="text" placeholder="Escribe aqu&iacute..." id="chatMessage" onchange="chatMessage(this)">
					<input type="submit" value="Enviar" id="chatMessageSubmit">
				</div>
			</div>
			<div id="videoControls">
				<button id="enterFullScreen" title="Pantalla Completa" onclick="enterFullScreen()"></button>
				<button id="exitFullScreen" title="Salir de Pantalla Completa" onclick="exitFullScreen()"></button>
				<button id="takePicture" title="Tomar Foto" onclick="takePicture()"></button>
				<button id="record" title="Pulse para Grabar" onclick="recordL()"></button>
				<button id="stopRecord" title="Grabando..." onclick="stopRecordL()"></button>
				<button id="sendFileOn" title="Compartir archivos"></button>
				<button id="sendFileOff" title="Compartiendo"></button>
				<input id="sendFile" type="file" value="">
				<div id="progressBar">
					<button id="cancelFile" title="Cancelar" onclick="cancelSendFile()">X</button>
					<div id="progress"></div>
					<div id="progressPercent"></div>
				</div>
				<button id="mute" title="Sonido On" onclick="toggleAudioMute()"></button>
				<button id="unMute" title="Sonido Off" onclick="toggleAudioMute()"></button>
				<button id="hangUp"  title="Colgar" onclick="onHangUp()"></button>
				<button id="reCall" title="Rellamar" onclick="reCall()" ></button>
				<button id="chatOn" title="Chat On" onclick="closeChat()"></button>
				<button id="chatOff" title="Chat Off" onclick="openChat()"></button>
			</div>
			<div id="local">
				<video id="localVideo" width="320px" height="160px"
					autoplay="autoplay"></video>
				<canvas id="canvasLocalVideo"></canvas>
				<img id="snapShot" src="" alt=" ">
			</div>
			<div id="videoConexion">
				<div id="remote">
					<video id="remoteVideo"
						autoplay="autoplay"></video>
				</div>
				<div id="mini">
					<video id="miniVideo" autoplay="autoplay"></video>
				</div>
			</div>
		</div>
	</div>
</body>
<script type="text/javascript">
//* share files *//
var fileName;
var cancelFile = false;
var cancelRecieveFile = false;
var chunk = 0;
var maxChunks;
var arrayToStoreChunks = [];
var blob;
var chunkLength = 1000;
var delay; // Variable para limpiar el timeOut de la barra de progreso de carga/descarga
// Funcion para abrir archivos con el explorador del S.O.
document.querySelector("#sendFileOn").addEventListener("click", function() {
	var clickEvent = document.createEvent('MouseEvents');
	clickEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
	  document.querySelector("#sendFile").dispatchEvent(clickEvent);
});
document.getElementById('sendFile').onchange = function() {
    var file = this.files[0];
    console.log(file.name);
    fileName = file.name;
    var reader = new window.FileReader();
    reader.readAsDataURL(file);
    reader.onload = onReadAsDataURL;
};

/* Funcion recursiva para enviar los datos en partes de 1000 bytes */
 
function onReadAsDataURL(event, text) {
	var data = {}; // objeto data para transmitirlo por el canal de mensajes (MessageServlet.java)
	if(!cancelFile && !cancelRecieveFile){
		if (event){ // la primera invocacion
			clearTimeout(delay);
			chunk = 0;
    		text = event.target.result;
    		data.maxChunks = Math.ceil(text.length / chunkLength); // Trozea el archivo en chunks de 1000 bytes y calcula el maximo
    		maxChunks = Math.ceil(text.length / chunkLength);
    		//console.log("Max Chunks -> "+ data.maxChunks);
    		$("#progressBar").fadeIn();
    		data.fileName = fileName; // Pasa el nombre del archivo en el primer evento
    	}
 	  	//$("#progressBar").show();
    	chunk = (100 / maxChunks) + chunk; // Porcentaje completado
    	if (text.length > chunkLength) {
	        data.message = text.slice(0, chunkLength); // trocea en un chunk usando el tamanio predefinido para el chunk
        	data.type = "file";
        	document.getElementById("cancelFile").style.display = "inherit";
    		document.getElementById("sendFileOn").style.display = "none";
    		document.getElementById("sendFileOff").style.display = "block";
        	document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
        	document.getElementById("progressPercent").innerHTML = "Enviando " + Math.ceil(chunk) + "%\n" + fileName ;
    	} else { // ultimo chunk
	        data.message = text;
        	data.last = true;
        	data.type = "file";
        	document.getElementById("cancelFile").style.display = "none";
        	document.getElementById("sendFileOn").style.display = "block";
    		document.getElementById("sendFileOff").style.display = "none";
        	document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
        	document.getElementById("progressPercent").innerHTML = "Enviado 100% - OK\n" + fileName ;
        	delay = setTimeout(function(){$("#progressBar").fadeOut(3000);},10000);
    	}
	    
		sendMessage(data);
		
	    var remainingDataURL = text.slice(data.message.length);
	    if (remainingDataURL.length) setTimeout(function () {
        	onReadAsDataURL(null, remainingDataURL); // continue transmitting
    	}, 500);
	}else{ // Se cancela el envio del archivo

		cancelFile = false;

        if(cancelRecieveFile){
        	cancelRecieveFile = false; // Reset la variable
        	document.getElementById("cancelFile").style.display = "none";
        	document.getElementById("sendFileOn").style.display = "block";
        	document.getElementById("sendFileOff").style.display = "none";
    		document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
            document.getElementById("progressPercent").innerHTML = "Cancelado remoto\n" + fileName ;
            delay = setTimeout(function(){$("#progressBar").delay(2000).fadeOut(3000);},10000);
        	
        }else{
    		data.cancel = true;
        	data.type = "file";
        	sendMessage(data); // Envia la cancelacion del envio
        	cancelRecieveFile = false; // Reset la variable
        	document.getElementById("cancelFile").style.display = "none";
        	document.getElementById("sendFileOn").style.display = "block";
        	document.getElementById("sendFileOff").style.display = "none";
    		document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
            document.getElementById("progressPercent").innerHTML = "Cancelado\n" + fileName ;
			delay = setTimeout(function(){$("#progressBar").fadeOut(3000);},10000);
        }
	}
}
function cancelSendFile(){
	cancelFile = true;
	//cancelRecieveFile = false;
}
function preLoader(){
	// Contador
	var i = 0;
    // Objeto Imagen
// 	imageObj = new Image();

//     // Lista de imagenes
//     images = new Array();
//     images[0]="./images/enterfullscreen.png";
//     images[1]="./images/exitfullscreen.png";
//     images[2]="./images/altavoz-off.png";
//     images[3]="./images/altavoz-on.png";
//     images[4]="./images/call.png";
//     images[5]="./images/hangup.png";
//     images[6]="./images/camera.png";
//     images[7]="./file/futura.ttf";
    
//     /* Empieza la precarga */
//     for(i=0; i <= 6; i++) 
//     {
//          imageObj.src=images[i];
//     };
    /* Fin de la precarga*/    
}
//** WebRTC Config **//
navigator.getUserMedia = navigator.getUserMedia
		|| navigator.mozGetUserMedia || navigator.webkitGetUserMedia;
window.RTCPeerConnection = window.RTCPeerConnection
		|| window.mozRTCPeerConnection
		|| window.webkitRTCPeerConnection;
window.RTCIceCandidate = window.RTCIceCandidate
		|| window.mozRTCIceCandidate || window.webkitRTCIceCandidate;
window.RTCSessionDescription = window.RTCSessionDescription
		|| window.mozRTCSessionDescription
		|| window.webkitRTCSessionDescription;
var localVideo;
var miniVideo;
var remoteVideo;
var localStream;
var remoteStream;
var channel;
var channelReady = false;
var pc;
var initiator = {initiator};
var started = false;
var panelInfo;
var card;
var channelToken = '{token}';
var roomKey = '{room_key}';
var me = '{me}';
var mini = document.getElementById("mini");
var ambilight;
var record = document.getElementById("record");
var pcConstraints = {'optional': [{"DtlsSrtpKeyAgreement": false}]};
var mediaConstraints = {"audio": true, "video": true};
var turnUrl = {'urls' : 'stun:stun.l.google.com:19302',};
//var peerConnectionConfig = {'iceServers' : [ {'urls' : 'stun:stun.services.mozilla.com'	}, {'urls' : 'stun:stun.l.google.com:19302'},{'urls': 'turn:numb.viagenie.ca', 'credential': 'muazkh', 'username': 'webrtc@live.com'}]};
var peerConnectionConfig = {'iceServers' : [ {'urls' : 'stun:stun.services.mozilla.com'	}, {'urls' : 'stun:stun.l.google.com:19302'}]};
function initialize() {
	//console.log("Iniciando...; room={room_key}.");
	console.log("Iniciando...; room=" + roomKey);
	card = document.getElementById("card");
	localVideo = document.getElementById("localVideo");
	miniVideo = document.getElementById("miniVideo");
	remoteVideo = document.getElementById("remoteVideo");
	panelInfo = document.getElementById("panelInfo");
	resetStatus();
	openChannel();
	getUserMedia();
}
function resetStatus() {
	if (!initiator) {
		setStatus("Esperando alguien para unirse: <a href=\"{room_link}\" target=_blank>{room_link}</a>");
	} else {
		setStatus("Iniciando...");
	}
}
function setStatus(state) {
	panelInfo.innerHTML = state;
}
function openChannel() {
		
	console.log("Abriendo el canal.");
	var location = "ws://{server_name}:8000/webrtc/";
// 	var location = "ws://{server_name}:8081/webrtc/";

	console.log(location);
	channel = new WebSocket(location);
	channel.onopen = onChannelOpened;
	
	channel.onmessage = onChannelMessage;
	channel.onclose = onChannelClosed;
	channel.onerror = onChannelError;
}
function onChannelOpened() {

	console.log('Canal abierto para el token: ' + channelToken);
	channel.send('{"type":"token", "value":"' + channelToken + '"}');
	//channel.send('token:' + channelToken);
	channelReady = true;

	if (initiator)
		maybeStart();
}
function onChannelMessage(message) {

	console.log('S -> C: ' + message.data);
	processSignalingMessage(message.data);

}
function onChannelError() {

	console.log('Error del canal para el token: ' + channelToken);
}
function onChannelClosed() {

	console.log('Canal cerrado para el token: ' + channelToken);
	alert('Canal cerrado por el usuario ' + (initiator + 1)	+ ' con el token ' + channelToken);
	//channel = null;
}

function getUserMedia() {
	try {
		navigator.getUserMedia({
		audio : true,
		video : true
		}, onUserMediaSuccess, onUserMediaError);
		console.log("Acceso solicitado al medio local con la nueva sintaxis");
	} catch (e) {
		try {
			navigator.getUserMedia("video,audio", onUserMediaSuccess, onUserMediaError);
			console.log("Acceso solicitado al medio local con la antig�a sintaxis");
		} catch (e) {
			alert("getUserMedia() ha fallado. Esta la opcion(flag) de MediaStream activa(enabled) en -> about:flags?");
			console.log("getUserMedia() ha fallado con la excepcion: " + e.message);
		};
	};
}

function onUserMediaSuccess(stream) {

	console.log("Usuario se le ha concedido el acceso al medio local.");
	var url = window.URL.createObjectURL(stream);
	localVideo.style.opacity = 1;
	localVideo.src = url;
	localStream = stream;
	// La llamada crea la PeerConnection.
	console.log("Initiator: " + initiator);
	//ambilight(document.getElementById('localVideo'));// Crea el efecto ambilight
	if (initiator) 
		maybeStart();
}

function onUserMediaError(error) {
	console.log("Ha fallado el acceso al medio local. El codigo de error es: " + error.message);
	alert("Ha fallado el acceso al medio local. El codigo de error es: " + error.message);
}

function maybeStart() {
	if (!started && localStream && channelReady) {
		setStatus("Conectando...");
		console.log("Creando PeerConnection.");
		createPeerConnection();
		console.log("Anadiendo localStream. Initiator = " + initiator);
		pc.addStream(localStream);
		started = true;
		// El llamado inicia la oferta "offer" al par.
		if (initiator)
			doCall();
	}
}

function createPeerConnection() {
	try {
		pc = new window.RTCPeerConnection(peerConnectionConfig);
		console.log("Creada la RTCPeerConnection con la configuracion \"{pc_config}\".");
	} catch (e) {
		console.log("Fallo al crear la PeerConnection, excepcion: " + e.message);
		alert("No se puede crear el objeto PeerConnection; Esta la opcion(flag) 'PeerConnection' activada(enabled) en about:flags?");
		return;
	}
	pc.onconnecting = onSessionConnecting;
	pc.onopen = onSessionOpened;
	pc.onaddstream = onRemoteStreamAdded;
	pc.onicecandidate = onIceCandidate;
	pc.onremovestream = onRemoteStreamRemoved;
}
function onSessionConnecting(message) {
	console.log("Conectando la sesion.");
}
function onSessionOpened(message) {
	console.log("Sesion abierta.");
}

function onRemoteStreamAdded(event) {
	
	// Elimina el efecto ambilight
	/*var canvas = document.getElementsByClassName("ambilight-left");
	var i = 0;
	console.log("Canvas " + canvas.lenght);
	for (i=0 ;i < canvas.lenght;i++) {
		canvas[i].parentNode.removeChild(canvas[i]);
		console.log("Canvas " + canvas.lenght);
	}
	canvas = document.getElementsByClassName("ambilight-right");
	
	for (i=0 ;i < canvas.lenght;i++) {
		
		canvas[i].parentNode.removeChild(canvas[i]);
	}*/
	
	console.log("Stream remoto anadido.");
	// Para grabar el stream remoto en disco
	remoteStream = event.stream; 
	var url = window.URL.createObjectURL(event.stream);
	miniVideo.src = localVideo.src;
	localVideo.style.display = "none";
	
	remoteVideo.src = url;			
	waitForRemoteVideo();
}
function onRemoteStreamRemoved(event) {
	console.log("Stream remoto eliminado.");
}
// Funcion para animar el miniVideo
function animate(elem) {
	var width = 100;
	var id = setInterval(frame, 1);
	function frame() {
		width = width - 10;
		elem.style.width = width + "%";
		if (width == 20) {
			clearInterval(id);
		}
	};
}
function onIceCandidate(event) {

	if (!pc || !event || !event.candidate) {
		console.log("End of candidates.");
		return;
	} else {
		sendMessage({
			type : 'candidate',
			'ice' : event.candidate,
		});
	}
}

function doCall() {
	console.log("Usuario: " + initiator + " - Envia la oferta al par");
	pc.createOffer(gotDescription, infoHandler, errorHandler);
}

function gotDescription(description) {
	try {
		console.log('Toma la descripcion');// con la descripcion: '+ JSON.stringify(description));
		pc.setLocalDescription(description, function(){sendMessage(description);}, errorHandler);
	} catch (err) {
		errorHandler(err.message);
	};
}
function errorHandler(error) {
	console.log("ERROR -> " + error);
}
function infoHandler(info) {
	console.log("INFO -> " + info);
}

function sendMessage(message) {
	try {
		var msgString = JSON.stringify(message);
		console.log('C -> S: ' + msgString);
		path = '/webrtc/message?r={room_key}' + '&u={me}';
		var xhr = new XMLHttpRequest();
		xhr.open('post', path, true);
		xhr.send(msgString);
	} catch (error) {
		console.log(error);
	};
}

function processSignalingMessage(message) {
	var msg = null;
	if (message) {
		try{
			msg = JSON.parse(message);
		}catch (e) {
			console.log("Error JSON");
		} 
		//console.log("Processing signaling message:\n Msg type: " + msg.type); 
		if (msg.type === 'offer') {
			/*La llamada crea la Conexion a pares (PeerConnection)*/
			if (!initiator && !started) {
				maybeStart();
			}
			pc.setRemoteDescription(new RTCSessionDescription(msg),
				function() {
					pc.createAnswer(function(answer) {
						pc.setLocalDescription(
							new RTCSessionDescription(answer),
								function() {
									// envia la respuesta al servidor para ser entregada a quien llama (a ti)
									sendMessage(answer);
								}, errorHandler);
					}, errorHandler);
				}, errorHandler);
		} else if (msg.type === 'answer' && started) {

			pc.setRemoteDescription(new RTCSessionDescription(msg));
			console.log("Anadido answer a la descripcion remota");

		} else if (msg.type === 'candidate' && started) {

			var candidate = new window.RTCIceCandidate(msg.ice);
			if (pc.addIceCandidate(candidate)) {

				console.log("Candidato anadido correctamente "
						+ candidate.candidate);
			};
		} else if (msg.type === 'bye' && started) {
			onRemoteHangup();
			chatWriteRecieveMessage("El usuario " + msg.user+ " ha cerrado la conexion");
			//var node = document.createElement("p");
			//var textnode = document.createTextNode("El usuario " + msg.user+ " ha cerrado la conexion");
			//node.appendChild(textnode);
			// inserta el mensaje en la lista de chat
			//document.getElementById("chatList").insertBefore(node, document.getElementById("chatList").firstChild);
		} else if (msg.type === 'chat' && started) {
			chatWriteRecieveMessage(msg.sdp);
			//var node = document.createElement("p");
			//var textnode = document.createTextNode(msg.user + " -> " + msg.sdp);
			//node.appendChild(textnode);
			//document.getElementById("chatList").insertBefore(node, document.getElementById("chatList").firstChild);
		} else if(msg.type === 'file' && started){
			if(!cancelFile){ // Si no se cancela recibir el archivo

				if(msg.maxChunks){ // El primer chunk envia el maxChunks, fileName y el mensaje
					clearTimeout(delay); // Resetea los time out fadeOut de progressBar
					chunk = 0;
					arrayToStoreChunks = []; // resetting array
					//console.log(msg.maxChunks);
					maxChunks = msg.maxChunks;
					fileName = msg.fileName;
					$("#progressBar").fadeIn();
					document.getElementById("cancelFile").style.display = "inherit";
					document.getElementById("sendFileOn").style.display = "none"; // Botones
		    		document.getElementById("sendFileOff").style.display = "block";// Botones
		    		cancelRecieveFile = false; // Si se ha cancelado previamente la recepcion, el primer chunk activa la recepcion del fichero
				}
				if(!cancelRecieveFile){
					chunk = (100 / maxChunks) + chunk;
					arrayToStoreChunks.push(msg.message); // Aplila chunks en el array
					document.getElementById("cancelFile").style.display = "inherit";
					document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
					document.getElementById("progressPercent").innerHTML = "Descargando " + Math.ceil(chunk) + "%\n" + fileName;
					cancelRecieveFile = false;
				}else{
					cancelRecieveFile = false;
					cancelFile = false;
				}
				
		    	if (msg.last) { // El ultimo chunk
			        //console.log(arrayToStoreChunks);
		        	var hyperlink = document.createElement('a');
					hyperlink.href = arrayToStoreChunks.join('');;
					hyperlink.target = '_blank';
					hyperlink.download = fileName;
					var node = document.createElement("div");
					node.className = "chatRecieve";
					var chatRecieveLateral = document.createElement("div");
					var chatRecieveLateralB = document.createElement("div");
					var chatRecieveMessage = document.createElement("div");
					chatRecieveLateral.className = "chatRecieveLateral";
					chatRecieveLateralB.className = "chatRecieveLateralB";
					chatRecieveMessage.className = "chatRecieveMessage";
					var message = document.createTextNode(fileName);
					hyperlink.appendChild(message);
					chatRecieveMessage.appendChild(hyperlink);
					node.appendChild(chatRecieveLateral);
					node.appendChild(chatRecieveLateralB);
					node.appendChild(chatRecieveMessage);
					document.getElementById("chatList").appendChild(node);
					window.setInterval(function() {
						  var elem = document.getElementById('chatList');
						  elem.scrollTop = elem.scrollHeight;
					}, 1000);					
					
					arrayToStoreChunks = []; // resetting array
					chunk = 0;
					document.getElementById("cancelFile").style.display = "none";
					document.getElementById("sendFileOn").style.display = "block";
		    		document.getElementById("sendFileOff").style.display = "none";
					document.getElementById("progressPercent").innerHTML = "Descargado 100% - OK\n" + fileName ;
					delay = setTimeout(function(){$("#progressBar").fadeOut(3000);},10000);
		    	};
		    	if(msg.cancel){ // Si cancela el envio el propietario del fichero
		    		cancelFile = false;
					arrayToStoreChunks = [];
					document.getElementById("cancelFile").style.display = "none";
		    		document.getElementById("sendFileOn").style.display = "block";
		    		document.getElementById("sendFileOff").style.display = "none";
					document.getElementById("progressPercent").innerHTML = "Se ha cancelado el envio";
					delay = setTimeout(function(){$("#progressBar").fadeOut(3000);},10000);
		    	};
		    	if(msg.cancelRecieveFile){ /* Senal para cancelar el archivo que se esta recibiendo y cancelar su envio al par (es cancelado por quien lo esta recibiendo)*/
		    		cancelRecieveFile = true;
		    		//cancelRevieveFile = true;
		    	}
		    	
			}else{ /* Se cancela el archivo que esta siendo recibido */
				
				data = {};
				data.cancelRecieveFile = true;
		    	data.type = "file";
		    	sendMessage(data);
		    	cancelFile = false;
		    	cancelRecieveFile = true;
				arrayToStoreChunks = [];
				document.getElementById("cancelFile").style.display = "none";
				document.getElementById("sendFileOn").style.display = "block";
		    	document.getElementById("sendFileOff").style.display = "none";
				document.getElementById("progress").style.width = Math.ceil(chunk) + "%";
		        document.getElementById("progressPercent").innerHTML = "Cancelado\n" + fileName ;
		        
		        delay = setTimeout(function(){$("#progressBar").fadeOut(3000);},10000);
		        
			};
		};
	};
}

function chatMessage(message) {
	//console.log(message.value);
	debugger;
	var cmessage = message.value;
	chatWriteSendMessage(cmessage);
	document.getElementById("chatMessage").value = "";
	
	/*document.getElementById("chatList").insertBefore(node, document.getElementById("chatList").firstChild);*/
	sendMessage({
		type : "chat",
		"sdp" : cmessage,
		"user" : '{me}',
	});
}
/* ESCRIBIR LOS MENSAJES EN EL CHAT */
function chatWriteRecieveMessage(message){
	var cmessage = message;
	//document.getElementById("chatMessage").value = "";
	var node = document.createElement("div");
	node.className = "chatRecieve";
	//var textnode = document.createTextNode('{me} -> ' + cmessage);
	var chatRecieveLateral = document.createElement("div");
	var chatRecieveLateralB = document.createElement("div");
	var chatRecieveMessage = document.createElement("div");
	chatRecieveLateral.className = "chatRecieveLateral";
	chatRecieveLateralB.className = "chatRecieveLateralB";
	chatRecieveMessage.className = "chatRecieveMessage";
	var message = document.createTextNode(cmessage);
	chatRecieveMessage.appendChild(message);
	node.appendChild(chatRecieveMessage);
	node.appendChild(chatRecieveLateral);
	node.appendChild(chatRecieveLateralB);
	document.getElementById("chatList").appendChild(node);
	window.setInterval(function() {
		  var elem = document.getElementById('chatList');
		  elem.scrollTop = elem.scrollHeight;
		}, 1000);
	
}
function chatWriteSendMessage(message){
	var cmessage = message;
	var node = document.createElement("div");
	node.className = "chatSend";
	var chatSendLateral = document.createElement("div");
	var chatSendLateralB = document.createElement("div");
	var chatSendMessage = document.createElement("div");
	chatSendLateral.className = "chatSendLateral";
	chatSendLateralB.className = "chatSendLateralB";
	chatSendMessage.className = "chatSendMessage";
	var message = document.createTextNode(cmessage);
	chatSendMessage.appendChild(message);
	node.appendChild(chatSendLateral);
	node.appendChild(chatSendLateralB);
	node.appendChild(chatSendMessage);
	document.getElementById("chatList").appendChild(node);
	window.setInterval(function() {
		  var elem = document.getElementById('chatList');
		  elem.scrollTop = elem.scrollHeight;
	}, 1000);
}
/* FIN ESCRIBIR LOS MENSAJES EN EL CHAT */
 
 /** FUNCIONES Y ANIMACIONES DE LA VIDEOCONFERENCIA **/
 
function onHangUp() {
	console.log("En espera.");
	started = false; // Para de procesar cualquier mensaje
	transitionToDone();
	// disparara un BYE desde el servidor
	channel.close();
	channel = null;
	document.getElementById("hangUp").style.display = "none";
	document.getElementById("reCall").style.display = "block";
}

function onRemoteHangup() {
	console.log('Sesion en ESPERA de forma remota.');
	started = false; // Para de procesar cualquier mensaje
	transitionToWaiting();
	initiator = 0;
}

function waitForRemoteVideo() {
	console.log("Esperado el video remoto.");
	if (remoteVideo) {
		transitionToActive();
	} else {
		setTimeout(waitForRemoteVideo, 100);
	}
}
function transitionToActive() {
	console.log("Video conferencia en estado ACTIVO.");
	document.getElementById("reCall").style.display = "none";
	document.getElementById("hangUp").style.display = "block";
	setStatus("Conexion OK");
	document.getElementById("videoConexion").style.display = "inherit";
	document.getElementById("local").style.display = "none";
	miniVideo.style.opacity = 1;
	remoteVideo.style.opacity = 1;
	//ambilight(document.getElementById('remoteVideo'));// Crea el efecto ambilight
	animate(mini);
}
function transitionToWaiting() {
	console.log("Video conferencia en estado ESPERA.");
	/*setTimeout(function() {
		localVideo.src = miniVideo.src;
		miniVideo.src = "";
		remoteVideo.src = "";
	}, 500);*/
	document.getElementById("videoConexion").style.display = "none";
	document.getElementById("local").style.display = "inherit";
	miniVideo.style.opacity = 0;
	remoteVideo.style.opacity = 0;
	localVideo.style.display ="inherit";
	//ambilight(document.getElementById('localVideo'));// Crea el efecto ambilight
	resetStatus();
}
function transitionToDone() {
	console.log("Video conferencia en estado DONE.");
	//localVideo.style.opacity = 0;
	remoteVideo.style.opacity = 0;
	setStatus("Has abandonado la llamada. <a href=\"{room_link}\">Haz click aqu� para</a> reestablecer.");
}


if (!window.WebSocket)
	alert("Este navegador no soporta el WebSocket");

initialize();





</script>
</html>
<!-- END: main -->