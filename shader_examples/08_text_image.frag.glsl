// 08_text_image.frag.glsl
// TEXT IMAGE — Words written directly into the image.
// Labels everything. Tells stories. Sometimes illegible.
// Always present. Always urgent.
//
// Aesthetic logic: Text is not caption, not description.
// Text IS the image. Words become pattern become texture become image.
// Every figure named. Every zone labeled. The image cannot be silent.
// Finster's exhortations, Wölfli's story-texts, Darger's narration,
// St. EOM's cosmic declarations — the maker must speak
// and the speech must be visible.
//
// Mark system: dense handwritten text blocks, isolated urgent words,
// numbers as images, circular text running around borders.

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;
uniform float u_text_density;   // key — overall text density
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

// Handwritten text simulation
// Models: variable letter width, baseline wobble, ink weight variation
float handwrittenLine(vec2 uv, float y, float lineScale, float seed) {
    float lineH = lineScale * 1.2;
    float localY = uv.y - y;
    float onLine = step(-lineH * 0.5, localY) * step(localY, lineH * 0.5);
    
    // Baseline wobble — hand not perfectly steady
    float baselineWobble = sin(uv.x * 8.0 + seed) * u_mark_wobble * lineH * 0.3;
    float wobbledY = localY - baselineWobble;
    onLine = step(-lineH * 0.5, wobbledY) * step(wobbledY, lineH * 0.5);
    
    // Letter width varies: some letters wide, some narrow
    float charAvgW = lineScale * 0.65;
    float charX = mod(uv.x, charAvgW);
    float charIdx = floor(uv.x / charAvgW);
    float cid = hash(vec2(charIdx + seed * 100.0, floor((uv.y - y) / lineH)));
    
    // Letter width (variable)
    float letterW = charAvgW * (0.35 + cid * 0.50);
    float inLetter = step(charAvgW * 0.08, charX) * step(charX, letterW);
    
    // Ink weight — thicker in middle of stroke
    float strokeWeight = sin(charX / letterW * 3.14159) * 0.4 + 0.6;
    strokeWeight *= noise(vec2(charIdx, uv.y * 50.0)) * 0.3 + 0.7;
    
    // Letter fills — different patterns per "letter" (abstracted handwriting)
    float letterType = floor(cid * 7.0);
    float letter = 0.0;
    
    float normX = charX / letterW;
    float normY = (wobbledY + lineH * 0.5) / lineH;
    
    if (letterType < 1.0) {
        // Tall letter (l, i, t) — vertical stroke
        letter = step(abs(normX - 0.5), 0.15) * step(0.1, normY) * step(normY, 0.9);
    } else if (letterType < 2.0) {
        // Round letter (o, e, c) — oval
        letter = 1.0 - smoothstep(0.35, 0.5, length(vec2((normX-0.5)*1.2, (normY-0.5)*1.5)));
        letter = max(letter, 0.0) - max(1.0 - smoothstep(0.15, 0.28, length(vec2((normX-0.5)*1.2, (normY-0.5)*1.5))), 0.0);
        letter = clamp(letter, 0.0, 1.0);
    } else if (letterType < 3.0) {
        // Arch letter (n, m, h) — up-curve
        float arch = sin(normX * 3.14159);
        letter = step(abs(normY - (0.3 + arch * 0.45)), 0.12);
    } else if (letterType < 4.0) {
        // Diagonal letter (v, w, x)
        float diag = abs(normX - 0.5) / max(normY, 0.01);
        letter = step(abs(diag - 1.0), 0.25) * step(0.1, normY);
    } else if (letterType < 5.0) {
        // Horizontal letter (z, e) — cross strokes
        float top = step(abs(normY - 0.85), 0.10);
        float mid = step(abs(normY - 0.50), 0.10) * step(normX, 0.7);
        float bot = step(abs(normY - 0.15), 0.10);
        letter = max(top, max(mid, bot));
    } else if (letterType < 6.0) {
        // Long stroke (p, q, g) — descender
        float stem = step(abs(normX - 0.3), 0.12) * step(0.0, normY);
        float bowl = 1.0 - smoothstep(0.22, 0.30, length(vec2((normX - 0.55)*1.1, (normY - 0.65)*1.2)));
        bowl = max(bowl, 0.0) - max(1.0 - smoothstep(0.10, 0.18, length(vec2((normX-0.55)*1.1, (normY-0.65)*1.2))), 0.0);
        letter = max(stem, clamp(bowl, 0.0, 1.0));
    } else {
        // Short fill (a, s, f) — complex
        letter = noise(vec2(normX * 8.0 + cid * 5.0, normY * 8.0)) > 0.4 ? 
                 step(0.1, normY) * step(normY, 0.9) * step(0.05, normX) * step(normX, 0.9) : 0.0;
    }
    
    // Skip some characters (spaces)
    float isSpace = step(0.85, hash(vec2(charIdx + seed * 200.0, 11.0)));
    letter *= 1.0 - isSpace;
    
    return onLine * letter * strokeWeight * step(0.15, cid);
}

