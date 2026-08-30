extends MarginContainer
class_name NetworkPanel

signal host_server(port: int)
signal join_server(ip: String, port: int)

@export var ip_box: LineEdit
@export var port_box: LineEdit


func _on_host_button_pressed() -> void:
	if port_box.text.is_valid_int() or port_box.text.is_empty():
		var port := port_box.text.to_int() if not port_box.text.is_empty() else ServerRunner.DEFAULT_PORT
		if port > 65535 or port < 1:
			printerr(Global.local_peer_name + "Invalid port number!")
			return
		
		host_server.emit(port)
	else:
		printerr(Global.local_peer_name + "Port is not a number!")


func _on_join_button_pressed() -> void:
	if ip_box.text.is_valid_ip_address() or ip_box.text.is_empty():
		var ip := ip_box.text if not ip_box.text.is_empty() else "127.0.0.1"
		if port_box.text.is_valid_int() or port_box.text.is_empty():
			var port := port_box.text.to_int() if not port_box.text.is_empty() else ServerRunner.DEFAULT_PORT
			if port > 65535 or port < 1:
				printerr(Global.local_peer_name + "Invalid port number!")
				return
			
			join_server.emit(ip, port)
		else:
			printerr(Global.local_peer_name + "Port is not a number!")
	else:
		printerr(Global.local_peer_name + "Invalid IP address!")
