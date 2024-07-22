extends Node

const vol1_json := "res://vol1.json"
var generated_scenes = []

func volumes_generator():
	var song_scenes = []
	var json_data = json_to_dict(FileAccess.get_file_as_string(vol1_json))
	
	for song in json_data:
		var scene_paths = create_scene(song["scene_name"], song, "user://Scenes/Levels/%s.tscn" % song["scene_name"])
		if scene_paths.size() > 0:
			generated_scenes.append(scene_paths[0])
		song_scenes.append(song["scene_name"])


func json_to_dict(json_string : String):
	var json = JSON.new()
	var err = json.parse(json_string)
	if err != OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	return json.data


func delete_levels(levels: Array):
	var levels_path = "user://Scenes/Levels/"
	var dir = DirAccess.open(levels_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var file_path = levels_path + file_name
				if file_path in levels:
					var error = dir.remove(file_path)
					if error != OK:
						print("Failed to delete file: ", file_path)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", levels_path)


func create_scene(node_name : String, song_data : Dictionary, res_path : String) -> Array:
	# check if scene already exists
	if FileAccess.file_exists(res_path):
		print("Scene already exists: ", res_path)
		return []
	
	var main = Control.new()
	
	main.name = node_name
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var song_player = load("res://Scenes/Presets/SongPlayer.tscn").instantiate()
	
	for key in song_data.keys():
		# manual intervention for some fields xdd
		if key == "background":
			var texture = load(song_data[key])
			if texture and texture is CompressedTexture2D:
				song_player.set("game_background", texture)
			else:
				print("Failed to load texture for key: ", key)
		elif key == "audio_file":
			var audio_stream = load(song_data[key])
			if audio_stream and audio_stream is AudioStream:
				song_player.set(key, audio_stream)
			else:
				print("Failed to load audio stream for key: ", key)
		else:
			song_player.set(key, song_data[key])
	
	# add the scene as child and set the main node as owner
	main.add_child(song_player)
	song_player.set_owner(main)
	
	# pack the scene up into the file
	var scene = PackedScene.new()
	var result = scene.pack(main)
	
	song_player.queue_free()
	
	if result == OK:
		var error = ResourceSaver.save(scene, res_path)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
			return []
		else:
			return [res_path]
	
	return []


func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		delete_levels(generated_scenes)
		get_tree().quit() # default behavior
