# 023 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 20, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:23:14
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 20.

---

## Resumen del ciclo ejecutado

Ciclo 20 del riel B-1 (ejecuté 1 ítem: G1-021). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-021 | `[x]` | 2026-10-25 23:23:14 | `cap_30_2026-10-25_23-22-34_nemotron_reloj_sin_hud.png` |

Nota: la captura se guardó en la carpeta del módulo `30-RelojEnTiempoReal/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_30_2026-10-25_23-22-34_nemotron_reloj_sin_hud.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay HUD de hora/reloj visible** en pantalla (solo FPS: 60 y panel "Controles:").
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-021 — Reloj en tiempo real (módulo 30):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay HUD de hora visible en pantalla (solo FPS: 60 y panel "Controles:"), por lo que **no se pudo validar coherencia visual hora↔luz** sin HUD de hora para comparar.
- Correlación debug: `[TimeCalendar] Configuración cargada: día 1440 min, año 336 días, 4 estaciones`; `[DayNightCycle] Curvas data-driven cargadas (data/light/)`; `[DayNightCycle] Ramps de color cargados (sun/sky) — M49 iter. 3`; `[DayNightCycle] fog_curve.tres cargado (niebla por hora)`; `[DayNightCycle] season_mod.tres cargado (modulacion estacional, diseno sec. 4)`.
- Sistema de tiempo cargado y activo (M30 + DayNightCycle) pero sin HUD de reloj expuesto en pantalla desde el estado inicial del juego.
- 0 warnings de tiempo/iluminación específicos en los logs.

## Contadores

hecho=1 (G1-021) skip=0 fail=0

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

Restantes: G1-022, G1-023…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-022 (33 Agricultura) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:23:14
