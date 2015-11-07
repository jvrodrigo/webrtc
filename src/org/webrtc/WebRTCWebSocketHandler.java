package org.webrtc;

import javax.servlet.http.HttpServletRequest;
import javax.websocket.ClientEndpoint;
import javax.websocket.server.ServerEndpoint;

import org.eclipse.jetty.websocket.WebSocket;
import org.eclipse.jetty.websocket.WebSocketHandler;
import org.eclipse.jetty.websocket.WebSocket.Connection;
import org.webrtc.common.SignalingWebSocket;

public class WebRTCWebSocketHandler extends WebSocketHandler {
	@Override
	public WebSocket doWebSocketConnect(HttpServletRequest request,String protocol) {
		System.out.println("doWebSocketConnect ----------");
		return new WebSocket() {
			
			@Override
			public void onOpen(Connection arg0) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onClose(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
		};
		//return new SignalingWebSocket();
	}
}