// Dense body text — columns
float bodyText(vec2 uv, float density) {
    float result = 0.0;
    float lineHeight = 1.0 / (density * 10.0);
    for (float row = 0.0; row < 8.0; row++) {
        float rowY = row / (density * 10.0);
        float rowSeed = hash(vec2(row, density));
        result = max(result, handwrittenLine(uv, rowY, lineHeight * 0.7, rowSeed));
    }
    return result;
}

// Isolated "important" word — larger, more deliberate
float importantWord(vec2 uv, vec2 pos, float size, float seed) {
    vec2 local = (uv - pos) / size;
    if (abs(local.x) > 2.5 || abs(local.y) > 0.8) return 0.0;
    
    float lineH = 0.6;
    float word = 0.0;
    // 3-6 letter word simulation
    float numChars = 3.0 + floor(hash(vec2(seed, 0.0)) * 4.0);
    float charW = 4.0 / numChars;
    
    for (float ci = 0.0; ci < 6.0; ci++) {
        if (ci >= numChars) break;
        float cx = -2.0 + ci * charW + charW * 0.5;
        float charSeed = hash(vec2(ci, seed));
        
        // Thick, deliberate letter mark
        float lx = local.x - cx;
        if (abs(lx) > charW * 0.5) continue;
        float normX = (lx + charW * 0.5) / charW;
        float normY = local.y / lineH + 0.5;
        
        float lType = floor(charSeed * 7.0);
        float letter = 0.0;
        float thick = 0.12 + charSeed * 0.06; // thick marks
        
        if (lType < 2.0) {
            letter = step(abs(normX - 0.5), thick);
            letter = max(letter, step(abs(normY - 0.9), thick * 0.7) * step(abs(normX - 0.5), 0.42));
            letter = max(letter, step(abs(normY - 0.5), thick * 0.7) * step(abs(normX - 0.5), 0.35));
            letter = max(letter, step(abs(normY - 0.1), thick * 0.7) * step(abs(normX - 0.5), 0.42));
        } else if (lType < 4.0) {
            float r = length(vec2((normX - 0.5) * 1.2, normY - 0.5));
            letter = step(abs(r - 0.38), thick);
        } else if (lType < 6.0) {
            letter = step(abs(normY - normX), thick * 1.5);
            letter = max(letter, step(abs(normY - (1.0 - normX)), thick * 1.5));
        } else {
            letter = step(abs(normX - 0.5), thick * 1.5) * step(0.05, normY) * step(normY, 0.95);
            letter = max(letter, step(abs(normY - 0.9), thick * 0.8));
        }
        letter *= step(0.05, normY) * step(normY, 0.95) * step(0.02, normX) * step(normX, 0.98);
        word = max(word, letter);
    }
    return word;
}

// Circular text running around a ring
float circularText(vec2 p, float r, float density) {
    float angle = atan(p.y, p.x);
    float radius = length(p);
    float onRing = 1.0 - smoothstep(0.015, 0.025, abs(radius - r));
    
    float charArc = 6.28318 / (density * 20.0);
    float charIdx = floor(angle / charArc);
    float localAngle = mod(angle, charArc) / charArc;
    float cid = hash(vec2(charIdx, r * 100.0));
    float charFill = step(0.1, localAngle) * step(localAngle, 0.5 + cid * 0.4);
    
    return onRing * charFill * step(0.2, cid);
}

