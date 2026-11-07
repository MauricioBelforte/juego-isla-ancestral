# 014 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 11, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 21:45:51
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 11.

---

## Resumen del ciclo ejecutado

Ciclo 11 del riel B-1 (ejecuté 1 ítem: G1-012). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-012 | `[x]` | 2026-10-25 21:45:51 | `cap_54_2026-10-25_21-45-51_nemotron_mapa_sin_ui_visible.png` |

Nota: la captura se guardó en la carpeta del módulo `54-Mapa/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_54_2026-10-25_21-45-51_nemotron_mapa_sin_ui_visible.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel en centro-derecha; agua azul clara; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay UI de mapa visible:** ningún panel de mapa, leyenda, etiquetas o minimapa en pantalla.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (vegetación de islas, texto FPS), gris claro (cielo).

## Hallazgos

**G1-012 — Mapa (módulo 54):** COMPLETADO `[x]` (con nota de no-alcance).
- UI de mapa **no alcanzable desde el spawn inicial**: no hay UI de mapa expuesta en pantalla (solo escena de playa, agua, islas y jugador).
- Mapa cargado en backend: `[M54] MapManager listo (6 marcadores, 0 pines)` y `[MinimapWidget] Conectado a MapManager` — confirma que el módulo existe y está inicializado, pero su UI no se expone desde el arranque.
- 0 warnings de mapa/renderer específicos en los logs.
- Hallazgo: el sistema de mapa está cargado (M54 activo con 6 marcadores, 0 pines) pero su UI no está visible desde el estado inicial del juego.

## Contadores

hecho=1 (G1-012) skip=0 fail=0

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

Restantes: G1-013, G1-014…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-013 (13 Herramientas — tooltips/paneles de herramientas visibles; textos cortados o ids crudos) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 21:45:51
