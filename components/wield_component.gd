extends Node3D
class_name WieldComponent

var wielded_item: Item

@export var inventory_comp: InventoryComponent
@export var plat_comp: PlatformerComponent
@export var remote_transform: RemoteTransform3D
@export var drop_position := Vector3(0.0, 0.0, 1.0)

@onready var raycast: RayCast3D = $RayCast3D


func _ready() -> void:
	inventory_comp.active_changed.connect(_on_inventory_component_active_changed)


func _process(_delta: float) -> void:
	if is_instance_valid(plat_comp):
		remote_transform.transform.basis = plat_comp.model.transform.basis # temporary for testing, so the held item rotates around with the player model

@rpc("call_local")
func throw_wielded_item(velocity: Vector3) -> void:
	if is_instance_valid(wielded_item):
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
			inventory_comp.invref.delete_single_slotref(inventory_comp.active_index)
	else:
		Global.game.console_panel.add_message("Tried to throw invalid wielded item!")

@rpc("call_local")
func change_active(slotref_data: Dictionary) -> void:
	if is_instance_valid(wielded_item): wielded_item.queue_free()
	if not slotref_data == {}:
		var slotref := SlotRef.deserialize(slotref_data)
		var new_item: Item = load(slotref.itemref.dropped_item).instantiate()
		new_item.set_held()
		Global.game.level_holder.current_level.add_child(new_item, true)
		remote_transform.remote_path = remote_transform.get_path_to(new_item)
		#holder_node.add_child(new_item)
		wielded_item = new_item
	else:
		wielded_item = null


func _on_inventory_component_active_changed(slotref: SlotRef) -> void:
	if not is_multiplayer_authority(): return
	var data := {}
	if is_instance_valid(slotref): data = SlotRef.serialize(slotref)
	change_active.rpc(data)
