#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;

out vec4 fragColor;

// Basit donanım dostu 2D gürültü fonksiyonu
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbmLava(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < 3; ++i) {
        v += a * noise2D(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / max(uResolution.xy, vec2(1.0));
    
    // Merkezden radyal mesafe (Altıgen içi odaklı)
    vec2 centered = uv - 0.5;
    float dist = length(centered);

    // Yavaş akan magma akıntı vektörü
    vec2 flowDir = vec2(sin(uTime * 0.4) * 0.15, uTime * 0.25);
    vec2 p = uv * 6.0 + flowDir;

    // Çok katmanlı dalgalanma (FBM)
    float n1 = fbmLava(p);
    float n2 = fbmLava(p + vec2(n1 * 1.5, n1 * 1.2) - uTime * 0.1);
    float lava = smoothstep(0.32, 0.75, n2);

    // Renk Paleti:
    // Soğumuş volkanik bazalt kabuk: #1a0808
    // Akkor sıcak lav: #d9480f -> #f59f00
    // Çekirdek beyaz alev: #fff3bf
    vec3 darkCrust = vec3(0.12, 0.04, 0.04);
    vec3 hotOrange = vec3(0.92, 0.28, 0.05);
    vec3 yellowCore = vec3(1.0, 0.78, 0.15);
    vec3 whiteHot = vec3(1.0, 0.96, 0.75);

    vec3 col = mix(darkCrust, hotOrange, lava);
    col = mix(col, yellowCore, smoothstep(0.65, 0.85, n2));
    col = mix(col, whiteHot, smoothstep(0.85, 0.98, n2));

    // Sıcaklık nabzı
    float pulse = 0.85 + 0.15 * sin(uTime * 2.0 + dist * 8.0);
    col *= pulse * uIntensity;

    // Altıgen kenarlara doğru hafif volkanik sis koyulaşması
    float alpha = clamp((1.0 - dist * 1.35) * 0.85, 0.0, 0.85);

    fragColor = vec4(col * alpha, alpha);
}
