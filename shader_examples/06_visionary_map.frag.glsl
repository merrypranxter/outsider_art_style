// 06_visionary_map.frag.glsl
// VISIONARY MAP — Personal cosmology as diagram.
// Part map, part mandala, part manifesto.
// The world according to one person who has seen how it really works.
//
// Aesthetic logic: geometric diagram with labeled zones.
// Concentric regions named (simulated), cardinal directions marked.
// Symbols for each territory. Roads/rivers as lines of force.
// The observer is always at the center — the map is self-referential.
//
// References: Wölfli's cosmographic maps,
//             Henry Darger's invented continent of "Abbiennia",
//             James Hampton's "The Throne of the Third Heaven"

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

// Map region colors — each zone has its territory color
vec3 zoneColor(float zoneId) {
    // Flat local colors — territories on a map
    float z = fract(zoneId * 0.137 + 0.05);
    if (z < 0.14) return vec3(0.961, 0.871, 0.702); // wheat/parchment
    if (z < 0.28) return vec3(0.545, 0.000, 0.000); // dark red
    if (z < 0.42) return vec3(0.855, 0.647, 0.125); // gold
    if (z < 0.56) return vec3(0.098, 0.098, 0.439); // midnight blue
    if (z < 0.70) return vec3(0.133, 0.545, 0.133); // forest green
    if (z < 0.84) return vec3(0.545, 0.271, 0.075); // brown
    return vec3(0.400, 0.000, 0.400);                // purple
}

// Voronoi regions — territories of the map
float voronoi(vec2 p, out float cellId) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minDist = 10.0;
    cellId = 0.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 h = vec2(hash(i + neighbor + 0.1), hash(i + neighbor + 0.2));
            // Slight drift over time — the territories shift
            h += 0.1 * vec2(sin(u_time * 0.02 + h.x * 6.28), cos(u_time * 0.02 + h.y * 6.28));
            vec2 diff = neighbor + h - f;
            float dist = length(diff);
            if (dist < minDist) {
                minDist = dist;
                cellId = hash(i + neighbor + 77.3);
            }
        }
    }
    return minDist;
}

// Territory boundaries — the drawn borders
float territoryBorder(vec2 p, float scale) {
    float cellId;
    float d = voronoi(p * scale, cellId);
    float wobW = noise(p * 20.0) * u_mark_wobble * 0.05;
    return 1.0 - smoothstep(0.025 - wobW, 0.055 + wobW, d);
}

// Compass rose at center
float compassRose(vec2 p) {
    float r = length(p);
    float a = atan(p.y, p.x);
    
    // Primary arms (N,S,E,W)
    float primary = cos(a * 2.0);
    float primaryShape = 1.0 - smoothstep(r, 0.0, 0.22 * abs(primary));
    primaryShape *= step(r, 0.22);
    
    // Secondary arms (NE,NW,SE,SW)
    float secondary = cos(a * 2.0 + 0.7854);
    float secondaryShape = 1.0 - smoothstep(r, 0.0, 0.14 * abs(secondary));
    secondaryShape *= step(r, 0.14);
    
    // Center dot
    float center = 1.0 - smoothstep(0.012, 0.018, r);
    
    // Outer ring
    float ring = 1.0 - smoothstep(0.002, 0.006, abs(r - 0.26));
    
    return max(max(primaryShape, secondaryShape), max(center, ring));
}

// Road/river lines — lines of force across the map
float mapLine(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float d = length(pa - ba * h);
    float wobble = noise(p * 25.0 + vec2(h * 5.0)) * u_mark_wobble * 0.015;
    return 1.0 - smoothstep(width - wobble, width + 0.004, d);
}

