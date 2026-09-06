extends Node
class_name LevelHolder

var current_level: Node3D


func _ready() -> void:
	current_level = get_child(0)
