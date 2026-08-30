extends Node
class_name PlayerHolder

const PLAYER = preload("uid://nw0kmvmm5cs")

var player_nodes: Dictionary[int, Player] = {}
var player_names: Dictionary[int, String] = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func spawn_player(id: int) -> void:
	#if not get_tree().get_multiplayer().get_unique_id() == 1: return
	if not multiplayer.is_server(): return
	#push_warning("Spawning player with ID ", id)
	if player_nodes.keys().has(id):
		printerr("Player of ID " + str(id) + " already exists!")
		return
	var new_player: Player = PLAYER.instantiate()
	#new_player.owner_peer_id = id
	new_player.name = str(id)
	new_player.debug_label.text = str(id)
	new_player.position += Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
	player_nodes[id] = new_player
	add_child(new_player)


func _on_peer_connected(id: int) -> void:
	spawn_player(id)


func _on_peer_disconnected(id: int) -> void:
	#player_nodes[id].queue_free()
	player_nodes.erase(id)