// Symbol for a map territory — small schematic mark
float mapSymbol(vec2 p, float symbolType) {
    float s = 0.0;
    if (symbolType < 0.2) {
        // Mountain triangle
        float h = -p.y + 0.25;
        float side = abs(p.x) / max(h, 0.001);
        s = step(side, 1.0) * step(0.0, h) * step(h, 0.32);
    } else if (symbolType < 0.4) {
        // Settlement square
        s = step(abs(p.x), 0.22) * step(abs(p.y), 0.22);
        s = max(s, 1.0 - step(0.16, min(abs(abs(p.x)-0.22), abs(abs(p.y)-0.22))));
    } else if (symbolType < 0.6) {
        // Tree circle
        s = 1.0 - smoothstep(0.18, 0.23, length(p));
        s = max(s, 1.0 - smoothstep(0.005, 0.012, abs(length(p) - 0.30)));
    } else if (symbolType < 0.8) {
        // River source (spiral)
        float r = length(p);
        float a = atan(p.y, p.x);
        float spiral = abs(fract((a / 6.28318 + r * 2.0)) - 0.5);
        s = step(spiral, 0.12) * step(r, 0.35);
    } else {
        // Sacred site (star)
        float a = atan(p.y, p.x);
        float star = 0.5 + 0.5 * cos(a * 6.0);
        s = 1.0 - smoothstep(0.3 * star + 0.1, 0.3 * star + 0.15, length(p));
    }
    return s;
}

// Text labels — zone names (simulated handwritten text)
float zoneLabel(vec2 uv, vec2 center, float scale) {
    vec2 local = (uv - center) / scale;
    // Two lines of "text"
    float line1 = abs(local.y - 0.3);
    float line2 = abs(local.y + 0.3);
    float onLine = step(line1, 0.08) + step(line2, 0.08);
    float charW = 0.18;
    float charX = mod(local.x + 1.0, charW) / charW;
    float cid = hash(vec2(floor((local.x + 1.0) / charW), floor((local.y + 1.0) / 0.6) + center.x * 10.0));
    float charF = step(0.1, charX) * step(charX, 0.55 + cid * 0.35);
    float inBounds = step(abs(local.x), 0.9) * step(abs(local.y), 0.7);
    return min(onLine, 1.0) * charF * step(0.25, cid) * inBounds;
}

