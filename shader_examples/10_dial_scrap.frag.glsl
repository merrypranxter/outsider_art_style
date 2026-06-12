// 10_dial_scrap.frag.glsl
// DIAL SCRAP — Thornton Dial, Birmingham Alabama.
// Working in found metal, wire, cloth, carpet, paint.
// The refuse of industrial civilization as raw material of vision.
// Tigers. Battles. The struggle for dignity and survival.
// Made in secret for years. Then the world found out.
//
// Aesthetic logic: layered paint over found metal texture.
// Compressed narrative — everything happens at once.
// Wire and rope lines. Carpet/cloth texture patches.
// Tiger shapes emergent from the dense surface.
// Heavy impasto — paint as material weight.
// Dark underpinning, bright overpaint.
//
// References: Thornton Dial Sr., Joseph Yoakum's rock strata,
//             Bill Traylor's compressed figures

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

// Metal / rust substrate
vec3 metalGround(vec2 uv) {
    // Rust pattern
    float rust = fbm(uv * 12.0) * 0.6 + fbm(uv * 40.0) * 0.3 + fbm(uv * 100.0) * 0.1;
    float rustPattern = pow(rust, 1.5);
    
    // Metal base tone (dark grey-brown)
    float metalBase = 0.25 - rust * 0.15;
    
    // Rust colors
    vec3 metalColor = vec3(metalBase + 0.1, metalBase * 0.7, metalBase * 0.5);
    vec3 rustColor = vec3(0.6 + rustPattern * 0.3, 0.3 - rustPattern * 0.1, 0.1);
    vec3 darkRust = vec3(0.35, 0.12, 0.05);
    
    float rustMask = smoothstep(0.4, 0.7, rust);
    vec3 result = mix(metalColor, rustColor, rustMask);
    result = mix(result, darkRust, step(0.75, rust) * 0.5);
    
    // Scratches in metal
    float scratchAngle = noise(uv * 0.5) * 3.14159;
    vec2 scrDir = vec2(cos(scratchAngle), sin(scratchAngle));
    vec2 scrPerp = vec2(-scrDir.y, scrDir.x);
    float scratches = pow(abs(fract(dot(uv, scrPerp) * 120.0) - 0.5) * 2.0, 15.0);
    result = mix(result, vec3(0.5, 0.4, 0.35), scratches * 0.4 * step(noise(uv * 30.0), 0.3));
    
    return result;
}

// Carpet/cloth texture patch
float carpetTexture(vec2 uv, vec2 center, float radius) {
    vec2 local = uv - center;
    float inPatch = 1.0 - smoothstep(radius * 0.8, radius, length(local));
    
    // Woven texture
    vec2 wuv = local / radius * 8.0;
    float weaveH = abs(fract(wuv.y) - 0.5) * 2.0;
    float weaveV = abs(fract(wuv.x) - 0.5) * 2.0;
    float weave = step(0.5, mod(floor(wuv.x) + floor(wuv.y), 2.0));
    float weavePat = mix(weaveH, weaveV, weave);
    weavePat = 1.0 - pow(weavePat, 3.0);
    
    return inPatch * weavePat;
}

// Wire/rope line
float wireLine(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float d = length(pa - ba * h);
    float wobble = noise(p * 30.0 + vec2(h * 7.0)) * u_mark_wobble * 0.02;
    // Twisted rope = two parallel lines close together
    float rope1 = 1.0 - smoothstep(width - wobble, width + 0.003, d);
    float offset = sin(h * 30.0) * width * 0.5;
    vec2 offsetDir = normalize(vec2(-ba.y, ba.x));
    float d2 = length(pa - ba * h - offsetDir * offset);
    float rope2 = 1.0 - smoothstep(width * 0.5, width * 0.5 + 0.003, d2);
    return max(rope1, rope2);
}

