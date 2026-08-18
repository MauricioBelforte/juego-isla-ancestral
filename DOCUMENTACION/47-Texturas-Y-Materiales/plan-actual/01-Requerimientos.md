**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 47: Texturas y Materiales

## ID del Módulo
- **Código:** M47 (CHECKLIST-GLOBAL: ID 47 — Texturas y Materiales; plan maestro: sección 46 "TEXTURAS Y MATERIALES")
- **Carpeta:** `DOCUMENTACION/47-Texturas-Y-Materiales/`
- **Dependencias:** M08 (Mundo Voxel — atlas de bloques), M45 (Arte 3D — slots de material), M46 (Arte 2D — coherencia de paleta), M04 (Godot — StandardMaterial3D/Shader). Relaciones: M61 (Rendimiento), M62 (Memoria), M50 (Vegetación), M51 (Agua), M108 (Pipeline de Assets), M09 (biomas)
- **Delegable desde:** M08 (catálogo de bloques), M45 (slots nombrados), M04 (materiales nativos de Godot)

## 1. Problema

Aurora es un mundo voxel (M08) con ~30 bloques y decenas de props 3D (M45). Sin un sistema de texturas y materiales definido, cada superficie se vería distinta y el proyecto degeneraría en: texturas de resolución inconsistente (unas 2K, otras 64 px), atlas de bloques desalineados, materiales duplicados en memoria (M62), o shaders costosos que rompen el presupuesto de frame (M61). El plan maestro lista explícitamente las superficies: tierra, césped, piedra, arena, arcilla, madera, metal, cristal, hielo, lava, agua, coral, musgo, ruinas, paredes, pisos, techos, muebles, ropa, herramientas, vehículos, vegetación, materiales ancestrales, materiales luminosos y variantes por bioma. El objetivo del módulo es que TODA superficie del juego tenga una textura/material definido, empaquetado en atlas eficientes y con variantes por bioma (M09), sin que el jugador perciba repetición alienante ni costos de rendimiento.

## 2. Objetivo

Definir el sistema de texturas y materiales de la isla: catálogo de superficies (plan maestro completo), atlas por categoría (bloques, mobiliario, personajes, mundo), materiales Godot reutilizables (StandardMaterial3D y shaders solo donde hacen falta: agua, lava, cristal, luminosos), texturas procedurales deterministas para variantes por bioma, y reglas de resolución/compresión verificables. El resultado debe ser un "material kit" central que cualquier superficie del juego consume, con variantes por bioma (M09) y presupuestos de memoria (M62) y de draw calls (M61) respetados.

## 3. Alcance

### 3.1 Dentro del alcance
- Catálogo de superficies del plan maestro (25+): de tierra a materiales ancestrales y luminosos.
- Atlas de bloques (M08/M09): un atlas único con tileset de todos los bloques, con variantes por bioma (M09).
- Atlas de categoría: mobiliario, personajes/ropa, props (consumen los slots de M45).
- Materiales Godot: StandardMaterial3D base + shaders específicos (agua, lava, cristal, emisivos).
- Materiales luminosos: glows con emisión, sin overdraw.
- Variantes por bioma: texturas procedurales deterministas por PRNG de partida (M10).
- Resoluciones y compresión: tabla por categoría; mipmaps; compresión VRAM (M108).
- Validación: `validate_material.gd` (editor) verifica tamaños, atlas alineados, naming.
- Determinismo de generación procedural de texturas (sin RNG en runtime).

