extends Node

const main_json := "res://main.json"
const vol1_json := "res://vol1.json"
const vol2_json := "res://vol2.json"
var generated_scenes := []


func _ready() -> void:
	ensure_folder()


func volumes_generator() -> void:
	var song_scenes := []

	var jsons := [
		json_to_array(FileAccess.get_file_as_string(main_json)),
		json_to_array(FileAccess.get_file_as_string(vol1_json)),
		json_to_array(FileAccess.get_file_as_string(vol2_json)),
	]

	for json_data: Array in jsons:
		for i in range(len(json_data)):
			var song: Dictionary = json_data[i]

			if i == 0:
				song["previous_scene"] = null
				if len(json_data) > 1:
					song["next_scene"] = json_data[i + 1]["scene_name"]
				else:
					song["next_scene"] = null
			elif i == len(json_data) - 1:
				song["previous_scene"] = json_data[i - 1]["scene_name"]
				song["next_scene"] = null
			else:
				song["previous_scene"] = json_data[i - 1]["scene_name"]
				song["next_scene"] = json_data[i + 1]["scene_name"]

			#print("%s: {%s | %s}" % [song["scene_name"], song["previous_scene"], song["next_scene"]])

			var scene_paths := create_scene(
				song["scene_name"], song, "user://Scenes/Levels/%s.tscn" % song["scene_name"]
			)
			if scene_paths.size() > 0:
				generated_scenes.append(scene_paths[0])
			song_scenes.append(song["scene_name"])


func json_to_array(json_string: String) -> Array:
	var json := JSON.new()
	var err := json.parse(json_string)
	if err != OK:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line()
		)
		return []
	return json.data


func delete_levels(levels: Array) -> void:
	var levels_path := "user://Scenes/Levels/"
	var dir := DirAccess.open(levels_path)

	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if file_name.ends_with(".tscn"):
				var file_path := levels_path + file_name
				if file_path in levels:
					var error := dir.remove(file_path)
					if error != OK:
						print("Failed to delete file: ", file_path)
			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Failed to open directory: ", levels_path)


func create_scene(node_name: String, song_data: Dictionary, res_path: String) -> Array:
	var main := Control.new()

	main.name = node_name
	main.set_anchors_preset(Control.PRESET_FULL_RECT)

	if song_data.has("is_ending") and song_data["is_ending"]:
		return create_end_scene(main, song_data, res_path)
	else:
		var song_player: Node = load("res://Scenes/Presets/SongPlayer.tscn").instantiate()

		for key: String in song_data.keys():
			# manual intervention for some fields xdd
			if key == "background":
				var texture := ensure_texture(song_data[key])
				var video := ensure_video(song_data[key])
				#if texture and texture is CompressedTexture2D:
				if texture and texture is Texture2D:
					song_player.set("game_background", texture)
				elif video and video is VideoStream:
					song_player.set("video_background", video)
				else:
					print("Failed to load texture for key: ", key)
			elif key == "audio_file":
				var audio_stream := ensure_mp3(song_data[key])
				if audio_stream and audio_stream is AudioStream:
					song_player.set(key, audio_stream)
				else:
					print("Failed to load audio stream for key: ", key)
			elif key == "ambi_sfx":
				var audio_stream := ensure_mp3(song_data[key])
				if audio_stream and audio_stream is AudioStream:
					song_player.set("ambiance_sfx", audio_stream)
			elif key == "hide_backpack":
				var should_hide: bool = song_data[key]
				song_player.set("hide_backpack", should_hide)
			elif key == "find_on_start":
				var items_array: Array[Defs.InvItem] = []
				for item_id: int in song_data[key]:
					items_array.append(item_id as Defs.InvItem)
				song_player.set("find_on_start", items_array)
			else:
				song_player.set(key, song_data[key])

		# add the scene as child and set the main node as owner
		main.add_child(song_player)
		song_player.set_owner(main)
		song_player.queue_free()

	# pack the scene up into the file
	var scene := PackedScene.new()
	var result := scene.pack(main)

	if result == OK:
		var error := ResourceSaver.save(scene, res_path)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
			return []
		else:
			return [res_path]

	return []


func create_end_scene(node: Node, song_data: Dictionary, res_path: String) -> Array:
	var endscreen: Node = load("res://Scenes/Presets/Endscreen.tscn").instantiate()

	endscreen.set("background", load(song_data["background"]))
	endscreen.set("text", song_data["text"])

	if song_data.has("ambi_sfx"):
		var audio_stream := ensure_mp3(song_data["ambi_sfx"])
		if audio_stream and audio_stream is AudioStream:
			endscreen.set("ambiance_sfx", audio_stream)

	if song_data.has("is_intermission") and song_data.get("is_intermission", false):
		endscreen.set("is_intermission", song_data["is_intermission"])

		if song_data.has("previous_scene") and song_data["previous_scene"]:
			endscreen.set("previous_scene", song_data["previous_scene"])

		if song_data.has("next_scene") and song_data["next_scene"]:
			endscreen.set("next_scene", song_data["next_scene"])

	node.add_child(endscreen)
	endscreen.set_owner(node)

	# pack the scene up into the file
	var scene := PackedScene.new()
	var result := scene.pack(node)  # pack the node with endscreen

	endscreen.queue_free()

	if result == OK:
		var error := ResourceSaver.save(scene, res_path)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
			return []
		else:
			return [res_path]

	return []


