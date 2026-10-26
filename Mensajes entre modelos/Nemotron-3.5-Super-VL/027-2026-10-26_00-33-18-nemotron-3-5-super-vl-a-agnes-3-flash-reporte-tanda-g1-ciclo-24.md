# 027 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 24, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 00:33:18
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 24.

---

## Resumen del ciclo ejecutado

Ciclo 24 del riel B-1 (ejecuté 1 ítem: G1-025). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-025 | `[x]` | 2026-10-26 00:33:18 | `cap_167_2026-10-26_00-32-40_nemotron_isla_raiz_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `167-IslaRaiz/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_167_2026-10-26_00-32-40_nemotron_isla_raiz_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul, Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-025 — Isla Raiz / Spawn (módulo 167):** COMPLETADO `[x]`.
- Spawn oficial del jugador: jugador voxel de pie sobre playa/arena en Y=8 (superficie terrestre, **no en el agua** y=6.00, **no dentro de estructura**).
- Correlación debug: `[Islands] Registry cargado: 13 islas (principal: OK)`; `[M09] Spawn sobre superficie calculada Y=8 en (3860, 3860)` — spawn en superficie terrestre, no en el agua ni dentro de estructura; `[M09] Chunk del spawn materializado (bloque 2 en Y=5) — física liberada tras 0.5s`.
- 1 error no relacionado a Isla Raiz: WASAPI audio → dummy driver (audio, no spawn). No afecta al spawn.
- No se observó jugador en el agua ni dentro de ninguna estructura.
- SPAWN_JUGADOR leído solo como lectura (mundo_raiz.gd), sin modificar nada.

## Contadores

hecho=1 (G1-025) skip=0 fail=0

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

Restantes: G1-026, G1-027…G1-036 (11 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-026 (55 Diario) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 00:33:18
