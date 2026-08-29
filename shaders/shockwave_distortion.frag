#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uCenter;
uniform float uProgress; // 0.0 to 1.0

out vec4 fragColor;

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 st = (coord - uCenter) / max(uResolution.x, uResolution.y);
    float dist = length(st * 2.2);

    // Genişleyen halka yarıçapı
    float waveRadius = uProgress * 1.6;
    float waveWidth = 0.15 * (1.0 - uProgress * 0.5);

    // Halka içindeki pik dalga yoğunluğu
    float diff = abs(dist - waveRadius);
    float ring = smoothstep(waveWidth, 0.0, diff);

    // Kromatik dispersiyon renkleri (Altın sarısı & Göksel Turkuaz rün parıltısı)
    vec3 runeGold = vec3(1.0, 0.85, 0.3);
    vec3 runeCyan = vec3(0.22, 0.74, 0.97);

    vec3 col = mix(runeGold, runeCyan, sin(dist * 18.0 - uTime * 4.0) * 0.5 + 0.5);

    // Dalga sönerken şeffaflaşır
    float alpha = ring * (1.0 - uProgress) * 0.75;

    fragColor = vec4(col * alpha, alpha);
}
