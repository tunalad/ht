extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "Fade_to_black":
		on_transition_finished.emit()
		animation_player.play("Fade_to_normal")
	elif anim_name == "Fade_to_normal":
		color_rect.visible = false
	
	animation_player.speed_scale = 1

func transition(speed_scale : float = 1):
	color_rect.visible = true
	animation_player.speed_scale = speed_scale
	animation_player.play("Fade_to_black")

func fade_to_normal(speed_scale : float = 1):
	color_rect.visible = true
	animation_player.speed_scale = speed_scale
	animation_player.play("Fade_to_normal")