// Grid overlay — the surveyor's grid beneath personal geography
float surveyGrid(vec2 uv, float density) {
    vec2 grid = abs(fract(uv * density) - 0.5);
    float gLine = min(grid.x, grid.y);
    float wobW = noise(uv * 40.0) * u_mark_wobble * 0.01;
    return 1.0 - smoothstep(0.01 - wobW, 0.02 + wobW, gLine);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvA = vec2(uv.x * aspect, uv.y);
    vec2 p = uvA - vec2(0.5 * aspect, 0.5);  // centered

    // Parchment / paper ground
    float paperAge = fbm(uv * 20.0) * 0.05 + noise(uv * 60.0) * 0.03;
    vec3 parchment = vec3(0.920 - paperAge, 0.870 - paperAge * 0.8, 0.720 - paperAge * 0.5);
    vec3 col = parchment;

    // Survey grid (fine background grid — the coordinate system)
    float gridDensity = 10.0 + u_repeat_density * 0.5;
    float grid = surveyGrid(uv, gridDensity);
    col = mix(col, vec3(0.780, 0.730, 0.600), grid * 0.4);

    // Voronoi territories
    float cellId;
    float vDist = voronoi(uv * (4.0 + u_repeat_density * 0.2), cellId);
    
    // Fill territories with zone colors
    vec3 territory = zoneColor(cellId);
    float fillStrength = u_horror_vacui * 0.5;
    col = mix(col, territory, fillStrength * (1.0 - vDist * 2.0) * step(0.0, 0.5 - vDist));

    // Territory borders — the drawn lines
    float border = territoryBorder(uv, 4.0 + u_repeat_density * 0.2);
    col = mix(col, vec3(0.15, 0.08, 0.02), border * 0.8);

    // Roads/rivers — major lines of force
    float roads = 0.0;
    roads = max(roads, mapLine(uv, vec2(0.0, 0.5), vec2(1.0, 0.5), 0.006));     // E-W road
    roads = max(roads, mapLine(uv, vec2(0.5, 0.0), vec2(0.5, 1.0), 0.006));     // N-S road
    roads = max(roads, mapLine(uv, vec2(0.0, 0.2), vec2(1.0, 0.75), 0.004));    // diagonal road
    roads = max(roads, mapLine(uv, vec2(0.15, 0.0), vec2(0.85, 1.0), 0.004));   // diagonal
    // River (thicker, blue)
    float river = mapLine(uv + fbm(uv * 5.0) * 0.02, vec2(0.0, 0.35), vec2(0.60, 0.40), 0.010);
    river = max(river, mapLine(uv + fbm(uv * 5.0 + 1.0) * 0.02, vec2(0.60, 0.40), vec2(1.0, 0.30), 0.010));
    col = mix(col, vec3(0.15, 0.08, 0.02), roads * 0.7);
    col = mix(col, vec3(0.098, 0.098, 0.439), river * 0.85);

    // Territory symbols — marks in each zone
    float symDensity = 5.0 + u_repeat_density * 0.2;
    vec2 symCell = floor(uv * symDensity);
    vec2 symLocal = fract(uv * symDensity) - 0.5;
    float symH = hash(symCell + 111.7);
    float symActive = step(0.55, symH);
    float symType = hash(symCell + 222.3);
    float sym = mapSymbol(symLocal * 2.5, symType);
    float symColor = hash(symCell + 333.9);
    vec3 symCol = zoneColor(symColor);
    col = mix(col, symCol * 0.7, sym * symActive * u_horror_vacui * 0.8);

    // Zone labels (simulated handwritten text in territory centers)
    if (u_text_density > 0.0) {
        for (float li = 0.0; li < 6.0; li++) {
            float lx = hash(vec2(li, 0.1)) * 0.7 + 0.15;
            float ly = hash(vec2(li, 0.2)) * 0.7 + 0.15;
            float ls = 0.04 + hash(vec2(li, 0.3)) * 0.02;
            float lbl = zoneLabel(uv, vec2(lx, ly), ls);
            col = mix(col, vec3(0.08, 0.04, 0.01), lbl * u_text_density * 0.8);
        }
    }

    // Compass rose at center
    float compassSize = 0.06;
    vec2 compassP = p / compassSize;
    float compass = compassRose(compassP);
    vec3 compassCol = vec3(0.545, 0.000, 0.000); // dark red compass
    col = mix(col, compassCol, compass * 0.9);

    // Scale bar at bottom
    float scaleY = smoothstep(0.025, 0.018, uv.y);
    float scaleX = step(0.15, uv.x) * step(uv.x, 0.85);
    float scaleBar = scaleY * scaleX;
    // Alternating black/white segments
    float scaleSeg = step(0.5, fract(uv.x * 8.0));
    col = mix(col, mix(vec3(0.08), vec3(0.95), scaleSeg), scaleBar * 0.7);

    // North arrow (top center)
    vec2 arrowP = uv - vec2(0.5, 0.94);
    float arrowH = -arrowP.y + 0.025;
    float arrowSide = abs(arrowP.x) / max(arrowH * 2.0, 0.001);
    float northArrow = step(arrowSide, 1.0) * step(0.0, arrowH) * step(arrowH, 0.03);
    col = mix(col, vec3(0.545, 0.000, 0.000), northArrow * 0.9);

    // Title area — border at top
    float titleBorder = smoothstep(0.965, 0.970, uv.y);
    col = mix(col, vec3(0.08, 0.04, 0.01), titleBorder * 0.8);

    // Outer border with decorative corners
    vec2 bEdge = min(uv, 1.0 - uv);
    float outerBorder = 1.0 - smoothstep(0.016, 0.022, min(bEdge.x, bEdge.y));
    float innerBorder = 1.0 - smoothstep(0.032, 0.038, min(bEdge.x, bEdge.y));
    float doubleBorder = max(outerBorder, innerBorder * 0.5);
    col = mix(col, vec3(0.15, 0.08, 0.02), doubleBorder * 0.9);

    // Aged vignette
    float vig = 1.0 - length((uv - 0.5) * 1.4) * 0.35;
    col *= vig;

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
