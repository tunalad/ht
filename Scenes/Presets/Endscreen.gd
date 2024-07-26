@tool
extends Control

@export var background : CompressedTexture2D
@export_multiline var text : String
@export var subtract_white : bool = false

@onready var AUDIO_PLAYER = $AudioStreamPlayer
@onready var diary_text = $diary/CenterContainer/text


func _process(delta):
	if Engine.is_editor_hint():
		set_text_background()


func _input(event):
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")) and DevConsole.visible == false:
		Global.play_sound(AUDIO_PLAYER, load("res://SFX/tapedeck-close-fx.wav"))
		$"tape-hiss".stop()
		#TransitionScreen.transition(2)
		TransitionScreen.transition(0.1, 3)
		await TransitionScreen.on_transition_finished
		DevConsole.menu()


func _ready():
	TransitionScreen.fade_to_normal()
	
	set_text_background()
	
	Global.play_sound(AUDIO_PLAYER, load("res://SFX/tapedeck-open-fx.wav"))
	await get_tree().create_timer(0.25).timeout
	
	Global.play_sound($"tape-hiss", load("res://SFX/green-tape-hiss-fx.wav"))


func set_text_background():
	if !subtract_white:
		$diary.material = null
	
	if background:
		$background.texture = background
	else:
		$background.visible = false
	
	if text:
		diary_text.text = text
	else:
		diary_text.visible = false


func _on_btn_menu_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_quit"])
	TransitionScreen.transition(2)
	await TransitionScreen.on_transition_finished
	DevConsole.menu()

