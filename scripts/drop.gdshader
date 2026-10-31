shader_type canvas_item;

// 'instance uniform' gives each node its own value on the same shared material
instance uniform float phase_offset = 0.0;

uniform float pulse_speed : hint_range(0.1, 30.0) = 16.755;
uniform float min_brightness : hint_range(0.0, 1.0) = 0.8;
uniform float max_brightness : hint_range(1.0, 3.0) = 1.4;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    float wave = 0.5 + 0.5 * sin(TIME * pulse_speed + phase_offset);
    float brightness = mix(min_brightness, max_brightness, wave);
    
    COLOR = vec4(tex_color.rgb * brightness * COLOR.rgb, tex_color.a * COLOR.a);
}