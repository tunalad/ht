extends CanvasLayer

var expression = Expression.new()
var history_list = []
var history_index = -1

@onready var history_label = $MarginContainer/console/ScrollContainer/VBoxContainer/history
@onready var input_label = $MarginContainer/console/input

signal on_terminal_closed

func _ready():
	self.visible = false

func _input(event):
	if event.is_action_pressed("ui_tilde"):
		console()
		
	if event.is_action_pressed("ui_cancel"):
		console("close")
	
	if event.is_action_pressed("ui_up"):
		var cycler = cycle_history(true)
		if cycler != null:
			input_label.text = cycler
		else:
			input_label.text = ""
		
		await get_tree().create_timer(0.001).timeout
		input_label.caret_column = 100000
	
	if event.is_action_pressed("ui_down"):
		var cycler = cycle_history(false)
		if cycler != null:
			input_label.text = cycler
		else:
			input_label.text = ""
		
	if event.is_action_pressed("ui_text_completion_replace"):
		var partial_command = input_label.text
		input_label.text = tab_completion(partial_command)
		input_label.caret_column = 100000

func commands():
	var command_list = []
	var methods = self.get_script().get_script_method_list()
	var excluded_methods = [
			"_ready", 
			"_process", 
			"_on_line_edit_text_submitted", 
			"handle_scrollbar_changed", 
			"_input",
			"cycle_history",
			"tab_completion"
		]
	
	for method in methods:
		if method.name not in excluded_methods:
			command_list.append(method.name)
	
	return "Available commands:\n- " + "\n- ".join(PackedStringArray(command_list))

func history():
	var temp_list = history_list
	temp_list.reverse()
	return "Commands history: \n- " + "\n- ".join(PackedStringArray(temp_list))

func echo(value=" "):
	history_label.text += "\n" + str(value)
	return

func console(value=null):
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

func load_song(song=null):
	var levels_path = "res://Scenes/Levels/"
	var dir = DirAccess.open(levels_path)
	var files = []
	
	if !song:
		files = dir.get_files()
		
		# remove '.tscn' or '.scn' from each filename
		for i in range(files.size()):
			var file_name = files[i].replace(".tscn", "").replace(".scn", "").replace(".remap", "")
			files[i] = file_name
		return "\n".join(files)
	else:
		var song_path = "res://Scenes/Levels/" + song + ".tscn"
		var song_path_remap = "res://Scenes/Levels/" + song + ".tscn.remap"
		
		var err = get_tree().change_scene_to_file(song_path)
		
		if err == OK:
			self.visible = false
			return "loaded song: " + song
		elif err == ERR_FILE_NOT_FOUND or err == ERR_CANT_OPEN:
			return "song '%s' not found." % song
		else:
			return "unknown error."

func menu():
	#console("close")
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
	return "loaded menu"

func quit():
	get_tree().quit()
	return ""

func clear():
	history_label.text = ""
	return ""

func volume(value=null):
	var audio_settings = ConfigHandler.load_audio_settings()
	
	if value == null:
		return "Volume is: " + str(audio_settings["master_volume"])
	
	value = float(value)
	
	if value < 0:
		value = 0
	
	audio_settings["master_volume"] = value
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	Global.load_settings()
	
	return audio_settings["master_volume"]

func crt_shader():
	var misc_settings = ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("crt_shader", !misc_settings["crt_shader"])
	Crt.toggle_crt()
	
	return !misc_settings["crt_shader"]

func sh_sfx():
	if Global.sounds == Global.sh_sounds:
		Global.sounds = Global.homemade_sounds
		AudioServer.set_bus_layout(load("res://SFX/homemade_sfx.tres"))
		return "Disabled Silent Hill sounds"
	else:
		Global.sounds = Global.sh_sounds
		AudioServer.set_bus_layout(load("res://SFX/sh_sfx.tres"))
		return "Enabled Silent Hill sounds"

func pc_humm():
	var misc_settings = ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("pc_humm", !misc_settings["pc_humm"])
	Global.load_settings()
	return !misc_settings["pc_humm"]

func fullscreen():
	var video_settings = ConfigHandler.load_video_settings()
	
	ConfigHandler.save_video_settings("fullscreen", !video_settings["fullscreen"])
	Global.load_settings()
	return !video_settings["fullscreen"]

func host_framerate(frames=null):
	if frames:
		Engine.time_scale = float(frames)
		AudioServer.playback_speed_scale = float(frames)
		
	return Engine.time_scale

func mouse_hidden():
	var misc_settings = ConfigHandler.load_misc_settings()
	
	ConfigHandler.save_misc_settings("hide_mouse", !misc_settings["hide_mouse"])
	Global.load_settings()
	
	return misc_settings["hide_mouse"]

# # # # # # # # # # # # # # # # # # # # # # 

func cycle_history(move_up):
	# note that the array is reversed
	# so the last command is on index 0
	if history_list.size() == 0:
		return null
	
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

func tab_completion(partial_command):
	if partial_command == "":
		return ""
	
	var command_list = commands().split("\n- ")
	command_list.remove_at(0) # trimming out the "avialable commands" part
	
	var matches = []
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

func _on_line_edit_text_submitted(new_text):
	input_label.text = ""
	
	if new_text.strip_edges() == "":
		echo(">")
		return
	
	var parts = new_text.split(" ", false, 2)
	var command = parts[0]
	var args = []
	
	if parts.size() > 1:
		args = parts[1].split(" ")
	
	var full_command = new_text
	
	history_list.push_front(full_command)
	history_label.text += "\n> " + full_command
	history_index = -1
	
	if not has_method(command):
		var error_message = "\"" + command + "\" is not a valid command"
		echo("Error: " + error_message)
		return
	
	var result = callv(command, args)
	
	if result != null:
		echo(result)
	else:
		pass
		#echo(command + " executed")
