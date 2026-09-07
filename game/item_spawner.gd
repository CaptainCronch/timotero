extends MultiplayerSpawner

@export_dir var root_folder_path := ""


func _ready() -> void:
	var scenes_folder := DirAccess.open(root_folder_path)
	if scenes_folder:
		scenes_folder.list_dir_begin()
		var folder_name := scenes_folder.get_next()
		while folder_name != "":
			if scenes_folder.current_is_dir():
				add_from_dir(root_folder_path + folder_name + "/")
			folder_name = scenes_folder.get_next()
		scenes_folder.list_dir_end()
	else:
		printerr("An error occurred when trying to access the Items folder.")


func add_from_dir(path: String) -> void:
	var current_folder := DirAccess.open(path)
	if current_folder:
		current_folder.list_dir_begin()
		var file_name := current_folder.get_next()
		while not file_name.is_empty():
			if not current_folder.current_is_dir():
				if file_name.ends_with(".tscn"):
					add_spawnable_scene(path + file_name)
			file_name = current_folder.get_next()
		current_folder.list_dir_end()
	else:
		printerr("An error occurred when trying to access a folder in the Items folder.")
