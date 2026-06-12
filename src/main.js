import * as THREE from 'three';

// ─── SHADER REGISTRY ────────────────────────────────────────────────────────
// Each entry: name, source URL, artist/regime reference, palette name
const SHADERS = [
  {
    name: 'Horror Vacui',
    file: '../shader_examples/01_horror_vacui.frag.glsl',
    regime: 'HORROR_VACUI',
    artist: 'Emma Kunz · Wölfli margins · Darger battle scenes',
    palette: 'DARGER_VIVID',
    defaults: { u_horror_vacui: 0.92, u_mark_wobble: 0.15, u_repeat_density: 12.0, u_ground_show: 0.1, u_text_density: 0.5, u_crayon_texture: 0.6 },
  },
  {
    name: 'Darger Army',
    file: '../shader_examples/02_darger_army.frag.glsl',
    regime: 'REPEATED_FIGURE',
    artist: 'Henry Darger — In the Realms of the Unreal',
    palette: 'DARGER_VIVID',
    defaults: { u_horror_vacui: 0.9, u_mark_wobble: 0.12, u_repeat_density: 8.0, u_ground_show: 0.0, u_text_density: 0.3, u_crayon_texture: 0.5 },
  },
  {
    name: 'Wölfli Cosmic',
    file: '../shader_examples/03_wolfli_cosmic.frag.glsl',
    regime: 'VISIONARY_MAP',
    artist: 'Adolf Wölfli — Vom Cradle bis zum Grab',
    palette: 'WOLFLI_COSMIC',
    defaults: { u_horror_vacui: 0.85, u_mark_wobble: 0.10, u_repeat_density: 8.0, u_ground_show: 0.2, u_text_density: 0.6, u_crayon_texture: 0.4 },
  },
  {
    name: 'Finster Gospel',
    file: '../shader_examples/04_finster_gospel.frag.glsl',
    regime: 'TEXT_IMAGE',
    artist: 'Howard Finster — Man of Visions (46,000 works)',
    palette: 'FINSTER_PRIMITIVE',
    defaults: { u_horror_vacui: 0.88, u_mark_wobble: 0.18, u_repeat_density: 5.0, u_ground_show: 0.4, u_text_density: 0.8, u_crayon_texture: 0.3 },
  },
  {
    name: 'Found Ground',
    file: '../shader_examples/05_found_ground.frag.glsl',
    regime: 'FOUND_GROUND',
    artist: 'Darger · Dial · Zemánková — substrate as meaning',
    palette: 'WOLFLI_COSMIC',
    defaults: { u_horror_vacui: 0.7, u_mark_wobble: 0.20, u_repeat_density: 6.0, u_ground_show: 0.7, u_text_density: 0.2, u_crayon_texture: 0.6 },
  },
  {
    name: 'Visionary Map',
    file: '../shader_examples/06_visionary_map.frag.glsl',
    regime: 'VISIONARY_MAP',
    artist: 'Wölfli cosmography · Darger\'s Abbiennia · Hampton\'s Throne',
    palette: 'WOLFLI_COSMIC',
    defaults: { u_horror_vacui: 0.75, u_mark_wobble: 0.12, u_repeat_density: 5.0, u_ground_show: 0.3, u_text_density: 0.7, u_crayon_texture: 0.2 },
  },
  {
    name: 'Repeated Figure',
    file: '../shader_examples/07_repeated_figure.frag.glsl',
    regime: 'REPEATED_FIGURE',
    artist: 'Wölfli margin faces · Darger armies · Madge Gill',
    palette: 'CRAYON_BOX',
    defaults: { u_horror_vacui: 0.9, u_mark_wobble: 0.15, u_repeat_density: 12.0, u_ground_show: 0.1, u_text_density: 0.4, u_crayon_texture: 0.5 },
  },
  {
    name: 'Text Image',
    file: '../shader_examples/08_text_image.frag.glsl',
    regime: 'TEXT_IMAGE',
    artist: 'Finster · Wölfli · Darger · St. EOM — the word as mark',
    palette: 'WOLFLI_COSMIC',
    defaults: { u_horror_vacui: 0.8, u_mark_wobble: 0.12, u_repeat_density: 8.0, u_ground_show: 0.2, u_text_density: 0.9, u_crayon_texture: 0.3 },
  },
  {
    name: 'Crayon Field',
    file: '../shader_examples/09_crayon_field.frag.glsl',
    regime: 'FOUND_GROUND',
    artist: 'The pure mark — automatic drawing before the image',
    palette: 'CRAYON_BOX',
    defaults: { u_horror_vacui: 0.85, u_mark_wobble: 0.20, u_repeat_density: 4.0, u_ground_show: 0.3, u_text_density: 0.0, u_crayon_texture: 0.95 },
  },
  {
    name: 'Dial Scrap',
    file: '../shader_examples/10_dial_scrap.frag.glsl',
    regime: 'FOUND_GROUND',
    artist: 'Thornton Dial Sr. — found metal, tigers, dignity, Birmingham',
    palette: 'FINSTER_PRIMITIVE',
    defaults: { u_horror_vacui: 0.88, u_mark_wobble: 0.18, u_repeat_density: 3.0, u_ground_show: 0.5, u_text_density: 0.2, u_crayon_texture: 0.7 },
  },
];

// ─── RENDERER SETUP ─────────────────────────────────────────────────────────
const scene = new THREE.Scene();
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
document.body.appendChild(renderer.domElement);

const geometry = new THREE.PlaneGeometry(2, 2);

const vertexShader = `void main() { gl_Position = vec4(position, 1.0); }`;

