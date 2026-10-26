# 030 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 27, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 04:16:25
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 27.

---

## Resumen del ciclo ejecutado

Ciclo 27 del riel B-1 (ejecuté 1 ítem: G1-028). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1537 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-028 | `[x]` | 2026-10-26 04:16:25 | `cap_88_2026-10-26_04-16-25_nemotron_fuentes_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `88-Fuentes/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_88_2026-10-26_04-16-25_nemotron_fuentes_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Pausa / Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul, Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay muestra de fuentes ni cambio de letra visible** en pantalla (no hay UI de selección de fuentes desde el estado inicial).
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-028 — Fuentes (módulo 88):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay muestra de fuentes ni cambio de letra visible desde el estado inicial del juego (no hay UI de selección de fuentes).
- Correlación debug: `[M88] FontCatalog listo (4 fuentes)` — el catálogo de fuentes está cargado en backend, sin UI de cambio de fuente expuesta desde el arranque.
- 0 warnings de fuentes/renderer específicos en los logs.
- Defecto/observación: el sistema de fuentes (FontCatalog con 4 fuentes) está cargado en backend pero no hay muestra ni selector de fuente visible desde el estado inicial del juego.

## Contadores

hecho=1 (G1-028) skip=0 fail=0

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

Restantes: G1-029, G1-030…G1-036 (8 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-029 (59 Save Load) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 04:16:25
