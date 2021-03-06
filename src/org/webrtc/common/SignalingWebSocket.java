package org.webrtc.common;

import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.logging.Logger;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.model.Room;
import org.webrtc.web.HallPageServlet;

@ServerEndpoint(value = "/")
public class SignalingWebSocket {

	private static final Logger logger = Logger.getLogger(SignalingWebSocket.class.getName());
	private static final ConcurrentMap<String, SignalingWebSocket> channels = new ConcurrentHashMap<String, SignalingWebSocket>();
	private Session session;
	private String userHall;
	private String userName;
	private String peerToken;

	/**
	 * Método público para abrir el socket ServerEndPoint
	 * 
	 * @param session
	 */
	@OnOpen
	public void onOpen(Session session) {
		logger.info("Conexion abierta");
		// Client (Browser) WebSockets has opened a connection: Store the opened
		// connection
		// this.connection = connection;
		this.session = session;

	}

	/**
	 * Método público para recibir los mensajes enviados por los clientes al socket
	 * 
	 * @param message
	 */
	@OnMessage
	public void onMessage(String message) {
		System.out.println("Se recibe -> " + message);
		JSONObject jsonObject;
		try {
			jsonObject = new JSONObject(message);

			if (!jsonObject.isNull("type")) {

				if (jsonObject.get("type").equals("connect")) {
					userName = jsonObject.getString("username");
					userHall = jsonObject.getString("token");
					channels.put(userHall, this);
					addUserToHall(userHall, userName);
				}
				if (jsonObject.get("type").equals("calling")) {
					String from = jsonObject.getString("from");
					String to = jsonObject.getString("to");
					String username = jsonObject.getString("username");
					callingToUser(from, username, to);
				}
				if (jsonObject.get("type").equals("token")) {
					peerToken = jsonObject.getString("value");
					channels.put(peerToken, this);
					logger.info("Añadido el token (valid=" + Helper.is_valid_token(peerToken) + "): " + peerToken);
				}
			}

		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Método publico para cerrar las conexiones con el socket
	 * 
	 * @param session
	 */
	@OnClose
	public void onClose(Session session) {
		try {
			if (userHall != null) {
				channels.remove(userHall, this);
				HallPageServlet.userList.remove(userHall);
				deleteFromHall(userHall);
				logger.info("Conexion cerrada de la sala principal -> Token:" + userHall);
			}
			if (peerToken != null) {
				channels.remove(peerToken, this);
				Room.disconnect(peerToken);
				logger.info("VideoConexion cerrada -> Token:" + peerToken);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Método para enviar la oferta, respuesta, ice candidates etc, de webrtc
	 * 
	 * @param token
	 * @param message
	 * @return
	 */
	public static boolean sendPeer(String token, String message) {
		logger.info("Enviando para " + token + " el mensaje (" + message + ") ");
		boolean success = false;
		SignalingWebSocket ws = channels.get(token);
		if (ws != null) {
			success = ws.send(message);
		}
		return success;
	}

	/**
	 * Método estatico para enviar la señal de conexión de un usuario a la sala
	 * Principal
	 * 
	 * @param userToken
	 * @param userName
	 */
	private static void addUserToHall(String userToken, String userName) {

		// Envia el mensaje de conexión en la sala Principal en broadcast
		for (Entry<String, SignalingWebSocket> a : channels.entrySet()) {
			SignalingWebSocket ws = a.getValue();
			String tokens = a.getKey();
			if (!userToken.equals(tokens)) {// Asi mismo no se envía el mensaje
				logger.info("Enviando mensaje para los usuarios -> " + tokens);
				JSONObject json = new JSONObject();
				try {
					json.put("type", "newuser");
					json.put("username", userName);
					json.put("usertoken", userToken);
					ws.sendMessageOut(json.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * Método estatico privado para enviar la señal de deconexión del usuario a los
	 * demás usuarios de la sala Principal
	 * 
	 * @param userToken
	 */
	private static void deleteFromHall(String userToken) {

		// Envia el mensaje de desconexión a la sala Principal en broadcast
		for (Entry<String, SignalingWebSocket> a : channels.entrySet()) {
			SignalingWebSocket ws = a.getValue();
			String token = a.getKey();
			if (!userToken.equals(token)) { // Asi mismo no se envía el mensaje
				logger.info("Enviando señal de desconexión a los usuarios -> " + ws);
				try {
					JSONObject json = new JSONObject();
					json.put("type", "deleteuser");
					json.put("usertoken", userToken);
					ws.sendMessageOut(json.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * Método estatico privado para llamar a un usuario para realizar la llamada
	 * VoIP, el usuario entra en la sala y envia la peticion a otro usuario
	 * 
	 * @param calling
	 * @param to
	 */
	private static void callingToUser(String from, String userName, String to) {
		SignalingWebSocket ws = channels.get(to);
		if (ws != null) {
			JSONObject json = new JSONObject();
			try {
				json.put("type", "calling");
				json.put("username", userName);
				json.put("sender", from);
				json.put("recive", to);
				ws.sendMessageOut(json.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}

	}

	/**
	 * Método público para enviar el mensaje desde el socket a los clientes de la
	 * sala principal
	 * 
	 * @param message
	 */
	public void sendMessageOut(String message) {
		if (session != null) {
			try {
				logger.info("Enviando el mensaje ... " + message);
				session.getBasicRemote().sendText(message);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * Método para enviar los datos de WebRTC para la videoconexión
	 * 
	 * @param message
	 * @return
	 */
	private boolean send(String message) {

		if (session != null) {
			try {
				logger.info("Enviando el mensaje ... " + message);
				session.getBasicRemote().sendText(message);
				return true;
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}
		return false;

	}

}
