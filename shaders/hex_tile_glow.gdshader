shader_type canvas_item;

// Göktürk Sinematik & Brutalist Altıgen Kenar ve Derinlik Gölgelendiricisi
uniform vec4 base_tint : source_color = vec4(0.12, 0.14, 0.18, 1.0);
uniform vec4 border_glow_color : source_color = vec4(0.38, 0.78, 0.95, 1.0);
uniform float border_width : hint_range(0.0, 0.25) = 0.06;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.8;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.2;
uniform float hover_lift : hint_range(0.0, 1.0) = 0.0;
uniform bool is_owned = false;
uniform bool is_hovered = false;

void vertex() {
	// Z-ekseni mikro etkileşimi: Üzerine gelindiğinde veya seçildiğinde yukarı kalkış
	if (is_hovered) {
		VERTEX.y -= hover_lift * 8.0;
	}
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	
	// Altıgen mesafe metriği (Hexagonal SDF)
	vec2 p = abs(uv);
	float hex_dist = max(p.x * 0.866025 + p.y * 0.5, p.y);
	
	// Temel doku veya renk
	vec4 col = texture(TEXTURE, UV) * base_tint;
	
	// Kenar Glow Maskesi
	float edge_dist = smoothstep(0.48 - border_width, 0.50, hex_dist);
	float inner_edge = smoothstep(0.50, 0.52, hex_dist);
	float border_mask = edge_dist * (1.0 - inner_edge);
	
	// Dinamik Parıltı / Nefes Alma
	float pulse = 0.85 + 0.15 * sin(TIME * pulse_speed);
	vec4 glow = border_glow_color * (border_mask * glow_intensity * pulse);
	
	if (is_hovered) {
		glow *= 1.4;
		col += vec4(0.05, 0.05, 0.08, 0.0);
	}
	
	COLOR = col + glow;
}
