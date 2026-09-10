@icon("res://addons/at-icons/node3d/shopping_bag.svg")
extends Area3D
class_name InventoryComponent

signal active_changed(slotref: SlotRef)

@export var inventory_name: String
@export var invref: InventoryRef
#@export var head_invref: InventoryRef
#@export var body_invref: InventoryRef
#@export var accessory_invref: InventoryRef
@export var pickup_enabled := false

var active_index := 0
var override_active: SlotRef = null
var overlapping_items: Array[Item] = []
#var last_active: SlotRef = null


func _enter_tree() -> void:
	set_multiplayer_authority(1) #maybe


func _ready() -> void:
	assert(is_instance_valid(invref), "Invalid InventoryRef in InventoryComponent!")
	assert(invref.slot_list.size() > 0, "InventoryRef with 0 slots in InventoryComponent!")
	invref.inventory_updated.connect(_on_inventory_updated)
	await get_tree().process_frame
	active_changed.emit(override_active if is_instance_valid(override_active) else invref.slot_list[active_index])


func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	for slot in invref.slot_list:
		if is_instance_valid(slot):
			slot.update(delta)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	for slot in invref.slot_list:
		if is_instance_valid(slot):
			slot.physics_update(delta)
	
	check_pickups()


func check_pickups() -> void:
	if not pickup_enabled: return
	var i := 0
	var deletion_queue: Array[int] = []
	for item in overlapping_items:
		if item.pickupable:
			if not (item.pick_up_timer > 0.0 and item.last_dropped_inventory_comp == self):
				if invref.check_space(item.slotref):
					deletion_queue.append(i)
					#Global.game.console_panel.add_message(item.name)
					item.request_pick_up.rpc_id(1, get_path())
					#pick_up_item.rpc(item.get_path())
		i += 1
	
	for index in deletion_queue:
		overlapping_items.remove_at(index) #FIXME: out of bounds index error here?

@rpc("any_peer", "call_local")
func crement_active(amount: int) -> void: ## Amount should be 1 or -1.
	#assert(not absi(amount * 1) == 1, "Cremented InventoryComponent active_index wrongly!")
	active_index += amount
	if active_index > invref.max_active_index or active_index > invref.slot_list.size() - 1:
		active_index = 0
	elif active_index < 0:
		if invref.max_active_index <= (invref.slot_list.size() - 1):
			active_index = invref.max_active_index
		else:
			active_index = invref.slot_list.size() - 1
	
	if not is_instance_valid(override_active):
		active_changed.emit(invref.slot_list[active_index])


func set_override_active(slotref: SlotRef) -> void:
	if is_instance_valid(slotref):
		override_active = slotref
		active_changed.emit(slotref)
	else:
		override_active = null
		active_changed.emit(invref.slot_list[active_index])

@rpc("any_peer", "call_local")
func pick_up_item(item_path: NodePath) -> void:
	#if is_multiplayer_authority(): print(str(item_path))
	var item: Item = get_node(item_path)
	#if item == null:
	#Global.game.console_panel.add_message("picked up " + str(item_path))
		#return
	if invref.add_slotref(item.slotref) == null:
		item.pick_up()

@rpc
func synchronize_inventories(data: Array[Dictionary]) -> void:
	var new_slot_list: Array[SlotRef] = []
	for slot in data:
		new_slot_list.append(SlotRef.deserialize(slot))
	invref.slot_list = new_slot_list


func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent and area.get_parent() is Item:
		overlapping_items.append(area.get_parent())


func _on_area_exited(area: Area3D) -> void:
	if area is HitboxComponent and area.get_parent() is Item:
		overlapping_items.erase(area.get_parent())


func _on_inventory_updated(updated_invref: InventoryRef, index: int) -> void:
	if is_multiplayer_authority():
		var data: Array[Dictionary] = []
		for slot in updated_invref.slot_list:
			data.append(SlotRef.serialize(slot))
		synchronize_inventories.rpc(data)
		if index == active_index:
			#Global.game.console_panel.add_message("Active index refreshed! = " + str(active_index))
			crement_active.rpc(0)
