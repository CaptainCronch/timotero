extends Resource
class_name InventoryRef

signal inventory_interacted(ref: InventoryRef, index: int, type: InteractType)

enum InteractType {
	PRIMARY, ## Clicking with the left mouse button.
	SECONDARY, ## Clicking with the right mouse button.
}

@export var slot_list: Array[SlotRef] = []
