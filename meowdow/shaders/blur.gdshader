shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 3.0) = 1.0;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE * blur_amount;
	vec4 color = vec4(0.0);

	color += texture(TEXTURE, UV + vec2(-2.0, -2.0) * ps) * 0.0625;
	color += texture(TEXTURE, UV + vec2(-1.0, -2.0) * ps) * 0.125;
	color += texture(TEXTURE, UV + vec2( 0.0, -2.0) * ps) * 0.0625;
	color += texture(TEXTURE, UV + vec2(-2.0, -1.0) * ps) * 0.125;
	color += texture(TEXTURE, UV + vec2(-1.0, -1.0) * ps) * 0.25;
	color += texture(TEXTURE, UV + vec2( 0.0, -1.0) * ps) * 0.125;
	color += texture(TEXTURE, UV + vec2(-2.0,  0.0) * ps) * 0.0625;
	color += texture(TEXTURE, UV + vec2(-1.0,  0.0) * ps) * 0.125;
	color += texture(TEXTURE, UV + vec2( 0.0,  0.0) * ps) * 0.0625;

	COLOR = color;
}