// 09_crayon_field.frag.glsl
// CRAYON FIELD — Pure mark-making study.
// The crayon in the hand. The wax. The paper.
// Direction varies. Pressure varies. Colors overlap.
// This is the most basic element — the individual stroke.
//
// Aesthetic logic: multiple layers of directional crayon strokes.
// Each layer has its color, direction, pressure pattern.
// Layering creates visual mixing (crayon doesn't blend, it overlaps).
// The CRAYON_BOX palette — primary and secondary school colors.
// Waxy grain, parallel directional texture, irregular pressure.
//
// References: early outsider work before figures emerge —
//             the pure mark before the image arrives,
//             "automatic" work where the hand just moves.

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;
uniform float u_text_density;
uniform float u_crayon_texture;   // key — controls crayon layer intensity

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p); vec2 f=fract(p); vec2 u=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),u.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),u.x),u.y);
}
float fbm(vec2 p) {
    float v=0.0,a=0.5;
    for(int i=0;i<5;i++){v+=a*noise(p);p*=2.1;a*=0.5;}
    return v;
}

// A single crayon layer
// direction: angle of strokes
// frequency: how many strokes per unit
// color: crayon color
// pressure: overall layer intensity
// wobble: stroke waviness
struct CrayonLayer {
    float direction;
    float frequency;
    vec3 color;
    float pressure;
    float offset;
};

float crayonStroke(vec2 uv, float direction, float frequency, float wobble) {
    // Direction vector and perpendicular
    vec2 dir = vec2(cos(direction), sin(direction));
    vec2 perp = vec2(-dir.y, dir.x);
    
    // Add wobble to direction (slight variation along stroke)
    float along = dot(uv, dir);
    float waveWobble = sin(along * 3.0 + noise(uv * 5.0) * 6.28) * wobble * 0.008;
    float waveWobble2 = noise(uv * 20.0) * wobble * 0.010;
    
    // Stroke position across perpendicular direction
    float across = dot(uv, perp) + waveWobble + waveWobble2;
    
    // Regular stroke lines
    float strokePos = fract(across * frequency);
    
    // Stroke width varies (pressure)
    float pressureVar = noise(uv * 8.0) * 0.5 + 0.5;
    float halfWidth = (0.08 + pressureVar * 0.12) / frequency;
    
    // Stroke intensity — waxy center, feathered edge
    float strokeDist = abs(strokePos - 0.5) * 2.0 / frequency;
    float strokeIntensity = 1.0 - smoothstep(halfWidth * 0.5, halfWidth, strokeDist);
    
    // Grain along stroke direction (waxy texture)
    float grain = noise(uv * vec2(200.0 * abs(dir.x) + 50.0, 200.0 * abs(dir.y) + 50.0));
    float waxGrain = pow(grain, 1.5) * 0.5 + 0.5;
    
    // Pressure trail — heavier at start/end of strokes
    float pressureTrail = 0.6 + sin(along * 15.0 + noise(vec2(along, 0.0) * 3.0) * 6.28) * 0.3;
    pressureTrail = clamp(pressureTrail, 0.3, 1.0);
    
    return strokeIntensity * waxGrain * pressureVar * pressureTrail;
}

// Paper texture — crayon sits on paper grain
float paperGrain(vec2 uv) {
    float fine = noise(uv * 400.0) * 0.3;
    float medium = noise(uv * 120.0) * 0.15;
    float coarse = noise(uv * 40.0) * 0.08;
    return 1.0 - (fine + medium + coarse);
}

