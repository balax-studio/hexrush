shader_type canvas_item;

// Dinamik Savaş Sisi (Fog of War) - Godot 4 CanvasItem
uniform vec4 fog_color : source_color = vec4(0.06, 0.09, 0.16, 0.85);
uniform float fog_density : hint_range(0.0, 1.0) = 0.75;
uniform float time_speed : hint_range(0.05, 1.0) = 0.15;
uniform float noise_scale : hint_range(1.0, 20.0) = 6.0;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < 4; ++i) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV;
    vec2 motion = vec2(TIME * time_speed * 0.5, TIME * time_speed * 0.3);
    float n = fbm(uv * noise_scale + motion);
    
    // Altıgen sınır yumuşatması (hexagonal vignette)
    vec2 d = abs(uv - vec2(0.5));
    float edge = max(d.x * 0.866 + d.y * 0.5, d.y);
    float alpha_edge = smoothstep(0.48, 0.35, edge);
    
    COLOR = vec4(fog_color.rgb, fog_color.a * (0.5 + 0.5 * n) * fog_density * (1.0 - alpha_edge));
}
