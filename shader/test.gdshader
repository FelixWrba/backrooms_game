shader_type canvas_item;
render_mode unshaded, blend_add;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float bloom_threshold : hint_range(0.0, 2.0) = 1.0;
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float blur_radius : hint_range(0.5, 3.0) = 1.5;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 texel = blur_radius / vec2(textureSize(screen_texture, 0));

    // Center sample
    vec3 col = texture(screen_texture, uv).rgb;

    // Bright-pass threshold
    col = max(col - vec3(bloom_threshold), vec3(0.0));

    // Kawase-style blur (4 taps only — mobile friendly)
    col += texture(screen_texture, uv + vec2( texel.x,  texel.y)).rgb;
    col += texture(screen_texture, uv + vec2(-texel.x,  texel.y)).rgb;
    col += texture(screen_texture, uv + vec2( texel.x, -texel.y)).rgb;
    col += texture(screen_texture, uv + vec2(-texel.x, -texel.y)).rgb;

    col *= 0.2; // normalize samples
	
    COLOR = vec4(col * bloom_intensity, 1.0);
}