// Tiger — Dial's primary recurring figure
// The tiger as metaphor for the Black man's struggle, power, and dignity
float tiger(vec2 p) {
    // Body — elongated horizontal
    float body = 1.0 - smoothstep(0.0, 0.02, max(0.0, length(p * vec2(1.0/0.40, 1.0/0.18)) - 1.0));
    
    // Head (right side)
    float head = 1.0 - smoothstep(0.17, 0.20, length(p - vec2(0.42, 0.0)));
    
    // Legs
    float legFL = 1.0 - smoothstep(0.04, 0.06, length(p - vec2(0.25, -0.24)));
    float legFR = 1.0 - smoothstep(0.04, 0.06, length(p - vec2(0.35, -0.24)));
    float legBL = 1.0 - smoothstep(0.04, 0.06, length(p - vec2(-0.25, -0.24)));
    float legBR = 1.0 - smoothstep(0.04, 0.06, length(p - vec2(-0.15, -0.24)));
    
    // Tail
    float tailX = p.x + 0.52;
    float tailY = p.y - tailX * 1.2;
    float tail = step(abs(tailY), 0.04) * step(-0.52, p.x) * step(p.x, -0.38);
    float tailTip = 1.0 - smoothstep(0.06, 0.08, length(p - vec2(-0.52, 0.15)));
    
    return max(max(body, head), max(max(legFL, legFR), max(max(legBL, legBR), max(tail, tailTip))));
}

// Stripe marks — tiger's stripes, also Dial's linear marks
float tigerStripe(vec2 p, float angle, float pos, float width) {
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 perp = vec2(-dir.y, dir.x);
    float d = dot(p, perp) - pos;
    float wobble = noise(p * 25.0) * u_mark_wobble * 0.02;
    return 1.0 - smoothstep(width - wobble, width + 0.005, abs(d));
}

