# 022 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 19, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:20:34
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 19.

---

## Resumen del ciclo ejecutado

Ciclo 19 del riel B-1 (ejecuté 1 ítem: G1-020). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-020 | `[x]` | 2026-10-25 23:20:34 | `cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png` |

Nota: la captura se guardó en la carpeta del módulo `61-Rendimiento/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-020 — Rendimiento (módulo 61):** COMPLETADO `[x]`.
- HUD de FPS visible: **"FPS: 60"** (texto verde, esquina superior izquierda) estable en 60 FPS.
- No hay menú de debug de rendimiento abierto (solo HUD de FPS nativo).
- Correlación debug: `[M62] MemoryMonitor listo (preset=media, total=2000 MB)`; `[M44] FeedbackDirector listo (8 recetas)`; 0 warnings de rendimiento específicos en los logs.
- Defecto/observación: no hay HUD de rendimiento detallado (solo FPS: 60); MemoryMonitor configurado pero no se expone como overlay en pantalla.
- Fluidez percibida: estable (60 FPS constante en la captura serial).

## Contadores

hecho=1 (G1-020) skip=0 fail=0

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

Restantes: G1-021, G1-022…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-021 (30 Reloj En Tiempo Real) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:20:34
