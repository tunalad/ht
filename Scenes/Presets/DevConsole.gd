extends CanvasLayer

var expression := Expression.new()
var history_list := []
var history_index := -1
var blacklist_for_browser := ["host_framerate", "quit"]

@onready var history_label := $MarginContainer/console/ScrollContainer/VBoxContainer/history
@onready var input_label := $MarginContainer/console/input

signal on_terminal_closed
signal console_pause

func _ready() -> void:
	self.visible = false

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_tilde"):
		console()
		
	if event.is_action_pressed("ui_cancel"):
		console("close")
	
	if event.is_action_pressed("ui_up"):
		var cycler := cycle_history(true)
		if cycler != null:
			input_label.text = cycler
		else:
			input_label.text = ""
		
		await get_tree().create_timer(0.001).timeout
		input_label.caret_column = 100000
	
	if event.is_action_pressed("ui_down"):
		var cycler := cycle_history(false)
		if cycler != null:
			input_label.text = cycler
		else:
			input_label.text = ""
		
	if event.is_action_pressed("ui_text_completion_replace"):
		var partial_command : String = input_label.text
		input_label.text = tab_completion(partial_command)
		input_label.caret_column = 100000

func commands() -> String:
	var command_list := []
	var methods : Array = self.get_script().get_script_method_list()
	var excluded_methods := [
			"_ready", 
			"_process", 
			"_on_line_edit_text_submitted", 
			"handle_scrollbar_changed", 
			"_input",
			"cycle_history",
			"tab_completion",
			"convert_args"
		]
	
	for method : Dictionary in methods:
		if method.name not in excluded_methods:
			command_list.append(method.name)
	
	return "Available commands:\n- " + "\n- ".join(PackedStringArray(command_list))

func history() -> String:
	var temp_list := history_list
	temp_list.reverse()
	return "Commands history: \n- " + "\n- ".join(PackedStringArray(temp_list))

func echo(value := " ") -> void:
	history_label.text += "\n" + str(value)

func console(value : String = "") -> void:
	if value == "close":
		self.visible = false
		on_terminal_closed.emit()
	elif value == "open":
		input_label.grab_focus()
		self.visible = true
	else:
		self.visible = !self.visible
		if self.visible:
			input_label.grab_focus()
		else:
			on_terminal_closed.emit()

func load_song(song : String = "") -> String:
	const all_paths := ["user://Scenes/Levels/", "res://Scenes/Levels/"]
	var all_files := []
	
	for levels_path : String in all_paths:
		var dir := DirAccess.open(levels_path)
		
		if dir == null:
			if levels_path == all_paths[0]:
				var err := DirAccess.make_dir_recursive_absolute(levels_path)
				print(err)
			dir = DirAccess.open(levels_path)
		
		if dir != null:
			if !song:
				var files := dir.get_files()
				for file in files:
					if file.ends_with(".tscn") or file.ends_with(".scn") or file.ends_with(".tscn.remap") or file.ends_with(".scn.remap"):
						var file_name := file.replace(".tscn", "").replace(".scn", "").replace(".remap", "")
						if !all_files.has(file_name):
							all_files.append(file_name)
			else:
				var song_path : String = levels_path + song + ".tscn"
				var err := get_tree().change_scene_to_file(song_path)
				
				if err == OK:
					self.visible = false
					return "loaded song: " + song
				elif err == ERR_FILE_NOT_FOUND or err == ERR_CANT_OPEN:
					continue
				else:
					return "unknown error."
	
	if !song:
		all_files.sort()
		return "\n".join(all_files)
	else:
		return "song '%s' not found." % song

func menu() -> String:
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
	return "loaded menu"

func quit() -> void:
	get_tree().quit()

func clear() -> void:
	history_label.text = ""

func volume(value : float = -1) -> String:
	var audio_settings := ConfigHandler.load_audio_settings()
	
	if value < 0:
		return "Volume is: " + str(audio_settings["master_volume"])
	
	value = float(value)
	
	if value < 0:
		value = 0
	
	audio_settings["master_volume"] = value
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	Global.load_settings()
	
	return str(audio_settings["master_volume"])

