package org.webrtc.web;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.webrtc.common.Helper;
import org.webrtc.model.Room;

/**The main UI page, renders the 'index.html' template.*/
public class MainPageServlet extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger(MainPageServlet.class.getName());
	public String token;
	public String roomKey;
	//public static final String PATH = "webrtc/videoconferencia";
	public static final String PATH = "webrtc/";
	private static final String INDEX = "http://webrtc-jvrodrigo.rhcloud.com/webrtc/index.jsp";
	
	/** Renders the main page. When this page is shown, we create a new channel to push asynchronous updates to the client.*/
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {		
		//String PATH = req.getContextPath().replace("/", "");
		String query = req.getQueryString();
		System.out.println("Consulta " + query);
		if(query==null) {
			logger.info("Sin consulta");
			resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			resp.sendRedirect(INDEX);
			return;
		}
		Map<String, String> params = Helper.get_query_map(query);
		String room_key    = Helper.sanitize(params.get("r"));
	    if(room_key==null || room_key.equals("")) {
	    	logger.info("Sin habitacion (room key)");
	    	resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	    	resp.sendRedirect(INDEX);
	        return;
	    }else {
	    	String user = null;
	        int initiator = 0;
	        Room room = Room.get_by_key_name(room_key);
	        if(room==null) { 
	        	logger.info("Nueva habitacion " + room_key);
	        	user = Helper.generate_random(16);
	        	room = new Room(room_key);
	        	room.add_user(user);
	        	initiator = 0;
	        	logger.info("Nueva habitacion " + room_key);
	        } else if(room!=null && room.get_occupancy() == 1) {
	        	user = Helper.generate_random(16);
	        	room.add_user(user);
	        	logger.info("Habitacion " + room_key + " con 1 usuario, anadido otro usuario: "+ user );
	        	initiator = 1;
	        } else { 
	        	logger.info("Habitacion " + room_key + " con 2 usuarios (completo).");
	        	Map<String, String> template_values = new HashMap<String, String>(); 
		        template_values.put("room_key", room_key);
		        resp.setContentType("text/html");
		        String filepath = getServletContext().getRealPath( "webrtc/full.jtpl" );
	        	File file = new File(filepath);
		        resp.getWriter().print(Helper.generatePage(file, template_values));
	        	return;
	        }

	        String server_name = req.getServerName();
	        int  server_port   = req.getServerPort();
	        String room_link = "http://"+server_name+":"+server_port+"/webrtc/?r=" + room_key;	        
	        String username = "UserName";
	        setToken(Helper.make_token(room_key, user));
	        setRoomKey(room_key);
	        String pc_config = Helper.make_pc_config("");
	        Map<String, String> template_values = new HashMap<String, String>(); 
	        template_values.put("server_name", server_name);
	        template_values.put("server_port", server_port+"");
	        template_values.put("PATH",  PATH);
	        template_values.put("token", token);
	        template_values.put("me", user);
	        template_values.put("username", username);
	        template_values.put("room_key", room_key);
	        template_values.put("room_link", room_link);
	        template_values.put("initiator", ""+initiator);
	        template_values.put("pc_config", pc_config);
	        resp.setContentType("text/html");
	        File file = new File(getServletContext().getRealPath("webrtc/index.jtpl"));
	        resp.getWriter().println(Helper.generatePage(file, template_values));
	        logger.info("Usuario " + user + " anadido a la habitacion " + room_key);
	        logger.info("La habitacion " + room_key + " tiene el estado " + room);
	        resp.setStatus(HttpServletResponse.SC_OK);
	    }	    
	}
	/* Getters and Setters */
	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}
	public String getRoomKey() {
		return roomKey;
	}
	public void setRoomKey(String roomKey) {
		this.roomKey = roomKey;
	}
}
