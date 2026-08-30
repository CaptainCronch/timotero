extends CharacterBody3D
class_name Player

const SPECIES: Array[Dictionary] = [
	{
		"ears": "Bunny",
		"texture": preload("uid://ddnalu3w85bxd"),
		"face": preload("uid://bmi03s6dgewoj"),
	},
	{
		"ears": "Capy",
		"texture": preload("uid://l6a5h0elmrqi"),
		"face": preload("uid://g4oiluox7fq1"),
	},
	{
		"ears": "Kitty",
		"texture": preload("uid://bwqt52rut5ecg"),
		"face": preload("uid://b3gq08y3fat6c"),
	},
	{
		"ears": "Fox",
		"texture": preload("uid://bps40p8oleq7g"),
		"face": preload("uid://dwvek7mgsrihw"),
	},
	{
		"ears": "Derg",
		"texture": preload("uid://dlqajrarf3um4"),
		"face": preload("uid://4mvy3t8187da"),
	},
	{
		"ears": "Racc",
		"texture": preload("uid://xalsfixindqb"),
		"face": preload("uid://dq0ou37v6o4qe"),
	},
	{
		"ears": "Badger",
		"texture": preload("uid://cfu2q5qpnw2ot"),
		"face": preload("uid://du2jmnlpk3hdt"),
	},
	{
		"ears": "Sparkle",
		"texture": preload("uid://c75uwlm4sjgpt"),
		"face": preload("uid://ccjw27wydxybm"),
	},
	{
		"ears": "Chamois",
		"texture": preload("uid://dhae0yd01wks"),
		"face": preload("uid://bgjecbjhhwyod"),
	},
	{
		"ears": "Kitty",
		"texture": preload("uid://chphs1ovrpfd4"),
		"face": preload("uid://br6ga0wm5bift"),
	},
	{
		"ears": "Fox",
		"texture": preload("uid://bps40p8oleq7g"),
		"face": preload("uid://buoe4ubhtjkf0"),
	},
	{
		"ears": "Badger",
		"texture": preload("uid://bo4mmsugh08el"),
		"face": preload("uid://thdgal88y6ts"),
	},
	{
		"ears": "Capy",
		"texture": preload("uid://cw4q0pwveeu68"),
		"face": preload("uid://c6ogvoo134aoy"),
	},
	{
		"ears": "Fox",
		"texture": preload("uid://cqk6875dbohhs"),
		"face": preload("uid://bon71ubk8crgc"),
	},
	{
		"ears": "Fox",
		"texture": preload("uid://c4brwswnyipu8"),
		"face": preload("uid://uarhe68pqcpa"),
	},
	{
		"ears": "Kitty",
		"texture": preload("uid://8fbj2m4uso7l"),
		"face": preload("uid://b1ft0rmgdxqhx"),
	},
	{
		"ears": "Bunny",
		"texture": preload("uid://cggfpc80ubw21"),
		"face": preload("uid://ckwwmar45c7up"),
	},
	{
		"ears": "Bird",
		"texture": preload("uid://dd2vx3pe6nh2q"),
		"face": preload("uid://cl74j1o8trd7o"),
	},
	{
		"ears": "Horned",
		"texture": preload("uid://qyodfahhj1eo"),
		"face": preload("uid://celluoibvs4lo"),
	},
	{
		"ears": "Fox",
		"texture": preload("uid://xo8rvvcf48tk"),
		"face": preload("uid://cwx51ump0tlry"),
	},
	{
		"ears": "Sparkle",
		"texture": preload("uid://b1r6yd3cbi8dc"),
		"face": preload("uid://dtt72yb3qrqfl"),
	},
	{
		"ears": "Lop",
		"texture": preload("uid://bps40p8oleq7g"),
		"face": preload("uid://cv447mysh22jd"),
	},
	{
		"ears": "Hat",
		"texture": preload("uid://dgufdxyw5l6nk"),
		"face": preload("uid://c5aictwhqr7g"),
	},
	{
		"ears": "Capy",
		"texture": preload("uid://c28qr7g8swj7v"),
		"face": preload("uid://ctpxe0i600d3c"),
	},
	{
		"ears": "Flop",
		"texture": preload("uid://yug4m0u83d11"),
		"face": preload("uid://bsfwwnqc5ioiu"),
	},
	{
		"ears": "Monkey",
		"texture": preload("uid://yug4m0u83d11"),
		"face": preload("uid://riu0nsp5s1vc"),
	},
]

