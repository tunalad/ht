extends Control

@export var background : CompressedTexture2D
@export_multiline var text : String

@onready var MENU_END = $menu_end.get_children()
@onready var AUDIO_PLAYER = $AudioStreamPlayer
@onready var diary_text = $diary/CenterContainer/text


func _process(_delta):
	# live engine updating
	if Engine.is_editor_hint():
		set_text_background()

func _ready():
	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	TransitionScreen.fade_to_normal()
	
	set_text_background()
	
	MENU_END[0].grab_focus()
	
	for btn in MENU_END:
		btn.skipped_sound = true

func set_text_background():
	if background:
		$background.texture = background
	
	if text:
		diary_text.text = text
	else:
		diary_text.visible = false
	pass


func _on_btn_menu_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_quit"])
	TransitionScreen.transition(0.5)
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")

func _on_dev_console_console_closed():
	MENU_END[0].grab_focus()
