// 01_horror_vacui.frag.glsl
// HORROR VACUI — Every space filled. Empty space is anxiety.
// The surface panics when it is not covered.
//
// Aesthetic logic: Recursive subdivision until coverage exceeds threshold.
// Borders within borders. Pattern fills every void.
// No negative space exists. Every pixel is claimed.
//
// References: Emma Kunz's geometric grids, Wölfli's margins,
//             Darger's battle scenes with no sky visible.

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;   // 0.0–1.0 fill drive (use 0.85–1.0)
uniform float u_mark_wobble;    // 0.0–0.3 stroke variation
uniform float u_repeat_density; // 1.0–50.0 figure repetition
uniform float u_ground_show;    // 0.0–1.0 substrate visibility
uniform float u_text_density;   // 0.0–1.0 text-as-texture
uniform float u_crayon_texture; // 0.0–1.0 waxy stroke

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i), hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), u.x), u.y);
}

float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for(int i=0;i<5;i++){ v+=a*noise(p); p*=2.1; a*=0.5; }
    return v;
}

// Hatching in a given direction
float hatch(vec2 uv, float angle, float freq, float thickness) {
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 perp = vec2(-dir.y, dir.x);
    float d = dot(uv, perp) * freq;
    float line = abs(fract(d) - 0.5);
    float wobWob = noise(uv * 40.0) * u_mark_wobble * 3.0;
    return 1.0 - smoothstep(thickness - wobWob, thickness + 0.005, line);
}

// Star / cross motif — primary fill unit
float crossFill(vec2 p) {
    float w = 0.06;
    float h = step(abs(p.x), w) * step(abs(p.y), 0.42);
    float v = step(abs(p.y), w) * step(abs(p.x), 0.42);
    return max(h, v);
}

float starFill(vec2 p, float r) {
    float a = atan(p.y, p.x);
    float sr = 0.5 + 0.5 * cos(a * 8.0);
    return 1.0 - smoothstep(r*(0.4+0.6*sr)*0.9, r*(0.4+0.6*sr), length(p));
}

// Diamond grid fill
float diamondGrid(vec2 uv, float density) {
    vec2 d = uv * density;
    vec2 cell = floor(d + 0.5);
    vec2 local = d - cell;
    float rot45 = abs(local.x) + abs(local.y);
    float wobW = noise(cell * 7.1) * u_mark_wobble;
    return 1.0 - smoothstep(0.38 - wobW, 0.42, rot45);
}

// Recursive fill: each level tiles a different motif
float recursiveFill(vec2 uv, float level) {
    float fill = 0.0;
    
    // Level 0: large diamonds
    fill = max(fill, diamondGrid(uv, 4.0 + level * 2.0));
    
    // Level 1: crossing hatch lines
    float h1 = hatch(uv, 0.0, 18.0 + level * 8.0, 0.12 - level * 0.02);
    float h2 = hatch(uv, 1.5708, 18.0 + level * 8.0, 0.12 - level * 0.02);
    fill = max(fill, max(h1, h2) * (0.4 + level * 0.2));
    
    // Level 2: star field
    vec2 sc = fract(uv * (6.0 + level * 3.0)) - 0.5;
    fill = max(fill, starFill(sc, 0.45 - level * 0.05));
    
    // Level 3: crosses in remaining void
    vec2 xc = fract(uv * (10.0 + level * 5.0)) - 0.5;
    fill = max(fill, crossFill(xc) * (0.6 + level * 0.3));
    
    return fill;
}

// Border system — frames within frames
float nestedBorder(vec2 uv, float n) {
    float result = 0.0;
    float gap = 0.025;
    float thick = 0.008 + u_mark_wobble * 0.005;
    for (float i = 0.0; i < n; i++) {
        float off = i * gap;
        vec2 inner = (uv - off) / (1.0 - 2.0 * off);
        if (any(lessThan(inner, vec2(0.0))) || any(greaterThan(inner, vec2(1.0)))) continue;
        vec2 b = min(inner, 1.0 - inner);
        float bVal = 1.0 - smoothstep(thick - u_mark_wobble*0.01, thick + 0.005, min(b.x, b.y));
        result = max(result, bVal);
    }
    return result;
}

