extends SpringArm3D
class_name CameraHolder

@export var mouse_sensitivity := 0.005
@export var analog_sensitivity := 0.75
#@export var offset := Vector3.ZERO
@export var x_rotation_limit_buffer := 0.1
@export var rotation_distance_range: Array[Array] = [[TAU/8.0, 3.0], [-TAU/4.0, 15.0]] ## [[min_angle, min_distance], [max_angle, max_distance]]
#@export var distance_range: PackedFloat32Array = [5.0, 10.0]
@export var smooth_look := true
@export var smooth_power := 40.0

var accumulated_rotation := Vector2()
var smooth_rotation: Vector2 = accumulated_rotation
var _analog_look := 0.0
var cam_lock := false

@export var camera: Camera3D
@export var plat_comp: PlatformerComponent
@export var target: Node3D

@onready var x_rotation_limit_range: PackedFloat32Array = [(-PI/2.0) + x_rotation_limit_buffer, (PI/2.0) - x_rotation_limit_buffer]


func _ready() -> void:
	if is_multiplayer_authority():
		camera.make_current()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	#$"../UI/FPS".text = str(Engine.get_frames_per_second())
	#_analog_look = Input.get_axis("look_left", "look_right")
	rotate_y(deg_to_rad(_analog_look * analog_sensitivity))
	#global_position.x = target.global_position.x
	#global_position.z = target.global_position.z
	#global_position.y = target.global_position.y# + offset.y
	#if player.is_on_floor() or absf(player.velocity.y) > player.plat_comp.jump_force * 1.5 or player.plat_comp.explosive_jumping:
	#	global_position.y = player.global_position.y + offset.y
	if cam_lock:
		plat_comp.turn_target = Vector2.UP.rotated(-rotation.y)
	else:
		plat_comp.turn_target = Vector2()
	
	spring_length = \
	clampf(
		remap(rotation.x,
		rotation_distance_range[0][0], rotation_distance_range[1][0],
		rotation_distance_range[0][1], rotation_distance_range[1][1]
	), rotation_distance_range[0][1], rotation_distance_range[1][1])
	
	if smooth_look:
		smooth_rotation = Global.decay_towards_vec2(smooth_rotation, accumulated_rotation, smooth_power, delta)
		
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), smooth_rotation.y) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), smooth_rotation.x) # then rotate in X
	
	transform = transform.orthonormalized()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#rotate_object_local(deg_to_rad(-event.screen_relative.x * mouse_sensitivity))
		#rotate_x(deg_to_rad(-event.screen_relative.y * mouse_sensitivity))
		accumulated_rotation.y -= event.screen_relative.x * mouse_sensitivity
		accumulated_rotation.x -= event.screen_relative.y * mouse_sensitivity
		accumulated_rotation.x = clampf(accumulated_rotation.x, x_rotation_limit_range[0], x_rotation_limit_range[1])
		
		if not smooth_look:
			transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), accumulated_rotation.y) # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), accumulated_rotation.x) # then rotate in X
