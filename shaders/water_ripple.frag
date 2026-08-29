#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uCenter;
uniform float uAlpha;
uniform float uIsNight;

out vec4 fragColor;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 st = (coord - uCenter) / max(uResolution.x, uResolution.y);

    // Multi-octave wave ripples (Huzurlu ve dingin su dalgalanması)
    float wave1 = sin(st.x * 24.0 + uTime * 0.85 + st.y * 12.0) * 0.5 + 0.5;
    float wave2 = cos(st.y * 28.0 - uTime * 0.70 + st.x * 8.0) * 0.5 + 0.5;
    float n = noise(st * 16.0 + vec2(uTime * 0.12, -uTime * 0.08));

    float wavePattern = (wave1 * 0.4 + wave2 * 0.3 + n * 0.3);

    // Neo-Brutalist Deep Water Palette
    vec3 waterDeep = vec3(0.012, 0.282, 0.443);   // #034871 Deep Cyan/Navy
    vec3 waterShallow = vec3(0.055, 0.541, 0.741); // #0e8abd Bright Aqua
    vec3 foamColor = vec3(0.678, 0.902, 0.988);   // #ade6fc Shore foam

    if (uIsNight > 0.5) {
        waterDeep = vec3(0.008, 0.122, 0.231);
        waterShallow = vec3(0.024, 0.263, 0.412);
        foamColor = vec3(0.243, 0.490, 0.655);
    }

    vec3 col = mix(waterDeep, waterShallow, wavePattern);

    // Highlight crests & foam
    if (wavePattern > 0.75) {
        float foamIntensity = smoothstep(0.75, 0.88, wavePattern);
        col = mix(col, foamColor, foamIntensity * 0.8);
    }

    float finalAlpha = clamp(uAlpha * 0.95, 0.0, 1.0);
    fragColor = vec4(col * finalAlpha, finalAlpha);
}
