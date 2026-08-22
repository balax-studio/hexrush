shader_type canvas_item;

// Gündüz / Günbatımı / Gece Atmosferik Tonlama ve Pencere Parıltısı - Godot 4
uniform float cycle_progress : hint_range(0.0, 1.0) = 0.0; // 0.0: Gündüz, 0.35: Günbatımı, 0.70: Gece, 1.0: Şafak
uniform vec4 day_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 sunset_tint : source_color = vec4(1.08, 0.88, 0.72, 1.0);
uniform vec4 night_tint : source_color = vec4(0.42, 0.48, 0.72, 1.0);
uniform vec4 dawn_tint : source_color = vec4(0.92, 0.85, 0.95, 1.0);

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    vec4 scene_color = texture(TEXTURE, UV);
    vec4 current_ambient;
    
    // 4 Aşamalı gökyüzü renk geçişi
    if (cycle_progress < 0.3) {
        float t = cycle_progress / 0.3;
        current_ambient = mix(day_tint, sunset_tint, t);
    } else if (cycle_progress < 0.65) {
        float t = (cycle_progress - 0.3) / 0.35;
        current_ambient = mix(sunset_tint, night_tint, t);
    } else if (cycle_progress < 0.85) {
        float t = (cycle_progress - 0.65) / 0.20;
        current_ambient = mix(night_tint, dawn_tint, t);
    } else {
        float t = (cycle_progress - 0.85) / 0.15;
        current_ambient = mix(dawn_tint, day_tint, t);
    }
    
    // Hafif kenar karartması
    vec2 uv = UV - vec2(0.5);
    float dist = dot(uv, uv);
    float vig = clamp(1.0 - dist * vignette_strength, 0.0, 1.0);
    
    COLOR = scene_color * current_ambient * vig;
}
