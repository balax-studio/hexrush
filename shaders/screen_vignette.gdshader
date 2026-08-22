shader_type canvas_item;

// Sinematik Odak & Tokluk Gölgelendiricisi (Cinematic Vignette & Friction)
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.02, 0.03, 0.05, 1.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	// Kenarlara doğru yumuşak koyulaşma
	float vig = smoothstep(0.3, 0.75, dist) * vignette_intensity;
	
	COLOR = vec4(vignette_color.rgb, vig * vignette_opacity);
}
