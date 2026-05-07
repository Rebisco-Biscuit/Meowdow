shader_type canvas_item;

uniform float glow_strength : hint_range(0.0, 5.0) = 2.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;

    float edge_x = smoothstep(0.0, 0.08, UV.x) * smoothstep(1.0, 0.92, UV.x);
    float edge_y = smoothstep(0.0, 0.08, UV.y) * smoothstep(1.0, 0.92, UV.y);
    float border = 1.0 - (edge_x * edge_y);

    vec4 glow = glow_color * glow_strength * border * pulse;
    COLOR = tex + glow;
}