package org.webrtc;

import javax.servlet.http.HttpServletRequest;
import org.eclipse.jetty.websocket.WebSocket;
import org.eclipse.jetty.websocket.WebSocketHandler;

public class WebRTCWebSocketHandler extends WebSocketHandler {
  @Override
  public WebSocket doWebSocketConnect(HttpServletRequest request, String protocol) {
    System.out.println("doWebSocketConnect ----------");
    return new WebSocket() {

      @Override
      public void onOpen(Connection arg0) {
        System.out.println("onOpen ----------");
      }

      @Override
      public void onClose(int arg0, String arg1) {
        System.out.println("onClose ----------");
      }
    };
    // return new SignalingWebSocket();
  }
}