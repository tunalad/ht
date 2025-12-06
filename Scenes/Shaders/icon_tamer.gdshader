shader_type canvas_item;
// DISCLAIMER: VIBECODED!!

// Parameters to combat the CRT shader
uniform float brightness_compensation : hint_range(0.0, 3.0) = 0.4;
uniform float white_preservation : hint_range(0.0, 1.0) = 0.9;
uniform float detail_boost : hint_range(0.0, 1.5) = 1;

// Shadow parameters
uniform float shadow_offset_x : hint_range(-20.0, 20.0) = 5.0;
uniform float shadow_offset_y : hint_range(-20.0, 20.0) = 5.0;
uniform float shadow_blur : hint_range(0.0, 10.0) = 2.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_alpha_threshold : hint_range(0.0, 1.0) = 0.1;

vec4 get_shadow_sample(vec2 uv, vec2 texture_size, sampler2D tex) {
    vec4 shadow = vec4(0.0);
    float blur_size = shadow_blur / texture_size.x;
    int samples = int(shadow_blur * 2.0) + 1;

    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_size;
            vec2 sample_uv = uv + vec2(shadow_offset_x, shadow_offset_y) / texture_size + offset;

            if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 && sample_uv.y >= 0.0 && sample_uv.y <= 1.0) {
                float alpha = texture(tex, sample_uv).a;
                if (alpha > shadow_alpha_threshold) {
                    float distance = length(offset);
                    float weight = exp(-distance * distance / (blur_size * blur_size));
                    shadow.a += weight * alpha;
                }
            }
        }
    }

    shadow.a = min(shadow.a, 1.0);
    shadow.rgb = shadow_color.rgb;
    shadow.a *= shadow_color.a;

    return shadow;
}

void fragment() {
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));

    // Get the original texture
    vec4 original_color = texture(TEXTURE, UV);

    // Apply your existing CRT compensation effects
    float luminance = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    float compensation_curve = mix(brightness_compensation, 1.0 + (brightness_compensation - 1.0) * white_preservation, luminance);
    vec3 compensated_color = original_color.rgb * compensation_curve;
    compensated_color = mix(compensated_color, (compensated_color - 0.5) * detail_boost + 0.5, 0.3);
    compensated_color = clamp(compensated_color, 0.0, 1.0);

    // Create the processed original texture
    vec4 processed_original = vec4(compensated_color, original_color.a);

    // Get the shadow
    vec4 shadow = get_shadow_sample(UV, texture_size, TEXTURE);

    // Combine shadow and processed original (shadow behind original)
    COLOR = mix(shadow, processed_original, processed_original.a);
}