@export var jump_boost := 0.3
@export var peak_velocity_range := 2.0
@export var peak_gravity_bane := 0.3
@export var falling_gravity_boon := 0.6
@export var current_species := 0

var owner_peer_id: int
var holding_jump := false
var buffer_time := 0.1
var coyote_time := 0.1
var gravity_boon := BoonManager.new(true)
var jump_cut := false
#var speed_boon := BoonManager.new(false)

@export var health_comp: HealthComponent
@export var hurtbox_comp: HurtboxComponent
@export var input_comp: InputComponent
@export var plat_comp: PlatformerComponent
@export var camera_holder: CameraHolder
@export var buffer_timer: Timer
@export var coyote_timer: Timer
@export var model: MeshInstance3D
@export var weapon_holder: Node3D
@export var animation_player: AnimationPlayer
@export var debug_label: Label3D

@onready var player_holder: PlayerHolder = $".."


func _enter_tree() -> void:
	var peer_id: int = str(name).to_int()
	set_multiplayer_authority(peer_id)
	#debug_label.text = str(owner_peer_id)
	#debug_label.text = player_holder.player_nodes


func _process(_delta: float) -> void:
	set_input()
	var face_angle := Global.rotation_y_from_vec2(plat_comp.last_desired_dir)
	hurtbox_comp.rotation.y = face_angle
	weapon_holder.rotation.y = model.rotation.y


func _physics_process(_delta: float) -> void:
	vertical_movement()


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("jump"):
		#buffer_timer.start(buffer_time) # waits until you touch the ground to jump


func set_input() -> void:
	if not is_multiplayer_authority(): return
	plat_comp.move_dir = Vector2.ZERO

	#plat_comp.move_dir.x = Input.get_axis("left", "right")
	#plat_comp.move_dir.y = Input.get_axis("forward", "back")
	plat_comp.move_dir = input_comp.move_vector
	plat_comp.move_dir = plat_comp.move_dir.rotated(Global.vec2_from_xz(camera_holder.transform.basis.z).angle() - PI/2.0)
	
	if not holding_jump and plat_comp.is_jumping:
		jump_cut = true
		#print("cutting")
		#gravity_boon.add_boon("falling", falling_gravity_boon)
		#gravity_boon.remove_bane("peak")
	
	if Input.is_action_just_released("debug_key"):# and is_multiplayer_authority():
		current_species += 1
		if current_species > SPECIES.size() - 1: current_species = 0
		
		for child in model.get_children():
			if child.name == "Face": continue
			elif child.name == SPECIES[current_species]["ears"]: child.visible = true
			else: child.visible = false
		
		$Model/Face.get_surface_override_material(0).albedo_texture = SPECIES[current_species]["face"]
		model.get_surface_override_material(0).albedo_texture = SPECIES[current_species]["texture"]


func vertical_movement() -> void:
	if not is_multiplayer_authority(): return
	
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


@rpc("call_local")
func hit() -> void:
	hurtbox_comp.attack.attack_direction = plat_comp.last_desired_dir
	hurtbox_comp.check_collision()
	animation_player.play("RESET")
	await animation_player.animation_finished
	animation_player.play("swing")


func _on_health_component_damage_taken(amount: float, _attack: Attack) -> void:
	debug_label.text = "Took " + str(amount) + " damage!"


func _on_health_component_death(_attack: Attack) -> void:
	debug_label.text = "I'm dead!"


func _on_input_jump() -> void:
	buffer_timer.start(buffer_time) # waits until you touch the ground to jump
	holding_jump = true


func _on_input_jump_release() -> void:
	holding_jump = false


func _on_plat_comp_knocked_up() -> void:
	gravity_boon.remove_boon("falling")
	gravity_boon.remove_bane("peak")


func _on_input_primary() -> void:
	if health_comp.dead: return
	hit.rpc()


func _on_input_toggle_strafe_release() -> void:
	plat_comp.forced_look = not plat_comp.forced_look
