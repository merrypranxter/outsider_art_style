// common.glsl — Shared math for outsider_art_style shaders
// Art Brut / Outsider Art mark-making primitives
// Every function here is a gesture. Every mark is urgent.

// ─── NOISE ────────────────────────────────────────────────────────────────────

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash3(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i + vec2(0,0)), hash(i + vec2(1,0)), u.x),
        mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), u.x),
        u.y
    );
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(0.8, -0.6, 0.6, 0.8);
    for (int i = 0; i < 6; i++) {
        v += a * noise(p);
        p = rot * p * 2.1;
        a *= 0.5;
    }
    return v;
}

float fbm4(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// ─── MARK WOBBLE ──────────────────────────────────────────────────────────────
// The pulse of the maker's hand. Not imperfection — life.

vec2 wobble(vec2 uv, float amount) {
    float wx = noise(uv * 50.0 + vec2(1.7, 0.0)) - 0.5;
    float wy = noise(uv * 50.0 + vec2(0.0, 2.3)) - 0.5;
    return uv + vec2(wx, wy) * amount;
}

vec2 wobbleSlow(vec2 uv, float amount) {
    float wx = noise(uv * 8.0 + vec2(1.7, 0.0)) - 0.5;
    float wy = noise(uv * 8.0 + vec2(0.0, 2.3)) - 0.5;
    return uv + vec2(wx, wy) * amount;
}

// ─── CRAYON TEXTURE ───────────────────────────────────────────────────────────
// Waxy parallel strokes. Direction varies slightly across the surface.
// This is the hand in the mark.

float crayonGrain(vec2 uv, float time) {
    // Primary stroke direction with slight wobble
    float angle = fbm(uv * 0.3) * 0.4;
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 perp = vec2(-dir.y, dir.x);
    
    // Parallel stroke lines
    float strokes = abs(sin(dot(uv, perp) * 180.0)) ;
    strokes = pow(strokes, 6.0);
    
    // Waxy grain along stroke direction
    float grain = noise(uv * 200.0 + dir * time * 0.1);
    grain = pow(grain, 2.0) * 0.4;
    
    // Pressure variation — some strokes heavier
    float pressure = noise(uv * 15.0) * 0.5 + 0.5;
    
    return (strokes * pressure + grain) * 0.7;
}

float crayonLayer(vec2 uv, vec2 direction, float frequency, float pressure) {
    vec2 perp = vec2(-direction.y, direction.x);
    float stroke = abs(fract(dot(uv, perp) * frequency) - 0.5) * 2.0;
    stroke = 1.0 - pow(stroke, 0.3);
    float grain = noise(uv * 300.0) * 0.4 + 0.6;
    return stroke * grain * pressure;
}

// ─── NEWSPAPER GROUND ─────────────────────────────────────────────────────────
// The found substrate. Text columns, column rules, worn paper.
// Not decoration — history showing through.

float newspaperGround(vec2 uv) {
    // Column structure (typically 5-7 columns per broadsheet)
    float cols = mod(uv.x * 7.0, 1.0);
    float colRule = smoothstep(0.0, 0.02, cols) * (1.0 - smoothstep(0.96, 1.0, cols));
    
    // Text line rows — simulate text at fine scale
    float lineSpacing = 120.0;
    float lineY = mod(uv.y * lineSpacing, 1.0);
    float textLine = step(0.3, lineY) * step(lineY, 0.85);
    
    // Individual character simulation
    float charW = 0.055;
    float charMod = mod(uv.x * 7.0 / charW, 1.0);
    float charSim = hash(vec2(floor(uv.x * 7.0 / charW), floor(uv.y * lineSpacing)));
    charSim = step(0.3, charSim); // ~70% of char slots filled
    
    float text = textLine * charSim * 0.25 * colRule;
    
    // Paper tone — aged, not white
    float paperAge = noise(uv * 30.0) * 0.05;
    float paperBase = 0.88 + paperAge;
    
    // Occasional darker spots (water damage, foxing)
    float foxing = step(0.97, hash(floor(uv * 50.0))) * 0.15;
    
    return clamp(paperBase - text - foxing, 0.0, 1.0);
}

vec3 newspaperColor(vec2 uv) {
    float paper = newspaperGround(uv);
    return vec3(paper * 0.98, paper * 0.95, paper * 0.85); // aged yellowing
}

// ─── PATTERN FILL ─────────────────────────────────────────────────────────────
// Repeated small motif packed into areas — star, cross, flower.
// Horror vacui's infantry.

float crossMark(vec2 p, float size) {
    float h = step(abs(p.x), size * 0.15) * step(abs(p.y), size * 0.5);
    float v = step(abs(p.y), size * 0.15) * step(abs(p.x), size * 0.5);
    return max(h, v);
}

float starMark(vec2 p, float size) {
    float r = length(p);
    float a = atan(p.y, p.x);
    float star = 0.5 + 0.5 * cos(a * 5.0);
    float edge = r / (size * (0.3 + 0.7 * star));
    return 1.0 - smoothstep(0.8, 1.0, edge);
}

float flowerMark(vec2 p, float size) {
    float r = length(p);
    float a = atan(p.y, p.x);
    float petals = abs(cos(a * 4.0)) * 0.7 + 0.3;
    return 1.0 - smoothstep(size * petals * 0.8, size * petals, r);
}

float patternFill(vec2 uv, float density, float time) {
    vec2 cell = floor(uv * density);
    vec2 local = fract(uv * density) - 0.5;
    
    float t = hash(cell);
    float mark = 0.0;
    
    if (t < 0.33) mark = crossMark(local, 0.4);
    else if (t < 0.66) mark = starMark(local, 0.38);
    else mark = flowerMark(local, 0.38);
    
    return mark;
}

// ─── NAIVE FIGURE ─────────────────────────────────────────────────────────────
// A body. Knows what a body IS but not exactly how it works.
// Proportions slightly wrong but emotionally correct.

float naiveFigure(vec2 p) {
    // Head (slightly too large — childlike)
    float head = 1.0 - smoothstep(0.14, 0.16, length(p - vec2(0.0, 0.28)));
    
    // Torso (rectangular, direct)
    float torso = step(abs(p.x), 0.10) * step(abs(p.y - 0.08), 0.16);
    
    // Arms (horizontal, slightly drooped)
    float armL = step(abs(p.y - 0.14 + p.x * 0.2), 0.04) * step(p.x, -0.08) * step(-0.30, p.x);
    float armR = step(abs(p.y - 0.14 - p.x * 0.2), 0.04) * step(0.08, p.x) * step(p.x, 0.30);
    
    // Legs (parallel down, slightly apart)
    float legL = step(abs(p.x + 0.055), 0.04) * step(p.y, -0.08) * step(-0.34, p.y);
    float legR = step(abs(p.x - 0.055), 0.04) * step(p.y, -0.08) * step(-0.34, p.y);
    
    return max(max(head, torso), max(max(armL, armR), max(legL, legR)));
}

float naiveFigureWobble(vec2 p, float wobbleAmt) {
    p += vec2(noise(p * 20.0) - 0.5, noise(p * 20.0 + 5.3) - 0.5) * wobbleAmt;
    return naiveFigure(p);
}

// ─── TEXT TEXTURE ─────────────────────────────────────────────────────────────
// Words as marks. Not for reading. For filling. For praying.
// Urgency encoded in rows of illegible-but-meaningful text.

float textTexture(vec2 uv, float density) {
    float lineH = 1.0 / (density * 12.0);
    float lineY = mod(uv.y, lineH);
    float onLine = step(lineH * 0.3, lineY) * step(lineY, lineH * 0.85);
    
    float charW = lineH * 0.55;
    float charX = mod(uv.x, charW);
    float charId = hash(vec2(floor(uv.x / charW), floor(uv.y / lineH)));
    
    // Letter width varies (not monospace — handwritten)
    float letterFill = step(charId * 0.7, 0.6);
    float charFill = step(charW * 0.1, charX) * step(charX, charW * (0.5 + charId * 0.4));
    
    return onLine * charFill * letterFill;
}

// ─── PALETTE FUNCTIONS ────────────────────────────────────────────────────────

vec3 dargerVivid(float t) {
    // Blood red, cartoon green, bright yellow, blue, pink
    vec3 pal[5];
    pal[0] = vec3(1.000, 0.255, 0.212); // #FF4136
    pal[1] = vec3(0.180, 0.800, 0.251); // #2ECC40
    pal[2] = vec3(1.000, 0.863, 0.000); // #FFDC00
    pal[3] = vec3(0.000, 0.455, 0.851); // #0074D9
    pal[4] = vec3(1.000, 0.412, 0.706); // #FF69B4
    int i = int(t * 4.99);
    float f = fract(t * 4.99);
    // Simple index-based (GLSL ES 2.0 compat)
    if (i == 0) return mix(pal[0], pal[1], f);
    if (i == 1) return mix(pal[1], pal[2], f);
    if (i == 2) return mix(pal[2], pal[3], f);
    if (i == 3) return mix(pal[3], pal[4], f);
    return pal[4];
}

vec3 wolfliCosmic(float t) {
    // Dark red, gold, midnight blue, forest green, wheat paper
    if (t < 0.25) return mix(vec3(0.545, 0.000, 0.000), vec3(0.855, 0.647, 0.125), t*4.0);
    if (t < 0.50) return mix(vec3(0.855, 0.647, 0.125), vec3(0.098, 0.098, 0.439), (t-0.25)*4.0);
    if (t < 0.75) return mix(vec3(0.098, 0.098, 0.439), vec3(0.133, 0.545, 0.133), (t-0.50)*4.0);
    return mix(vec3(0.133, 0.545, 0.133), vec3(0.961, 0.871, 0.702), (t-0.75)*4.0);
}

vec3 finsterPrimitive(float t) {
    // Tomato, lime, gold, saddle brown
    if (t < 0.33) return mix(vec3(1.000, 0.388, 0.278), vec3(0.196, 0.804, 0.196), t*3.0);
    if (t < 0.66) return mix(vec3(0.196, 0.804, 0.196), vec3(1.000, 0.843, 0.000), (t-0.33)*3.0);
    return mix(vec3(1.000, 0.843, 0.000), vec3(0.545, 0.271, 0.075), (t-0.66)*3.0);
}

vec3 crayonBox(float t) {
    // Red, blue, gold, green, pink, brown
    if (t < 0.2)  return mix(vec3(1.000, 0.141, 0.000), vec3(0.000, 0.278, 0.671), t*5.0);
    if (t < 0.4)  return mix(vec3(0.000, 0.278, 0.671), vec3(1.000, 0.843, 0.000), (t-0.2)*5.0);
    if (t < 0.6)  return mix(vec3(1.000, 0.843, 0.000), vec3(0.133, 0.545, 0.133), (t-0.4)*5.0);
    if (t < 0.8)  return mix(vec3(0.133, 0.545, 0.133), vec3(1.000, 0.412, 0.706), (t-0.6)*5.0);
    return mix(vec3(1.000, 0.412, 0.706), vec3(0.545, 0.271, 0.075), (t-0.8)*5.0);
}

// ─── BORDER SYSTEM ────────────────────────────────────────────────────────────
// Borders within borders. The frame is part of the work.
// Every edge is declared, not assumed.

float border(vec2 uv, float thickness) {
    vec2 b = min(uv, 1.0 - uv);
    return 1.0 - step(thickness, min(b.x, b.y));
}

float borderWobble(vec2 uv, float thickness, float wobbleAmt) {
    float w = noise(uv * 30.0 + vec2(0.5, 0.5)) * wobbleAmt;
    vec2 b = min(uv, 1.0 - uv) - w;
    return 1.0 - step(thickness, min(b.x, b.y));
}

// Nested borders — the obsessive frame
float nestedBorders(vec2 uv, int count, float gap, float thickness, float wobbleAmt) {
    float result = 0.0;
    for (int i = 0; i < 6; i++) {
        if (i >= count) break;
        float offset = float(i) * gap;
        vec2 inner = (uv - offset) / (1.0 - 2.0 * offset);
        if (any(lessThan(inner, vec2(0.0))) || any(greaterThan(inner, vec2(1.0)))) continue;
        result = max(result, borderWobble(inner, thickness, wobbleAmt));
    }
    return result;
}

// ─── SDF SHAPES ───────────────────────────────────────────────────────────────

float sdCircle(vec2 p, float r) { return length(p) - r; }
float sdBox(vec2 p, vec2 b) { vec2 d = abs(p) - b; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); }
float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Outline (Sobel-style thickening) from distance field
float outline(float sdf, float thickness) {
    return 1.0 - smoothstep(0.0, thickness, abs(sdf));
}
