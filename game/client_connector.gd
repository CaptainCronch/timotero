extends Node
class_name ClientConnector

const LOCALHOST := "127.0.0.1"


func connect_to_server(server_ip := LOCALHOST, port := ServerRunner.DEFAULT_PORT) -> void:
	var network := ENetMultiplayerPeer.new()
	network.create_client(server_ip, port)
	
	multiplayer.multiplayer_peer = network
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	print(Global.local_peer_name + " is connecting to " + server_ip + ":" + str(port) + "!")


func _on_connected_to_server() -> void:
	print(Global.local_peer_name + " successfully connected to server!")


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
