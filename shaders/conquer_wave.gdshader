shader_type canvas_item;

// Fetih Anı Dalga & Şok Dalgası Gölgelendiricisi (Conquer Shockwave VFX)
uniform float wave_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 wave_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // Altın/Neon Taç Rengi
uniform float wave_width : hint_range(0.01, 0.3) = 0.08;
uniform float wave_feather : hint_range(0.01, 0.2) = 0.04;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	
	// Dışa doğru genişleyen çembersel şok dalgası
	float ring = smoothstep(wave_progress - wave_width, wave_progress, dist) -
	             smoothstep(wave_progress, wave_progress + wave_feather, dist);
	
	ring = clamp(ring, 0.0, 1.0);
	float fade = 1.0 - wave_progress;
	
	vec4 base_color = texture(TEXTURE, UV);
	vec4 shock_glow = wave_color * (ring * fade * 2.5);
	
	COLOR = base_color + shock_glow;
}
