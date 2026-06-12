// 07_repeated_figure.frag.glsl
// REPEATED FIGURE — The obsessive image.
// One figure type repeated across the entire surface.
// Army of angels. Field of faces. Forest of trees-as-people.
// Each slightly different. The variation is the point.
//
// Aesthetic logic: fract(uv * density) — packed figure array.
// Same SDF figure placed in every cell.
// Variation per cell: rotation, color, scale, slight deformation.
// The figure as prayer bead — repetition as act of devotion.
// Faces emerge from pattern. The figure becomes textile.
//
// References: Wölfli's margin faces, Darger's armies,
//             Madge Gill's spirit-guided automatic drawing

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;  // key — controls figure count
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

// The repeated figure — a face/head form
// Naive but recognizable. The minimum viable human.
float naiveFace(vec2 p, float wobble) {
    // Apply wobble to the whole figure
    p += vec2(noise(p * 15.0 + 3.1) - 0.5, noise(p * 15.0 + 7.7) - 0.5) * wobble;
    
    // Outer shape — slightly irregular oval
    float outerR = length(p * vec2(1.0, 1.2)) - 0.42;
    float outer = 1.0 - smoothstep(-0.01, 0.01, outerR);
    
    // Eyes — asymmetric (one slightly higher, slightly different size)
    float eyeL = 1.0 - smoothstep(0.06, 0.09, length(p - vec2(-0.15, 0.10 + noise(p*3.0)*wobble*0.05)));
    float eyeR = 1.0 - smoothstep(0.07, 0.10, length(p - vec2( 0.14, 0.12 + noise(p*3.1)*wobble*0.05)));
    
    // Pupil — the direct gaze
    float pupilL = 1.0 - smoothstep(0.03, 0.04, length(p - vec2(-0.15, 0.10)));
    float pupilR = 1.0 - smoothstep(0.03, 0.04, length(p - vec2( 0.14, 0.12)));
    
    // Nose (simple line or dot)
    float nose = 1.0 - smoothstep(0.03, 0.04, length(p - vec2(0.01, -0.05)));
    
    // Mouth — direct horizontal line, sometimes curved
    float mouthY = -0.22 + noise(p * 5.0) * wobble * 0.05;
    float mouth = 1.0 - smoothstep(0.008, 0.02, abs(p.y - mouthY)) * step(abs(p.x), 0.22);
    mouth *= step(abs(p.x), 0.22);
    
    // Combine: background is 1.0 (filled face), 0.0 for eyes/mouth (hollow)
    float faceVal = outer;
    faceVal = mix(faceVal, 0.0, eyeL);
    faceVal = mix(faceVal, 0.0, eyeR);
    faceVal = mix(faceVal, 1.0, pupilL * outer);
    faceVal = mix(faceVal, 1.0, pupilR * outer);
    faceVal = mix(faceVal, 0.0, mouth);
    faceVal = mix(faceVal, 1.0, nose * outer);
    
    return clamp(faceVal, 0.0, 1.0);
}

// Angel figure — body with wings
float angelFigure(vec2 p, float wobble) {
    p += vec2(noise(p*12.0)-0.5, noise(p*12.0+3.3)-0.5) * wobble * 0.05;
    
    float head = 1.0 - smoothstep(0.10, 0.12, length(p - vec2(0.0, 0.30)));
    float halo = 1.0 - smoothstep(0.003, 0.010, abs(length(p - vec2(0.0, 0.30)) - 0.17));
    float body = step(abs(p.x), 0.08) * step(abs(p.y - 0.05), 0.20);
    
    // Wings — simple triangular
    float wL = step(0.0, -p.x - 0.08) * step(-p.x - 0.08, 0.30) *
               step(-p.y + 0.22 - (-p.x - 0.08) * 0.7, 0.0) *
               step(0.0, p.y + 0.02);
    float wR = step(0.0, p.x - 0.08) * step(p.x - 0.08, 0.30) *
               step(-p.y + 0.22 - (p.x - 0.08) * 0.7, 0.0) *
               step(0.0, p.y + 0.02);
    
    return max(max(head, halo), max(body, max(wL, wR)));
}

