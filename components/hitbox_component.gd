extends Area3D
class_name HitboxComponent
## Exists to be detected. Relays attacks from hurtboxes to health components.

signal struck(attack: Attack)

enum ALIGNMENT {
	NONE,
	PLAYER,
	ENEMY,
	ENVIRONMENT,
}

var detectable := true

@export var alignment: ALIGNMENT
@export var target: Node3D
@export var health_comp: HealthComponent


func _ready() -> void:
	assert(collision_layer and collision_mask, 
			"HitboxComponent of " + get_parent().name + " has no collision bits enabled!")
	#if is_instance_valid(health_comp):
		#health_comp.death.connect(func(_attack): detectable = false)

@rpc("any_peer", "call_local")
func strike(data: Dictionary[String, Variant]) -> void:
	var attack := Attack.deserialize(data)
	struck.emit(attack)
	if is_instance_valid(health_comp): health_comp.hurt(attack)
