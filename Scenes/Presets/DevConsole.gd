extends CanvasLayer

var expression = Expression.new()
var history = []
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
	
	if event.is_action_pressed("ui_down"):
		var cycler = cycle_history(false)
		if cycler != null:
			input_label.text = cycler
		else:
			input_label.text = ""

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
		]
	
	for method in methods:
		if method.name not in excluded_methods:
			command_list.append(method.name)
	
	return "Available commands:\n" + "\n- ".join(PackedStringArray(command_list))

func echo(value):
	return value

func console(value=null):
	if value == "close":
		self.visible = true
		input_label.grab_focus()
		on_terminal_closed.emit()
	elif value == "open":
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
			var file_name = files[i].replace(".tscn", "").replace(".scn", "")
			files[i] = file_name
		
		return "\n".join(files)
	else:
		self.visible = false
		get_tree().change_scene_to_file("res://Scenes/Levels/" + song + ".tscn")
		return "loaded song: " + song

func menu():
	console("close")
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
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(audio_settings["master_volume"])
	)
	
	return audio_settings["master_volume"]

func cycle_history(move_up):
	# note that the array is reversed
	# so the last command is on index 0
	if history.size() == 0:
		return null
	
	if move_up:
		history_index += 1
		if history_index >= history.size():
			history_index = history.size() - 1
	else:
		history_index -= 1
		if history_index < 0:
			history_index = -1
			return ""
	
	return history[history_index]

# # # # # # # # # # # # # # # # # # # # # # 

func _on_line_edit_text_submitted(new_text):
	var parts = new_text.split(" ", false, 2)
	var command = parts[0]
	var args = []
	
	if parts.size() > 1:
		args = parts[1].split(" ")
	
	var full_command = new_text
	
	history.push_front(full_command)
	history_label.text += "\n> " + full_command
	history_index = -1
	
	if not has_method(command):
		var error_message = "\"" + command + "\" is not a valid command"
		print(error_message)
		history_label.text += "\nError: " + error_message
		return
	
	var result = callv(command, args)
	
	if result != null:
		if typeof(result) == TYPE_STRING:
			history_label.text += ("\n" + result)
		else:
			history_label.text += ("\n" + str(result))
	else:
		history_label.text += ("\n" + command + " executed")
	
	input_label.text = ""
