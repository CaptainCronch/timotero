@icon("res://addons/at-icons/node3d/box.svg")
extends CharacterBody3D
class_name Item

const PICK_UP_DELAY := 1.0

@export var slotref: SlotRef
@export var health_comp: HealthComponent
@export var hitbox_comp: HitboxComponent
@export var plat_comp: PlatformerComponent
@export var collider: CollisionShape3D
@export var model: Node3D
@export var dropped_marker: Marker3D
@export var held_marker: Marker3D
@export var multiplayer_synchronizer: MultiplayerSynchronizer

var pickupable := false
var pick_up_timer := PICK_UP_DELAY
var last_dropped_inventory_comp: InventoryComponent = null


func _ready() -> void:
	var has_synchronizer := false
	for child in get_children(): if child is MultiplayerSynchronizer: has_synchronizer = true
	assert(has_synchronizer, name + " is missing a MultiplayerSynchronizer!")
	var slot_valid := is_instance_valid(slotref)
	assert(slot_valid, name + " has an invalid SlotRef!")
	if slot_valid:
		assert(is_instance_valid(slotref.itemref), name + " has an invalid ItemRef!")
	assert(collision_layer == 256 and collision_mask == (1+2), name + " has misconfiguered collision layers / masks!")
	assert(health_comp.defense == INF)


func _process(delta: float) -> void:
	if pick_up_timer > 0.0:
		pick_up_timer -= delta
		if pick_up_timer <= 0.0:
			pickupable = true

@rpc("any_peer", "call_local")
func request_pick_up(path_to_inv_comp: NodePath) -> void:
	if not multiplayer.is_server(): return
	var inv_comp: InventoryComponent = get_node(path_to_inv_comp)
	#Global.game.console_panel.add_message(inv_comp.get_parent().name + " requested to pick up " + name)
	#print(get_path())
	if inv_comp.invref.check_space(slotref):
		inv_comp.pick_up_item.rpc(get_path())
	else:
		Global.game.console_panel.add_message(str(multiplayer.get_remote_sender_id()) + " tried to pick up an item they don't have room for!")

#@rpc("call_local")
func pick_up() -> void:
	set_held()
	queue_free()


func set_held() -> void:
	plat_comp.disabled = true
	hitbox_comp.detectable = false
	collider.set_deferred("disabled", true)
	pickupable = false
	pick_up_timer = -1.0
	model.transform = held_marker.transform
	#if multiplayer.is_server():
		#toggle_replication("position", SceneReplicationConfig.REPLICATION_MODE_NEVER)
		#toggle_replication("rotation", SceneReplicationConfig.REPLICATION_MODE_NEVER)


func set_dropped() -> void:
	plat_comp.disabled = false
	hitbox_comp.detectable = true
	collider.set_deferred("disabled", false)
	pickupable = true
	pick_up_timer = PICK_UP_DELAY
	model.transform = dropped_marker.transform
	#if multiplayer.is_server():
		#toggle_replication("position", SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
		#toggle_replication("rotation", SceneReplicationConfig.REPLICATION_MODE_ALWAYS)


func toggle_replication(property: String, replication_move: int) -> void:
	if not multiplayer_synchronizer.replication_config.property_get_replication_mode(property) == replication_move:
		multiplayer_synchronizer.replication_config.property_set_replication_mode(property, replication_move)
	Global.game.console_panel.add_message("Changed " + property + " replication from " + str(replication_move) + " to " + str(multiplayer_synchronizer.replication_config.property_get_replication_mode(property)))
