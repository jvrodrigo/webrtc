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
	
	//public static final String PATH = "webrtc/videoconferencia";
	public static final String PATH = "";
	
	/** Renders the main page. When this page is shown, we create a new channel to push asynchronous updates to the client.*/
	@SuppressWarnings("null")
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {		
		String PATH = req.getContextPath().replace("/", "");
		String query = req.getQueryString();
		System.out.println("Consulta " + query);
		if(query==null) {
			String redirect = "/" + PATH + "/?r=" + Helper.generate_random(8);
			logger.info("Null Query -> Redirecting visitor to base URL to " + redirect);
			resp.sendRedirect(redirect);
			return;
		}
		Map<String, String> params = Helper.get_query_map(query);
		String room_key    = Helper.sanitize(params.get("r"));
		String debug       = params.get("debug");
	    String stun_server = params.get("ss");
	    //System.out.println("Debug: " + debug + " - Stun Server: " + stun_server);
	    //String audio_video = params.get("av");
	    if(room_key==null || room_key.equals("")) {
	    	room_key = Helper.generate_random(8);
	        String redirect = "/" + PATH + "/?r=" + room_key;
	        if(debug!=null)
	        	redirect += ("&debug=" + debug);
	        if(stun_server!=null || !stun_server.equals(""))
	        	redirect += ("&ss=" + stun_server);	        	        
	        logger.info("Sin habitacion (room key) -> Redirigiendo al usuario de base URL a " + redirect);
	        resp.sendRedirect(redirect);	        
	        return;
	    }else {
	    	String user = null;
	        int initiator = 0;
	        Room room = Room.get_by_key_name(room_key);
	        if(room==null && (debug==null||!"full".equals(debug))) { 
	        	logger.info("Nueva habitacion " + room_key);
	        	user = Helper.generate_random(8);
	        	room = new Room(room_key);
	        	room.add_user(user);
	        	if(!"loopback".equals(debug))
	        		initiator = 0;
	        	else {
	        		room.add_user(user);
	        		initiator = 1;
	        	}
	        } else if(room!=null && room.get_occupancy() == 1 && !"full".equals(debug)) {
	        	logger.info("Habitacion " + room_key + " con 1 usuario.");
	        	user = Helper.generate_random(8);
	        	room.add_user(user);
	        	initiator = 1;
	        } else { 
	        	logger.info("Habitacion " + room_key + " con 2 usuarios (completo).");
	        	Map<String, String> template_values = new HashMap<String, String>(); 
		        template_values.put("room_key", room_key);
		        String filepath = getServletContext().getRealPath( "/full.jtpl" );
	        	File file = new File(filepath);
		        resp.getWriter().print(Helper.generatePage(file, template_values));
	        	return;
	        }

	        String server_name = req.getServerName();
//	        int  server_port   = req.getServerPort();
	        int  server_port   = 8080;
	        String room_link = "http://"+server_name+":"+server_port+"/"+PATH+"/?r=" + room_key;
	        if(debug!=null)
	        	room_link += ("&debug=" + debug);
	        if(stun_server!=null)
	        	room_link += ("&ss=" + stun_server);
	        String username = "UserName";
	        String token = Helper.make_token(room_key, user);
	        String pc_config = Helper.make_pc_config(stun_server);
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
	        File file = new File(getServletContext().getRealPath( "/index.jtpl" ));
	        resp.getWriter().print(Helper.generatePage(file, template_values));
	        logger.info("Usuario " + user + " anadido a la habitacion " + room_key);
	        logger.info("La habitacion " + room_key + " tiene el estado " + room);
	        resp.setContentType("text/html");
    		resp.setStatus(HttpServletResponse.SC_OK);
	    }	    
	}
		
}
