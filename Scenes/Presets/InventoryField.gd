extends Button

# not this is something extremely hacky. Shader that I wrote for combating white blowup
# works nice on the button, but it also makes the border go away.
# What are we doing here is not applying the icon directly onto the button, but applying it to the TextureRect.
# TextureRect has the shader applied onto it, and everything looks okay.
# I could have used TextureButton, but I want the default button look as base (for now at least)

var _icon_rect: TextureRect

var crt_blowdown : Dictionary = {
	"brightness_compensation" = 0.4,
	"white_preservation" = 0.9,
	"detail_boost" = 0.735,
}

var crt_off : Dictionary = {
	"brightness_compensation" = 0,
	"white_preservation" = 0,
	"detail_boost" = 0,
}

func _ready() -> void:
	Crt.connect("on_crt_change", _on_crt_change)

	_icon_rect = $TextureRect
	if _icon_rect:
		_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var misc_settings := ConfigHandler.load_misc_settings()

	if !misc_settings["crt_shader"]:
		_on_crt_change("off")
	else:
		_on_crt_change("on")

func icons_filter_settings(values: Dictionary) -> void:
	if _icon_rect and _icon_rect.material and _icon_rect.material is ShaderMaterial:
		var shader_material : ShaderMaterial = _icon_rect.material as ShaderMaterial

		for property_name : String in values.keys():
			var property_value : float = values[property_name]
			shader_material.set_shader_parameter(property_name, property_value)

# overriding the setter
func _set(property: StringName, value: Variant) -> bool:
	if property == "icon":
		_handle_icon_change(value)
		return true
	return false

func _handle_icon_change(new_icon: Texture2D) -> void:
	# skip setting button icon and set it on TextureRect
	if _icon_rect and new_icon:
		_icon_rect.texture = new_icon

func _on_crt_change(action: String) -> void:
	print("we got da signal ", action)
	if action == "off":
		icons_filter_settings(crt_off)
	elif action == "on":
		icons_filter_settings(crt_blowdown)
	pass
