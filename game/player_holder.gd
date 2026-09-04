extends Node
class_name PlayerHolder

const PLAYER = preload("uid://nw0kmvmm5cs")

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info: Dictionary[String, String] = {"name": "Name"}
var player_nodes: Dictionary[int, Player] = {}
#var player_names: Dictionary[int, String] = {}

@export var game: Game


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
	new_player.owner_peer_id = id
	new_player.name = str(id)
	#new_player.owner_peer_id = id
	#new_player.debug_label.text = str(id)
	new_player.position += Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
	player_nodes[id] = new_player
	add_child(new_player, true)


func _on_peer_connected(id: int) -> void:
	spawn_player(id)


func _on_peer_disconnected(id: int) -> void:
	#player_nodes[id].queue_free()
	player_nodes.erase(id)
