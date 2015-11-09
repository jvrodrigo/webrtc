# WEBRTC
<h1>Aplicacion WebRTC para realizar videoconferencias con navegadores web Firefox / Chome / Opera</h1>

<h2>Puedes ver el ejemplo de esta aplicación desplegada en un servidor JBoss(Tomcat 7) en <strong>Openshift</strong>
en <a href="http://webrtc-jvrodrigo.rhcloud.com/webrtc/index.jsp">http://webrtc-jvrodrigo.rhcloud.com/webrtc</a></h2>

<p>Proyecto WEBRTC desplegado en un servidor Java Tomcat 7, con un servidor Jetty embebido, utilizando las reglas de WebSocket JSR 356(Java API for WebSockets) para la transmisión de datos y JavaScript en el cliente para utilizar
la conexión </p>

<h2>WebSocket JSR 356</h2>
<code>
import java.io.IOException;
import java.util.logging.Logger;
import javax.websocket.CloseReason;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.CloseReason.CloseCodes;
import javax.websocket.server.ServerEndpoint;
@ServerEndpoint(value = "/")
public class SignalingWebSocket {
	private Logger logger = Logger.getLogger(this.getClass().getName());
	@OnOpen
	public void onOpen(Session session) {
		logger.info("Connected ... " + session.getId());
	}
	@OnMessage
	public String onMessage(String message, Session session) {
            try {
                
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            break;
        }
        return message;
    }
    @OnClose
    public void onClose(Session session) {
        logger.info(String.format("Session %s closed", session.getId()));
    }
}
</code>
<h2>JavaScript navegador Cliente</h2>
<code>
function openChannel() {
		
	console.log("Abriendo el WebSocket...");
	var location = "ws://{server_name}:8000/webrtc/";
	channel = new WebSocket(location);
	
	channel.onopen = onChannelOpened;
	channel.onmessage = onChannelMessage;
	channel.onclose = onChannelClosed;
	channel.onerror = onChannelError;
}
</code>
<h2>Referencias:</h2>
<ul>
<li>Proyecto de DZLAB WebRTC <a href="https://github.com/dzlab/jWebRTC">https://github.com/dzlab/jWebRTC</a></li>
<li>Proyecto de WebRTC experiments de Muaz Khan <a href="https://www.webrtc-experiment.com/">https://www.webrtc-experiment.com/</a></li>
<li>HTML5 Rocks <a href="http://www.html5rocks.com/en/tutorials/webrtc/basics">http://www.html5rocks.com/en/tutorials/webrtc/basics</a></li>
<h3>Espero que disfrutes de este proyecto.</h3>
