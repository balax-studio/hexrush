#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uCenter;
uniform float uAlpha;
uniform float uSeed;

out vec4 fragColor;

// Procedural 2D Hash & Noise
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21) + uSeed * 0.137);
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
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 4; ++i) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 st = (coord - uCenter) / max(uResolution.x, uResolution.y);
    
    // Animate coordinates (Huzurlu ve sakin sis dalgalanması)
    vec2 q = vec2(fbm(st + 0.012 * uTime), fbm(st + vec2(1.0)));
    vec2 r = vec2(fbm(st + 1.0 * q + vec2(1.7, 9.2) + 0.035 * uTime), fbm(st + 1.0 * q + vec2(8.3, 2.8) + 0.028 * uTime));
    float f = fbm(st + r);

    // Neo-Brutalist Deep Basalt Void Palette (#020617 to #0a0f1d)
    vec3 deepDark = vec3(0.008, 0.024, 0.055); // #020617
    vec3 mistGlow = vec3(0.025, 0.045, 0.080); // #070b14

    vec3 col = mix(deepDark, mistGlow, clamp(f * f * 2.5, 0.0, 1.0));
    
    // Solid opaque basalt surface (Zero see-through artifacts)
    fragColor = vec4(col, 1.0);
}
