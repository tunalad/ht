shader_type canvas_item;

uniform vec4 shadow_color; // Shadow color
uniform float shadow_offset_x; // Horizontal shadow offset
uniform float shadow_offset_y; // Vertical shadow offset

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 shadow_tex_color = texture(TEXTURE, UV + vec2(shadow_offset_x, shadow_offset_y));

    // Draw the shadow first
    COLOR = shadow_tex_color;
    // Then draw the original text on top
    COLOR += tex_color;
}

void vertex() {
    VERTEX.x += shadow_offset_x;
    VERTEX.y += shadow_offset_y;
}