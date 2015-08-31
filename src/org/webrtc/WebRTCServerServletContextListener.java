package org.webrtc;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.DefaultHandler;

import java.util.logging.Logger;
/**
 * Application Lifecycle Listener implementation for start/stop Embedding Jetty
 * Server configured to manage Signaling WebSocket with {@link WebRTCWebSocketHandler}.
 */
public class WebRTCServerServletContextListener implements ServletContextListener {
	private static final Logger logger = Logger.getLogger(WebRTCServerServletContextListener.class.getName());
	private Server server = null;

	/** Start Embedding Jetty server when WEB Application is started. */
	public void contextInitialized(ServletContextEvent event) {
		try {
			// 1) Create a Jetty server with the 8081 port.
			this.server = new Server(8081);
			logger.info("Servidor Jetty con el puerto" + this.server);
			// 2) Register SingalingWebSocketHandler in the Jetty server instance.
			WebRTCWebSocketHandler webRTCWebSocketHandler = new WebRTCWebSocketHandler();
			webRTCWebSocketHandler.setHandler(new DefaultHandler());
			server.setHandler(webRTCWebSocketHandler);
			// 2) Start the Jetty server.
			server.start();
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}

	/** Stop Embedding Jetty server when WEB Application is stopped. */
	public void contextDestroyed(ServletContextEvent event) {
		if (server != null) {
			try {// stop the Jetty server.
				server.stop();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

}
