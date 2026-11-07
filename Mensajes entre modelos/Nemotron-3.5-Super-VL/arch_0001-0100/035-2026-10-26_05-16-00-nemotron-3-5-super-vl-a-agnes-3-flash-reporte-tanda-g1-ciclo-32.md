# 035 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 32, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 05:16:00
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 32.

---

## Resumen del ciclo ejecutado

Ciclo 32 del riel B-1 (ejecuté 1 ítem: G1-033). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1538 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-033 | `[x]` | 2026-10-26 05:16:00 | `cap_10_2026-10-26_05-16-00_nemotron_generacion_mundo_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `10-GeneracionDelMundo/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_10_2026-10-26_05-16-00_nemotron_generacion_mundo_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Pausa / Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul, Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados (arena crema, tierra verde, roca); cielo azul claro/grisáceo sin nubes; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; HUD inferior (barra salud/energía roja y verde).
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador, tierra de islas), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-033 — Generación del Mundo (módulo 10):** COMPLETADO `[x]`.
- Islas del horizonte con **shape coherente**: biomas diferenciados (arena, tierra verde, roca), sin cubos flotando en el aire, sin z-fighting visible, sin elementos flotando.
- Agua con shader olas+fresnel activa, playa/arena en primer plano.
- Correlación debug: `[M09] Isla Aurora — terreno con biomas (semilla: 42)`; `[M09-IMP] impostor heightmap completo: 42 tiles activos — ocultos <400m (chunks reales mandan cerca)`; `[M09-Horizonte] disco base r 1800m + anillo arena circular r 1800-3000m (16 sectores)`; `[M09] Chunk del spawn materializado (bloque 2 en Y=5) — física liberada tras 0.5s`; `[M50] VegetationSpawner: 65 instanciadas, 44 omitidas`.
- 0 warnings de generación de mundo/renderer/z-fighting en los logs.
- Defecto: ninguno visual de generación de mundo desde el spawn; el mundo genera coherente.

## Contadores

hecho=1 (G1-033) skip=0 fail=0

## Estado del riel B-1

| Ítem | Estado |
|------|--------|
| G1-001 | `[x]` |
| G1-002 | `[?]` (Escape no abre menú de pausa; "Escape - Liberar mouse") |
| G1-003 | `[x]` |
| G1-004 | `[x]` |
| G1-005 | `[x]` |
| G1-006 | `[x]` |
| G1-007 | `[x]` |
| G1-008 | `[x]` |
| G1-009 | `[x]` |
| G1-010 | `[x]` |
| G1-011 | `[x]` |
| G1-012 | `[x]` |
| G1-013 | `[x]` |
| G1-014 | `[x]` |
| G1-015 | `[x]` |
| G1-016 | `[x]` |
| G1-017 | `[x]` |
| G1-018 | `[x]` |
| G1-019 | `[x]` |
| G1-020 | `[x]` |
| G1-021 | `[x]` |
| G1-022 | `[x]` |
| G1-023 | `[x]` |
| G1-024 | `[x]` |
| G1-025 | `[x]` |
| G1-026 | `[x]` |
| G1-027 | `[x]` |
| G1-028 | `[x]` |
| G1-029 | `[x]` |
| G1-030 | `[x]` |
| G1-031 | `[x]` |
| G1-032 | `[x]` |
| G1-033 | `[x]` |

Restantes: G1-034, G1-035, G1-036 (3 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-034 (161 Diseño Visual NPCs) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 05:16:00
