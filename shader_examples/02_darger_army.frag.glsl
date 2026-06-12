// 02_darger_army.frag.glsl
// DARGER ARMY — Henry Darger, "In the Realms of the Unreal"
// Armies of Vivian Girls fighting Glandelinian soldiers.
// 15,145 pages. 87 paintings. Made alone. Never shown.
//
// Aesthetic logic: DARGER_VIVID palette. Flat cartoon color.
// Figures in horizontal bands — the narrative as frieze.
// Flowers everywhere (always flowers). Storm clouds and battlefields.
// The same girl figure repeated — each slightly different.
// Landscape in watercolor washes; figures cut-and-paste sharp.
//
// Mark-making: hard crayon outline on soft watercolor ground.
// Colors: #FF4136 #2ECC40 #FFDC00 #0074D9 #FF69B4

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;
uniform float u_text_density;
uniform float u_crayon_texture;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p); vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),u.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),u.x),u.y);
}
float fbm(vec2 p) {
    float v=0.0,a=0.5;
    for(int i=0;i<5;i++){v+=a*noise(p);p*=2.1;a*=0.5;}
    return v;
}

// Darger's watercolor sky — horizontal bands of color washes
vec3 skyGround(vec2 uv) {
    float y = uv.y;
    // Storm sky — dramatic bands
    vec3 skyTop = vec3(0.20, 0.30, 0.65);    // stormy blue
    vec3 skyMid = vec3(0.55, 0.42, 0.65);    // purple storm
    vec3 skyLow = vec3(0.95, 0.65, 0.35);    // orange horizon
    vec3 ground  = vec3(0.30, 0.60, 0.25);   // green field
    
    float cloudFbm = fbm(uv * 3.0 + vec2(u_time * 0.05, 0.0));
    float cloudMask = smoothstep(0.4, 0.7, cloudFbm);
    vec3 cloudColor = mix(skyTop, vec3(0.92, 0.88, 0.95), cloudMask);
    
    vec3 sky;
    if (y > 0.55) sky = mix(skyMid, cloudColor, (y - 0.55) / 0.45);
    else if (y > 0.38) sky = mix(skyLow, skyMid, (y - 0.38) / 0.17);
    else sky = mix(ground, skyLow, y / 0.38);
    
    // Watercolor paper texture
    float paperTex = noise(uv * 80.0) * 0.06;
    sky += paperTex;
    
    return sky;
}

// Darger's flowers — scattered everywhere, always
float flower(vec2 p, float size) {
    float r = length(p);
    float a = atan(p.y, p.x);
    float petals = 0.5 + 0.5 * abs(cos(a * 5.0 + u_time * 0.3));
    float petalShape = r / (size * (0.3 + 0.7 * petals));
    float petal = 1.0 - smoothstep(0.7, 1.0, petalShape);
    float center = 1.0 - smoothstep(0.0, size * 0.25, r);
    return max(petal, center);
}

// Flower field — ground cover
float flowerField(vec2 uv, float density) {
    vec2 cell = floor(uv * density);
    vec2 local = fract(uv * density) - 0.5;
    
    float cellHash = hash(cell);
    // Stagger placement
    local += (vec2(hash(cell + 0.1), hash(cell + 0.2)) - 0.5) * 0.3;
    
    return flower(local, 0.3 + cellHash * 0.1) * step(0.3, cellHash);
}

// A Vivian Girl figure — the repeated protagonist
// Darger traced his figures from coloring books
float vivianGirl(vec2 p) {
    // Head
    float head = 1.0 - smoothstep(0.11, 0.13, length(p - vec2(0.0, 0.32)));
    // Hair — bun / ribbon at top
    float hair = 1.0 - smoothstep(0.08, 0.10, length(p - vec2(0.0, 0.44)));
    // Body — dress silhouette (trapezoid)
    float bodyY = (p.y + 0.10) / 0.36; // normalize
    float bodyW = 0.07 + bodyY * 0.08; // wider at bottom (skirt)
    float body = step(abs(p.x), bodyW) * step(-0.10, p.y) * step(p.y, 0.22);
    // Arms
    float armL = step(abs(p.y - 0.18), 0.03) * step(p.x, -0.07) * step(-0.22, p.x);
    float armR = step(abs(p.y - 0.18), 0.03) * step(0.07, p.x) * step(p.x, 0.22);
    // Legs
    float legL = step(abs(p.x + 0.04), 0.03) * step(p.y, -0.10) * step(-0.38, p.y);
    float legR = step(abs(p.x - 0.04), 0.03) * step(p.y, -0.10) * step(-0.38, p.y);
    
    return max(max(head, hair), max(max(body, armL), max(armR, max(legL, legR))));
}

vec3 girlColor(vec2 cell) {
    float t = hash(cell + 17.3);
    // Darger palette — vivid primaries
    if (t < 0.2)  return vec3(1.000, 0.255, 0.212); // red
    if (t < 0.4)  return vec3(0.180, 0.800, 0.251); // green
    if (t < 0.6)  return vec3(1.000, 0.863, 0.000); // yellow
    if (t < 0.8)  return vec3(0.000, 0.455, 0.851); // blue
    return vec3(1.000, 0.412, 0.706);                // pink
}

