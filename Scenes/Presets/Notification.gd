extends Control

@onready var anim_player := $AnimationPlayer
@onready var label := $Label
@onready var timer := $Timer

@export var duration : int = 3

func _ready() -> void:
	z_index = 100
	anim_player.play("notify-off")


func notify(message : String) -> void:
	if !message:
		return
	
	print("doing the msg")
	
	label.text = message
	
	anim_player.play("notify-in")
	timer.start(duration)


func _on_timer_timeout() -> void:
	anim_player.play_backwards("notify-in")
	print("bbye")
	timer.stop()
