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
@export var amount := 1:
	set(value):
		if not itemref.stackable and value > 1:
			push_error(str(self) + "Tried to stack " + str(itemref.name) + ", which is unstackable.")
			return
		amount = value

var slot_tags


static func serialize(slotref: SlotRef) -> Dictionary:
	return {}


static func deserialize(dict: Dictionary) -> SlotRef:
	return SlotRef.new()
