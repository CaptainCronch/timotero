@icon("res://addons/at-icons/node3d/hand.svg")
extends Node3D
class_name WieldComponent

signal threw_wielded_item()

var wielded_item: Item

@export var inventory_comp: InventoryComponent
@export var plat_comp: PlatformerComponent
@export var remote_transform: RemoteTransform3D
@export var drop_position := Vector3(0.0, 0.0, 1.0)

@onready var raycast: RayCast3D = %RayCast3D


#func _enter_tree() -> void:
	#set_multiplayer_authority(1)


func _ready() -> void:
	inventory_comp.active_changed.connect(_on_inventory_component_active_changed)


func _process(_delta: float) -> void:
	if is_instance_valid(plat_comp):
		remote_transform.transform.basis = plat_comp.model.transform.basis # temporary for testing, so the held item rotates around with the player model

@rpc("any_peer", "call_local")
func request_throw(velocity: Vector3) -> void:
	if is_instance_valid(wielded_item):
		throw_wielded_item.rpc(velocity)
	else:
		Global.game.console_panel.add_message("Tried to throw invalid wielded item!")

@rpc("any_peer", "call_local")
func throw_wielded_item(velocity: Vector3) -> void:
	#Global.game.console_panel.add_message(wielded_item.name)
	wielded_item.set_dropped()
	if is_instance_valid(inventory_comp):
		wielded_item.last_dropped_inventory_comp = inventory_comp
	
	remote_transform.remote_path = NodePath()
	var rotated_position := drop_position.rotated(Vector3.UP, remote_transform.rotation.y)
	raycast.target_position = rotated_position
	if raycast.is_colliding():
		wielded_item.global_position = raycast.get_collision_point()
	else:
		wielded_item.global_position = to_global(rotated_position)
	
	wielded_item.plat_comp.target.velocity = velocity.rotated(Vector3.UP, remote_transform.rotation.y)
	#wielded_item.reparent(Global.game.level_holder.current_level)
	
	wielded_item = null # if you don't do this it'll delete the item before you get a chance to toss it
	#inventory_comp.invref.slot_list[inventory_comp.active_index] = null
	#inventory_comp.invref.drop_single_slotref(null, inventory_comp.active_index)
	if not is_instance_valid(inventory_comp.override_active):
		inventory_comp.invref.delete_slotref(inventory_comp.active_index)
	
	threw_wielded_item.emit()

@rpc("any_peer", "call_local")
func request_change_active(slotref_data: Dictionary[String, Variant]) -> void: ## Should only run on the server.
	if is_instance_valid(wielded_item): wielded_item.queue_free()
	var slotref := SlotRef.deserialize(slotref_data)
	if not slotref == null:
		var new_item: Item = load(slotref.itemref.dropped_item).instantiate()
		new_item.slotref = slotref
		Global.game.console_panel.add_message(str(new_item.slotref.amount) + " should be " + str(slotref.amount))
		Global.game.level_holder.current_level.add_child(new_item, true)
		#remote_transform.remote_path = remote_transform.get_path_to(new_item)
		change_active.rpc(slotref_data, new_item.get_path())
	else:
		remote_transform.remote_path = ""
		change_active.rpc(slotref_data, "")

@rpc("any_peer", "call_local") #TODO: request to change active from the server instead because only the server can spawn things for the multiplayerspawner
func change_active(slotref_data: Dictionary[String, Variant], new_item_path: NodePath) -> void: ## Should be called by the server and ran on all clients.
	#if is_instance_valid(wielded_item): wielded_item.queue_free()
	var new_slotref: SlotRef = null
	if not slotref_data == {}:
		new_slotref = SlotRef.deserialize(slotref_data)
	var new_item: Item = get_node_or_null(new_item_path) # will be null if the new active slot is empty
	#if is_instance_valid(slotref):
		#var slotref := SlotRef.deserialize(slotref_data)
		#var new_item: Item = load(slotref.itemref.dropped_item).instantiate()
	if is_instance_valid(new_item):
		new_item.slotref = new_slotref
		new_item.set_held()
	
	remote_transform.remote_path = new_item_path
	#Global.game.level_holder.current_level.add_child(new_item, true)
	#Global.game.console_panel.add_message(new_item.name)
	#holder_node.add_child(new_item)
	wielded_item = new_item
	#else:
		#wielded_item = null


func _on_inventory_component_active_changed(slotref: SlotRef) -> void: # might be called on all clients at the same time? be careful
	if not is_multiplayer_authority(): return
	request_change_active.rpc_id(1, SlotRef.serialize(slotref))
	#return
	#if not is_multiplayer_authority(): return
	#var data: Dictionary[String, Variant] = {}
	#if is_instance_valid(slotref): data = SlotRef.serialize(slotref)
	#change_active.rpc(data)