// Tree figure — the tree-as-person (naive botanical)
float treeFigure(vec2 p, float wobble) {
    p += vec2(noise(p*20.0)-0.5, noise(p*20.1)-0.5) * wobble * 0.03;
    
    // Trunk
    float trunk = step(abs(p.x), 0.06) * step(-0.42, p.y) * step(p.y, -0.02);
    
    // Root spread
    float rootL = step(abs(p.y + 0.38 + p.x * 0.5), 0.04) * step(-0.20, p.x) * step(p.x, -0.06);
    float rootR = step(abs(p.y + 0.38 - (p.x - 0.06) * 0.5), 0.04) * step(0.06, p.x) * step(p.x, 0.20);
    
    // Crown — rounded mass of leaves
    float crownR = length(p - vec2(0.0, 0.15));
    float crown = 1.0 - smoothstep(0.24, 0.28, crownR);
    // Add lumps to crown
    for (float ci = 0.0; ci < 5.0; ci++) {
        float ca = ci * 6.28318 / 5.0;
        float cr = 0.2;
        float clump = 1.0 - smoothstep(0.10, 0.14, length(p - vec2(0.0, 0.15) - vec2(cos(ca), sin(ca)) * cr));
        crown = max(crown, clump);
    }
    
    return max(max(trunk, max(rootL, rootR)), crown);
}

// Pick figure type based on overall u_repeat_density value
// Low density: faces. Mid: angels. High: trees.
float getFigure(vec2 p, float figType, float wobble) {
    if (figType < 0.33) return naiveFace(p, wobble);
    if (figType < 0.66) return angelFigure(p, wobble);
    return treeFigure(p, wobble);
}

// Color per cell — pulled from the outsider art palettes
vec3 figureColor(vec2 cell, float brightness) {
    float t = hash(cell + 55.5);
    vec3 baseColor;
    // Mixed palette across all schemes
    float t5 = t * 5.0;
    if (t5 < 1.0)      baseColor = vec3(1.000, 0.255, 0.212); // Darger red
    else if (t5 < 2.0) baseColor = vec3(0.180, 0.800, 0.251); // Darger green
    else if (t5 < 3.0) baseColor = vec3(0.855, 0.647, 0.125); // Wolfli gold
    else if (t5 < 4.0) baseColor = vec3(0.098, 0.098, 0.439); // Wolfli blue
    else                baseColor = vec3(1.000, 0.388, 0.278); // Finster tomato
    return baseColor * brightness;
}