// Fallback fragment shader (shown while loading)
const fallbackFrag = `
  precision highp float;
  uniform float u_time;
  uniform vec2 u_resolution;
  void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float h = fract(sin(dot(floor(uv*20.0), vec2(127.1,311.7)))*43758.5);
    gl_FragColor = vec4(vec3(h * 0.3 + 0.5, h * 0.2 + 0.3, 0.2), 1.0);
  }
`;

// ─── STATE ──────────────────────────────────────────────────────────────────
let currentIndex = 0;
let material = null;
let mesh = null;

const uniformValues = {
  u_time:           { value: 0 },
  u_resolution:     { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
  u_horror_vacui:   { value: 0.9 },
  u_mark_wobble:    { value: 0.15 },
  u_repeat_density: { value: 8.0 },
  u_ground_show:    { value: 0.3 },
  u_text_density:   { value: 0.5 },
  u_crayon_texture: { value: 0.6 },
};

function buildMaterial(fragmentShader) {
  return new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: uniformValues,
  });
}

function applyDefaults(defaults) {
  for (const [key, val] of Object.entries(defaults)) {
    if (uniformValues[key]) uniformValues[key].value = val;
  }
  syncSliders();
}

// ─── SHADER LOADING ─────────────────────────────────────────────────────────
async function loadShader(index) {
  const shader = SHADERS[index];
  let fragSrc;
  try {
    const response = await fetch(shader.file);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    fragSrc = await response.text();
  } catch (e) {
    console.warn(`Could not load ${shader.file}, using fallback`, e);
    fragSrc = fallbackFrag;
  }

  if (mesh) scene.remove(mesh);
  if (material) material.dispose();

  material = buildMaterial(fragSrc);
  mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);

  applyDefaults(shader.defaults);
  updateUI(index);
}

// ─── UI ─────────────────────────────────────────────────────────────────────
const infoEl = document.getElementById('info');
const nameEl = document.getElementById('shader-name');
const artistEl = document.getElementById('shader-artist');
const regimeEl = document.getElementById('shader-regime');
const paletteEl = document.getElementById('shader-palette');
const prevBtn = document.getElementById('btn-prev');
const nextBtn = document.getElementById('btn-next');
const indexEl = document.getElementById('shader-index');

function updateUI(index) {
  const s = SHADERS[index];
  nameEl.textContent = s.name;
  artistEl.textContent = s.artist;
  regimeEl.textContent = s.regime;
  paletteEl.textContent = s.palette;
  indexEl.textContent = `${index + 1} / ${SHADERS.length}`;
}

prevBtn.addEventListener('click', () => {
  currentIndex = (currentIndex - 1 + SHADERS.length) % SHADERS.length;
  loadShader(currentIndex);
});
nextBtn.addEventListener('click', () => {
  currentIndex = (currentIndex + 1) % SHADERS.length;
  loadShader(currentIndex);
});

// Keyboard navigation
window.addEventListener('keydown', (e) => {
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
    currentIndex = (currentIndex + 1) % SHADERS.length;
    loadShader(currentIndex);
  } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
    currentIndex = (currentIndex - 1 + SHADERS.length) % SHADERS.length;
    loadShader(currentIndex);
  }
});

// ─── PARAMETER SLIDERS ───────────────────────────────────────────────────────
const PARAMS = [
  { key: 'u_horror_vacui',   label: 'Horror Vacui',    min: 0, max: 1,  step: 0.01 },
  { key: 'u_mark_wobble',    label: 'Mark Wobble',     min: 0, max: 0.3, step: 0.005 },
  { key: 'u_repeat_density', label: 'Repeat Density',  min: 1, max: 50, step: 0.5 },
  { key: 'u_ground_show',    label: 'Ground Show',     min: 0, max: 1,  step: 0.01 },
  { key: 'u_text_density',   label: 'Text Density',    min: 0, max: 1,  step: 0.01 },
  { key: 'u_crayon_texture', label: 'Crayon Texture',  min: 0, max: 1,  step: 0.01 },
];

const slidersContainer = document.getElementById('sliders');
const sliderEls = {};

PARAMS.forEach(({ key, label, min, max, step }) => {
  const row = document.createElement('div');
  row.className = 'slider-row';

  const lbl = document.createElement('label');
  lbl.textContent = label;

  const input = document.createElement('input');
  input.type = 'range';
  input.min = min;
  input.max = max;
  input.step = step;
  input.value = uniformValues[key].value;

  const val = document.createElement('span');
  val.className = 'slider-val';
  val.textContent = Number(uniformValues[key].value).toFixed(2);

  input.addEventListener('input', () => {
    const v = parseFloat(input.value);
    uniformValues[key].value = v;
    val.textContent = v.toFixed(2);
  });

  sliderEls[key] = { input, val };
  row.appendChild(lbl);
  row.appendChild(input);
  row.appendChild(val);
  slidersContainer.appendChild(row);
});

function syncSliders() {
  for (const [key, { input, val }] of Object.entries(sliderEls)) {
    const v = uniformValues[key].value;
    input.value = v;
    val.textContent = Number(v).toFixed(2);
  }
}

// ─── ANIMATION LOOP ─────────────────────────────────────────────────────────
function animate(time) {
  uniformValues.u_time.value = time * 0.001;
  if (material) renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);

// ─── RESIZE ─────────────────────────────────────────────────────────────────
window.addEventListener('resize', () => {
  renderer.setSize(window.innerWidth, window.innerHeight);
  uniformValues.u_resolution.value.set(window.innerWidth, window.innerHeight);
});

// ─── INIT ────────────────────────────────────────────────────────────────────
loadShader(0);
