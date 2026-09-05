extends CharacterBody3D
class_name Item

const PICK_UP_DELAY := 0.5

@export var slotref: SlotRef
@export var health_comp: HealthComponent
@export var hitbox_comp: HitboxComponent
@export var plat_comp: PlatformerComponent
@export var collider: CollisionShape3D
@export var model: Node3D
@export var dropped_marker: Marker3D
@export var held_marker: Marker3D

var pickupable := false
var pick_up_timer := PICK_UP_DELAY


func _ready() -> void:
	var slot_valid := is_instance_valid(slotref)
	assert(slot_valid, name + " has an invalid SlotRef!")
	if slot_valid:
		assert(is_instance_valid(slotref.itemref), name + " has an invalid ItemRef!")
	assert(collision_layer == 256 and collision_mask == (1+2), name + " has misconfiguered collision layers / masks!")
	assert(is_instance_valid(get_node_or_null("MultiplayerSynchronizer")), name + " has no MultiplayerSynchronizer!")
	assert(health_comp.defense == INF)


func _process(delta: float) -> void:
	if pick_up_timer > 0.0:
		pick_up_timer -= delta
		if pick_up_timer <= 0.0:
			pickupable = true


func pick_up() -> void:
	plat_comp.disabled = true
	hitbox_comp.detectable = false
	collider.disabled = true
	pickupable = false
	pick_up_timer = -1.0
	model.transform = held_marker.transform


func drop() -> void:
	plat_comp.disabled = false
	hitbox_comp.detectable = true
	collider.disabled = false
	pickupable = false
	pick_up_timer = PICK_UP_DELAY
	model.transform = dropped_marker.transform