// Dense impasto texture
float impasto(vec2 uv) {
    float thick1 = noise(uv * 15.0);
    float thick2 = noise(uv * 40.0) * 0.5;
    float thick3 = noise(uv * 100.0) * 0.25;
    float impastoVal = thick1 + thick2 + thick3;
    // Create ridges in paint
    float ridges = abs(sin(impastoVal * 15.0)) * 0.5;
    return ridges;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);
    vec2 p = uvA - vec2(0.5 * aspect, 0.5);  // centered

    // Metal/rust ground
    vec3 col = metalGround(uv);

    // Dark foundational layer — Dial starts dark
    float darkLayer = fbm(uv * 4.0) * 0.5 + 0.3;
    col = mix(col, vec3(0.12, 0.08, 0.05) * darkLayer, 0.6 * (1.0 - u_ground_show));

    // Carpet/cloth texture patches — found material elements
    float carpetDensity = 4.0 + u_repeat_density * 0.2;
    vec2 carpCell = floor(uvA * carpetDensity);
    vec2 carpLocal = fract(uvA * carpetDensity) - 0.5;
    float carpH = hash(carpCell);
    float inCarpet = carpetTexture(carpLocal, vec2(0.0), 0.35 + carpH * 0.1) * step(0.6, carpH);
    
    // Carpet colors — earth tones mixed with vivid
    float carpColor = hash(carpCell + 0.5);
    vec3 carpCol;
    if (carpColor < 0.25)      carpCol = vec3(0.65, 0.25, 0.10); // rust red
    else if (carpColor < 0.50) carpCol = vec3(0.15, 0.35, 0.15); // dark green
    else if (carpColor < 0.75) carpCol = vec3(0.55, 0.45, 0.10); // dark gold
    else                        carpCol = vec3(0.10, 0.10, 0.35); // dark blue
    col = mix(col, carpCol, inCarpet * 0.7 * u_ground_show * 0.5 + inCarpet * 0.3);

    // Wire/rope lines crossing the surface — bound/compressed narrative
    float wires = 0.0;
    wires = max(wires, wireLine(uv, vec2(0.0, 0.25), vec2(1.0, 0.35), 0.006));
    wires = max(wires, wireLine(uv, vec2(0.1, 0.6), vec2(0.9, 0.55), 0.005));
    wires = max(wires, wireLine(uv, vec2(0.0, 0.75), vec2(1.0, 0.68), 0.007));
    wires = max(wires, wireLine(uv, vec2(0.3, 0.0), vec2(0.4, 1.0), 0.004));
    wires = max(wires, wireLine(uv, vec2(0.65, 0.0), vec2(0.7, 1.0), 0.005));
    wires = max(wires, wireLine(uv, vec2(0.0, 0.45), vec2(0.5, 0.80), 0.004));
    wires = max(wires, wireLine(uv, vec2(0.5, 0.80), vec2(1.0, 0.50), 0.004));
    col = mix(col, vec3(0.10, 0.07, 0.04), wires * 0.9);

    // Paint overpaint — bright colors pushing through
    float paint1 = smoothstep(0.5, 0.4, length(uv - vec2(0.25, 0.65)));
    float paint1Alpha = fbm(uv * 3.0 + 0.5) * 0.8 + 0.1;
    col = mix(col, vec3(1.000, 0.255, 0.212) * (0.7 + noise(uv*8.0)*0.3), 
              paint1 * paint1Alpha * u_horror_vacui * 0.7);

    float paint2 = smoothstep(0.45, 0.3, length(uv - vec2(0.72, 0.35)));
    float paint2Alpha = fbm(uv * 4.0 + 2.0) * 0.7 + 0.15;
    col = mix(col, vec3(1.000, 0.843, 0.000) * (0.6 + noise(uv*10.0)*0.4),
              paint2 * paint2Alpha * u_horror_vacui * 0.6);
    
    float paint3 = smoothstep(0.40, 0.28, length(uv - vec2(0.50, 0.52)));
    float paint3Alpha = fbm(uv * 2.5 + 4.0) * 0.85 + 0.1;
    col = mix(col, vec3(0.133, 0.545, 0.133) * (0.65 + noise(uv*7.0)*0.35),
              paint3 * paint3Alpha * u_horror_vacui * 0.55);

    // Tigers — the central figure, multiple
    float tigerCount = 1.0 + floor(u_repeat_density * 0.15);
    for (float ti = 0.0; ti < 3.0; ti++) {
        if (ti >= tigerCount) break;
        float tx = (hash(vec2(ti, 0.1)) * 0.6 + 0.2) * aspect;
        float ty = hash(vec2(ti, 0.2)) * 0.5 + 0.25;
        float tScale = 0.18 + hash(vec2(ti, 0.3)) * 0.10;
        vec2 tp = (uvA - vec2(tx, ty)) / tScale;
        
        // Tiger orientation — some facing left
        if (hash(vec2(ti, 0.4)) > 0.5) tp.x = -tp.x;
        
        float tigerShape = tiger(tp);
        
        // Tiger color — orange-gold with black stripes
        float tigerBase = step(0.0, tigerShape);
        vec3 tigerOrange = vec3(0.900, 0.500, 0.050); // orange
        col = mix(col, tigerOrange, tigerShape * u_horror_vacui * 0.9);
        
        // Tiger stripes — dark over the orange
        for (float si = 0.0; si < 5.0; si++) {
            float stripeAngle = 1.3 + si * 0.15;
            float stripePos = -0.15 + si * 0.08;
            float stripe = tigerStripe(tp, stripeAngle, stripePos, 0.025);
            stripe *= tigerShape;
            col = mix(col, vec3(0.05, 0.02, 0.01), stripe * 0.9);
        }
        
        // Tiger outline
        float dxT = dFdx(tigerShape);
        float dyT = dFdy(tigerShape);
        float tigerEdge = length(vec2(dxT, dyT)) * 40.0;
        col = mix(col, vec3(0.05, 0.02, 0.01), smoothstep(0.3, 1.5, tigerEdge) * 0.95);
    }

    // Impasto texture
    if (u_crayon_texture > 0.0) {
        float imp = impasto(uv);
        // Impasto creates highlight and shadow
        col += imp * u_crayon_texture * 0.08;
        col -= imp * imp * u_crayon_texture * 0.12;
    }

    // Text marks — if Dial's words are in the image
    if (u_text_density > 0.0) {
        float lineH = 0.015;
        float lineY = mod(uv.y, lineH);
        float onLine = step(lineH*0.3, lineY) * step(lineY, lineH*0.8);
        float cW = 0.006;
        float cid = hash(vec2(floor(uv.x/cW), floor(uv.y/lineH)));
        float cF = step(0.1, mod(uv.x,cW)/cW) * step(mod(uv.x,cW)/cW, 0.5+cid*0.4);
        float txt = onLine * cF * step(0.3, cid) * smoothstep(0.95, 0.98, uv.y);
        col = mix(col, vec3(0.9, 0.75, 0.1), txt * u_text_density * 0.8);
    }

    // Heavy vignette — Dial's work has compressed dark edges
    float vig = 1.0 - length((uv - 0.5) * 1.6) * 0.55;
    vig = max(0.3, vig);
    col *= vig;

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