### 3.2 Fuera del alcance
- El modelado 3D y los slots de material: M45.
- El arte 2D de UI/iconos: M46 (comparte paleta, no atlas).
- La iluminación global (shaders de luz, GI): M49.
- El pipeline de importación/técnico: M108.
- La lógica de vegetación/agua del mundo: M50/M51 (consumen materiales definidos aquí).
- Los shaders de post-procesado: M49.

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** materials nativos (StandardMaterial3D), shaders solo donde se justifican.
- **Presupuesto:** cada material/textura se registra contra M61/M62 (memoria de VRAM acotada).
- **Determinismo:** texturas procedurales generadas con PRNG de partida (M10); jamás RNG en runtime.
- **Atlas de bloques:** alineación estricta a la grilla voxel de M08 (1 texel = 1 px en 16px/tile o 32px/tile).
- **Reutilización:** un material por superficie base + variantes por bioma/color; prohibido un material por instancia.
- **Compresión:** VRAM comprimida (S3TC/BC) para runtime, PNG fuente en repo (M108).
- **Cozy:** paleta pastel (M45/M46/M09); texturas sin ruido excesivo ni brillos agresivos.
- **Validable:** cada textura/material pasa `validate_material.gd` previo a importar.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de superficies | Lista completa del plan maestro (25+ superficies) con prioridad y biomas |
| RF2 | Atlas de bloques | Tileset único (M08) con variantes por bioma (M09): tierra, césped, piedra, arena, arcilla, madera, metal, cristal, hielo, lava, agua, coral, musgo |
| RF3 | Variantes por bioma | Cada superficie base tiene variantes de color/patrón por bioma, procedurales deterministas |
| RF4 | Materiales de personajes | Ropa (M19/M11) con slots de material y recolor por NPC |
| RF5 | Materiales de mobiliario | Muebles y construcción (M17/M18) con atlas propio |
| RF6 | Materiales de ruinas/templos | Ruinas (M25), templos (M24/M26) con acabado ancestral |
| RF7 | Materiales luminosos | Glows emisivos (esporas de luz M11, materiales ancestrales) sin overdraw |
| RF8 | Agua | Material transparente con onda suave determinista (no shader pesado; ver M51) |
| RF9 | Lava | Emisión + movimiento suave; presencia solo en Cenizas/islas volcánicas |
| RF10 | Cristal | Transparencia + refracción ligera (shader dedicado acotado) |
| RF11 | Variantes de herramientas | 9 herramientas × 4 niveles (M13) con materiales distintos por nivel |
| RF12 | Validación automática | `validate_material.gd`: resolución, alineación de atlas, naming, memoria estimada |
| RF13 | Naming | Prefijos `tex_` (textura), `mat_` (material), `atlas_` (atlas) con convención M108 |
| RF14 | Registro de presupuesto | Cada textura declara resolución y formato; suma contra M62 |
| RF15 | Determinismo procedural | Script de generación de texturas procedurales reproduce el mismo resultado con la misma semilla |

## 6. Requisitos No Funcionales

- **Rendimiento:** un draw call por material compartido; los shaders costosos ≤ 2 en escena; sin texturas > 2K en runtime.
- **Memoria (M62):** atlas por categoría ≤ 2K; estimación de VRAM por escena en el registro (RF14).
- **Variedad percibida:** cada textura base tiene ≥ 3 variantes por bioma para romper la repetición.
- **Cozy:** paleta derivada de M09; prohibidos contrastes agresivos y parpadeos.
- **Mantenible:** fuentes procedurales (scripts) versionadas; PNG fuente en repo, texturas comprimidas generadas en build (M108).
- **Consistencia:** el atlas de bloques es ÚNICO; prohibido duplicar un bloque en otro atlas.

## 7. Criterios de Aceptación

1. El catálogo de superficies (RF1) lista las 25+ superficies del plan maestro, todas con material asignado.
2. El atlas de bloques (RF2) contiene todos los bloques de M08 y sus variantes por bioma; un bloque jamás aparece en dos atlas.
3. Generando el mundo con una semilla (M10), dos partidas producen exactamente las mismas variantes procedurales.
4. Un material de personaje recolicado (RF4) no duplica memoria: comparte la textura base.
5. La lava y el cristal usan sus shaders dedicados y no más de 2 shaders costosos coinciden en escena.
6. El validador rechaza una textura 4K o desalineada del atlas con mensaje accionable.
7. La estimación de VRAM por escena típica (pueblo) no supera el presupuesto de M62.
8. Todas las superficies cumplen convenciones de nombres M108 y Git LFS.

## 8. Fuentes de Contexto (plan maestro)

- Sección 46 "TEXTURAS Y MATERIALES": Tierra, Césped, Piedra, Arena, Arcilla, Madera, Metal, Cristal, Hielo, Lava, Agua, Coral, Musgo, Ruinas, Paredes, Pisos, Techos, Muebles, Ropa, Herramientas, Vehículos, Vegetación, Materiales ancestrales, Materiales luminosos, Variantes por bioma.
- Plan de producción §4: paleta por bioma, coherencia visual, low-poly redondeado en materiales.
- M152: performance prioridad sobre visuales; licencias de assets claras.