// Crayon color mixing — wax-on-wax creates optical mix, not pigment mix
// Crayon Box palette: red, blue, gold, green, pink, brown
vec3 crayonBoxColor(float t) {
    float t5 = mod(t, 1.0) * 6.0;
    if (t5 < 1.0) return mix(vec3(1.000, 0.141, 0.000), vec3(0.000, 0.278, 0.671), fract(t5));
    if (t5 < 2.0) return mix(vec3(0.000, 0.278, 0.671), vec3(1.000, 0.843, 0.000), fract(t5));
    if (t5 < 3.0) return mix(vec3(1.000, 0.843, 0.000), vec3(0.133, 0.545, 0.133), fract(t5));
    if (t5 < 4.0) return mix(vec3(0.133, 0.545, 0.133), vec3(1.000, 0.412, 0.706), fract(t5));
    if (t5 < 5.0) return mix(vec3(1.000, 0.412, 0.706), vec3(0.545, 0.271, 0.075), fract(t5));
    return mix(vec3(0.545, 0.271, 0.075), vec3(1.000, 0.141, 0.000), fract(t5));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y) / aspect;

    // Paper ground — cream/off-white
    float paper = paperGrain(uvA);
    float paperAge = fbm(uvA * 15.0) * 0.07;
    vec3 col = vec3(0.96, 0.93, 0.82) * paper * (1.0 - paperAge * 0.3);

    // Slightly warmer paper in ground mode
    if (u_ground_show > 0.0) {
        col = mix(col, vec3(0.88, 0.80, 0.65) * paper, u_ground_show * 0.5);
    }

    float wobble = u_mark_wobble;
    float layers = u_crayon_texture;
    
    // Number of stroke layers — more with higher horror_vacui
    float numLayers = 3.0 + u_horror_vacui * 5.0;
    
    // Define crayon layers with their properties
    // Each layer: direction, frequency, color index, pressure
    
    // Layer angles — vary over time slightly (the artist rotates the paper)
    float t0 = u_time * 0.005;
    
    // Layer 1: Primary horizontal-ish strokes
    float dir1 = 0.10 + sin(t0) * 0.05;
    float stroke1 = crayonStroke(uvA, dir1, 14.0 + u_repeat_density * 0.3, wobble);
    vec3 col1 = crayonBoxColor(0.0); // red
    col = mix(col, col1, stroke1 * layers * 0.75 * (fbm(uvA * 1.5) * 0.6 + 0.2));

    if (numLayers < 2.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 2: Blue, perpendicular-ish
    float dir2 = 1.48 + cos(t0 * 1.3) * 0.08;
    float stroke2 = crayonStroke(uvA, dir2, 12.0 + u_repeat_density * 0.2, wobble * 0.8);
    vec3 col2 = crayonBoxColor(0.167); // blue
    col = mix(col, col2, stroke2 * layers * 0.65 * (fbm(uvA * 2.0 + 1.0) * 0.5 + 0.25));

    if (numLayers < 3.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 3: Yellow, diagonal
    float dir3 = 0.785 + sin(t0 * 0.7) * 0.06;
    float stroke3 = crayonStroke(uvA, dir3, 10.0 + u_repeat_density * 0.15, wobble * 1.2);
    vec3 col3 = crayonBoxColor(0.333); // gold
    col = mix(col, col3, stroke3 * layers * 0.55 * (fbm(uvA * 1.8 + 2.0) * 0.7 + 0.15));

    if (numLayers < 4.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 4: Green, counter-diagonal
    float dir4 = -0.785 + cos(t0 * 0.9) * 0.07;
    float stroke4 = crayonStroke(uvA, dir4, 16.0, wobble * 0.9);
    vec3 col4 = crayonBoxColor(0.500); // green
    col = mix(col, col4, stroke4 * layers * 0.50 * (fbm(uvA * 2.5 + 3.0) * 0.6 + 0.20));

    if (numLayers < 5.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 5: Pink, steeper diagonal
    float dir5 = 0.3 + sin(t0 * 1.1) * 0.05;
    float stroke5 = crayonStroke(uvA, dir5, 18.0, wobble * 1.1);
    vec3 col5 = crayonBoxColor(0.667); // pink
    col = mix(col, col5, stroke5 * layers * 0.45 * (fbm(uvA * 3.0 + 4.0) * 0.5 + 0.25));

    if (numLayers < 6.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 6: Brown, nearly horizontal
    float dir6 = 0.05 + cos(t0 * 0.8) * 0.04;
    float stroke6 = crayonStroke(uvA, dir6, 22.0, wobble * 0.7);
    vec3 col6 = crayonBoxColor(0.833); // brown
    col = mix(col, col6, stroke6 * layers * 0.40 * (fbm(uvA * 2.2 + 5.0) * 0.7 + 0.10));

    if (numLayers < 7.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 7: Overlaid dense hatching (maximum horror vacui)
    float dir7 = 1.05;
    float stroke7 = crayonStroke(uvA, dir7, 26.0, wobble * 1.5);
    vec3 col7 = crayonBoxColor(0.15); // slightly different blue
    col = mix(col, col7, stroke7 * layers * 0.35 * u_horror_vacui);

    if (numLayers < 8.0) { gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0); return; }

    // Layer 8: Final dense red over everything
    float dir8 = 0.52;
    float stroke8 = crayonStroke(uvA, dir8, 30.0, wobble * 1.3);
    col = mix(col, vec3(0.85, 0.05, 0.05), stroke8 * layers * 0.30 * u_horror_vacui);

    // Border — crayon drawn frame
    vec2 bEdge = min(uv, 1.0 - uv);
    float borderW = 0.02;
    float border = 1.0 - smoothstep(borderW * 0.5, borderW, min(bEdge.x, bEdge.y));
    float borderWobble = noise(uv * 20.0) * u_mark_wobble * 0.008;
    border = 1.0 - smoothstep(borderW * 0.5 - borderWobble, borderW + borderWobble, min(bEdge.x, bEdge.y));
    col = mix(col, vec3(0.08, 0.04, 0.01), border * 0.8);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