// Army in bands — horizontal frieze of girls
float armyBand(vec2 uv, float bandY, float density) {
    // Place figures in a horizontal band
    float inBand = step(abs(uv.y - bandY), 0.13);
    
    vec2 cell = floor(vec2(uv.x * density, 0.0));
    vec2 local = vec2(fract(uv.x * density) - 0.5, (uv.y - bandY) / 0.13);
    
    // Slight position variation per figure
    float ph = hash(cell + vec2(0.0, bandY * 10.0));
    local.x += (ph - 0.5) * 0.2;
    local.y += (hash(cell + 0.5) - 0.5) * 0.1;
    
    // Scale figure
    local *= 2.8;
    
    return vivianGirl(local) * inBand;
}

// Crayon outline effect
float crayonOutline(vec2 uv, float figureVal) {
    float eps = 0.003 + u_mark_wobble * 0.005;
    // Approximate gradient for outlining
    float dx = dFdx(figureVal);
    float dy = dFdy(figureVal);
    float edge = length(vec2(dx, dy)) * 60.0;
    float wobbleEdge = noise(uv * 60.0) * u_mark_wobble * 5.0;
    return smoothstep(0.3, 0.9 + wobbleEdge, edge);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);

    // Time-based horizontal scroll (the epic narrative, always continuing)
    float scroll = u_time * 0.03;
    vec2 scrollUV = vec2(uv.x + scroll, uv.y);

    // Sky/ground watercolor
    vec3 col = skyGround(uv);
    
    // Flower ground cover (lower third)
    float flowers = flowerField(scrollUV * vec2(1.0, 2.0) + vec2(0.0, -0.1), 
                                 20.0 + u_repeat_density * 0.5);
    flowers *= smoothstep(0.42, 0.30, uv.y);  // only on ground
    
    // Flower colors — mixed vivid
    float fh = hash(floor((scrollUV + vec2(0.0, -0.1)) * 20.0));
    vec3 flowerColor;
    if (fh < 0.33)      flowerColor = vec3(1.000, 0.255, 0.212);  // red
    else if (fh < 0.66) flowerColor = vec3(1.000, 0.863, 0.000);  // yellow
    else                 flowerColor = vec3(1.000, 0.412, 0.706);  // pink
    
    col = mix(col, flowerColor, flowers * 0.9);
    
    // Army bands (multiple horizontal rows)
    float density = 8.0 + u_repeat_density * 0.4;
    
    // Three bands of girls — the army
    float band1 = armyBand(scrollUV, 0.55, density);
    float band2 = armyBand(scrollUV + vec2(0.5/density, 0.0), 0.35, density * 1.2);
    float band3 = armyBand(scrollUV + vec2(0.25/density, 0.0), 0.20, density * 0.8);
    
    // Girl colors per band
    vec3 gCol1 = girlColor(floor(vec2(scrollUV.x * density, 1.0)));
    vec3 gCol2 = girlColor(floor(vec2(scrollUV.x * density * 1.2, 2.0)));
    vec3 gCol3 = girlColor(floor(vec2(scrollUV.x * density * 0.8, 3.0)));
    
    // Flat color fill — Darger's cut-and-paste clarity
    col = mix(col, gCol1, band1 * u_horror_vacui);
    col = mix(col, gCol2, band2 * u_horror_vacui * 0.9);
    col = mix(col, gCol3, band3 * u_horror_vacui * 0.8);
    
    // Crayon outlines
    float outl1 = crayonOutline(uvA, band1);
    float outl2 = crayonOutline(uvA, band2);
    float outl3 = crayonOutline(uvA, band3);
    float outlines = max(max(outl1, outl2), outl3);
    col = mix(col, vec3(0.05, 0.02, 0.02), outlines * 0.8);
    
    // Crayon texture on figures
    float crayonAngle = fbm(uv * 0.8) * 0.5;
    vec2 cPerp = vec2(-sin(crayonAngle), cos(crayonAngle));
    float crayonLine = pow(abs(fract(dot(uv, cPerp) * 140.0) - 0.5)*2.0, 5.0);
    float grain = noise(uv * 200.0);
    float crayon = crayonLine * grain * u_crayon_texture * 0.3;
    col -= crayon * max(band1, max(band2, band3));
    
    // Text across sky — Darger's handwritten narrative
    if (u_text_density > 0.0) {
        float lineH = 0.018;
        float lineY = mod(uv.y + u_time * 0.002, lineH);
        float onLine = step(lineH*0.35, lineY) * step(lineY, lineH*0.8);
        float charW = 0.009;
        float cid = hash(vec2(floor(uv.x / charW), floor(uv.y / lineH)));
        float charFill = step(0.1, mod(uv.x, charW)/charW) * step(mod(uv.x, charW)/charW, 0.5+cid*0.4);
        float txt = onLine * charFill * step(0.35, cid) * smoothstep(0.7, 0.5, uv.y);
        col = mix(col, vec3(0.15, 0.08, 0.02), txt * u_text_density * 0.6);
    }
    
    // Subtle ground visibility (newsprint beneath)
    if (u_ground_show > 0.0) {
        float news = noise(uv * vec2(80.0, 180.0)) * 0.2 + 0.8;
        vec3 newsColor = vec3(0.92, 0.89, 0.78) * news;
        col = mix(col, newsColor, u_ground_show * 0.3);
    }
    
    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
