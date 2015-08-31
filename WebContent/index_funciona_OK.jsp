<!-- BEGIN: main -->
<!DOCTYPE HTML>
<html>
<head>
<link rel="canonical" href="{room_link}"/>
<meta charset="UTF-8">
</head>
<body>
<div id="footer">Iniciando...
  </div>
<div id="container" ondblclick="enterFullScreen()"> 
  <div id="card">
    <div id="local">
      <video width="100%" height="100%" id="localVideo" autoplay="autoplay"></video>
    </div>
    <div id="remote">
      <video width="100%" height="100%" id="remoteVideo" autoplay="autoplay"></video>
      <div id="mini">
        <video width="100%" height="100%" id="miniVideo" autoplay="autoplay"></video>
      </div>
    </div>
  </div>
</div>
<script type="text/javascript">
var peerConnectionConfig = {'iceServers': [{'url': 'stun:stun.services.mozilla.com'}, {'url': 'stun:stun.l.google.com:19302'}]};

navigator.getUserMedia = navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia;
window.RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
window.RTCIceCandidate = window.RTCIceCandidate || window.mozRTCIceCandidate || window.webkitRTCIceCandidate;
window.RTCSessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription || window.webkitRTCSessionDescription;

  var localVideo;
  var miniVideo;
  var remoteVideo;
  var localStream;
  var channel;
  var channelReady = false;
  var pc;
  var socket;
  var initiator = {initiator};
  var time = new Date();
  var started = false;
  var footer;
  var peerConnectionConfig = {
			'iceServers' : [ {
				'url' : 'stun:stun.services.mozilla.com'
			}, {
				'url' : 'stun:stun.l.google.com:19302'
			} ]
		};
  function initialize() {
    console.log("Initializing; room={room_key}.");
    card = document.getElementById("card");
    localVideo = document.getElementById("localVideo");
    miniVideo = document.getElementById("miniVideo");
    remoteVideo = document.getElementById("remoteVideo");
    footer = document.getElementById("footer");
    resetStatus();
    openChannel();
    getUserMedia();
  }

  function openChannel() {
    console.log("Opening channel.");
	var location = "ws://{server_name}:8081/";
    channel = new WebSocket(location);
	channel.onopen    = onChannelOpened;
	channel.onmessage = onChannelMessage;
	channel.onclose   = onChannelClosed;
	channel.onerror   = onChannelError;
  }

  function resetStatus() {
    if (!initiator) {
      setStatus("Esperando alguien para unirse: <a href=\"{room_link}\">{room_link}</a>");
    } else {
      setStatus("Iniciando...");
    }
  }

  function getUserMedia() {
    try {
      navigator.getUserMedia({audio:true, video:true}, onUserMediaSuccess, onUserMediaError);
      console.log("Requested access to local media with new syntax: "+navigator.mozGetUserMedia);
      
    } catch (e) {
      try {
        navigator.getUserMedia("video,audio", onUserMediaSuccess, onUserMediaError);
        console.log("Requested access to local media with old syntax.");
      } catch (e) {
        alert("webkitGetUserMedia() failed. Is the MediaStream flag enabled in about:flags?");
        console.log("webkitGetUserMedia failed with exception: " + e.message);
      };
    };
  }

  function createPeerConnection() {
    try {
      //pc = new webkitPeerConnection00("{pc_config}", onIceCandidate);
      pc = new window.RTCPeerConnection(peerConnectionConfig);//firefox
      console.log("Created RTCPeerConnection with config \"{pc_config}\".");
    } catch (e) {
      console.log("Failed to create PeerConnection, exception: " + e.message);
      alert("Cannot create PeerConnection object; Is the 'PeerConnection' flag enabled in about:flags?");
      return;
    }
    
    pc.onconnecting = onSessionConnecting;
    pc.onopen = onSessionOpened;
    pc.onicecandidate = onIceCandidate;
   // pc.localDescription = localDescription;
   // pc.remoteDescription = remoteDescription;
   	pc.onaddstream = onRemoteStreamAdded;
    pc.onremovestream = onRemoteStreamRemoved;
    console.log("Salgo de createPeerConnection()");
  }

  function maybeStart() {
    if (!started && localStream && channelReady) {
      setStatus("Conectando...");
      console.log("Creating PeerConnection.");
      createPeerConnection();
      console.log("Adding local stream. Initiator = " + initiator);
      pc.addStream(localStream);
      started = true;
      // Caller initiates offer to peer.
     if (initiator)
        doCall();
    }
  }

  function setStatus(state) {
    footer.innerHTML = state;
  }

  function doCall() {
    console.log("Usuario: "+ initiator +" - Send offer to peer");
    pc.createOffer(gotDescription,infoHandler, errorHandler);
    //sendMessage({type: 'offer', sdp: offer.sdp,});   
    //pc.startIce();
  }
  function gotDescription(description) {
	  try{
	    console.log('Got description con la descripcion: '+ JSON.stringify(description));
	    pc.setLocalDescription(description, function () {
	        sendMessage(description);
	    }, function() {console.log('set description error');});
	    
	  }catch(e){
		  console.log(e);
		  
	  };
	}
  function errorHandler(error) {
	    console.log("ERROR ->"+error);
	}
  function infoHandler(info){
	  console.log("INFO:"+info);
  }
  /*
 function doAnswer() {
    console.log("Send answer to peer");
    var offer = pc.remoteDescription;
    var answer = pc.createAnswer(offer.sdp, {audio:true,video:true,});
    pc.setLocalDescription(pc.SDP_ANSWER, answer);
    sendMessage({type: 'answer', sdp: answer.sdp,});
    //pc.startIce();
  }*/
  function doAnswer() {
	    console.log("Send answer to peer");
	    var offer = pc.remoteDescription;
	    console.log("DoAnswer->Offer:"+ JSON.stringify(offer));
	  
	    var answer = pc.createAnswer(offer, infoHandler,errorHandler);	   
	  	pc.setLocalDescription(pc.SDP_ANSWER, answer);
	    sendMessage({type: 'answer', 'sdp': message.sdp,});
	 }
  function sendMessage(message) {
    var msgString = JSON.stringify(message);
    console.log('C->S: ' + msgString);
    path = '/{PATH}/message?r={room_key}' + '&u={me}';
    console.log("PATH -> "+ path);
    var xhr = new XMLHttpRequest();
    xhr.open('POST', path, true);
    xhr.send(msgString);
  }

  /*function processSignalingMessage(message) {
	console.log("Processing signaling message: " + message);
    var msg = JSON.parse(message);

    if (msg.type === 'offer') {
      // Callee creates PeerConnection
      if (!initiator && !started)
        maybeStart();

      pc.setRemoteDescription(pc.SDP_OFFER, new SessionDescription(msg.sdp));
      doAnswer();
    } else if (msg.type === 'answer' && started) {
      pc.setRemoteDescription(pc.SDP_ANSWER, new SessionDescription(msg.sdp));
    } else if (msg.type === 'candidate' && started) {
      var candidate = new IceCandidate(msg.label, msg.candidate);
      pc.processIceMessage(candidate);
    } else if (msg.type === 'bye' && started) {
      onRemoteHangup();
    };
  }*/
  
  function processSignalingMessage(message) {
	  console.log("Processing signaling message");
	  console.log(time.toUTCString() + " : Processing signaling message: " + message);
	  var msg = JSON.parse(message);
	  console.log("Msg: " + msg.sdp);
	  if (msg.type === 'offer') {
	    /*Callee creates PeerConnection*/
	    console.log("Procesando senal -> started = "+ started);
	    if (!initiator && !started){
	      maybeStart();
	      console.log("Salgo de maybeStart() en ProcessSignal");
	    }
	   	/*
	    pc.setRemoteDescription(new RTCSessionDescription(msg.sdp));
	    doAnswer();*/
	    pc.setRemoteDescription(new RTCSessionDescription(msg), function() {
	        pc.createAnswer(function(answer) {
	          pc.setLocalDescription(new RTCSessionDescription(answer), function() {
	            // send the answer to a server to be forwarded back to the caller (you)
	        	  sendMessage({type: 'answer', 'sdp': answer.sdp,});
	          }, infoHandler, errorHandler);
	        }, infoHandler, errorHandler);
	      }, infoHandler, errorHandler);
	  } else if (msg.type === 'answer' && started) {
		  pc.setRemoteDescription(new RTCSessionDescription(msg), function() {
		        pc.createAnswer(function(answer) {
		          pc.setLocalDescription(new RTCSessionDescription(answer), function() {
		            // send the answer to a server to be forwarded back to the caller (you)
		        	  //sendMessage({type: 'answer', 'sdp': answer.sdp,});
		          }, infoHandler, errorHandler);
		        }, infoHandler, errorHandler);
		      }, infoHandler, errorHandler);
	    //pc.setRemoteDescription(new RTCSessionDescription(msg));
	  } else if (msg.type === 'candidate' && started) {
	    //var candidate = new window.RTCIceCandidate(msg.label,
	    //                                     msg.candidate);
	    
	    var candidate = new window.RTCIceCandidate(msg.ice);
	    console.log("Candidate ->" + candidate);
	    pc.addIceCandidate(candidate);
	    console.log("Anadido el candidato:" + cadidate);
	  } else if (msg.type === 'bye' && started) {
	    onRemoteHangup();
	  }
	}

  function onChannelOpened() {
    console.log('Channel opened for token:{token}');
	channel.send('token:{token}');
    channelReady = true;
    if (initiator) maybeStart();
  }
  function onChannelMessage(message) {
    console.log('S->C: ' + message.data);
    processSignalingMessage(message.data);
  }
  function onChannelError() {
    console.log('Channel error for token: {token}');
  }
  function onChannelClosed() {
    console.log('Channel closed for token: {token}');
    alert('Channel closed for user '+(initiator+1)+' with token {token}.');
	channel = null;
  }

  function onUserMediaSuccess(stream) {
    console.log("User has granted access to local media.");
    //var url = webkitURL.createObjectURL(stream);
    var url = window.URL.createObjectURL(stream);
    localVideo.style.opacity = 1;
    localVideo.src = url;
    localStream = stream;
    // Caller creates PeerConnection.
    console.log("Initiator: " + initiator);
    if (initiator)
    { console.log("onUserMediaSuccess: MaybeStart() se ejecuta");
    	maybeStart();
    }else{
    	/*createPeerConnection();
    	pc.addStream(localStream);
    	var offer = pc.createOffer(gotDescription,infoHandler, errorHandler);
        sendMessage({type: 'offer', sdp: offer.sdp,});*/ 
    };
    
  }
  function onUserMediaError(error) {
    console.log("Failed to get access to local media. Error code was " + error.code);
    alert("Failed to get access to local media. Error code was " + error.code + ".");
  }

