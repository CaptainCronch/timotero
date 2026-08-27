extends CharacterBody3D
class_name TestDummy

@export_enum("Timed", "Timed Multihit", "On Enter") var attack_type: String = "Timed"

@export var hitbox_comp: HitboxComponent
@export var hurtbox_comp: HurtboxComponent
@export var plat_comp: PlatformerComponent
@export var model: MeshInstance3D
@export var hit_visual: MeshInstance3D
@export var debug_label: Label3D


func _ready() -> void:
	if attack_type == "Timed":
		debug_label.text = "I attack every 0.5s!"
	elif attack_type == "Timed Multihit":
		hurtbox_comp.multihit = true
		debug_label.text = "I attack multiple entities every 0.5s!"
	elif attack_type == "On Enter":
		hurtbox_comp.updates = false
		debug_label.text = "I attack when I see something!"


func _on_hurtbox_area_entered(area: Area3D) -> void:
	#model.transform.basis = Basis()
	#model.rotate_y(global_position.direction_to(area.global_position).angle_to(Vector3.FORWARD))
	model.rotation.y = Global.rotation_y_from_dir(global_position.direction_to(area.global_position))
	if attack_type == "On Enter" and area is HitboxComponent:
		hurtbox_comp.check_collision()


func _on_hurtbox_hit(hitbox: HitboxComponent) -> void:
	debug_label.text = "I just hit " + hitbox.get_parent().name + "!"
	hit_visual.visible = true
	await get_tree().create_timer(0.1).timeout
	hit_visual.visible = false


func _on_hitbox_struck(attack: Attack) -> void:
	debug_label.text = "Ow! I was struck by " + attack.origin_name + "!"


func _on_health_component_death(_attack: Attack) -> void:
	debug_label.text = "I'm dead!"
