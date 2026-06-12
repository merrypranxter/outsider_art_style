// Outsider Art Style — Fragment Shader Stub
// Horror vacui, crayon texture, mark wobble, repeated figures, found ground

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;
uniform float u_text_density;
uniform float u_crayon_texture;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5); }
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * hash(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // Found ground (newspaper texture)
    float news = hash(floor(uv * vec2(40.0, 80.0))) * 0.3 + 0.7;
    vec3 ground = vec3(0.9, 0.88, 0.8) * news;
    
    // Crayon texture
    float crayon = fbm(uv * 200.0) * u_crayon_texture;
    
    // Repeated figure pattern
    vec2 rep = fract(uv * u_repeat_density) - 0.5;
    float figure = smoothstep(0.3, 0.0, length(rep));
    figure *= sin(u_time + uv.x * 10.0) * 0.5 + 0.5;
    
    // Mark wobble
    float wobble = hash(uv * 50.0) * u_mark_wobble;
    
    // Darger palette
    vec3 darger = vec3(1.0, 0.25, 0.2);
    vec3 wölfli = vec3(0.1, 0.1, 0.6);
    vec3 finster = vec3(0.2, 0.8, 0.2);
    
    vec3 col = mix(ground, darger + wobble, figure * u_horror_vacui);
    col += crayon * 0.1;
    col = mix(col, ground, u_ground_show * 0.5);
    
    gl_FragColor = vec4(col, 1.0);
}
