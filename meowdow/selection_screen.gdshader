shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur_strength : hint_range(0.0, 10.0) = 4.0;

void fragment() {
	vec2 size = vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 uv = SCREEN_UV;

	vec4 color = vec4(0.0);

	color += texture(SCREEN_TEXTURE, uv + vec2(-blur_strength, 0.0) / size);
	color += texture(SCREEN_TEXTURE, uv + vec2( blur_strength, 0.0) / size);
	color += texture(SCREEN_TEXTURE, uv + vec2(0.0, -blur_strength) / size);
	color += texture(SCREEN_TEXTURE, uv + vec2(0.0,  blur_strength) / size);
	color += texture(SCREEN_TEXTURE, uv);

	COLOR = color / 5.0;
}