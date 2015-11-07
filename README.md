# WEBRTC
<h1>Aplicacion WebRtc para realizar videoconferencias con navegadores web Firefox / Chome / Opera</h1>

<h2>Puedes ver el ejemplo de esta aplicación desplegada en un servidor JBoss(Tomcat 7) en <strong>Openshift</strong>
en <a href="http://webrtc-jvrodrigo.rhcloud.com/webrtc/index.jsp">http://webrtc-jvrodrigo.rhcloud.com/webrtc</a></h2>

<p>Proyecto WEBRTC desplegado en un servidor Java Tomcat 7, con un servidor Jetty embebido 
y utilizando las reglas de WebSocket JSR 356(Java API for WebSockets)</p>
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

  
  @ServerEndpoint(value = "/game")
  public class WordgameServerEndpoint {
   private Logger logger = Logger.getLogger(this.getClass().getName());
    @OnOpen
    public void onOpen(Session session) {
        logger.info("Connected ... " + session.getId());
    }
 
    @OnMessage
    public String onMessage(String message, Session session) {
        switch (message) {
        case "quit":
            try {
                session.close(new CloseReason(CloseCodes.NORMAL_CLOSURE, "Game ended"));
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            break;
        }
        return message;
    }
 
    @OnClose
    public void onClose(Session session, CloseReason closeReason) {
        logger.info(String.format("Session %s closed because of %s", session.getId(), closeReason));
    }
  }
</code>
<h2>Referencias:</h2>
<ul>
<li>Proyecto de DZLAB WebRTC <a href="https://github.com/dzlab/jWebRTC">https://github.com/dzlab/jWebRTC</a></li>
<li>Proyecto de WebRTC experiments de Muaz Khan <a href="https://www.webrtc-experiment.com/>https://www.webrtc-experiment.com/</a></li>

<h3>Espero que disfrutes de este proyecto.</h3>
