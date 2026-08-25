extends Node3D
class_name HealthComponent

#TODO: emit percentage change in signals
signal damage_taken(attack: Attack)
signal healed(amount: float)
signal health_changed(total: float)
signal death(attack: Attack)
signal bled(amount: float)
signal restored_blood(amount: float)
signal blood_level_changed(total: float)
signal stunned(attack: Attack)
signal unstunned()

@export var max_health: float
#@export var invincibility_time := 0.0
@export var defense := 0.0
@export var knockback_factor := 1.0
@export var knockup_factor := 1.0
@export var target: Node3D
@export var plat_comp: PlatformerComponent

var blood_ratio := 1.0 ## Ratio of blood level to max health.
var dead := false
var is_stunned := false
var stun_timer := 0.0

@onready var health := max_health
@onready var blood_level := max_health:
	set(value):
		blood_level = value
		blood_ratio = blood_level / max_health

#@onready var invincibility_timer: Timer = $Invincibility


func _process(delta: float) -> void:
	if stun_timer > 0.0:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			unstunned.emit()


func hurt(attack: Attack):
	if dead: return
	#if not invincibility_timer.is_stopped(): return
	stun(attack)
	if target is CharacterBody3D:
		target.velocity += Vector3(
			attack.attack_direction.x * attack.knockback_force * knockback_factor,
			attack.knockup_force * knockup_factor,
			attack.attack_direction.y * attack.knockback_force * knockback_factor,
		)
		#if is_instance_valid(plat_comp):
			#plat_comp.velocity_z += attack.knockup_force * knockup_factor
	#var current_damage := attack.attack_damage if not is_player else attack.player_damage
	if attack.attack_damage <= 0.0: return
	if attack.attack_damage - defense <= 0.0: return
	#TODO: use the more complicated defense formula from that one blogpost that makes defense \
	#more effective the higher the damage is which effectively enables high DPS low damage builds \
	#to be better at hitting low defense entities VS low DPS high damage builds to be better at \
	#hitting high defense entities but both can still always do some damage at least?
	health -= attack.attack_damage - defense
	damage_taken.emit(attack.attack_damage - defense)
	health_changed.emit(health)
	
	if health <= 0.0:
		die(attack)
		#return
	#if is_zero_approx(invincibility_time): return
	#invincibility_timer.start(invincibility_time)


func heal(amount: float) -> void:
	if dead: return
	if amount <= 0.0: return
	health = minf(health + amount, blood_level)
	healed.emit(amount)
	health_changed.emit(health)


func die(attack: Attack):
	if dead: return
	#if target is CharacterBody3D:
		#target.velocity += attack.attack_direction * attack.knockback_force * knockback_factor
		#if is_instance_valid(plat_comp):
			#plat_comp.velocity_z += attack.knockup_force * knockup_factor - 5.0
	dead = true
	death.emit(attack)
	#target.queue_free()


func bleed(amount: float) -> void:
	if dead: return
	if amount <= 0.0: return
	var health_ratio := health / blood_level
	var last_health := health
	
	blood_level = maxf(blood_level - amount, 1.0) # Blood level cannot be lower than 1.
	health = blood_level * health_ratio
	
	bled.emit(amount)
	blood_level_changed.emit(blood_level)
	if not is_zero_approx(last_health - health): health_changed.emit(health)


func restore_blood(amount: float) -> void:
	if dead: return
	if amount <= 0.0: return
	var health_ratio := health / blood_level
	var last_health := health
	
	blood_level = minf(blood_level + amount, max_health)
	health = blood_level * health_ratio
	
	restored_blood.emit(amount)
	blood_level_changed.emit(blood_level)
	if not is_zero_approx(health - last_health): health_changed.emit(health)


func stun(attack: Attack) -> void:
	#stun_timer.start(attack.stun_time)
	if dead: return
	if attack.stun_time <= 0.0: return
	if stun_timer < attack.stun_time: # Smaller stuns should not override existing large stuns.
		stun_timer = attack.stun_time
	is_stunned = true
	stunned.emit(attack)


func _on_stun_timeout() -> void:
	is_stunned = false
	unstunned.emit()
