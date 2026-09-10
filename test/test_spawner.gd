extends Node3D

@export_file_path("*.tscn") var spawned_scene: String
@export var spawn_delay := 5.0
@export var spawn_force := 5.0


func _ready() -> void:
	#if not multiplayer.is_server(): return
	#if not is_multiplayer_authority(): return
	$Timer.start(spawn_delay)
	#await get_tree().physics_frame
	#_on_timer_timeout()


func _on_timer_timeout() -> void:
	#if not multiplayer.is_server(): return
	if not is_multiplayer_authority(): return
	var scene: Node3D = load(spawned_scene).instantiate()
	var plat_comp: PlatformerComponent = scene.get_node_or_null("PlatformerComponent")
	if not plat_comp == null:
		plat_comp.target.velocity = (Vector3.FORWARD * spawn_force).rotated(Vector3.UP, randf_range(0.0, TAU))
	scene.position = global_position
	get_parent().add_child(scene, true)
	#Global.game.console_panel.add_message("spawned a " + scene.name)
	#$Timer.start(spawn_delay)
