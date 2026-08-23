extends Node
class_name PlatformerComponent

const MAX_FALL_SPEED := -1000.0

@export_category("Values")
@export var base_speed := 7.0
@export var base_acceleration := 18.0
@export var base_friction := 15.0
@export var air_acceleration := 6.0 # air acceleration / friction as a negative 'bonus'?
@export var air_friction := 0.1
@export var base_jump_force := 12.0
@export var base_gravity := 30.0
@export var turn_acceleration := 30.0

var last_desired_dir := Vector2.UP
var move_dir := Vector2.ZERO:
	set(value):
		move_dir = value
		if not value.is_zero_approx(): last_desired_dir = value
#var move_multiplier := 1.0
#var explosive_jumping := false
#var stunned := false
#var turning := true
var turn_target := Vector2()
var is_jumping := false

@export_category("Nodes")
@export var target: CharacterBody3D
@export var model: Node3D
#@export var health_comp: HealthComponent

#@onready var stun_timer: Timer = $StunTimer
@onready var speed := base_speed
@onready var acceleration := base_acceleration
@onready var friction := base_friction
@onready var jump_force := base_jump_force
@onready var gravity := base_gravity


func _ready():
	if not is_instance_valid(target): push_error("This PlatformerComponent is lacking a target")
	if not is_instance_valid(model): push_error("This PlatformerComponent is lacking a model")
	#if health_comp:
		#health_comp.damage_taken.connect(knockback)


func _process(_delta) -> void :
	model_controls(move_dir if turn_target == Vector2() else turn_target)


func _physics_process(delta) -> void :
	vertical_movement(delta)
	horizontal_movement(delta)
	target.move_and_slide()
	if is_on_floor(): is_jumping = false


func vertical_movement(delta) -> void :
	if is_on_floor(): return
	#if target.velocity.y >= peak_range: gravity = base_gravity
	#elif target.velocity.y <= -peak_range: gravity = fall_gravity
	#else: gravity = peak_gravity # dfferent gravities applied based on y velocity

	target.velocity.y -= gravity * delta # gravity
	target.velocity.y = maxf(target.velocity.y, MAX_FALL_SPEED)


func horizontal_movement(delta : float) -> void :
	var desired_velocity := move_dir * speed# * move_multiplier

	if is_on_floor():
		acceleration = base_acceleration
		friction = base_friction
		#explosive_jumping = false
		#move_multiplier = Global.decay_towards(move_multiplier, 1.0, multiplier_decay, delta)
	else:
		acceleration = air_acceleration
		friction = air_friction

	# interpolate between acceleration and friction based on how close the desired velocity is to the target's velocity
	#var desire_difference := Vector2(target.velocity.x, target.velocity.z).normalized().dot(desired_velocity.normalized()) if not desired_velocity.is_zero_approx() else 0.0
	#var change_rate := lerpf(friction, acceleration, (desire_difference + 1.0) / 2.0)
	var change_rate: float
	var target_velocity: Vector2
	if move_dir.is_zero_approx():
		change_rate = friction
		target_velocity = Vector2()
	else:
		change_rate = acceleration
		target_velocity = desired_velocity

	#if not move_dir.is_zero_approx():# and not stunned:
	target.velocity.x = Global.decay_towards(target.velocity.x, target_velocity.x, change_rate, delta)
	target.velocity.z = Global.decay_towards(target.velocity.z, target_velocity.y, change_rate, delta)
	#else:
		#target.velocity.x = Global.decay_towards(target.velocity.x, 0.0, friction, delta)
		#target.velocity.z = Global.decay_towards(target.velocity.z, 0.0, friction, delta)


func model_controls(dir := move_dir) -> void :
	if not dir.is_zero_approx():# and turning and not stunned:
		model.rotation.y = Global.decay_angle_towards(
				model.rotation.y,
				atan2(dir.x, dir.y),
				turn_acceleration,
				get_process_delta_time())


func jump(ignore_ground_check := false) -> void:
	if not is_on_floor() and not ignore_ground_check: return# or stunned: return
	target.velocity.y = jump_force
	is_jumping = true


#func explode(origin : Vector3, radius : float, power : float, upthrust := 0.0) -> void :
	#var distance_factor : float = (inverse_lerp(0, radius, target.global_position.distance_to(origin)) * -0.5) + 1
	#if distance_factor < 0.5: return
#
	#var upthrust_corrected_position = Vector3(
			#target.global_position.x,
			#target.global_position.y + upthrust,
			#target.global_position.z)
#
	#target.velocity += origin.direction_to(upthrust_corrected_position) * distance_factor * power
	#explosive_jumping = true


#func knockback(attack : Attack) -> void :
	#stun(attack.stun_time)
	#if is_zero_approx(attack.knockback_force): return
	#var pos_2d := Vector2(target.global_position.x, target.global_position.z)
	#var attack_2d := Vector2(attack.attack_position.x, attack.attack_position.z)
	#var dir := attack_2d.direction_to(pos_2d)
	#var kb_factor := attack.knockback_force - (attack.knockback_force * knockback_resistance)
	#var knockback_total := Vector3(dir.x, 0.5, dir.y).normalized() * kb_factor
	#target.velocity = knockback_total


#func stun(time : float) -> void:
	#if is_zero_approx(time): return
	#stunned = true
	##move_dir = Vector2.ZERO


#func instant_velocity(direction : Vector2) -> void :
	#direction *= move_speed
	#target.velocity.x = direction.x
	#target.velocity.z = direction.y


func is_on_floor() -> bool :
	return target.is_on_floor()


#func _on_stun_timer_timeout():
	#stunned = false
