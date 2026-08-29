#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uDioramaStrength; // 0.0 -> 1.0

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / max(uResolution.xy, vec2(1.0));
    vec2 centered = uv - 0.5;

    // Tilt-shift odak çizgisi (Merkez şerit net, üst ve alt kenarlar minyatür odak dışı)
    float focusBand = abs(centered.y);
    float dofBlur = smoothstep(0.18, 0.48, focusBand) * uDioramaStrength;

    // Yumuşak dairesel vinyet (Atmospheric Vignette)
    float vignette = 1.0 - dot(centered * 1.15, centered * 1.15);
    vignette = clamp(pow(vignette, 1.4), 0.0, 1.0);

    // Bozkır sıcaklık tonlaması (Color Grading: hafif kehribar ve derin koyu zeminler)
    vec3 warmTint = vec3(0.98, 0.95, 0.88);
    vec3 shadowColor = vec3(0.04, 0.06, 0.12);

    // Atmosferik parlaklık ve sis
    float horizonGlow = smoothstep(0.4, 0.0, uv.y) * 0.12 * uDioramaStrength;

    vec3 col = mix(shadowColor, warmTint, vignette);
    col += vec3(0.85, 0.92, 1.0) * horizonGlow;

    // Sadece ekran uzayı katmanı alfa harmanlaması
    float alpha = clamp((1.0 - vignette) * 0.45 + dofBlur * 0.35 + horizonGlow, 0.0, 0.65);

    fragColor = vec4(col * alpha, alpha);
}
