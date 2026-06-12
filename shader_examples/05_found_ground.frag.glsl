// 05_found_ground.frag.glsl
// FOUND GROUND — The material is part of the image.
// Newspaper, cardboard, wood. Not hidden — revealed.
// Paint as gesture that doesn't cover but converses with substrate.
//
// Aesthetic logic: Layered semi-transparent paint over readable substrate.
// The original text/grain shows through translucent washes.
// Thick paint in some areas, bare substrate in others.
// The accident of ground is embraced as meaning.
//
// References: Henry Darger (watercolor on found paper),
//             Thornton Dial (paint on cardboard and metal),
//             Anna Zemánková (found paper ground)

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform float u_horror_vacui;
uniform float u_mark_wobble;
uniform float u_repeat_density;
uniform float u_ground_show;    // key parameter — how much ground shows
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

// Newspaper column simulation — full broadsheet
vec3 newspaper(vec2 uv) {
    // 6-column newspaper layout
    float cols = 6.0;
    float colWidth = 1.0 / cols;
    float colX = mod(uv.x, colWidth) / colWidth;
    float colIdx = floor(uv.x / colWidth);
    
    // Column gutter
    float gutter = 0.06;
    float inCol = step(gutter * 0.5, colX) * step(colX, 1.0 - gutter * 0.5);
    
    // Headline at top of some columns
    float colHash = hash(vec2(colIdx, 99.0));
    float headlineY = 0.85 + colHash * 0.05;
    float isHeadline = step(headlineY, uv.y);
    
    // Headline text — larger
    float hlLineH = 0.028;
    float hlLineY = mod(uv.y, hlLineH);
    float hlOnLine = step(hlLineH * 0.2, hlLineY) * step(hlLineY, hlLineH * 0.85);
    float hlCharW = 0.0055;
    float hlCid = hash(vec2(floor(uv.x / hlCharW), floor(uv.y / hlLineH) + colIdx * 100.0));
    float hlCharF = step(hlCharW*0.1, mod(uv.x, hlCharW)) * step(mod(uv.x,hlCharW), hlCharW*(0.55+hlCid*0.35));
    float headline = hlOnLine * hlCharF * step(0.25, hlCid) * isHeadline * inCol;
    
    // Body text — smaller
    float lineH = 0.012;
    float lineY = mod(uv.y, lineH);
    float onLine = step(lineH * 0.3, lineY) * step(lineY, lineH * 0.82);
    float charW = 0.0038;
    float cid = hash(vec2(floor(uv.x / charW), floor(uv.y / lineH) + colIdx * 500.0));
    float charFill = step(charW*0.08, mod(uv.x, charW)) * step(mod(uv.x,charW), charW*(0.45+cid*0.45));
    float bodyText = onLine * charFill * step(0.3, cid) * (1.0 - isHeadline) * inCol;
    
    // Image/photo placeholder (dark box in some columns)
    float imgZone = step(0.35, uv.y) * step(uv.y, 0.60);
    float imgBox = step(colHash, 0.3) * imgZone * inCol;
    float imgTexture = noise(uv * 40.0) * 0.3 + 0.35;
    
    // Combine onto paper
    float paperAge = noise(uv * 20.0) * 0.05 + fbm(uv * 5.0) * 0.04;
    float paperBase = 0.88 - paperAge;
    
    float textDarkness = headline * 0.45 + bodyText * 0.22 + imgBox * (1.0 - imgTexture);
    float value = clamp(paperBase - textDarkness, 0.0, 1.0);
    
    // Aged yellowing
    return vec3(value * 0.97, value * 0.93, value * 0.78);
}

// Paint wash — translucent color over ground
// Alpha varies by noise (thin here, thick there)
float paintAlpha(vec2 uv, float seed) {
    float thick = fbm(uv * 2.0 + seed) * 0.8 + 0.1;
    // Paint edges — soft, diffuse
    float edge = noise(uv * 15.0 + seed * 3.0) * 0.4;
    return clamp(thick - edge * (1.0 - u_horror_vacui), 0.0, 1.0);
}

