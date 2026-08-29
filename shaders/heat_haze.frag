#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uCenter;
uniform float uIntensity;

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
    float dist = length(st * 2.0);

    // Yükselen termal serap kırılması dalgaları
    float wave1 = sin(st.y * 32.0 - uTime * 2.5 + st.x * 12.0);
    float wave2 = cos(st.x * 24.0 + uTime * 1.8 - st.y * 8.0);
    float n = noise(st * 20.0 + vec2(0.0, -uTime * 0.8));

    float shimmer = (wave1 * 0.4 + wave2 * 0.3 + n * 0.3) * smoothstep(1.0, 0.2, dist);

    // Sıcaklık ışıması (Akkor turuncu ve amber sıcak hava aurası)
    vec3 heatOrange = vec3(0.96, 0.45, 0.12);
    vec3 hotGlow = vec3(1.0, 0.78, 0.25);

    vec3 col = mix(heatOrange, hotGlow, shimmer * 0.5 + 0.5);
    float alpha = clamp(shimmer * uIntensity * 0.45 * smoothstep(1.1, 0.3, dist), 0.0, 0.85);

    fragColor = vec4(col * alpha, alpha);
}
