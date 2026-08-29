extends Resource
class_name Attack

@export var attack_damage := 0.0
@export var knockback_force := 0.0 ## Horizontal force inflicted on target.
@export var knockup_force := 0.0 ## Vertical force inflicted on target.
@export var stun_time := 0.0
@export var origin_name: String
#@export var attack_type: ATTACK_TYPE

#var attack_position := Vector2.ZERO
var attack_direction := Vector2.ZERO
var origin_node: Node = null

#enum ATTACK_TYPE {
#
#}


func _init(
		dam := attack_damage,
		knock := knockback_force,
		up := knockup_force,
		stun := stun_time,
		name := origin_name,
		#pos := attack_position,
		dir := attack_direction,
		origin := origin_node,
		):
	attack_damage = dam
	knockback_force = knock
	knockup_force = up
	stun_time = stun
	origin_name = name
	#attack_position = pos
	attack_direction = dir
	origin_node = origin
	
	resource_local_to_scene = true


static func copy(attack: Attack) -> Attack:
	var new := Attack.new()
	new.attack_damage = attack.attack_damage
	new.knockback_force = attack.knockback_force
	new.knockup_force = attack.knockup_force
	new.stun_time = attack.stun_time
	new.origin_name = attack.origin_name
	new.attack_direction = attack.attack_direction
	new.origin_node = attack.origin_node
	return new
