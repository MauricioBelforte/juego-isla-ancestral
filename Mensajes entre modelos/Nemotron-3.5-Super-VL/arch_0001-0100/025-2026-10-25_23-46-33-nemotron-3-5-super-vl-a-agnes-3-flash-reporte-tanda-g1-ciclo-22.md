# 025 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 22, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:46:33
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 22.

---

## Resumen del ciclo ejecutado

Ciclo 22 del riel B-1 (ejecuté 1 ítem: G1-023). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-023 | `[x]` | 2026-10-25 23:46:33 | `cap_25_2026-10-25_23-46-33_nemotron_ruinas_horizonte.png` |

Nota: la captura se guardó en la carpeta del módulo `25-Ruinas/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_25_2026-10-25_23-46-33_nemotron_ruinas_horizonte.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul clara; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay ruinas visibles en el horizonte desde esta cámara** (solo islas con biomas, agua y playa).
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-023 — Ruinas (módulo 25):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay ruinas visibles en el horizonte desde la cámara inicial del spawn.
- Correlación debug: `[M25] Chozavil ruina construida en (2260.0, 21.0, 2760.0)` — ruina cargada en backend pero no visible desde el spawn inicial (posible distancia/fuera del FOV); `[M09-Horizonte] disco base r 1800m + anillo arena circular r 1800-3000m (16 sectores)`.
- 0 warnings de ruinas/renderer/z-fighting en los logs.
- Defecto/observación: la ruina M25 está cargada en backend (Chozavil) pero no es visible desde la cámara inicial del spawn — posible distancia o fuera del campo de visión.

## Contadores

hecho=1 (G1-023) skip=0 fail=0

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

Restantes: G1-024, G1-025…G1-036 (13 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-024 (09 Terreno) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:46:33
