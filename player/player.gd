extends CharacterBody3D
class_name Player

var species_dict: Array[Dictionary] = [
	{
		"ears": "Bunny",
		"texture": load("uid://ddnalu3w85bxd"),
		"face": load("uid://bmi03s6dgewoj"),
	},
	{
		"ears": "Capy",
		"texture": load("uid://l6a5h0elmrqi"),
		"face": load("uid://g4oiluox7fq1"),
	},
	{
		"ears": "Kitty",
		"texture": load("uid://bwqt52rut5ecg"),
		"face": load("uid://b3gq08y3fat6c"),
	},
	{
		"ears": "Fox",
		"texture": load("uid://bps40p8oleq7g"),
		"face": load("uid://dwvek7mgsrihw"),
	},
	{
		"ears": "Derg",
		"texture": load("uid://dlqajrarf3um4"),
		"face": load("uid://4mvy3t8187da"),
	},
	{
		"ears": "Racc",
		"texture": load("uid://xalsfixindqb"),
		"face": load("uid://dq0ou37v6o4qe"),
	},
	{
		"ears": "Badger",
		"texture": load("uid://cfu2q5qpnw2ot"),
		"face": load("uid://du2jmnlpk3hdt"),
	},
	{
		"ears": "Sparkle",
		"texture": load("uid://c75uwlm4sjgpt"),
		"face": load("uid://ccjw27wydxybm"),
	},
	{
		"ears": "Chamois",
		"texture": load("uid://dhae0yd01wks"),
		"face": load("uid://bgjecbjhhwyod"),
	},
	{
		"ears": "Kitty",
		"texture": load("uid://chphs1ovrpfd4"),
		"face": load("uid://br6ga0wm5bift"),
	},
	{
		"ears": "Fox",
		"texture": load("uid://bps40p8oleq7g"),
		"face": load("uid://buoe4ubhtjkf0"),
	},
	{
		"ears": "Badger",
		"texture": load("uid://bo4mmsugh08el"),
		"face": load("uid://thdgal88y6ts"),
	},
	{
		"ears": "Capy",
		"texture": load("uid://cw4q0pwveeu68"),
		"face": load("uid://c6ogvoo134aoy"),
	},
	{
		"ears": "Fox",
		"texture": load("uid://cqk6875dbohhs"),
		"face": load("uid://bon71ubk8crgc"),
	},
	{
		"ears": "Fox",
		"texture": load("uid://c4brwswnyipu8"),
		"face": load("uid://uarhe68pqcpa"),
	},
	{
		"ears": "Kitty",
		"texture": load("uid://8fbj2m4uso7l"),
		"face": load("uid://b1ft0rmgdxqhx"),
	},
	{
		"ears": "Bunny",
		"texture": load("uid://cggfpc80ubw21"),
		"face": load("uid://ckwwmar45c7up"),
	},
	{
		"ears": "Bird",
		"texture": load("uid://dd2vx3pe6nh2q"),
		"face": load("uid://cl74j1o8trd7o"),
	},
	{
		"ears": "Horned",
		"texture": load("uid://qyodfahhj1eo"),
		"face": load("uid://celluoibvs4lo"),
	},
	{
		"ears": "Fox",
		"texture": load("uid://xo8rvvcf48tk"),
		"face": load("uid://cwx51ump0tlry"),
	},
	{
		"ears": "Sparkle",
		"texture": load("uid://b1r6yd3cbi8dc"),
		"face": load("uid://dtt72yb3qrqfl"),
	},
	{
		"ears": "Lop",
		"texture": load("uid://bps40p8oleq7g"),
		"face": load("uid://cv447mysh22jd"),
	},
	{
		"ears": "Hat",
		"texture": load("uid://dgufdxyw5l6nk"),
		"face": load("uid://c5aictwhqr7g"),
	},
	{
		"ears": "Capy",
		"texture": load("uid://c28qr7g8swj7v"),
		"face": load("uid://ctpxe0i600d3c"),
	},
	{
		"ears": "Flop",
		"texture": load("uid://yug4m0u83d11"),
		"face": load("uid://bsfwwnqc5ioiu"),
	},
	{
		"ears": "Monkey",
		"texture": load("uid://yug4m0u83d11"),
		"face": load("uid://riu0nsp5s1vc"),
	},
	{
		"ears": "Tail",
		"texture": load("uid://dlqajrarf3um4"),
		"face": load("uid://dp2364pxkmo4b"),
	},
	{
		"ears": "Kitty",
		"texture": load("uid://bps40p8oleq7g"),
		"face": load("uid://2fvxt5piq6m6"),
	},
	{
		"ears": "Combo",
		"texture": load("uid://bps40p8oleq7g"),
		"face": load("uid://c135xpt5sfd1t"),
	},
]

@export_category("Values")
@export var jump_boost := 0.3
@export var peak_velocity_range := 2.0
@export var peak_gravity_bane := 0.3
@export var falling_gravity_boon := 0.6
@export var owner_peer_id: int#:
	#set(id):
		#owner_peer_id = id
		#set_multiplayer_authority(id)
@export var inventory: InventoryRef

var holding_jump := false
var buffer_time := 0.1
var coyote_time := 0.1
var gravity_boon := BoonManager.new(true)
var jump_cut := false
#var speed_boon := BoonManager.new(false)

@export_category("Nodes")
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

@export_category("Synced")
@export var display_name: String:
	set(value):
		display_name = value
		debug_label.text = value
@export var current_species := 0

@onready var player_holder: PlayerHolder = $".."


func _enter_tree() -> void:
	#var peer_id: int = str(name).to_int()
	#Global.console_panel.add_message(name)
	set_multiplayer_authority(str(name).to_int())
	#set_multiplayer_authority(owner_peer_id)
	#print(str(name))
	#print(get_multiplayer_authority())
	#display_name = Global.local_peer_name#name
	#debug_label.text = str(owner_peer_id)
	#debug_label.text = player_holder.player_nodes


func _ready() -> void:
	if is_multiplayer_authority():
		player_holder.game.local_player = self
		#print(Global.local_peer_name)
		#Global.console_panel.add_message(Global.local_peer_name)
		#set_display_name.rpc(Global.local_peer_name)
		display_name = Global.local_peer_name
		#Global.local_player = self
		#debug_label.text = display_name
	update_character(current_species)


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
		if current_species > species_dict.size() - 1: current_species = 0
		update_character.rpc(current_species)


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

@rpc("call_local")
func respawn() -> void:
	health_comp.dead = false
	health_comp.health = health_comp.max_health
	plat_comp.frozen = false
	debug_label.text = "I'm alive!"

@rpc("call_local")
func update_character(index: int) -> void:
	for child in model.get_children():
		if child.name == "Face": continue
		elif child.name == species_dict[index]["ears"]: child.visible = true
		else: child.visible = false
	
	$Model/Face.get_surface_override_material(0).albedo_texture = species_dict[index]["face"]
	model.get_surface_override_material(0).albedo_texture = species_dict[index]["texture"]

@rpc("any_peer", "call_local")
func set_display_name(new_name: String) -> void:
	debug_label.text = new_name


func _on_health_component_damage_taken(amount: float, _attack: Attack) -> void:
	debug_label.text = "Took " + str(amount) + " damage!"


func _on_health_component_death(_attack: Attack) -> void:
	debug_label.text = "I'm dead!"
	if not is_multiplayer_authority(): return
	await get_tree().create_timer(5.0).timeout
	respawn.rpc()


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
