shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Base color
    vec4 color = texture(screen_texture, uv);

    // --- Bloom ---
    vec3 bloom = vec3(color.r * 0.3, 0.0, color.b * 0.3);
    color.rgb += bloom;

    // --- Chromatic aberration ---
    float offset = 0.002;
    float r = texture(screen_texture, uv + vec2(offset, 0)).r;
    float g = color.g;
    float b = texture(screen_texture, uv - vec2(offset, 0)).b;
    color.rgb = vec3(r, g, b);

    // --- Noise ---
    float noise = fract(sin(dot(uv + TIME, vec2(12.9898,78.233))) * 43758.5453);
    color.rgb += (noise - 0.5) * 0.05;

    COLOR = color;
}
