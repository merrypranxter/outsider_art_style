// 04_finster_gospel.frag.glsl
// FINSTER GOSPEL — Howard Finster, "Man of Visions"
// God told him to paint sacred art and he did. 46,000 works.
// Housepaint on found wood. Text everywhere. The message is urgent.
// Every image is a sermon. Numbers count down to something.
//
// Aesthetic logic: FINSTER_PRIMITIVE palette.
// Housepaint thickness — thick, unhesitant strokes.
// Found wood grain shows through.
// Text is part of the image — labels, Bible verses, exhortations.
// Simple angelic figures. Flat color with no modeling.
// The sacred made of hardware-store materials.
//
// Colors: #FF6347 (tomato), #32CD32 (lime), #FFD700 (gold), #8B4513 (saddle brown)

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

// Found wood grain — the substrate that shows through
vec3 woodGrain(vec2 uv) {
    float grain = 0.0;
    // Primary grain direction (mostly vertical with slight tilt)
    float tilt = 0.08;
    vec2 grainDir = normalize(vec2(tilt, 1.0));
    vec2 grainPerp = vec2(-grainDir.y, grainDir.x);
    float pos = dot(uv, grainDir);
    float across = dot(uv, grainPerp);
    
    // Wood grain rings (elliptical)
    grain += 0.5 * noise(vec2(across * 12.0 + fbm(uv * 2.0) * 1.5, pos * 0.5));
    grain += 0.3 * noise(vec2(across * 25.0 + fbm(uv * 4.0) * 0.8, pos * 1.0));
    grain += 0.2 * noise(vec2(across * 60.0, pos * 2.0));
    
    // Knot
    float knotPos = vec2(0.35, 0.6) - uv;
    float knotR = length(knotPos * vec2(1.0, 1.8));
    float knot = smoothstep(0.12, 0.0, knotR) * 0.4;
    grain += knot;
    
    float warmTone = 0.65 + grain * 0.25;
    return vec3(warmTone * 0.72, warmTone * 0.50, warmTone * 0.30);
}

// Finster's angel — simple frontal figure with wings
// Wings are the most important part
float finsterAngel(vec2 p) {
    // Head
    float head = 1.0 - smoothstep(0.11, 0.13, length(p - vec2(0.0, 0.30)));
    // Halo
    float haloR = length(p - vec2(0.0, 0.30));
    float halo = smoothstep(0.005, 0.002, abs(haloR - 0.18));
    // Body (rectangle)
    float body = step(abs(p.x), 0.09) * step(abs(p.y - 0.05), 0.20);
    // Wings — the key element — extending far out
    // Left wing
    float wLx = -p.x - 0.09;
    float wLy = p.y - 0.12;
    float wingL = step(0.0, wLx) * step(wLx, 0.35) *
                  step(0.0, wLy + wLx * 0.5) *
                  step(wLy, 0.22 - wLx * 0.5);
    float wingR = step(0.0, p.x - 0.09) * step(p.x - 0.09, 0.35) *
                  step(0.0, p.y - 0.12 + (p.x - 0.09) * 0.5) *
                  step(p.y - 0.12, 0.22 - (p.x - 0.09) * 0.5);
    // Legs/robe bottom
    float robe = step(abs(p.x) - 0.05, 0.10 * (1.0 - (p.y + 0.18) * 0.8)) *
                 step(-0.36, p.y) * step(p.y, -0.08);
    return max(max(head, halo), max(max(body, wingL), max(wingR, robe)));
}

// Housepaint mark — thick, decisive, slightly uneven edges
float housepainth(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float d = length(pa - ba * h);
    // Uneven edge (paint drip effect)
    float wobEdge = noise(vec2(h * 20.0, length(pa) * 10.0)) * u_mark_wobble * 0.03;
    return 1.0 - smoothstep(width - wobEdge, width + 0.008, d);
}

// Text label — Finster's exhortations
// Simulated as dense rows of marks
float finsterText(vec2 uv, float density, float rowOffset) {
    float lineH = 1.0 / (density * 8.0);
    float lineY = mod(uv.y + rowOffset, lineH);
    float onLine = step(lineH * 0.25, lineY) * step(lineY, lineH * 0.80);
    float charW = lineH * 0.50;
    float charIdx = floor(uv.x / charW);
    float charY = floor((uv.y + rowOffset) / lineH);
    float cid = hash(vec2(charIdx, charY));
    // Block-letter style (Finster's lettering is blocky, caps)
    float charFill = step(charW * 0.08, mod(uv.x, charW)) *
                     step(mod(uv.x, charW), charW * (0.45 + cid * 0.45));
    return onLine * charFill * step(0.2, cid);
}

