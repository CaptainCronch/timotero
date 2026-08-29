extends Node
class_name ServerRunner

signal created_server

#const DEFAULT_MAX_PLAYERS := 4
const DEFAULT_PORT := 33333


func create_server(max_players: int, port := DEFAULT_PORT) -> void:
	var network := ENetMultiplayerPeer.new()
	network.create_server(port, max_players)
	
	multiplayer.multiplayer_peer = network
	
	created_server.emit()
