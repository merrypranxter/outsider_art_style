# outsider_art_style

made outside. made without permission. made because it had to be made.

Art Brut / Outsider Art / Visionary Folk Art — Henry Darger's epic armies of girls, Adolf Wölfli's musical cosmologies, Howard Finster's religious fever, Thornton Dial's scrap-metal allegories. Made without art school, without galleries, without knowing that's what you were doing.

## What This Is

Visual language of Outsider Art as generative substrate — not appropriation, but distillation. The mark-making logic, compositional anarchy, obsessive repetition, and direct relationship between maker and material that defines art made from necessity.

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
- `DARGER_VIVID`: `#FF4136` (blood red), `#2ECC40` (cartoon green), `#FFDC00` (bright yellow), `#0074D9` (blue), `#FF69B4` (pink)
- `WÖLFLI_COSMIC`: `#8B0000` (dark red), `#DAA520` (gold), `#191970` (midnight blue), `#228B22` (forest green), `#F5DEB3` (wheat paper)
- `FINSTER_PRIMITIVE`: `#FF6347` (tomato), `#32CD32` (lime), `#FFD700` (gold), `#8B4513` (saddle brown)
- `CHALK_BOARD`: `#2C5F2E`, `#FFFFFF`, `#FFD700`, `#FF4500`
- `CRAYON_BOX`: `#FF2400`, `#0047AB`, `#FFD700`, `#228B22`, `#FF69B4`, `#8B4513`

**Mark-making:**
- Crayon texture: waxy parallel strokes with slight direction variation
- Marker line: consistent weight stroke, slightly wobbly
- Dense hatching: overlapping short strokes filling form
- Newspaper ground: regular text columns showing through translucent paint
- Pattern fill: repeated small motif (flower, star, cross) packed into areas

## Aesthetic Regimes

### `HORROR_VACUI` — Every space filled
Dense. Packed. Figures overlapping figures. Borders within borders. Text in the gaps. No negative space exists.

### `VISIONARY_MAP` — Personal cosmology as diagram
Geometric structures. Labeled zones. Repeated symbols. Part map, part mandala, part manifesto. The cosmos according to one person.

### `REPEATED_FIGURE` — The obsessive image
One figure (or figure type) repeated across the surface with slight variations. Army of angels. Field of faces. Forest of trees-as-people.

### `FOUND_GROUND` — Material shows through
Newspaper, cardboard, or wood grain is the ground. Paint sits on top of it, not hiding it. The material is part of the image.

### `TEXT_IMAGE` — Words as visual texture
Text written directly into the image. Labels everything. Tells stories. Sometimes illegible. Always present.

## Shader Parameters

```glsl
uniform float u_horror_vacui;       // 0.0–1.0, fill density drive
uniform float u_mark_wobble;        // 0.0–0.3, stroke variation
uniform float u_repeat_density;     // 1.0–50.0, figure repetition
uniform float u_ground_show;        // 0.0–1.0, found material visibility
uniform float u_text_density;       // 0.0–1.0, text-as-texture amount
uniform float u_crayon_texture;     // 0.0–1.0, waxy stroke texture
```

## Ecosystem

Part of the [merrypranxter](https://github.com/merrypranxter) generative art pipeline.
RepoScripter2 context source. ShaderForge style module.

Use with: `cave_art`, `ancient_hindu_art`, `garbage_enlightenment_style`, `psychedelic_collage`
