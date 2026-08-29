extends Node
class_name Game

const MAX_PLAYERS := 1000

@export var player_holder: PlayerHolder
@export var network_panel: NetworkPanel
@export var server_runner: ServerRunner
@export var client_connector: ClientConnector


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_network_panel_host_server(port: int) -> void:
	server_runner.create_server(MAX_PLAYERS, port)


func _on_network_panel_join_server(ip: String, port: int) -> void:
	client_connector.connect_to_server(ip, port)


func _on_connected_to_server() -> void:
	network_panel.hide()


func _on_created_server() -> void:
	network_panel.hide()
	player_holder.spawn_player(1)
	push_warning("created server")
