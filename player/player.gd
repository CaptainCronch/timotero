extends CharacterBody3D
class_name Player

@export var jump_boost := 0.3
@export var peak_velocity_range := 2.0
@export var peak_gravity_bane := 0.3
@export var falling_gravity_boon := 0.6

var buffer_time := 0.1
var coyote_time := 0.1
var gravity_boon := BoonManager.new(true)
var jump_cut := false
#var speed_boon := BoonManager.new(false)

@export var plat_comp: PlatformerComponent
@export var model: MeshInstance3D
@export var spring_arm: SpringArm3D
@export var buffer_timer: Timer
@export var coyote_timer: Timer
@export var debug_label: Label3D


func _process(_delta: float) -> void:
	get_input()


func _physics_process(_delta: float) -> void:
	vertical_movement()


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("jump"):
		#buffer_timer.start(buffer_time) # waits until you touch the ground to jump


func get_input() -> void:
	plat_comp.move_dir = Vector2.ZERO

	#plat_comp.move_dir.x = Input.get_axis("left", "right")
	#plat_comp.move_dir.y = Input.get_axis("forward", "back")
	plat_comp.move_dir = Input.get_vector("left", "right", "forwards", "backwards")
	plat_comp.move_dir = plat_comp.move_dir.rotated(Global.vec2_from_xz(spring_arm.transform.basis.z).angle() - PI/2.0)
	
	if Input.is_action_just_pressed("jump"):
		buffer_timer.start(buffer_time) # waits until you touch the ground to jump
	if not Input.is_action_pressed("jump") and plat_comp.is_jumping:
		jump_cut = true
		#print("cutting")
		#gravity_boon.add_boon("falling", falling_gravity_boon)
		#gravity_boon.remove_bane("peak")


func vertical_movement() -> void:
	if is_on_floor():
		coyote_timer.start(coyote_time) # starts letting you jump
		jump_cut = false

	if not coyote_timer.is_stopped() and not buffer_timer.is_stopped():
		jump_cut = false
		plat_comp.jump(true)
		velocity += Global.xz_from_vec2(plat_comp.move_dir) * velocity.length() * jump_boost
		#plat_comp.move_multiplier = jump_move_multiplier
		#velocity.x *= jump_move_multiplier
		#velocity.z *= jump_move_multiplier

		buffer_timer.stop()
		coyote_timer.stop()
		gravity_boon.remove_boon("falling")
		gravity_boon.remove_bane("peak")
	
	if plat_comp.is_jumping:
		if velocity.y < peak_velocity_range and velocity.y > -peak_velocity_range and not jump_cut:
			gravity_boon.remove_boon("falling")
			gravity_boon.add_bane("peak", peak_gravity_bane)
		elif velocity.y < -peak_velocity_range or jump_cut:
			gravity_boon.add_boon("falling", falling_gravity_boon)
			gravity_boon.remove_bane("peak")
	else:
		gravity_boon.remove_boon("falling")
		gravity_boon.remove_bane("peak")
	
	plat_comp.gravity = plat_comp.base_gravity * gravity_boon.get_total()
	#debug_label.text = str(gravity_boon.boons.keys()) + " " + str(gravity_boon.banes.keys())
	#debug_label.text = "cutting: " + str(jump_cut)
	#debug_label.text = str(plat_comp.gravity)
