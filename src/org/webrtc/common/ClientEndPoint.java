package org.webrtc.common;

import java.util.logging.Logger;

import javax.websocket.ClientEndpoint;
import javax.websocket.OnOpen;
import javax.websocket.Session;


public class ClientEndPoint {
	 private Logger logger = Logger.getLogger(this.getClass().getName());     

	    @OnOpen 
	    public void onOpen(Session s) {
	        logger.info("Client Connected ... " + s.getId());
	        s.getAsyncRemote().sendText("hello from the client!");  
	    }
}
