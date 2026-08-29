#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uPrismPower;

out vec4 fragColor;

// Spektral gökkuşağı rengi üretimi
vec3 spectralRainbow(float t) {
    vec3 c = vec3(
        0.5 + 0.5 * cos(6.28318 * (t + 0.00)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
    return c;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / max(uResolution.xy, vec2(1.0));
    vec2 centered = uv - 0.5;
    float dist = length(centered);
    float angle = atan(centered.y, centered.x);

    // 6-gen prizma eksenel kırılma açısı
    float hexFacet = cos(angle * 6.0 + uTime * 0.8) * 0.15;
    float prismPhase = dist * 3.5 + hexFacet + uTime * 0.35;

    // Spektral gökkuşağı dalgalanması
    vec3 rainbow = spectralRainbow(prismPhase);

    // Çekirdekte parlak kozmik mor-mavi ve beyaz ışıma
    vec3 cosmicIndigo = vec3(0.38, 0.15, 0.85);
    vec3 celestialCyan = vec3(0.20, 0.80, 0.95);
    vec3 crystalCore = mix(cosmicIndigo, celestialCyan, sin(uTime * 1.5 + dist * 5.0) * 0.5 + 0.5);

    // Prizma ve gökkuşağı harmanlaması
    vec3 col = mix(crystalCore, rainbow, 0.45 * uPrismPower);

    // Dönen prizmatik ışık şeritleri (caustics)
    float rays = max(0.0, sin(angle * 3.0 - uTime * 1.2 + dist * 6.0));
    rays = pow(rays, 4.0);
    col += vec3(0.9, 0.95, 1.0) * rays * 0.55;

    // Nabız gibi atan merkez aura
    float pulse = 0.8 + 0.2 * sin(uTime * 2.5);
    col *= pulse;

    // Altıgen sınır maskesi
    float alpha = clamp((1.0 - dist * 1.4) * 0.78, 0.0, 0.78);

    fragColor = vec4(col * alpha, alpha);
}