func crt_shader() -> String:
	var misc_settings := ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("crt_shader", !misc_settings["crt_shader"])
	Crt.toggle_crt()
	
	return str(!misc_settings["crt_shader"])

func sh_sfx() -> String:
	if Global.sounds == Global.sh_sounds:
		Global.sounds = Global.homemade_sounds
		AudioServer.set_bus_layout(load("res://SFX/homemade_sfx.tres"))
		return "Disabled Silent Hill sounds"
	else:
		Global.sounds = Global.sh_sounds
		AudioServer.set_bus_layout(load("res://SFX/sh_sfx.tres"))
		return "Enabled Silent Hill sounds"

func pc_humm() -> String:
	var misc_settings := ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("pc_humm", !misc_settings["pc_humm"])
	Global.load_settings()
	return str(!misc_settings["pc_humm"])

func fullscreen() -> String:
	var video_settings := ConfigHandler.load_video_settings()
	
	ConfigHandler.save_video_settings("fullscreen", !video_settings["fullscreen"])
	Global.load_settings()
	return str(!video_settings["fullscreen"])

func host_framerate(frames : float = 1) -> float:
	if frames > 0:
		Engine.time_scale = float(frames)
		AudioServer.playback_speed_scale = float(frames)
		
	return Engine.time_scale

func mouse_hidden() -> String:
	var misc_settings := ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("hide_mouse", !misc_settings["hide_mouse"])
	Global.load_settings()
	
	return str(misc_settings["hide_mouse"])

func pause() -> void:
	console_pause.emit()

# # # # # # # # # # # # # # # # # # # # # # 

func cycle_history(move_up : bool) -> String:
	# note that the array is reversed
	# so the last command is on index 0
	if history_list.size() == 0:
		return ""
	
	if move_up:
		history_index += 1
		if history_index >= history_list.size():
			history_index = history_list.size() - 1
	else:
		history_index -= 1
		if history_index < 0:
			history_index = -1
			return ""
	
	return history_list[history_index]

func tab_completion(partial_command : String) -> String:
	if partial_command == "":
		return ""
	
	var command_list := commands().split("\n- ")
	command_list.remove_at(0) # trimming out the "avialable commands" part
	
	var matches := []
	for command in command_list:
		if command.begins_with(partial_command):
			matches.append(command)
	
	if matches.size() == 1:
		return matches[0]
	elif matches.size() > 1:
		history_label.text += "\n" + str(matches.size()) + " possible options:\n " + "\n ".join(matches)
		return partial_command
	
	return partial_command

# # # # # # # # # # # # # # # # # # # # # # 

func _on_line_edit_text_submitted(new_text : String) -> void:
	input_label.text = ""
	
	if new_text.strip_edges() == "":
		echo(">")
		return
	
	var parts : Array = new_text.split(" ", false, 2)
	var command : String = parts[0]
	var args := []
	
	if parts.size() > 1:
		args = parts[1].split(" ")
	
	var full_command : String = new_text
	
	history_list.push_front(full_command)
	history_label.text += "\n> " + full_command
	history_index = -1
	
	if OS.get_name() == "Web" and command in blacklist_for_browser:
		echo("Error: \"" + command + "\" is not available on browser platform.")
		return
	
	if not has_method(command):
		var error_message : String = "\"" + command + "\" is not a valid command"
		echo("Error: " + error_message)
		return
	
	args = convert_args(command, args)
	
	var result : Variant = callv(command, args)
	
	if result != null:
		echo(str(result))

# because of static typing, I need to implement a function for converting arguments...
func convert_args(command : String, args : Array) -> Array:
	var expected_arg_types := {
		"volume": [TYPE_FLOAT],
		"host_framerate": [TYPE_FLOAT],
	}
	
	if expected_arg_types.has(command):
		for i in range(args.size()):
			var arg_type : int = expected_arg_types[command][i]
			match arg_type:
				TYPE_INT:
					args[i] = int(args[i])
				TYPE_FLOAT:
					args[i] = float(args[i])
				TYPE_BOOL:
					args[i] = args[i].to_lower() in ["true", "1", "yes"]
				
	return args
