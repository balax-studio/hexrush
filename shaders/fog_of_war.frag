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

    // Neo-Brutalist Fog Palette (#060913 to #0f172a / #1e293b with subtle blue tint)
    vec3 deepDark = vec3(0.039, 0.059, 0.098); // #0a0f19
    vec3 mistGlow = vec3(0.118, 0.161, 0.231); // #1e293b
    vec3 borderAura = vec3(0.22, 0.74, 0.97);  // #38bdf8 sky blue hint

    vec3 col = mix(deepDark, mistGlow, clamp(f * f * 4.0, 0.0, 1.0));
    
    // Radial boundary fade
    float dist = length(st * 2.0);
    float edgeGlow = smoothstep(0.7, 0.95, dist) * (1.0 - smoothstep(0.95, 1.1, dist));
    col += borderAura * edgeGlow * 0.45;

    float finalAlpha = clamp(uAlpha * (0.88 + 0.12 * f), 0.0, 1.0);
    fragColor = vec4(col * finalAlpha, finalAlpha);
}
