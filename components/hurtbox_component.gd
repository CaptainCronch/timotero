extends Area3D
class_name HurtboxComponent
## Exists to detect. Checks for hitboxes and applies damage.

signal hit(hitbox: HitboxComponent)

@export var attack: Attack
@export var updates := true ## If true, the hurtbox will check for hits automatically
@export var update_delay := 0.0 ## Will check overlaps every frame if set to 0.0 and updates is set to true.
@export var multihit := false ## If true, the hurtbox can strike multiple hitboxes per update or check.
#@export var detection_groups: PackedStringArray

var update_timer := 0.0

@onready var collider: CollisionShape2D = $CollisionShape2D


#func _ready():
	#if detection_groups[0].is_empty():
		#push_error("HitboxComponent of ", str(self), " has no detection groups!")


func _physics_process(delta: float) -> void:
	if not monitoring or not updates: return
	if update_delay <= 0.0:
		check_collision()
	elif update_timer < update_delay:
		update_timer += delta
		if update_timer >= update_delay:
			if check_collision(): # stop checking after delay only if you hit something
				update_timer = 0.0


func check_collision() -> bool: ## Emits hit signal for every hitbox damaged. Returns true if any hitbox was hit.
	var hit_anything := false
	for area in get_overlapping_areas():
		if area is HitboxComponent:
			#if attack.attack_direction.is_zero_approx():
				#attack.attack_direction = Global.vec2_from_xz(global_position.direction_to(area.global_position))
				#hit.emit(area)
				#area.damage(attack)
				#attack.attack_direction = Vector2.ZERO
			#else:
			hit.emit(area)
			area.strike(attack.duplicate())
			
			hit_anything = true
			if not multihit: break
	return hit_anything
