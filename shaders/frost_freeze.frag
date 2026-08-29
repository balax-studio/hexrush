#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uFrostProgress; // 0.0 (temiz) -> 1.0 (tamamen buz tutmuş)

out vec4 fragColor;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float voronoiIce(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float minDist = 1.0;

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = vec2(hash21(n + g), hash21(n + g + 13.7));
            vec2 r = g + o - f;
            float d = dot(r, r);
            minDist = min(minDist, d);
        }
    }
    return sqrt(minDist);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / max(uResolution.xy, vec2(1.0));
    vec2 centered = uv - 0.5;
    float dist = length(centered);

    // Dış kenarlardan merkeze doğru ilerleyen buzlanma eşiği
    float edgeFactor = smoothstep(0.1, 0.55, dist);
    float frostThreshold = clamp(uFrostProgress * 1.3 - (1.0 - edgeFactor) * 0.4, 0.0, 1.0);

    // Buz kristalleri dallanması
    vec2 iceCoord = uv * 9.0;
    float v1 = voronoiIce(iceCoord);
    float v2 = voronoiIce(iceCoord * 2.0 + vec2(uTime * 0.05, -uTime * 0.03));
    float crystal = (1.0 - v1) * 0.6 + (1.0 - v2) * 0.4;

    // Buz kütlesi maskesi
    float iceMask = smoothstep(1.0 - frostThreshold, 1.2 - frostThreshold * 0.8, crystal * edgeFactor);

    // Buzul Renk Paleti:
    // Derin buz mavisi: #0284c7 -> #38bdf8
    // Beyaz ayaz kırağısı: #f0f9ff
    // Işıltılı kristal parıltı: #ffffff
    vec3 deepIce = vec3(0.08, 0.42, 0.68);
    vec3 brightFrost = vec3(0.65, 0.88, 0.98);
    vec3 whiteGlint = vec3(1.0, 1.0, 1.0);

    vec3 col = mix(deepIce, brightFrost, crystal);

    // Güneş ışığında mikro-parıldama (sparkle)
    float sparkle = pow(max(0.0, sin(dot(uv, vec2(150.0, 150.0)) + uTime * 3.0)), 12.0) * 0.7;
    col += whiteGlint * sparkle * iceMask;

    float alpha = iceMask * clamp(uFrostProgress * 0.9, 0.0, 0.82);

    fragColor = vec4(col * alpha, alpha);
}