// Brush stroke — a single gesture
float brushStroke(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float d = length(pa - ba * h);
    float wobble = noise(p * 30.0) * u_mark_wobble * 0.03;
    float wid = width * (0.7 + noise(vec2(h * 10.0, 0.0)) * 0.5); // varying width
    return 1.0 - smoothstep(wid - wobble, wid + 0.01, d);
}

// Mark-making on top of ground — brushwork
float brushworkLayer(vec2 uv) {
    float marks = 0.0;
    // Large gestural strokes
    marks = max(marks, brushStroke(uv, vec2(0.1, 0.3), vec2(0.9, 0.4), 0.035));
    marks = max(marks, brushStroke(uv, vec2(0.0, 0.6), vec2(0.7, 0.55), 0.025));
    marks = max(marks, brushStroke(uv, vec2(0.2, 0.75), vec2(1.0, 0.70), 0.030));
    marks = max(marks, brushStroke(uv, vec2(0.3, 0.20), vec2(0.8, 0.25), 0.020));
    // Smaller gestural marks
    marks = max(marks, brushStroke(uv, vec2(0.1, 0.85), vec2(0.5, 0.88), 0.015));
    marks = max(marks, brushStroke(uv, vec2(0.5, 0.10), vec2(0.9, 0.15), 0.018));
    marks = max(marks, brushStroke(uv, vec2(0.05, 0.50), vec2(0.35, 0.45), 0.022));
    marks = max(marks, brushStroke(uv, vec2(0.65, 0.65), vec2(0.95, 0.62), 0.020));
    return marks;
}

