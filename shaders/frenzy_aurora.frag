#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / max(uResolution.xy, vec2(1.0));
    vec2 centered = uv - 0.5;
    float dist = length(centered);
    float angle = atan(centered.y, centered.x);

    // Dönen güneş ışınları (Toy Coşkusu şavkı)
    float sunRays = sin(angle * 12.0 + uTime * 2.2) * 0.5 + 0.5;
    sunRays = pow(sunRays, 3.0);

    // Dışarı doğru yayılan şok dalgası halkaları
    float ringPhase = fract(uTime * 0.8 - dist * 2.0);
    float ring = smoothstep(0.0, 0.15, ringPhase) * smoothstep(0.4, 0.15, ringPhase);

    // Altın - Amber Toy Coşkusu Renk Paleti:
    // Derin kehribar: #b45309
    // Parlak altın sarısı: #facc15
    // Akkor beyaz güneş: #fef08a
    vec3 deepAmber = vec3(0.85, 0.38, 0.05);
    vec3 brightGold = vec3(1.0, 0.82, 0.12);
    vec3 whiteSolar = vec3(1.0, 0.98, 0.70);

    vec3 col = mix(deepAmber, brightGold, sunRays * 0.7 + ring * 0.3);
    col = mix(col, whiteSolar, max(0.0, 1.0 - dist * 2.2));

    // Nabız ve güç çarpanı
    float pulse = 0.9 + 0.25 * sin(uTime * 4.0);
    col *= pulse * uIntensity;

    // Yumuşak radyal kenar sönümlenmesi
    float alpha = clamp((1.0 - dist * 1.5) * 0.82 * uIntensity, 0.0, 0.82);

    fragColor = vec4(col * alpha, alpha);
}
