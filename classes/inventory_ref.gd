extends Resource
class_name InventoryRef

signal inventory_interacted(ref: InventoryRef, index: int, type: InteractType)
signal inventory_updated(invred: InventoryRef, index: int)
signal slotref_changed(old_ref: SlotRef, new_ref: SlotRef)

const DEFAULT_INVENTORY_SIZE := 30

enum InteractType {
	NONE, ## Used for initializing or invalid button.
	PRIMARY, ## Clicking with the left mouse button.
	SECONDARY, ## Clicking with the right mouse button.
}

@export var slot_list: Array[SlotRef] = []
@export var filter_tag: ItemRef.Tag


func set_slotref(index: int, new_slotref: SlotRef) -> void:
	var old_slotref := slot_list[index]
	slot_list[index] = new_slotref
	slotref_changed.emit(old_slotref, new_slotref)


func grab_slotref(index: int) -> SlotRef: ## Called on primary interact with empty grabber.
	var slotref = slot_list[index]
	if slotref:
		set_slotref(index, null)
		emit_updated(index)
		return slotref
	else:
		return null


func grab_half_slotref(index: int) -> SlotRef: ## Called on secondary interact with empty hand. Grabber keeps the extra on odd numbers.
	var slotref = slot_list[index].duplicate()
	if slotref:
		if slotref.amount == 1: return grab_slotref(index)
		var half_amount = roundi(slotref.amount / 2.0)
		slot_list[index].amount = half_amount
		slotref.amount -= half_amount
		emit_updated(index)
		return slotref
	else:
		return null


func drop_slotref(grabbed_slotref: SlotRef, index: int) -> SlotRef: ## Called on primary interact with grabbed slotref.
	var slotref := slot_list[index]
	if not check_eligibility(grabbed_slotref): return grabbed_slotref

	if slotref and slotref.can_merge_with(grabbed_slotref):
		var grabbed := slotref.merge_with(grabbed_slotref)
		emit_updated(index)
		return grabbed
	else:
		set_slotref(index, grabbed_slotref)
		emit_updated(index)
		return slotref


func drop_single_slotref(grabbed_slotref: SlotRef, index: int) -> SlotRef: ## Called on secondary click with grabbed slotref.
	var slotref = slot_list[index]
	if not check_eligibility(grabbed_slotref): return grabbed_slotref

	if not slotref:
		set_slotref(index, grabbed_slotref.create_single_slotref())
	elif slotref.can_merge_with(grabbed_slotref, true):
		slotref.merge_with(grabbed_slotref, true)

	emit_updated(index)

	if grabbed_slotref.amount > 0:
		return grabbed_slotref
	else:
		return null


func delete_slotref(index: int) -> void:
	slotref_changed.emit(slot_list[index], null)
	set_slotref(index, null)
	emit_updated(index)


func add_slotref(input: SlotRef) -> SlotRef:
	var slotref := input.duplicate()
	var i := 0
	for space in slot_list:
		if check_eligibility(slotref):
			if space == null:
				set_slotref(i, slotref)
				slotref = null
				emit_updated(i)
				return null
			if space.can_merge_with(slotref):
				var remainder := space.merge_with(slotref)
				if remainder == null:
					emit_updated(i)
					return null
				else: add_slotref(remainder)
		i += 1
	return slotref


func check_eligibility(new_slotref: SlotRef) -> bool:
	if not filter_tag: return true
	if new_slotref.itemref.tags.has(filter_tag): return true
	else: return false


func emit_updated(index := -1) -> void:
	inventory_updated.emit(self, index)


func _on_slot_clicked(index: int, button: int) -> void:
	inventory_interacted.emit(self, index, button)
