extends Button

@onready var shadow_label = $ShadowLabel

func _ready():
	shadow_label.z_index = -1
	shadow_label.text = text
	shadow_label.position = Vector2(0, 0) # Adjust offset as needed
	shadow_label.modulate = Color(0, 0, 0, 0.5) # Set shadow color and transparency

# Example function to update button text and shadow dynamically
func update_button_text(new_text):
	text = new_text
	shadow_label.text = text
