package org.webrtc;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.DefaultHandler;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.logging.Logger;
/**
 * Application Lifecycle Listener implementation for start/stop Embedding Jetty
 * Server configured to manage Signaling WebSocket with {@link WebRTCWebSocketHandler}.
 */

public class WebRTCServerServletContextListener implements ServletContextListener {
	private static final Logger logger = Logger.getLogger(WebRTCServerServletContextListener.class.getName());
	private Server server = null;
	
	/** Start Embedding Jetty server when WEB Application is started. */
	@Override
	public void contextInitialized(ServletContextEvent event) {
		try {
			// 1) Create a Jetty server with the 8081 port.
			int port = 8000; // OpenShift WebSocket port support
			//server = new Server(8081); // Localhost port support
			
			InetAddress address = InetAddress.getByName("127.5.78.129"); // OpenShift Ip Address
			//InetAddress address = InetAddress.getByName("localhost");
			
			//InetSocketAddress bindAddr = new InetSocketAddress(address,8081);
		    InetSocketAddress bindAddr = new InetSocketAddress(address,port);
			server = new Server(bindAddr);
			
			logger.info("Servidor Jetty: ip -> " + server.getConnectors()[0].getName());
			
			// 2) Register SingalingWebSocketHandler in the Jetty server instance.
			WebRTCWebSocketHandler webRTCWebSocketHandler = new WebRTCWebSocketHandler();

			webRTCWebSocketHandler.setHandler(new DefaultHandler());
			server.setHandler(webRTCWebSocketHandler);
			// 2) Start the Jetty server.
			
			server.start();
			System.out.println("Estado del servidor -> " + server.getState());
			
			
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}

	/** Stop Embedding Jetty server when WEB Application is stopped. */
	@Override
	public void contextDestroyed(ServletContextEvent event) {
		if (server != null) {
			try {// stop the Jetty server.
				logger.info("Servidor Jetty con la referencia -> " + server + " es detenido");
				server.stop();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

}
