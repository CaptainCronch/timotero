extends MarginContainer
class_name InventoryPanel

signal override_active(slotref: SlotRef)

const SLOT_DISPLAY := preload("uid://cjnfw5e7hvhfi")
#const SLOT_AMOUNT := 30
const GRAB_OFFSET := Vector2(-5.0, -5.0)

var slots: Array[SlotDisplay] = []
var tween: Tween

@export var game: Game
@export var grab_display: SlotDisplay
@export var grabbed_slotref: SlotRef
@export var grid_container: GridContainer
@export var active_overlay: Panel

@onready var active_slot_display_pos: Vector2 = (grid_container.get_child(0) as SlotDisplay).position


func _ready() -> void:
	Global.inventory_panel = self
	#for i in SLOT_AMOUNT:
		#var new_slot: SlotDisplay = SLOT_DISPLAY.instantiate()
		#grid_container.add_child(new_slot)
		#new_slot.slot_clicked.connect(populate_grid)


func _process(_delta: float) -> void:
	if grab_display.visible:
		grab_display.position = get_local_mouse_position() - (grab_display.size/2.0)# + GRAB_OFFSET
	if is_instance_valid(grabbed_slotref):
		active_overlay.position = grab_display.position
	else:
		active_overlay.position = active_slot_display_pos


func set_inventory_data(invref: InventoryRef) -> void:
	invref.inventory_updated.connect(populate_grid)
	invref.inventory_interacted.connect(_on_inventory_interact)
	populate_grid(invref, 0)


func populate_grid(invref: InventoryRef, _index: int) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for slotref in invref.slot_list:
		var item_display = SLOT_DISPLAY.instantiate()
		grid_container.add_child(item_display)
		
		item_display.slot_clicked.connect(invref._on_slot_clicked)
		if slotref:
			item_display.set_slotref(slotref)


func update_grabbed_slot() -> void:
	if grabbed_slotref:
		grab_display.visible = true
		grab_display.set_slotref(grabbed_slotref, true)
		override_active.emit(grabbed_slotref)
	else:
		grab_display.visible = false
		override_active.emit(null)


func switch_active(index: int) -> void:
	#game.console_panel.add_message(str(index))
	if index == -1:
		active_slot_display_pos = grab_display.position
	else:
		active_slot_display_pos = grid_container.get_child(index).position


func _on_inventory_interact(invref: InventoryRef, index: int, interact_type: InventoryRef.InteractType) -> void:
	match [grabbed_slotref, interact_type]:
		[null, InventoryRef.InteractType.PRIMARY]:
			grabbed_slotref = invref.grab_slotref(index)
		[_, InventoryRef.InteractType.PRIMARY]:
			grabbed_slotref = invref.drop_slotref(grabbed_slotref, index)
		[null, InventoryRef.InteractType.SECONDARY]:
			grabbed_slotref = invref.grab_half_slotref(index)
		[_, InventoryRef.InteractType.SECONDARY]:
			grabbed_slotref = invref.drop_single_slotref(grabbed_slotref, index)
	update_grabbed_slot()


func _on_mouse_entered() -> void:
	game.local_player.input_comp.ui_enabled = true


func _on_mouse_exited() -> void:
	game.local_player.input_comp.ui_enabled = false
