extends MarginContainer
class_name ConsolePanel

const MESSAGE = preload("uid://gw4j4iu1a1k0")
const LIFETIME := 10.0
const MAX_CHILDREN := 13

var messages: Array[Dictionary] = []

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var dummy: Node = $VBoxContainer/Dummy


func _process(delta: float) -> void:
	var i := 0
	for message in messages:
		message["time"] -= delta
		if message["time"] <= 0.0:
			messages[i]["node"].queue_free()
			messages.remove_at(i)
		i += 1


func add_message(content: String) -> void:
	var new_message: Message = MESSAGE.instantiate()
	new_message.label.text = content
	messages.append({"node": new_message, "time": LIFETIME})
	dummy.add_sibling(new_message)
	if v_box_container.get_child_count() > MAX_CHILDREN:
		messages.pop_front()
		v_box_container.get_child(v_box_container.get_child_count() - 1).free()
