extends Button

# not this is something extremely hacky. Shader that I wrote for combating white blowup 
# works nice on the button, but it also makes the border go away. 
# What are we doing here is not applying the icon directly onto the button, but applying it to the TextureRect.
# TextureRect has the shader applied onto it, and everything looks okay.
# I could have used TextureButton, but I want the default button look as base (for now at least)

var _icon_rect: TextureRect

func _ready() -> void:
	_icon_rect = $TextureRect
	if _icon_rect:
		_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
