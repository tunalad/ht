extends CanvasLayer

var expression = Expression.new()
var history = []

#@onready var history_label = $MarginContainer/console/history
@onready var history_label = $MarginContainer/console/ScrollContainer/VBoxContainer/history
@onready var input_label = $MarginContainer/console/input

signal console_closed

func _ready():
	self.visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_tilde"):
		self.visible = !self.visible
		if self.visible:
			input_label.grab_focus()
		else:
			emit_signal("console_closed")
		
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = false
		emit_signal("console_closed")

func echo(value):
	return value

func load_song(song=null):
	var levels_path = "res://Scenes/Levels/"
	
	var dir = DirAccess.open(levels_path)
	var files = []
	
	if!song:
		files = dir.get_files()
		# Remove '.tscn' or '.scn' from each filename
		for i in range(files.size()):
			var file_name = files[i].replace(".tscn", "").replace(".scn", "")
			files[i] = file_name
		
		return "\n".join(files)
	else:
		self.visible = false
		get_tree().change_scene_to_file("res://Scenes/Levels/" + song + ".tscn")
		return ""


func menu():
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
	return ""

func quit():
	get_tree().quit()
	return ""

func clear():
	history_label.text = ""
	return ""

func volume(value):
	var audio_settings = ConfigHandler.load_audio_settings()
	
	if value < 0:
		value = 0
	
	audio_settings["master_volume"] = value
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(audio_settings["master_volume"])
	)
	return ""

# # # # # # # # # # # # # # # # # # # # # # 

func _on_line_edit_text_submitted(new_text):
	var error = expression.parse(new_text)
	
	history.append(str(new_text))
	
	if error != OK:
		var error_message = "\"" + new_text + "\" doesn't exist"
		print(error_message)
		history_label.text += "\nError: " + error_message
		return
	
	# execute the parsed expression with custom functions
	var result = expression.execute([], self, false)
	
	if not expression.has_execute_failed():
		history_label.text += ("\n" + str(result))
	else:
		var error_message = "Unknown command \"%s\"" % new_text
		print(error_message)
		history_label.text += "\nError: " + error_message
	
	input_label.text = ""

