extends Control

@export var menu_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	TransitionScreen.fade_to_normal(0.5)
	await get_tree().create_timer(5.0).timeout
	load_menu()

func _input(event):
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")) and DevConsole.visible == false:
		load_menu()

func load_menu():
	TransitionScreen.transition(0.5)
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(menu_scene)