// Background color — ground between figures
vec3 groundColor(vec2 uv) {
    // Aged paper / parchment
    float age = noise(uv * 40.0) * 0.08;
    return vec3(0.91 - age, 0.87 - age, 0.74 - age);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);

    // Ground
    vec3 col = groundColor(uv);
    
    // Dense crosshatch background when horror_vacui is high
    if (u_horror_vacui > 0.5) {
        float h1 = abs(fract(uv.x * 60.0 + uv.y * 20.0) - 0.5);
        float h2 = abs(fract(-uv.x * 60.0 + uv.y * 20.0) - 0.5);
        float hatch = max(1.0 - h1 * 12.0, 1.0 - h2 * 12.0);
        hatch = clamp(hatch, 0.0, 1.0) * (u_horror_vacui - 0.5) * 2.0 * 0.2;
        col = mix(col, vec3(0.75, 0.70, 0.58), hatch);
    }

    // Figure density — drives how many figures tile
    float density = max(2.0, u_repeat_density);
    
    // Tile UV — create grid of figures
    vec2 tileUV = vec2(uvA.x / aspect, uv.y) * density;
    vec2 cell = floor(tileUV);
    vec2 local = fract(tileUV) - 0.5;  // centered in cell
    
    // Per-cell variation
    float cellH = hash(cell);
    float cellH2 = hash(cell + 0.5);
    
    // Scale variation (slightly different sizes — like a field of things growing)
    float cellScale = 0.85 + cellH * 0.25;
    local /= cellScale;
    
    // Rotation variation — slight tilt per figure
    float rotAngle = (cellH2 - 0.5) * 0.35 + u_time * 0.01;
    float cosA = cos(rotAngle);
    float sinA = sin(rotAngle);
    local = vec2(local.x * cosA - local.y * sinA, local.x * sinA + local.y * cosA);
    
    // Figure type — varies by position region (creates zones of face/angel/tree)
    float regionX = floor(uv.x * 3.0) / 3.0;
    float regionY = floor(uv.y * 3.0) / 3.0;
    float figType = hash(vec2(regionX, regionY) + 13.7);
    // Or vary per cell for full mix
    if (u_repeat_density > 20.0) figType = hash(cell + 200.0);
    
    float figure = getFigure(local, figType, u_mark_wobble);
    
    // Figure fill color
    float brightness = 0.85 + noise(cell) * 0.15;
    vec3 fColor = figureColor(cell, brightness);
    
    // Background of figure (face outline vs face interior)
    // For faces: fill = 1.0 is the face; use a slightly different color for whites-of-eyes
    vec3 bgFigColor;
    if (figType < 0.33) {
        // Face: flesh tone
        bgFigColor = vec3(0.96, 0.80, 0.65) * brightness;
    } else {
        bgFigColor = fColor;
    }
    
    col = mix(col, bgFigColor, figure * u_horror_vacui);
    
    // Dark outline — every figure has a strong edge
    float dxF = dFdx(figure);
    float dyF = dFdy(figure);
    float edge = length(vec2(dxF, dyF)) * 35.0;
    float wobEdge = noise(uvA * 50.0) * u_mark_wobble * 3.0;
    col = mix(col, vec3(0.06, 0.03, 0.02), smoothstep(0.4, 1.5 + wobEdge, edge) * 0.9);
    
    // Nested frames
    vec2 bEdge = min(uv, 1.0 - uv);
    float frame1 = 1.0 - smoothstep(0.008, 0.015, min(bEdge.x, bEdge.y));
    float frame2 = 1.0 - smoothstep(0.022, 0.028, min(bEdge.x, bEdge.y));
    float frame3 = 1.0 - smoothstep(0.038, 0.044, min(bEdge.x, bEdge.y));
    col = mix(col, vec3(0.06, 0.03, 0.02), max(frame1, max(frame2 * 0.6, frame3 * 0.4)));
    
    // Crayon texture
    if (u_crayon_texture > 0.0) {
        float cAngle = fbm(uv * 0.5) * 0.8;
        vec2 cPerp = vec2(-sin(cAngle), cos(cAngle));
        float cStroke = pow(abs(fract(dot(uv, cPerp) * 130.0) - 0.5)*2.0, 5.0);
        float cGrain = noise(uv * 220.0) * 0.4 + 0.6;
        col *= 1.0 - cStroke * cGrain * u_crayon_texture * 0.18;
    }
    
    // Text density — labels between figures
    if (u_text_density > 0.0) {
        // Text fills the ground between figures
        vec2 tuv = uv * vec2(1.0, 1.0);
        float lineH = 0.006 + 0.004 * (1.0 - u_text_density);
        float lineY = mod(tuv.y, lineH);
        float onLine = step(lineH*0.3, lineY) * step(lineY, lineH*0.82);
        float cW = lineH * 0.55;
        float cid = hash(vec2(floor(tuv.x/cW), floor(tuv.y/lineH)));
        float cF = step(cW*0.1, mod(tuv.x, cW)) * step(mod(tuv.x,cW), cW*(0.45+cid*0.45));
        float txt = onLine * cF * step(0.3, cid);
        // Only in ground (not on figures)
        txt *= (1.0 - figure);
        col = mix(col, vec3(0.12, 0.06, 0.02), txt * u_text_density * 0.55);
    }

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