function onIceCandidate(event) {
	    if (event.candidate) {
	    	channel.send(JSON.stringify({
	    		type : 'candidate',
                'ice': event.candidate,
	     }));
	    } else {
	      console.log("End of candidates.");
	    }
	 }
  /*function onIceCandidate(event) {
	    if (event.candidate) {
	        sendMessage({type: 'candidate',
	                     label: event.candidate.label, candidate: event.candidate.sdp});
	    }else{
	    	console.log("End of candidates.");
	    	
	    }
	  }*/
  /* function onIceCandidate(event) {
	    if (event.candidate) {
	    	sendMessage(JSON.stringify({
	    	type: 'candidate',
            'ice': event.candidate,
	     }));
	    } else {
	      console.log("End of candidates.");
	    }
	 }*/
  function onSessionConnecting(message) {
    console.log("Session connecting.");
  }
  function onSessionOpened(message) {
    console.log("Session opened.");
  }

  function onRemoteStreamAdded(event) {
    console.log("Remote stream added.");
    var url = window.URL.createObjectURL(event.stream);
    miniVideo.src = localVideo.src;
    remoteVideo.src = url;
    waitForRemoteVideo();  
  }
  function onRemoteStreamRemoved(event) {
    console.log("Remote stream removed.");
  }

  function onHangup() {
    console.log("Hanging up.");
    started = false;    // Stop processing any message
    transitionToDone();
    pc.close();
    // will trigger BYE from server
    socket.close();
    pc = null;
    //socket = null;
  }
   
  function onRemoteHangup() {
    console.log('Session terminated.');
    started = false;    // Stop processing any message
    transitionToWaiting();
    pc.close();
    pc = null;
    initiator = 0;
  }

  function waitForRemoteVideo() {
	console.log("Waiting for remote video.");
    if (remoteVideo.currentTime > 0) {
      transitionToActive();
    } else {
      setTimeout(waitForRemoteVideo, 100);
    }
  }
  function transitionToActive() {
	console.log("Video conference transiting to active state.");
    remoteVideo.style.opacity = 1;
    //card.style.webkitTransform = "rotateY(180deg)";
    setTimeout(function() { localVideo.src = ""; }, 500);
    setTimeout(function() { miniVideo.style.opacity = 1; }, 1000);
    setStatus("<input type=\"button\" id=\"hangup\" value=\"Hang up\" onclick=\"onHangup()\" />");
  }
  function transitionToWaiting() {
	console.log("Video conference transiting to waiting state.");
   // card.style.webkitTransform = "rotateY(0deg)";
    setTimeout(function() { localVideo.src = miniVideo.src; miniVideo.src = ""; remoteVideo.src = "";}, 500);
    miniVideo.style.opacity = 0;
    remoteVideo.style.opacity = 0;
    resetStatus();
  }
  function transitionToDone() {
	console.log("Video conference transiting to done state.");
    localVideo.style.opacity = 0;
    remoteVideo.style.opacity = 0;
    miniVideo.style.opacity = 0;
    setStatus("You have left the call. <a href=\"{room_link}\">Click here</a> to rejoin.");
  }
  function enterFullScreen() {
	console.log("Entering full screen mode.");
    remote.webkitRequestFullScreen();
  }

  if (!window.WebSocket)
	alert("WebSocket not supported by this browser");

  setTimeout(initialize, 1);
</script>
</body>
</html>
<!-- END: main -->