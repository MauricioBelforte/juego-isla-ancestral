# 016 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 13, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 22:31:46
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 13.

---

## Resumen del ciclo ejecutado

Ciclo 13 del riel B-1 (ejecuté 1 ítem: G1-014). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-014 | `[x]` | 2026-10-25 22:31:46 | `cap_40_2026-10-25_22-31-46_nemotron_infraestructura_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `40-Infraestructura/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_40_2026-10-25_22-31-46_nemotron_infraestructura_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro; agua azul clara; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes; cubo naranja/amarillo (nodo de recurso) a la derecha del jugador.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS), gris claro (cielo), naranja/amarillo (nodo de recurso).

## Hallazgos

**G1-014 — Infraestructura (módulo 40):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay estructuras de muelle ni casas cerca del spawn: solo playa/arena, agua, islas lejanas y un cubo naranja/amarillo (nodo de recurso) a la derecha del jugador.
- Correlación debug: `[M17] Construccion listo (catalogo=46, terreno=false, inventario=true)` — sistema de construcción cargado pero sin estructuras colocadas cerca del spawn; `[M16] Mesa de trabajo colocada en (3866, ~, 3862)` — única estructura en logs (no visible desde esta cámara); `[M67] VehicleManager listo (3 presets)`.
- 0 warnings de infraestructura/renderer/z-fighting en los logs.
- No se observaron colisiones visibles ni elementos flotando en la escena capturada.
- Defecto observado: ausencia de infraestructura construida (muelle/casas) en la zona inicial de spawn — el sistema M17 está listo pero sin estructuras colocadas.

## Contadores

hecho=1 (G1-014) skip=0 fail=0

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

Restantes: G1-015, G1-016…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-015 (19 NPC — capturar NPC visible cerca del spawn: skin/animación/reacción de mirada; incoherencias visuales) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 22:31:46
