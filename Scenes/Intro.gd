extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	TransitionScreen.fade_to_normal()

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
