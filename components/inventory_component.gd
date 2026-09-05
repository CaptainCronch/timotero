extends Node
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
var last_active: SlotRef = null


func _ready() -> void:
	assert(is_instance_valid(invref), "Invalid InventoryRef in InventoryComponent!")
	assert(invref.slot_list.size() > 0, "InventoryRef with 0 slots in InventoryComponent!")
	invref.inventory_updated.connect(_on_inventory_updated)
	await get_tree().process_frame
	active_changed.emit(override_active if is_instance_valid(override_active) else invref.slot_list[active_index])


func _process(delta: float) -> void:
	for slot in invref.slot_list:
		if is_instance_valid(slot):
			slot.update(delta)


func _physics_process(delta: float) -> void:
	for slot in invref.slot_list:
		if is_instance_valid(slot):
			slot.physics_update(delta)


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


func _on_area_entered(area: Area3D) -> void:
	if not pickup_enabled: return
	var item := area.get_parent()
	if item is Item and item.pickupable:
		if invref.add_slotref(item.slotref) == null:
			item.pick_up()
			item.queue_free()


func _on_inventory_updated(_invref: InventoryRef, index: int) -> void:
	if index == active_index:
		crement_active(0)