// Star of divine light
float divinestar(vec2 p, float r) {
    float a = atan(p.y, p.x);
    // 8-pointed Finster star
    float star8 = cos(a * 4.0);
    float shape = r * (0.5 + 0.5 * abs(star8));
    return 1.0 - smoothstep(shape * 0.9, shape, length(p));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);

    // Wood grain ground
    vec3 woodCol = woodGrain(uv);
    vec3 col = woodCol;

    // Housepaint sky — solid bright color, thick application
    // Finster uses loud solid backgrounds
    float skyZone = smoothstep(0.35, 0.40, uv.y);
    vec3 skyColor = vec3(0.196, 0.804, 0.196); // lime green — sacred green
    // Rough paint edge
    float paintEdge = noise(vec2(uv.x * 30.0, 0.0)) * 0.04;
    skyZone = smoothstep(0.35 + paintEdge, 0.42 + paintEdge, uv.y);
    
    col = mix(col, skyColor, skyZone * (1.0 - u_ground_show * 0.5));

    // Ground earth — tomato red / brown
    float groundZone = 1.0 - smoothstep(0.08, 0.15, uv.y);
    col = mix(col, vec3(0.545, 0.271, 0.075), groundZone * 0.8);

    // Divine sunburst behind angel — gold radiating lines
    vec2 sunCenter = vec2(0.5 * aspect, 0.60);
    vec2 sunP = uvA - sunCenter;
    float sunAngle = atan(sunP.y, sunP.x);
    float sunRay = 0.5 + 0.5 * cos(sunAngle * 24.0);
    sunRay = pow(sunRay, 3.0);
    float sunDecay = exp(-length(sunP) * 4.0);
    float sunWobble = noise(vec2(sunAngle * 5.0, length(sunP) * 10.0)) * u_mark_wobble * 0.5;
    col = mix(col, vec3(1.000, 0.843, 0.000), sunRay * sunDecay * 0.8 + sunWobble * 0.2);

    // Stars of sacred light scattered across sky
    float starDensity = 15.0 + u_repeat_density * 0.5;
    vec2 starCell = floor(uvA * starDensity);
    vec2 starLocal = fract(uvA * starDensity) - 0.5;
    float starH = hash(starCell);
    float starMask = step(0.6, starH) * skyZone;
    float starShape = divinestar(starLocal, 0.32 + starH * 0.1);
    vec3 starColor = mix(vec3(1.0, 0.843, 0.0), vec3(1.0, 0.4, 0.2), fract(starH * 3.7));
    col = mix(col, starColor, starShape * starMask * u_horror_vacui);

    // Multiple angels — the heavenly host
    float aDensity = 3.0 + u_repeat_density * 0.1;
    for (float ai = 0.0; ai < 5.0; ai++) {
        if (ai >= aDensity) break;
        float ax = 0.1 + ai / aDensity * 0.8;
        float ay = 0.32 + sin(ai * 2.7) * 0.06;
        vec2 angelUV = uvA - vec2(ax * aspect, ay);
        angelUV *= 1.0 / (0.20 + hash(vec2(ai, 0.0)) * 0.08);
        float angel = finsterAngel(angelUV);
        
        // Angel color from Finster palette
        float aC = hash(vec2(ai, 3.7));
        vec3 angelColor;
        if (aC < 0.33)      angelColor = vec3(1.000, 0.388, 0.278); // tomato
        else if (aC < 0.66) angelColor = vec3(1.000, 0.843, 0.000); // gold
        else                 angelColor = vec3(0.196, 0.804, 0.196); // lime
        
        col = mix(col, angelColor, angel * u_horror_vacui);
        
        // Dark outline — housepaint edge
        float dxA = dFdx(angel);
        float dyA = dFdy(angel);
        float edgeA = length(vec2(dxA, dyA)) * 40.0;
        col = mix(col, vec3(0.08, 0.04, 0.01), smoothstep(0.3, 1.2, edgeA) * 0.9);
    }

    // Text — the sermon
    // Rows of text in the border areas and sky
    float txtTop = finsterText(uv, 12.0 * u_text_density, 0.0) *
                   smoothstep(0.92, 0.98, uv.y) * u_text_density;
    float txtBot = finsterText(uv, 10.0 * u_text_density, 0.3) *
                   smoothstep(0.08, 0.02, uv.y) * u_text_density;
    float txtLeft = finsterText(vec2(uv.y, uv.x), 10.0 * u_text_density, 0.7) *
                    smoothstep(0.06, 0.01, uv.x) * u_text_density;
    float txtRight = finsterText(vec2(uv.y, uv.x), 10.0 * u_text_density, 0.9) *
                     smoothstep(0.94, 0.99, uv.x) * u_text_density;
    float txt = max(max(txtTop, txtBot), max(txtLeft, txtRight));
    col = mix(col, vec3(0.08, 0.04, 0.01), txt * 0.85);

    // Numbers scattered — Finster counted everything
    // Represented as small rectangular digit-like marks
    if (u_text_density > 0.3) {
        vec2 numCell = floor(uv * 8.0);
        vec2 numLocal = fract(uv * 8.0);
        float numH = hash(numCell + 99.1);
        float numMask = step(0.75, numH);
        // Digit-like shape
        float digit = step(0.1, numLocal.x) * step(numLocal.x, 0.9) *
                      step(0.1, numLocal.y) * step(numLocal.y, 0.9);
        digit *= (1.0 - step(0.2, numLocal.x) * step(numLocal.x, 0.8) *
                        step(0.25, numLocal.y) * step(numLocal.y, 0.75));
        col = mix(col, vec3(1.0, 0.843, 0.0), digit * numMask * u_text_density * 0.5);
    }

    // Housepaint texture — thick, slightly uneven
    if (u_crayon_texture > 0.0) {
        float paintTexture = noise(uv * 30.0) * 0.08 + noise(uv * 80.0) * 0.04;
        col += (paintTexture - 0.06) * u_crayon_texture * 0.15;
    }

    // Bright border — Finster painted the edges of his boards
    vec2 bEdge = min(uv, 1.0 - uv);
    float borderThick = 0.025;
    float border = 1.0 - smoothstep(borderThick * 0.5, borderThick, min(bEdge.x, bEdge.y));
    col = mix(col, vec3(1.000, 0.388, 0.278), border * 0.9); // tomato red border

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
