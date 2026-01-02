shader_type canvas_item;
render_mode unshaded, blend_add;

uniform float aberration: hint_range(0.0, 0.01) = 0.002;

uniform float bloom_threshold : hint_range(0.0, 2.0) = 1.0;
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float blur_radius : hint_range(0.5, 3.0) = 1.5;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Base color
    vec4 color = texture(screen_texture, uv);

	// Bloom
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
    color += vec4(col * bloom_intensity, 1.0);

    // --- Chromatic aberration ---
	float x = abs(UV.x-.5)*2.0;
	float y = abs(UV.y-.5)*2.0;
    vec2 offset = vec2(x, y) * aberration;
    float r = texture(screen_texture, uv + offset).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - offset).b;
    color += vec4(r, g, b, 1.0);

    // --- Noise ---
    float noise = fract(sin(dot(uv + TIME, vec2(12.9898,78.233))) * 43758.5453);
    color.rgb += (noise - 0.5) * 0.05;

	COLOR = color;
}
