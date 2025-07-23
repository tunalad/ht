extends CanvasLayer

signal on_crt_change(action: String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.visible = false


func toggle_crt() -> void:
	var misc_settings := ConfigHandler.load_misc_settings()

	print("we togglin")

	if !misc_settings["crt_shader"]:
		on_crt_change.emit("off")
		self.visible = false
	else:
		on_crt_change.emit("on")
		self.visible = true
