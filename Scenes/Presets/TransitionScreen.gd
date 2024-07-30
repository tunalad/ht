extends CanvasLayer

signal on_transition_finished

@onready var color_rect := $ColorRect
@onready var animation_player := $AnimationPlayer

var hold_time := 0.0

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name : String) -> void:
	if anim_name == "Fade_to_black":
		if hold_time > 0:
			await get_tree().create_timer(hold_time).timeout
		on_transition_finished.emit()
		animation_player.play("Fade_to_normal")
	elif anim_name == "Fade_to_normal":
		color_rect.visible = false
		
	animation_player.speed_scale = 1

func transition(duration: float = 1.0, hold: float = 0.0) -> void:
	color_rect.visible = true
	animation_player.speed_scale = animation_player.get_animation("Fade_to_black").length / duration
	animation_player.play("Fade_to_black")
	hold_time = hold

func fade_to_normal(speed_scale : float = 1) -> void:
	color_rect.visible = true
	animation_player.speed_scale = animation_player.get_animation("Fade_to_normal").length / speed_scale
	animation_player.play("Fade_to_normal")
