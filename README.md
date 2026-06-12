# outsider_art_style

made outside. made without permission. made because it had to be made.

Art Brut / Outsider Art / Visionary Folk Art — Henry Darger's epic armies of girls, Adolf Wölfli's musical cosmologies, Howard Finster's religious fever, Thornton Dial's scrap-metal allegories. Made without art school, without galleries, without knowing that's what you were doing.

## What This Is

Ten GLSL fragment shaders encoding the visual logic of outsider art as generative substrate. Not appropriation — distillation. The mark-making compulsion, compositional anarchy, obsessive repetition, and direct relationship between maker and material that defines art made from necessity.

An interactive WebGL gallery. Runs in the browser. Fully real-time.

## Quick Start

```bash
npm install
npm run dev
```

Navigate shaders with **← →** arrow keys or the Prev/Next buttons. Adjust parameters in the right panel.

## Shaders

| # | Name | Regime | Artist Reference |
|---|------|--------|-----------------|
| 01 | Horror Vacui | HORROR_VACUI | Emma Kunz · Wölfli margins · Darger battle scenes |
| 02 | Darger Army | REPEATED_FIGURE | Henry Darger — In the Realms of the Unreal |
| 03 | Wölfli Cosmic | VISIONARY_MAP | Adolf Wölfli — Vom Cradle bis zum Grab |
| 04 | Finster Gospel | TEXT_IMAGE | Howard Finster — Man of Visions (46,000 works) |
| 05 | Found Ground | FOUND_GROUND | Darger · Dial · Zemánková — substrate as meaning |
| 06 | Visionary Map | VISIONARY_MAP | Wölfli cosmography · Darger's Abbiennia |
| 07 | Repeated Figure | REPEATED_FIGURE | Wölfli margin faces · Darger armies · Madge Gill |
| 08 | Text Image | TEXT_IMAGE | Finster · Wölfli · Darger · St. EOM |
| 09 | Crayon Field | FOUND_GROUND | The pure mark — before the image arrives |
| 10 | Dial Scrap | FOUND_GROUND | Thornton Dial Sr. — found metal, tigers, Birmingham |

## Visual DNA

**Core signatures:**
- Horror vacui: fill every available space. Empty space is anxiety.
- Obsessive repetition: the same mark, figure, or symbol iterated hundreds of times
- Direct mark: no correction, no underdrawing, crayon/paint/marker directness
- Naive anatomy: figures that know what a body is but not how it works
- Text integration: words written directly into image, often misspelled, always meaningful
- Found materials: newspaper, cardboard, wood grain showing through
- Flat color: no shadow modeling, pure local color, objects identified not depicted
- Visionary content: angels, demons, cosmic diagrams, personal mythology

**Color palettes:**
- `DARGER_VIVID`: `#FF4136` · `#2ECC40` · `#FFDC00` · `#0074D9` · `#FF69B4`
- `WOLFLI_COSMIC`: `#8B0000` · `#DAA520` · `#191970` · `#228B22` · `#F5DEB3`
- `FINSTER_PRIMITIVE`: `#FF6347` · `#32CD32` · `#FFD700` · `#8B4513`
- `CHALK_BOARD`: `#2C5F2E` · `#FFFFFF` · `#FFD700` · `#FF4500`
- `CRAYON_BOX`: `#FF2400` · `#0047AB` · `#FFD700` · `#228B22` · `#FF69B4` · `#8B4513`

## Shader Parameters

```glsl
uniform float u_horror_vacui;       // 0.0–1.0  fill density drive
uniform float u_mark_wobble;        // 0.0–0.3  stroke variation (the hand's pulse)
uniform float u_repeat_density;     // 1.0–50.0 figure repetition
uniform float u_ground_show;        // 0.0–1.0  found material / substrate visibility
uniform float u_text_density;       // 0.0–1.0  text-as-texture amount
uniform float u_crayon_texture;     // 0.0–1.0  waxy stroke texture intensity
```

## Aesthetic Regimes

### `HORROR_VACUI` — Every space filled
Dense. Packed. Figures overlapping figures. Borders within borders. Text in the gaps. No negative space exists. Every pixel is claimed.

### `VISIONARY_MAP` — Personal cosmology as diagram
Geometric structures. Labeled zones. Repeated symbols. Part map, part mandala, part manifesto. The cosmos according to one person.

### `REPEATED_FIGURE` — The obsessive image
One figure (or figure type) repeated across the surface with slight variations. Army of angels. Field of faces. Forest of trees-as-people. Repetition as prayer.

### `FOUND_GROUND` — Material shows through
Newspaper, cardboard, or wood grain is the ground. Paint sits on top, not hiding it. The material is part of the image. The accident is intention.

### `TEXT_IMAGE` — Words as visual texture
Text written directly into the image. Labels everything. Tells stories. Sometimes illegible. Always present. Always urgent.

## Shared Math Primitives

See [`src/shaders/common.glsl`](src/shaders/common.glsl) for the shared library:
- `hash(vec2)`, `noise(vec2)`, `fbm(vec2)` — noise foundation
- `wobble(uv, amount)` — the pulse of the maker's hand
- `crayonGrain(uv, time)` — waxy parallel stroke texture
- `newspaperGround(uv)` — text column substrate simulation
- `patternFill(uv, density, time)` — packed motif field (cross/star/flower)
- `naiveFigure(p)` — body that knows what it is but not how it works
- `textTexture(uv, density)` — words as marks
- `nestedBorders(uv, count, gap, thickness, wobble)` — the obsessive frame
- `dargerVivid(t)`, `wolfliCosmic(t)`, `finsterPrimitive(t)`, `crayonBox(t)` — palettes

## File Structure

```
outsider_art_style/
├── README.md
├── package.json          — Vite + Three.js
├── vite.config.js
├── index.html            — Gallery viewer with parameter UI
├── src/
│   ├── main.js           — Three.js gallery + shader switching
│   ├── style.frag.glsl   — Base shader stub
│   └── shaders/
│       └── common.glsl   — Shared math primitives
├── shader_examples/
│   ├── preview.frag.glsl
│   ├── 01_horror_vacui.frag.glsl
│   ├── 02_darger_army.frag.glsl
│   ├── 03_wolfli_cosmic.frag.glsl
│   ├── 04_finster_gospel.frag.glsl
│   ├── 05_found_ground.frag.glsl
│   ├── 06_visionary_map.frag.glsl
│   ├── 07_repeated_figure.frag.glsl
│   ├── 08_text_image.frag.glsl
│   ├── 09_crayon_field.frag.glsl
│   └── 10_dial_scrap.frag.glsl
├── docs/
│   └── mark-making-systems.md
└── outsider_art_style/
    ├── README.md
    ├── context.manifest.json
    └── repo_seed.txt
```

## Stack

Three.js + WebGL2 + GLSL + Vite

## Ecosystem

Part of the [merrypranxter](https://github.com/merrypranxter) generative art pipeline.  
RepoScripter2 context source. ShaderForge style module.

Use with: `cave_art`, `ancient_hindu_art`, `garbage_enlightenment_style`, `psychedelic_collage`

---

The wobble is not imperfection. It is the pulse of the maker's hand.
