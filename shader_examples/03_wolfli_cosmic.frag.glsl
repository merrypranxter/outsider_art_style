// 03_wolfli_cosmic.frag.glsl
// WÖLFLI COSMIC — Adolf Wölfli, confined to an asylum, created 45 volumes
// of autobiography, music, poetry, and cosmology.
// Every page packed. Every margin filled. Faces in every pattern.
//
// Aesthetic logic: WOLFLI_COSMIC palette. Concentric geometric structures.
// Musical notation motifs. Mandala-as-cosmology. The universe has a plan
// and Wölfli knows it — every circle labeled, every zone named.
// Dense rotational symmetry interrupted by narrative.
//
// Colors: #8B0000 (dark red), #DAA520 (gold), #191970 (midnight blue),
//         #228B22 (forest green), #F5DEB3 (wheat paper)

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;
uniform float u_text_density;
uniform float u_crayon_texture;

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

// Wolfli palette
vec3 wolfliColor(float t) {
    // wheat paper base, dark red, gold, midnight blue, forest green
    if (t < 0.25) return mix(vec3(0.961,0.871,0.702), vec3(0.545,0.000,0.000), t*4.0);
    if (t < 0.50) return mix(vec3(0.545,0.000,0.000), vec3(0.855,0.647,0.125), (t-0.25)*4.0);
    if (t < 0.75) return mix(vec3(0.855,0.647,0.125), vec3(0.098,0.098,0.439), (t-0.50)*4.0);
    return mix(vec3(0.098,0.098,0.439), vec3(0.133,0.545,0.133), (t-0.75)*4.0);
}

// Wölfli's faces — appear in every pattern, every margin
float wolfliface(vec2 p, float size) {
    float r = length(p);
    float face = 1.0 - smoothstep(size*0.9, size, r);
    // Eyes
    float eyeL = 1.0 - smoothstep(size*0.12, size*0.15, length(p - vec2(-size*0.28, size*0.1)));
    float eyeR = 1.0 - smoothstep(size*0.12, size*0.15, length(p - vec2( size*0.28, size*0.1)));
    // Nose dot
    float nose  = 1.0 - smoothstep(size*0.07, size*0.10, length(p - vec2(0.0, -size*0.08)));
    // Mouth (simple arc approximation)
    float mouthR = length(p - vec2(0.0, -size*0.32));
    float mouth  = 1.0 - smoothstep(size*0.05, size*0.08, abs(mouthR - size*0.22));
    mouth *= step(p.y, -size*0.25);  // lower half only
    return face * max(1.0 - eyeL - eyeR - nose, 0.0) + eyeL + eyeR + nose + mouth * 0.5;
}

// Concentric rings — the cosmological structure
float concentricRings(vec2 p, float n, float wobble) {
    float r = length(p);
    float angle = atan(p.y, p.x);
    float wobR = r + noise(vec2(angle * 3.0, r * 8.0)) * wobble;
    float rings = fract(wobR * n);
    return smoothstep(0.0, 0.15, rings) * (1.0 - smoothstep(0.85, 1.0, rings));
}

// Musical notation — Wölfli invented his own system
// Represented as horizontal staves with dot-notes
float musicalStave(vec2 uv, float y, float noteFreq) {
    float inStave = smoothstep(0.012, 0.008, abs(uv.y - y));
    // Note positions
    float noteX = mod(uv.x * noteFreq + hash(vec2(floor(uv.x * noteFreq), y*100.0)) * 0.5, 1.0);
    float noteCell = floor(uv.x * noteFreq);
    float noteY = y + (hash(vec2(noteCell, y*100.0+1.0)) - 0.5) * 0.04;
    float note = 1.0 - smoothstep(0.006, 0.010, length(uv - vec2(
        (noteCell + 0.5) / noteFreq, noteY)));
    return max(inStave, note);
}

// Rotational symmetry — Wölfli's mandalas
// k-fold symmetry applied to UV
vec2 kfoldSymmetry(vec2 p, float k) {
    float a = atan(p.y, p.x);
    float r = length(p);
    float segA = 6.28318 / k;
    a = mod(a, segA);
    if (a > segA * 0.5) a = segA - a;  // mirror within segment
    return r * vec2(cos(a), sin(a));
}

