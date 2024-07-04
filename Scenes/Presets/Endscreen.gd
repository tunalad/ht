extends Control

@export var background : CompressedTexture2D
@export var text : String

@onready var MENU_END = $menu_end.get_children()
@onready var AUDIO_PLAYER = $AudioStreamPlayer

func _ready():
	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	TransitionScreen.fade_to_normal()
	
	if background:
		$background.texture = background
	
	MENU_END[0].grab_focus()
	
	for btn in MENU_END:
		btn.skipped_sound = true


func _on_btn_menu_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_quit"])
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")

func _on_dev_console_console_closed():
	MENU_END[0].grab_focus()
