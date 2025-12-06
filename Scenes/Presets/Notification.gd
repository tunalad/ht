# Copyright (c) 2025 tunalad
# SPDX-License-Identifier: BSD-2-Clause
# See LICENSE file for details
extends Control

signal on_notify_finished

@onready var anim_player := $AnimationPlayer
@onready var label := $Label
@onready var timer := $Timer
@onready var sfx_player := $AudioStreamPlayer

@export var duration: int = 3


func _ready() -> void:
	z_index = 100
	sfx_player.stream = Global.sounds["notify"]
	anim_player.play("notify-off")


func notify(message: String) -> void:
	if !message:
		return

	$".".visible = true
	label.text = message

	sfx_player.play()
	anim_player.play("notify-in")
	timer.start(duration)


func notify_update(new_message: String) -> void:
	label.text = new_message


func _on_timer_timeout() -> void:
	anim_player.play_backwards("notify-in")
	timer.stop()
	on_notify_finished.emit()
