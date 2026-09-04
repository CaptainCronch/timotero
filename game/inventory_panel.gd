extends MarginContainer
class_name InventoryPanel

const SLOT_DISPLAY := preload("uid://cjnfw5e7hvhfi")
#const SLOT_AMOUNT := 30

var slots: Array[SlotDisplay] = []
var tween: Tween

@export var game: Game
@export var grid_container: GridContainer


func _ready() -> void:
	Global.inventory_panel = self
	#for i in SLOT_AMOUNT:
		#var new_slot: SlotDisplay = SLOT_DISPLAY.instantiate()
		#grid_container.add_child(new_slot)
		#new_slot.slot_clicked.connect(populate_grid)


func set_inventory_data(invref: InventoryRef) -> void:
	invref.inventory_updated.connect(populate_grid)
	populate_grid(invref, 0, InventoryRef.InteractType.NONE)


func populate_grid(invref: InventoryRef, _index: int, _interact_type: InventoryRef.InteractType) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for slotref in invref.slot_list:
		var item_display = SLOT_DISPLAY.instantiate()
		grid_container.add_child(item_display)
		
		item_display.slot_clicked.connect(invref._on_slot_clicked)
		if slotref:
			item_display.set_slotref(slotref)


func _on_mouse_entered() -> void:
	game.local_player.input_comp.ui_enabled = true


func _on_mouse_exited() -> void:
	game.local_player.input_comp.ui_enabled = false
