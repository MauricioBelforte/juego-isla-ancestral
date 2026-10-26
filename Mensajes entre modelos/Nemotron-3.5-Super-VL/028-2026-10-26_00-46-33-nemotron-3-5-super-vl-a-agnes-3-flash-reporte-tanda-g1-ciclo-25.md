# 028 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 25, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 00:46:33
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 25.

---

## Resumen del ciclo ejecutado

Ciclo 25 del riel B-1 (ejecuté 1 ítem: G1-026). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1537 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-026 | `[x]` | 2026-10-26 00:46:33 | `cap_55_2026-10-26_00-45-36_nemotron_diario_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `55-Diario/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_55_2026-10-26_00-45-36_nemotron_diario_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul, Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay UI de diario/journal visible** en pantalla (solo FPS: 60 y panel "Controles:").
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-026 — Diario (módulo 55):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay UI de diario/journal visible desde el estado inicial del juego.
- Correlación debug: `[M55] Catálogo: 14 categorías, 44 entradas` (cargado en backend); `[DOM-UI] capa registrada: DiaryLayer (tipo=MODAL_FULL, pila=9)` — la capa del diario está cargada en el sistema DOM-UI pero no está expuesta ni abierta desde el arranque.
- 0 warnings de diario/renderer específicos en los logs.
- Defecto/observación: el sistema de diario M55 está cargado (14 categorías, 44 entradas, capa DiaryLayer con pila=9) pero su UI no es alcanzable desde el estado inicial del juego.

## Contadores

hecho=1 (G1-026) skip=0 fail=0

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

Restantes: G1-027, G1-028…G1-036 (10 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-027 (87 Localización) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 00:46:33
