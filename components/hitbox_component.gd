extends Area3D
class_name HitboxComponent
## Exists to be detected. Relays attacks from hurtboxes to health components.

signal struck(attack: Attack)

@export var health_comp: HealthComponent


func _ready() -> void:
	if not collision_layer and not collision_mask:
		printerr("HitboxComponent of ", get_parent().name, " has no collision bits enabled!")


func strike(attack: Attack) -> void:
	struck.emit(attack)
	if is_instance_valid(health_comp): health_comp.hurt(attack)