// Geometric border — square frames with triangular notches
float geometricBorder(vec2 p, float r, float wobble) {
    // Diamond shape
    float diamond = abs(p.x) + abs(p.y);
    float wobD = noise(vec2(atan(p.y,p.x) * 5.0, u_time * 0.1)) * wobble;
    return abs(diamond - r + wobD);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 p = (uv - 0.5) * vec2(aspect, 1.0);  // centered, aspect-corrected

    // Slow rotation — the cosmos turns
    float cosT = cos(u_time * 0.04);
    float sinT = sin(u_time * 0.04);
    vec2 rp = vec2(p.x * cosT - p.y * sinT, p.x * sinT + p.y * cosT);

    // Wheat paper ground
    float paperNoise = fbm(uv * 40.0) * 0.06;
    vec3 col = vec3(0.961 - paperNoise, 0.871 - paperNoise, 0.702 - paperNoise);

    // Primary cosmological structure — 8-fold symmetry
    float sym = 8.0 + u_repeat_density * 0.3;
    vec2 sp = kfoldSymmetry(rp, sym);

    // Concentric rings — zones of the cosmos, each inhabited
    float rings = concentricRings(rp, 12.0 + u_horror_vacui * 8.0, u_mark_wobble * 0.04);
    float ringZone = fract(length(rp) * 12.0);

    // Zone color — each ring has its color
    float ringIdx = floor(length(rp) * 12.0);
    vec3 ringColor = wolfliColor(fract(ringIdx * 0.13 + 0.07));
    col = mix(col, ringColor, rings * 0.7);

    // Radiating spokes
    float a = atan(sp.y, sp.x);
    float spoke = smoothstep(0.04, 0.01, abs(fract(a / (3.14159 / 4.0)) - 0.5));
    float spokeDecay = exp(-length(rp) * 3.0);
    col = mix(col, wolfliColor(fract(a * 0.3)), spoke * spokeDecay * 0.8);

    // Triangular grid overlay — Wölfli's preferred micro-pattern
    vec2 triUV = sp * (10.0 + u_repeat_density * 0.5);
    float triA = fract(triUV.x - triUV.y);
    float triB = fract(triUV.x + triUV.y);
    float triGrid = smoothstep(0.05, 0.0, min(triA, triB)) + 
                    smoothstep(0.95, 1.0, max(triA, triB));
    col = mix(col, vec3(0.545, 0.000, 0.000), triGrid * 0.5 * u_horror_vacui);

    // Faces in the margins — they're always watching
    float faceCount = 6.0;
    for (float fi = 0.0; fi < 6.0; fi++) {
        float fa = fi * 6.28318 / faceCount + u_time * 0.02;
        float fr = 0.35 + fi * 0.01;
        vec2 facePos = p - vec2(cos(fa), sin(fa)) * fr;
        float faceSize = 0.055 + noise(vec2(fi, 0.0)) * 0.02;
        float f = wolfliface(facePos, faceSize);
        float faceColor = fract(fi * 0.17 + 0.33);
        col = mix(col, wolfliColor(faceColor), f * 0.9);
    }

    // Central mandala — the self at the center of the universe
    vec2 cp = kfoldSymmetry(rp, 12.0);
    float centralR = length(rp);
    float centralPattern = noise(cp * (20.0 + u_repeat_density) + u_time * 0.02) > 0.5 ? 1.0 : 0.0;
    centralPattern *= smoothstep(0.25, 0.05, centralR);
    col = mix(col, vec3(0.855, 0.647, 0.125), centralPattern * 0.9); // gold center

    // Musical staves around the outer ring
    for (float si = 0.0; si < 4.0; si++) {
        float staveY = 0.12 + si * 0.08;
        // Convert to ring coordinates — staves become arcs
        float staveR = staveY * 1.8;
        float ringStave = smoothstep(0.006, 0.003, abs(length(rp) - staveR));
        col = mix(col, vec3(0.098, 0.098, 0.439), ringStave * 0.7 * u_text_density);
        
        // Note-like dots on the stave
        float noteAngle = mod(atan(rp.y, rp.x) + u_time * 0.01, 6.28318);
        float noteDensity = 20.0 + u_repeat_density;
        float noteSeg = fract(noteAngle * noteDensity / 6.28318);
        float notePulse = step(0.88, hash(vec2(floor(noteAngle * noteDensity / 6.28318), si)));
        float noteR = staveR + (hash(vec2(floor(noteAngle * noteDensity / 6.28318), si+0.5)) - 0.5) * 0.05;
        float noteDot = smoothstep(0.012, 0.005, abs(length(rp) - noteR));
        noteDot *= notePulse;
        col = mix(col, vec3(0.855, 0.647, 0.125), noteDot * u_text_density);
    }

    // Geometric diamond borders
    for (float bi = 0.0; bi < 5.0; bi++) {
        float br = 0.15 + bi * 0.09;
        float gBorder = geometricBorder(rp, br, u_mark_wobble * 0.008);
        col = mix(col, wolfliColor(fract(bi * 0.2)), 
                  (1.0 - smoothstep(0.003, 0.012, gBorder)) * 0.8);
    }

    // Text fill in outer regions
    if (u_text_density > 0.0) {
        float outerZone = smoothstep(0.42, 0.48, length(rp));
        float lineH = 0.016;
        float lineY = mod(uv.y, lineH);
        float onLine = step(lineH*0.3, lineY) * step(lineY, lineH*0.8);
        float cid = hash(vec2(floor(uv.x * 90.0), floor(uv.y / lineH)));
        float charF = step(0.1, mod(uv.x * 90.0, 1.0)) * step(mod(uv.x*90.0,1.0), 0.6+cid*0.3);
        float txt = onLine * charF * step(0.3, cid);
        col = mix(col, vec3(0.098, 0.098, 0.439), txt * u_text_density * outerZone * 0.7);
    }

    // Crayon/pencil texture
    if (u_crayon_texture > 0.0) {
        float angle = atan(rp.y, rp.x) + 3.14159 * 0.25;
        vec2 cDir = vec2(cos(angle), sin(angle));
        vec2 cPerp = vec2(-cDir.y, cDir.x);
        float cStroke = pow(abs(fract(dot(uv, cPerp) * 150.0) - 0.5)*2.0, 5.0);
        float cGrain = noise(uv * 250.0) * 0.4 + 0.6;
        col *= 1.0 - cStroke * cGrain * u_crayon_texture * 0.2;
    }

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
