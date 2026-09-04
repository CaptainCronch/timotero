extends Resource
class_name ItemRef

enum Tag { ## ItemRef tags are inherent to the type of item they belong to.
	NONE, ## Used for initialization purposes.
	MATERIAL, ## Means you can craft with it.
	USABLE, ## Means you can use at least your primary input to activate the item's use.
	EQUIPPABLE, ## Means you can wear the item as armor or an accessory.
	TOOL, ## Means the item is reusable for work.
	WEAPON, ## Means the item is a tool for violence.
	HEAD, ## Means you can wear the item on your head.
	BODY, ## Means you can wear the item on your body.
	#LEGS, ## Means you can wear the item on your legs. # still deciding on whether i wanna separate armor like this
	ACCESSORY, ## Means you can wear the item as an accessory.
	VANITY, ## Means you can wear the item as vanity.
}

#TBD: use resource_path to grab it from the files as needed?
# All of these need to be static data for an item so they can be replicated across the network using only a filename
@export var image: CompressedTexture2D
@export var name: String
@export_multiline var description: String
@export var stackable := true
@export var max_stack := 99
@export var inherent_tags: Array[Tag] = []
@export_file("*.tscn") var dropped_item: String ## Filepath used to load the physical item version of this ItemRef. ItemRefs probably shouldn't have direct references to their dropped item versions because otherwise a chest would be full of useless nodes, but it's okay for a dropped items to hold its itemref definition in it.


func _init() -> void: # an item should never be created with ItemRef.new()
	assert(stackable or max_stack == 1, name + " ItemRef has a misconfigured stack size!")