// Cardboard texture (alternative to newspaper)
vec3 cardboard(vec2 uv) {
    // Corrugated fluting
    float corrugation = 0.5 + 0.5 * sin(uv.x * 80.0 + noise(uv * 5.0) * 2.0);
    corrugation = pow(corrugation, 4.0) * 0.15;
    
    // Surface texture
    float surface = fbm(uv * 30.0) * 0.1;
    float scratches = noise(uv * 150.0) * 0.05;
    
    float value = 0.72 - corrugation - surface - scratches;
    return vec3(value * 0.85, value * 0.65, value * 0.40); // warm brown
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);

    // Choose ground type based on u_ground_show value
    // 0.0-0.33: newspaper; 0.33-0.66: cardboard; 0.66-1.0: wood
    float groundT = u_ground_show;
    vec3 groundColor;
    if (groundT < 0.5) {
        groundColor = mix(newspaper(uv), cardboard(uv), groundT * 2.0);
    } else {
        // Wood grain
        float grain = fbm(uv * vec2(1.0, 8.0) + fbm(uv * 2.0));
        float warmGrain = 0.65 + grain * 0.2;
        vec3 wood = vec3(warmGrain * 0.72, warmGrain * 0.48, warmGrain * 0.26);
        groundColor = mix(cardboard(uv), wood, (groundT - 0.5) * 2.0);
    }
    
    vec3 col = groundColor;

    // Paint washes — overlapping translucent color areas
    // Zone 1: Upper left area — red-orange wash
    float wash1 = paintAlpha(uv + vec2(0.1, 0.0), 1.1) *
                  smoothstep(0.8, 0.3, length(uv - vec2(0.25, 0.70)));
    vec3 wash1Col = vec3(1.000, 0.388, 0.278) * (0.7 + noise(uv * 10.0) * 0.3);
    col = mix(col, wash1Col, wash1 * (1.0 - u_ground_show * 0.4) * u_horror_vacui);

    // Zone 2: Lower right — blue-green wash
    float wash2 = paintAlpha(uv + vec2(0.5, 0.3), 2.3) *
                  smoothstep(0.75, 0.25, length(uv - vec2(0.72, 0.28)));
    vec3 wash2Col = vec3(0.133, 0.545, 0.133) * (0.6 + noise(uv * 12.0 + 1.0) * 0.4);
    col = mix(col, wash2Col, wash2 * (1.0 - u_ground_show * 0.3) * u_horror_vacui);

    // Zone 3: Center — gold wash
    float wash3 = paintAlpha(uv + vec2(0.3, 0.7), 3.7) *
                  smoothstep(0.55, 0.15, length(uv - vec2(0.50, 0.52)));
    vec3 wash3Col = vec3(1.000, 0.843, 0.000) * (0.5 + noise(uv * 8.0 + 2.0) * 0.5);
    col = mix(col, wash3Col, wash3 * (1.0 - u_ground_show * 0.35) * u_horror_vacui * 0.8);

    // Zone 4: Upper right — deep blue
    float wash4 = paintAlpha(uv + vec2(0.9, 0.1), 4.9) *
                  smoothstep(0.65, 0.20, length(uv - vec2(0.80, 0.75)));
    vec3 wash4Col = vec3(0.098, 0.098, 0.439) * (0.7 + noise(uv * 9.0 + 3.0) * 0.3);
    col = mix(col, wash4Col, wash4 * (1.0 - u_ground_show * 0.3) * u_horror_vacui * 0.9);

    // Gestural brushwork on top
    float brushwork = brushworkLayer(uv + vec2(fbm(uv * 3.0) * u_mark_wobble * 0.1, 0.0));
    float brushSeed = fbm(uv * 1.5) * 0.8 + 0.1;
    vec3 brushColor;
    if (brushSeed < 0.25)      brushColor = vec3(0.545, 0.000, 0.000);  // dark red
    else if (brushSeed < 0.50) brushColor = vec3(0.855, 0.647, 0.125);  // gold
    else if (brushSeed < 0.75) brushColor = vec3(0.133, 0.545, 0.133);  // green
    else                        brushColor = vec3(0.098, 0.098, 0.439);  // midnight blue
    col = mix(col, brushColor, brushwork * u_horror_vacui * 0.85);

    // Ground showing through — the more u_ground_show, the more visible
    // Blend back toward original ground in areas
    float groundReveal = fbm(uv * 4.0 + u_time * 0.01) * u_ground_show;
    col = mix(col, groundColor, groundReveal * 0.5);

    // Paint texture / impasto effect
    if (u_crayon_texture > 0.0) {
        float impasto = noise(uv * 100.0) * noise(uv * 50.0 + 1.0) * 0.1;
        col += impasto * u_crayon_texture * 0.15;
        // Brush direction grain
        float brushDir = fbm(uv * 2.0) * 3.14159;
        vec2 bd = vec2(cos(brushDir), sin(brushDir));
        vec2 bp = vec2(-bd.y, bd.x);
        float brushGrain = pow(abs(fract(dot(uv, bp) * 80.0) - 0.5) * 2.0, 6.0);
        col -= brushGrain * u_crayon_texture * 0.08;
    }

    // Drips — paint that ran down
    float dripX = fract(uv.x * 12.0);
    float dripCell = floor(uv.x * 12.0);
    float dripH = hash(vec2(dripCell, 77.0));
    float dripActive = step(0.8, dripH);
    float dripTop = 0.95 - dripH * 0.3;
    float dripLen = hash(vec2(dripCell, 88.0)) * 0.2 + 0.05;
    float dripWidth = 0.008 + noise(vec2(dripCell, uv.y * 20.0)) * u_mark_wobble * 0.01;
    float drip = step(abs(dripX - 0.5), dripWidth) * 
                 step(dripTop - dripLen, uv.y) * step(uv.y, dripTop);
    drip *= dripActive * u_horror_vacui;
    float dripColor = hash(vec2(dripCell, 33.0));
    vec3 dripCol = dripColor < 0.5 ? vec3(1.0, 0.2, 0.1) : vec3(0.1, 0.4, 0.8);
    col = mix(col, dripCol, drip * 0.9);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