// Text columns — prayer or compulsion, both look the same
float textColumns(vec2 uv) {
    if (u_text_density < 0.01) return 0.0;
    float lines = 60.0 * u_text_density;
    float lineY = mod(uv.y * lines, 1.0);
    float onLine = step(0.35, lineY) * step(lineY, 0.80);
    float charW = 0.012;
    float cid = hash(vec2(floor(uv.x / charW), floor(uv.y * lines)));
    float charFill = step(charW*0.1, mod(uv.x, charW)) * step(mod(uv.x, charW), charW * (0.5 + cid*0.4));
    return onLine * charFill * step(0.35, cid);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    uv.x *= aspect;
    uv /= aspect;  // normalize to square

    // Wobble the UV slightly — the hand trembles
    vec2 wuv = uv;
    wuv += (vec2(noise(uv * 30.0 + vec2(u_time*0.1, 0.0)),
                 noise(uv * 30.0 + vec2(0.0, u_time*0.1))) - 0.5) * u_mark_wobble * 0.02;

    // Ground — aged paper
    float paperAge = noise(wuv * 50.0) * 0.06;
    vec3 ground = vec3(0.92 - paperAge, 0.89 - paperAge, 0.78 - paperAge);

    // Fill layers — each adds density
    float density = u_horror_vacui;
    float fill0 = recursiveFill(wuv, 0.0);
    float fill1 = recursiveFill(wuv * 1.618 + 0.3, 1.0);
    float fill2 = recursiveFill(wuv * 2.618 + 0.7, 2.0);
    float totalFill = mix(fill0, 1.0, density * 0.3);
    totalFill = max(totalFill, fill1 * density * 0.8);
    totalFill = max(totalFill, fill2 * density * 0.6);

    // Nested borders — the obsessive frame
    float borders = nestedBorder(uv, 7.0);
    totalFill = max(totalFill, borders);

    // Diagonal hatch in fills
    float diagH = hatch(wuv, 0.7854, 40.0, 0.15);
    float diagH2 = hatch(wuv, -0.7854, 40.0, 0.15);
    float crossHatch = max(diagH, diagH2) * 0.5;
    totalFill = max(totalFill, crossHatch * density);

    // Palette — rotates through zones based on position and fbm
    float zone = fbm(wuv * 3.0 + u_time * 0.05);
    vec3 c0 = vec3(1.0, 0.25, 0.21);   // Darger red
    vec3 c1 = vec3(0.18, 0.80, 0.25);  // Darger green
    vec3 c2 = vec3(1.00, 0.86, 0.00);  // Darger yellow
    vec3 c3 = vec3(0.00, 0.45, 0.85);  // Darger blue
    vec3 c4 = vec3(1.00, 0.41, 0.71);  // Darger pink
    
    vec3 fillColor;
    float z4 = zone * 4.0;
    if (zone < 0.25)      fillColor = mix(c0, c1, z4);
    else if (zone < 0.50) fillColor = mix(c1, c2, z4 - 1.0);
    else if (zone < 0.75) fillColor = mix(c2, c3, z4 - 2.0);
    else                   fillColor = mix(c3, c4, z4 - 3.0);

    // Crayon texture modulation
    float crayonAngle = fbm(wuv * 0.5) * 0.6;
    vec2 cDir = vec2(cos(crayonAngle), sin(crayonAngle));
    vec2 cPerp = vec2(-cDir.y, cDir.x);
    float crayonStroke = abs(fract(dot(wuv, cPerp) * 160.0) - 0.5) * 2.0;
    crayonStroke = pow(crayonStroke, 4.0);
    float crayonGrain = noise(wuv * 250.0) * 0.3 + 0.7;
    float crayon = (crayonStroke * crayonGrain) * u_crayon_texture;

    fillColor = fillColor * (1.0 - crayon * 0.25);

    // Text overlay
    float txt = textColumns(wuv);
    vec3 txtColor = vec3(0.08, 0.05, 0.02);
    
    // Compose
    vec3 col = mix(ground, fillColor, totalFill * density);
    col = mix(col, ground, u_ground_show * (1.0 - totalFill) * 0.5);
    col = mix(col, txtColor, txt * u_text_density * 0.7);
    
    // Vignette — the edge is always darker, more pressing
    float vig = 1.0 - length((uv - 0.5) * 1.8);
    col *= mix(0.7, 1.0, vig);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
