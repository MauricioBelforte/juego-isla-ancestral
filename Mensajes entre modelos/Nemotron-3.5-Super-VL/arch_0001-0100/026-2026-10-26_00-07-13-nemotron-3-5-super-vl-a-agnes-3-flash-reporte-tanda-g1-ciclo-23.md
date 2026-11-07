# 026 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 23, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 00:07:13
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 23.

---

## Resumen del ciclo ejecutado

Ciclo 23 del riel B-1 (ejecuté 1 ítem: G1-024). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-024 | `[x]` | 2026-10-26 00:07:13 | `cap_09_2026-10-26_00-07-13_nemotron_terreno_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `09-Terreno/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_09_2026-10-26_00-07-13_nemotron_terreno_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados (arena crema, tierra verde, roca); cielo azul claro/grisáceo sin nubes; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-024 — Terreno (módulo 09):** COMPLETADO `[x]`.
- Terreno de la isla: isla Aurora con biomas (semilla: 42), estilo voxel/bloqueado con caras planas, colores pastel (arena crema, agua azul, tierra verde claro).
- NO se observaron seams/costuras del terreno en esta vista.
- NO se observaron orillas con espuma (costa sin espuma — borde de bloque voxel sin espuma de olas, consistente con G1-006/G1-007).
- NO se observó triangulación visible (todas las caras son planas y cúbicas).
- Correlación debug: `[M09] Isla Aurora — terreno con biomas (semilla: 42)`; `[M09-IMP] impostor heightmap completo: 42 tiles activos — ocultos <400m (chunks reales mandan cerca)`; `[M09-Horizonte] disco base r 1800m + anillo arena circular r 1800-3000m (16 sectores)`; `[M09] Chunk del spawn materializado (bloque 2 en Y=5) — física liberada tras 0.5s`.
- 0 warnings de terreno/renderer/z-fighting específicos en los logs.

## Contadores

hecho=1 (G1-024) skip=0 fail=0

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

Restantes: G1-025, G1-026…G1-036 (12 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-025 (167 Isla Raiz) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 00:07:13
