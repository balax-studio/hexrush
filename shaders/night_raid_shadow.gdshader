shader_type canvas_item;

// Gece Baskını Gölgeleri & Sisli Akıncılar Shader'ı
uniform vec4 shadow_color : source_color = vec4(0.08, 0.05, 0.15, 0.85);
uniform float speed : hint_range(0.5, 5.0) = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec2 uv = UV;
	float wave = sin(uv.x * 12.0 + TIME * speed) * cos(uv.y * 8.0 + TIME * speed * 0.7);
	float edge_dist = distance(uv, vec2(0.5));
	float alpha = smoothstep(0.5, 0.1, edge_dist) * intensity * (0.8 + 0.2 * wave);
	
	COLOR = vec4(shadow_color.rgb, shadow_color.a * alpha);
}
