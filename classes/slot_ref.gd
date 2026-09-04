extends Resource
class_name SlotRef

#TBD: Have slotref tags that get added on?
#TBD: This is where referenced item states should go (such as cooldowns), but how?
#     - let the items that need it extend from SlotRef to make their own state?
#       - sounds like there would be a lot of new classes from that. also this would be an interface then.
#     - we'll see i guess when i actually try to implement something like that
#       - like a weapon that keeps its cooldown / reload while put away
#         - the inventory timer would probably need to tick every frame for something like this

@export var itemref: ItemRef
@export var amount := 1: set = set_amount

#var transient_tags: Array[SlotRef.Tag] = [] ???


func can_merge_with(other_slotref: SlotRef, single := false) -> bool: ## Check if other SlotRef can merge with this one. Set single to true if only merging one from other pile rather than all.
	return (itemref == other_slotref.itemref
			and itemref.stackable
			and amount < itemref.max_stack
			and (other_slotref.amount < itemref.max_stack or single))


func merge_with(other_slotref: SlotRef, single := false) -> SlotRef: ## Add the amounts of both SlotRefs together. Set single to true if only merging one from other pile rather than all.
	if single:
		set_amount(amount + 1)
		other_slotref.set_amount(other_slotref.amount - 1)
		if other_slotref.amount == 0:
			return null
		else: return other_slotref

	var total := amount + other_slotref.amount
	if total > itemref.max_stack:
		set_amount(itemref.max_stack)
		other_slotref.set_amount(total - itemref.max_stack)
		return other_slotref
	else:
		set_amount(total)
		return null


func create_single_slotref() -> SlotRef:
	var new_slotref : SlotRef = duplicate()
	new_slotref.set_amount(1)
	set_amount(amount - 1)
	return new_slotref


func set_amount(value: int) -> void:
	amount = value
	if not itemref.stackable and amount > 1:
		amount = 1
		push_error(str(self) + "Tried to stack " + str(itemref.name) + ", which is unstackable.")


static func serialize(slotref: SlotRef) -> Dictionary:
	return {}


static func deserialize(dict: Dictionary) -> SlotRef:
	return SlotRef.new()
