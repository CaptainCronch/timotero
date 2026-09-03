extends Resource
class_name ItemRef

enum Tag {
	MATERIAL, ## Means you can craft with it.
	USABLE, ## Means you can use at least your primary input to activate the item's use.
	EQUIPPABLE, ## Means you can wear the item as armor or an accessory.
	TOOL, ## Means the item is reusable for work.
	WEAPON, ## Means the item is a tool for violence.
}

#TBD: use resource_path to grab it from the files as needed?
# All of these need to be static data for an item so they can be replicated across the network using only a filename
@export var image: CompressedTexture2D
@export var name: String
@export_multiline var description: String
@export var stackable := true
@export var max_stack := 99
@export var tags: Array[Tag] = []
@export_file("res://items/*.tscn") var dropped_item: String ## Filepath used to load the physical item version of this ItemRef. ItemRefs probably shouldn't have direct references to their dropped item versions because otherwise a chest would be full of useless nodes, but it's okay for a dropped items to hold its itemref definition in it.
