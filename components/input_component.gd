extends Node
class_name InputComponent

#region signals
signal forwards
signal forwards_hold
signal forwards_release
signal backwards
signal backwards_hold
signal backwards_release
signal right
signal right_hold
signal right_release
signal left
signal left_hold
signal left_release
signal jump
signal jump_hold
signal jump_release
signal primary
signal primary_hold
signal primary_release
signal secondary
signal secondary_hold
signal secondary_release
signal tertiary
signal tertiary_hold
signal tertiary_release
signal ability
signal ability_hold
signal ability_release
signal toggle_strafe
signal toggle_strafe_hold
signal toggle_strafe_release
signal inventory
signal inventory_hold
signal inventory_release
signal escape
signal escape_hold
signal escape_release
signal item_next
signal item_previous
#endregion

var enabled = true
var move_vector := Vector2()

@export var spring_arm: SpringArm3D
@export var plat_comp: PlatformerComponent


func _process(_delta: float) -> void: # how do you do this better
	if not is_multiplayer_authority(): return
	if not enabled: return
	puppet_plat_comp()
	move_vector = Input.get_vector("left", "right", "forwards", "backwards")
	
	if Input.is_action_just_pressed("forwards"): forwards.emit()
	if Input.is_action_pressed("forwards"): forwards_hold.emit()
	if Input.is_action_just_released("forwards"): forwards_release.emit()
	
	if Input.is_action_just_pressed("backwards"): backwards.emit()
	if Input.is_action_pressed("backwards"): backwards_hold.emit()
	if Input.is_action_just_released("backwards"): backwards_release.emit()
	
	if Input.is_action_just_pressed("right"): right.emit()
	if Input.is_action_pressed("right"): right_hold.emit()
	if Input.is_action_just_released("right"): right_release.emit()
	
	if Input.is_action_just_pressed("left"): left.emit()
	if Input.is_action_pressed("left"): left_hold.emit()
	if Input.is_action_just_released("left"): left_release.emit()
	
	if Input.is_action_just_pressed("jump"): jump.emit()
	if Input.is_action_pressed("jump"): jump_hold.emit()
	if Input.is_action_just_released("jump"): jump_release.emit()
	
	if Input.is_action_just_pressed("primary"): primary.emit()
	if Input.is_action_pressed("primary"): primary_hold.emit()
	if Input.is_action_just_released("primary"): primary_release.emit()
	
	if Input.is_action_just_pressed("secondary"): secondary.emit()
	if Input.is_action_pressed("secondary"): secondary_hold.emit()
	if Input.is_action_just_released("secondary"): secondary_release.emit()
	
	if Input.is_action_just_pressed("tertiary"): tertiary.emit()
	if Input.is_action_pressed("tertiary"): tertiary_hold.emit()
	if Input.is_action_just_released("tertiary"): tertiary_release.emit()
	
	if Input.is_action_just_pressed("ability"): ability.emit()
	if Input.is_action_pressed("ability"): ability_hold.emit()
	if Input.is_action_just_released("ability"): ability_release.emit()
	
	if Input.is_action_just_pressed("toggle_strafe"): toggle_strafe.emit()
	if Input.is_action_pressed("toggle_strafe"): toggle_strafe_hold.emit()
	if Input.is_action_just_released("toggle_strafe"): toggle_strafe_release.emit()
	
	if Input.is_action_just_pressed("inventory"): inventory.emit()
	if Input.is_action_pressed("inventory"): inventory_hold.emit()
	if Input.is_action_just_released("inventory"): inventory_release.emit()
	
	if Input.is_action_just_pressed("escape"): escape.emit()
	if Input.is_action_pressed("escape"): escape_hold.emit()
	if Input.is_action_just_released("escape"): escape_release.emit()
	
	# special inputs because mouse wheel rolls are always released only
	if Input.is_action_just_released("scroll_up"): item_next.emit()
	if Input.is_action_just_released("scroll_down"): item_previous.emit()


func puppet_plat_comp() -> void:
	pass