func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_CRASH:
		delete_levels(generated_scenes)
		get_tree().quit()  # default behavior


func customs_generator() -> void:
	# Define the base path for custom scenes
	var custom_scenes_path := "user://Scenes/Levels/"
	var custom_base_path := "res://customs/"

	# Open the custom directory
	var dir := DirAccess.open(custom_base_path)
	if dir == null:
		DevConsole.echo("Failed to open custom directory: %s" % custom_base_path)
		return

	# Begin listing the custom directories
	dir.list_dir_begin()
	while true:
		var folder := dir.get_next()
		if folder == "":
			break
		if !dir.current_is_dir() or folder.begins_with("."):
			continue

		# Construct the path to the tracklist.json file
		var json_path := custom_base_path + folder + "/tracklist.json"

		# Check if the tracklist.json file exists
		if !FileAccess.file_exists(json_path):
			DevConsole.echo("No tracklist.json found in %s" % folder)
			continue

		# Read the JSON data from the file
		var json_data := json_to_array(FileAccess.get_file_as_string(json_path))
		if json_data.size() == 0:
			DevConsole.echo("No data found in %s" % json_path)
			continue

		# Iterate through the JSON data and generate scenes
		for i in range(len(json_data)):
			var song: Dictionary = json_data[i]

			if i == 0:
				song["previous_scene"] = null
				if len(json_data) > 1:
					song["next_scene"] = json_data[i + 1]["scene_name"]
				else:
					song["next_scene"] = null
			elif i == len(json_data) - 1:
				song["previous_scene"] = json_data[i - 1]["scene_name"]
				song["next_scene"] = null
			else:
				song["previous_scene"] = json_data[i - 1]["scene_name"]
				song["next_scene"] = json_data[i + 1]["scene_name"]

			# Generate the scene and add it to the list of custom scenes
			var scene_paths := create_scene(
				song["scene_name"], song, custom_scenes_path + "%s.tscn" % song["scene_name"]
			)
			if scene_paths.size() > 0:
				generated_scenes.append(scene_paths[0])


# TODO: OPTIMIZE THESE TWO BELOW AAAA


func ensure_mp3(path: String) -> AudioStream:
	# check if already an AudioStream
	var existing_resource := ResourceLoader.load(path)
	if existing_resource and existing_resource is AudioStream:
		return existing_resource as AudioStream

	path = "res://" + path

	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var data := file.get_buffer(file.get_length())
		file.close()

		var audio_stream := AudioStreamMP3.new()
		audio_stream.data = data

		return audio_stream
	else:
		print("Failed to open file: %s" % path)
		return null


func ensure_texture(path: String) -> Texture2D:
	# check if already CompressedTexture2D
	var existing_resource := ResourceLoader.load(path)
	if existing_resource and existing_resource is CompressedTexture2D:
		return existing_resource as CompressedTexture2D

	if existing_resource is VideoStream:
		return null

	path = "res://" + path

	# Create and load the image
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		print("Failed to load image from file: %s, Error: %s" % [path, error])
		return null

	# Verify the image has valid dimensions
	if image.get_width() <= 0 or image.get_height() <= 0:
		print("Image has invalid dimensions: %s" % path)
		return null

	# Create an ImageTexture from the image
	var image_texture := ImageTexture.create_from_image(image)

	return image_texture


func ensure_video(path: String) -> VideoStream:
	# vibe coded this function real function icl #quirkyy!
	# Check if stream already exists
	var existing_resource := ResourceLoader.load(path)
	if existing_resource and existing_resource is VideoStream:
		return existing_resource as VideoStream

	if existing_resource is CompressedTexture2D:
		return null

	path = "res://" + path

	# load the video stream
	var video_stream := ResourceLoader.load(path)

	# validate the loaded resource
	if !video_stream or !(video_stream is VideoStream):
		print("Failed to load video stream from file: %s" % path)
		return null

	# Verify it's specifically a VideoStreamTheora (required format)
	if !(video_stream is VideoStreamTheora):
		print("Video must be in Ogg Theora format (.ogv): %s" % path)
		return null

	return video_stream


func ensure_folder() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("user://Scenes/Levels"):
		dir.make_dir_recursive("user://Scenes/Levels")
