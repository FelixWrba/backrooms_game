shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec4 color = texture(screen_texture, UV);
	color += vec4((color.rgb - 0.5) * 0.3, 1.0);
	COLOR = color;
}