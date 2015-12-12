package org.webrtc.common;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.io.IOUtils;
import org.webrtc.model.Room;

import net.sf.jtpl.Template;

public class Helper {

	//public static final String SERVER = "http://localhost:8080";
	
	public static final String SERVER = "http://webrtc-jvrodrigo.rhcloud.com";
	/**
	 * Genera numeros aleatorios para crear los tokens
	 * @param len
	 * @return
	 */
	public static String generate_random(int length) {
		String generated = "";
		for(int i=0; i<length; i++) {
			int index = ((int) Math.round(Math.random()*62))%62;
			generated += "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".charAt(index);
		}		
		return generated;
	}
	
	/**
	 * Método para remplazar el caracter "-" de las cadena de texto  
	 * @param key
	 * @return
	 */
	public static String sanitize(String key){  
		return key.replace("[^a-zA-Z0-9\\-]", "-");
	}
	
	/**
	 * Método para crear un token con la habitación y del token del usuario
	 * @param room
	 * @param user
	 * @return un String con el formato "room:Room/userToken:String"
	 */
	public static String make_token(Room room, String user) {		 
		return room.key() + "/" + user;
	}
	
	/**
	 * Método para crear un token con el nombre de la habitacion y token del usuario
	 * @param room_key
	 * @param user
	 * @return un String con el formato "room:Room/userToken:String"
	 */
	public static String make_token(String room_key, String user) {		 
		return room_key + "/" + user;
	}
	
	/**
	 * Método para comprobar si el token la habitación
	 * @param token
	 * @return
	 */
	public static boolean is_valid_token(String token) {
		boolean valid = false;
		Room room = Room.get_by_key_name(get_room_key(token));
		String user = get_user(token);
		if(room!=null && room.has_user(user))
			valid = true;
		return valid;
	}
	
	/**
	 * Metodo para obtener el token de la habitacion de la concatenacion del token de la habitacion y el usuario "roomToken/userToken"
	 * @param token
	 * @return
	 */
	public static String get_room_key(String token) {
		String room_key = null;
		if(token!=null) {
			String[] values = token.split("/");
			if(values!=null && values.length>0)
				room_key = values[0];
		}
		return room_key;
	}
	/** 
	 * Metodo para obtener el token del usuario de la concatenacion del token de la habitacion y el usuario "roomToken/userToken"
	 * @param token
	 * @return
	 */
	public static String get_user(String token) {
		String user = null;
		if(token!=null) {
			String[] values = token.split("/");
			if(values!=null && values.length>1)
				user = values[1];
		}
		return user;
	}
	/**
	 * Devuelve una cadena de texto para de la direccion del servidor STUN/TURN
	 * @param stun_server
	 * @return
	 */
	public static String make_pc_config(String stun_server) {		
		if(stun_server!=null && !stun_server.equals(""))	
			return "STUN " + stun_server;		 
		else
			return "STUN stun.services.mozilla.com";
		    //return "STUN stun.l.google.com:19302";
	}

	
	/** 
	 * Devuelve un map<string, string> de una petición url con el formato -> nombre=valor
	 * @param query
	 * @return
	 */
	public static Map<String, String> get_query_map(String query) {  
	    String[] params = query.split("&");  
	    Map<String, String> map = new HashMap<String, String>();  
	    for (String param : params) {  
	        String name = param.split("=")[0];  
	        String value = param.split("=")[1];  
	        map.put(name, value);  
	    }  
	    return map;  
	} 
	
	/**
	 *  Devuelve una cadena de texto de un InputStream
	 * @param input
	 * @return
	 */
	public static String get_string_from_stream(InputStream input) {
		String output = null;
		try {
			StringWriter writer = new StringWriter();
			IOUtils.copy(input, writer);
			output = writer.toString();
		}catch(IOException e) {
			e.printStackTrace();
		}		
		return output;
	}
	
	/** 
	 * Método para generar una página HTML desde una plantilla JTPL preparada para remplazar las variables con los valores asignados en un map<String,String>
	 * @param file
	 * @param values
	 * @return
	 */
	public static String generatePage(File file, Map<String, String> values) {
		String block = "main"; 
		String output = null;
		try {
			Template tpl = new Template(file);
			for(String key :values.keySet()) {
				tpl.assign(key, values.get(key));
			}     		
			tpl.parse(block);
	        output = tpl.out();
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		return output;
	}
}