// Number/count as image — big numerals
float bigNumber(vec2 p, float digit) {
    float n = mod(floor(digit), 10.0);
    vec2 lp = p;
    float num = 0.0;
    float thick = 0.08;
    
    // Segments of a 7-segment display (rendered as rough marks)
    bool top =    (n==0.0||n==2.0||n==3.0||n==5.0||n==6.0||n==7.0||n==8.0||n==9.0);
    bool topL =   (n==0.0||n==4.0||n==5.0||n==6.0||n==8.0||n==9.0);
    bool topR =   (n==0.0||n==1.0||n==2.0||n==3.0||n==4.0||n==7.0||n==8.0||n==9.0);
    bool mid =    (n==2.0||n==3.0||n==4.0||n==5.0||n==6.0||n==8.0||n==9.0);
    bool botL =   (n==0.0||n==2.0||n==6.0||n==8.0);
    bool botR =   (n==0.0||n==1.0||n==3.0||n==4.0||n==5.0||n==6.0||n==7.0||n==8.0||n==9.0);
    bool bot =    (n==0.0||n==2.0||n==3.0||n==5.0||n==6.0||n==8.0||n==9.0);
    
    float segW = 0.30;
    if (top)  num = max(num, step(abs(lp.y - 0.42), thick*0.7) * step(abs(lp.x), segW));
    if (mid)  num = max(num, step(abs(lp.y), thick*0.7) * step(abs(lp.x), segW));
    if (bot)  num = max(num, step(abs(lp.y + 0.42), thick*0.7) * step(abs(lp.x), segW));
    if (topL) num = max(num, step(abs(lp.x + 0.32), thick*0.7) * step(lp.y, 0.42) * step(0.0, lp.y));
    if (topR) num = max(num, step(abs(lp.x - 0.32), thick*0.7) * step(lp.y, 0.42) * step(0.0, lp.y));
    if (botL) num = max(num, step(abs(lp.x + 0.32), thick*0.7) * step(-0.42, lp.y) * step(lp.y, 0.0));
    if (botR) num = max(num, step(abs(lp.x - 0.32), thick*0.7) * step(-0.42, lp.y) * step(lp.y, 0.0));
    
    return num;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);
    vec2 p = uvA - vec2(0.5 * aspect, 0.5);

    // Paper ground — warm, aged
    float paper = noise(uv * 40.0) * 0.06 + fbm(uv * 8.0) * 0.04;
    vec3 col = vec3(0.93 - paper, 0.89 - paper, 0.76 - paper);

    // Color zone backgrounds — each text block has a color zone
    float zone = fbm(uv * 2.5 + u_time * 0.01);
    if (zone > 0.55 * u_horror_vacui) {
        float zoneColor = fract(zone * 3.7);
        vec3 zc;
        if (zoneColor < 0.25)      zc = vec3(1.00, 0.86, 0.70);
        else if (zoneColor < 0.50) zc = vec3(0.70, 0.88, 0.70);
        else if (zoneColor < 0.75) zc = vec3(0.70, 0.80, 1.00);
        else                        zc = vec3(1.00, 0.80, 0.80);
        col = mix(col, zc, (zone - 0.55 * u_horror_vacui) * 2.0 * 0.6);
    }

    // Dense body text — multiple blocks across the image
    float textScale = u_text_density * 0.8 + 0.2;
    
    // Block 1: Upper left
    vec2 block1UV = uv * vec2(2.5, 2.5) + vec2(0.0, -1.0);
    float text1 = bodyText(block1UV, textScale * 3.0);
    text1 *= smoothstep(0.55, 0.50, uv.x) * smoothstep(0.95, 0.98, uv.y) * smoothstep(0.52, 0.55, uv.y);
    
    // Block 2: Right column
    vec2 block2UV = vec2(uv.x - 0.55, uv.y) * vec2(4.0, 2.0) + vec2(0.0, -0.5);
    float text2 = bodyText(block2UV, textScale * 2.5);
    text2 *= smoothstep(0.52, 0.55, uv.x) * smoothstep(0.92, 0.95, uv.y) * smoothstep(0.08, 0.12, uv.y);
    
    // Block 3: Lower
    vec2 block3UV = uv * vec2(3.0, 4.0) + vec2(0.1, -0.2);
    float text3 = bodyText(block3UV, textScale * 4.0);
    text3 *= smoothstep(0.22, 0.18, uv.y) * smoothstep(0.02, 0.05, uv.y);
    
    float allText = max(max(text1, text2), text3) * u_text_density;
    
    // Text color varies — dark ink on light, sometimes color
    float textColorSeed = fbm(uv * 3.0);
    vec3 textColor;
    if (textColorSeed < 0.35)      textColor = vec3(0.08, 0.04, 0.01); // dark ink
    else if (textColorSeed < 0.60) textColor = vec3(0.40, 0.00, 0.00); // dark red
    else if (textColorSeed < 0.80) textColor = vec3(0.00, 0.05, 0.40); // dark blue
    else                            textColor = vec3(0.40, 0.30, 0.00); // dark gold
    
    col = mix(col, textColor, allText * 0.9);

    // Important words — isolated large text
    for (float wi = 0.0; wi < 5.0; wi++) {
        float wx = hash(vec2(wi, 10.0)) * 0.7 + 0.15;
        float wy = hash(vec2(wi, 20.0)) * 0.6 + 0.22;
        float ws = 0.03 + hash(vec2(wi, 30.0)) * 0.03;
        float word = importantWord(uv, vec2(wx, wy), ws, wi * 17.3);
        float wColor = hash(vec2(wi, 40.0));
        vec3 wCol;
        if (wColor < 0.33)      wCol = vec3(0.545, 0.000, 0.000);
        else if (wColor < 0.66) wCol = vec3(0.000, 0.000, 0.439);
        else                     wCol = vec3(0.545, 0.271, 0.075);
        col = mix(col, wCol, word * u_text_density * 0.9);
    }

    // Circular text around center
    if (u_text_density > 0.3) {
        for (float ri = 0.0; ri < 3.0; ri++) {
            float r = 0.15 + ri * 0.12;
            float ct = circularText(p / (r / 0.3), r / 0.3, 1.0 + ri * 0.3);
            col = mix(col, vec3(0.08, 0.04, 0.01), ct * u_text_density * 0.7);
        }
    }

    // Large numbers as images — sacred counting
    if (u_text_density > 0.5) {
        float numX = fract(u_time * 0.005) * 3.0;
        for (float ni = 0.0; ni < 3.0; ni++) {
            vec2 numPos = vec2(0.20 + ni * 0.30, 0.52);
            vec2 numP = (uv - numPos) / 0.06;
            float digit = mod(floor(ni + u_time * 0.1 + hash(vec2(ni, 0.0)) * 10.0), 10.0);
            float num = bigNumber(numP, digit);
            col = mix(col, vec3(0.855, 0.647, 0.125), num * u_text_density * 0.8);
        }
    }
    
    // Borders — text runs into borders, borders mark zones
    vec2 bEdge = min(uv, 1.0 - uv);
    for (float bi = 0.0; bi < 4.0; bi++) {
        float bOff = bi * 0.018;
        vec2 inner = (uv - bOff) / (1.0 - 2.0 * bOff);
        if (any(lessThan(inner, vec2(0.0))) || any(greaterThan(inner, vec2(1.0)))) continue;
        vec2 be = min(inner, 1.0 - inner);
        float bVal = 1.0 - smoothstep(0.006, 0.012, min(be.x, be.y));
        float bwobble = noise(uv * 25.0) * u_mark_wobble * 0.003;
        bVal = 1.0 - smoothstep(0.006 - bwobble, 0.012 + bwobble, min(be.x, be.y));
        col = mix(col, vec3(0.08, 0.04, 0.01), bVal * 0.8 * (bi < 2.0 ? 1.0 : 0.5));
    }
    
    // Crayon / pencil texture on text
    if (u_crayon_texture > 0.0) {
        float cAngle = fbm(uv * 0.3) * 0.4;
        vec2 cPerp = vec2(-sin(cAngle), cos(cAngle));
        float cGrain = noise(uv * 280.0) * 0.3 + 0.7;
        float cLine = pow(abs(fract(dot(uv, cPerp) * 170.0) - 0.5)*2.0, 6.0);
        col *= 1.0 - cLine * cGrain * u_crayon_texture * 0.12;
    }

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
