# WEBRTC
WebRTC app to do videocalls between web browsers

WEBRTC project is deployed in a tomcat7 with a embembed Jetty server. It use JSR356 websocket rules to send and recieve data.
It also have an clientUI write in HTML and js to handle the conexion and all the client features:
- Video chat
- Audio
- Send files
- Text chat

## Java

Goes to java 14

## Maven 

```bash
mvn package
mvn clean install
```

### WebSocket JSR 356
```java
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
      // ...
      return message;
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  @OnClose
  public void onClose(Session session) {
    logger.info(String.format("Session %s closed", session.getId()));
  }
}
```
### JavaScript client browser
```js
function openChannel() {
		
	console.log("Abriendo el WebSocket...");
	var location = "ws://{server_name}:8000/webrtc/";
	channel = new WebSocket(location);
	
	channel.onopen = onChannelOpened;
	channel.onmessage = onChannelMessage;
	channel.onclose = onChannelClosed;
	channel.onerror = onChannelError;
}
```
## References:
- DZLAB project WebRTC <a href="https://github.com/dzlab/jWebRTC">https://github.com/dzlab/jWebRTC
- WebRTC experiments projects Muaz Khan <a href="https://www.webrtc-experiment.com/">https://www.webrtc-experiment.com/
- HTML5 Rocks <a href="http://www.html5rocks.com/en/tutorials/webrtc/basics">http://www.html5rocks.com/en/tutorials/webrtc/basics
```sh
Enjoy it!! Happy coding
```
