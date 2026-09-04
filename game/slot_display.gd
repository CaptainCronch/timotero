extends MarginContainer
class_name SlotDisplay

signal slot_clicked(index: int, type: InventoryRef.InteractType)

@export var texture_rect: TextureRect
@export var label: Label


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and \
				(event.button_index == MOUSE_BUTTON_LEFT or \
				event.button_index == MOUSE_BUTTON_RIGHT):
			slot_clicked.emit(get_index(), event.button_index)
			accept_event()


func set_slotref(slotref: SlotRef, is_grabbed := false) -> void:
	var itemref := slotref.itemref
	texture_rect.texture = itemref.image
	if is_grabbed:
		tooltip_text = ""
	else:
		tooltip_text = itemref.name + "\n" + itemref.description
	
	if slotref.amount > 1:
		label.show()
		label.text = str(slotref.amount)
	else:
		label.hide()
