@tool
extends TextureButton

signal left_key_pressed
signal right_key_pressed

@export var text : String = "Text button"
@export var arrow_margin : int = 20

@export var function_left : String = ""
@export var function_right : String = ""

@export var AUDIO_PLAYER : AudioStreamPlayer

var skipped_sound := false

func _ready() -> void:
	setup_text()
	hide_arrows()
	set_focus_mode(Control.FOCUS_ALL)


func _process(_delta : float) -> void:
	# live engine updating
	if Engine.is_editor_hint():
		setup_text()
		show_arrows()
	
	# pressing left and right to execute some stuff
	if has_focus():
		if Input.is_action_just_pressed("ui_left"):
			if function_left: 
				Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
				emit_signal("left_key_pressed")
		
		if Input.is_action_just_pressed("ui_right"):
			if function_right:
				emit_signal("right_key_pressed")
				Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])


func setup_text() -> void:
	$RichTextLabel.text = text
	# right arrow position is pretty much the size of the whole button
	custom_minimum_size.x = $ArrowRight.position.x


func show_arrows() -> void:
	# Get the center position of the TextureButton
	var center_x := size.x / 2
	var center_y := size.y / 2
	
	for arrow : Label in [$ArrowLeft, $ArrowRight]:
		arrow.visible = true
		arrow.position.y = center_y - arrow.size.y / 2
	
	$ArrowLeft.position.x = center_x - arrow_margin - $ArrowLeft.size.x / 2
	$ArrowRight.position.x = center_x + arrow_margin - $ArrowRight.size.x / 2
	
	if skipped_sound:
		Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_move"])


func hide_arrows() -> void:
	for arrow : Label in [$ArrowLeft, $ArrowRight]:
		arrow.visible = false


func _on_focus_entered() -> void:
	show_arrows()


func _on_focus_exited() -> void:
	hide_arrows()


func _on_mouse_entered() -> void:
	grab_focus()
