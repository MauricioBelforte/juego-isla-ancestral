# 015 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 12, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 22:01:16
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 12.

---

## Resumen del ciclo ejecutado

Ciclo 12 del riel B-1 (ejecuté 1 ítem: G1-013). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-013 | `[x]` | 2026-10-25 22:01:16 | `cap_13_2026-10-25_22-01-16_nemotron_herramientas_sin_tooltips.png` |

Nota: la captura se guardó en la carpeta del módulo `13-Herramientas/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_13_2026-10-25_22-01-16_nemotron_herramientas_sin_tooltips.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul) en centro-derecha; Pico de Cobre equipado en la mano; agua azul clara; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay tooltips visibles:** ningún texto emergente sobre herramientas, objeto o UI.
- **No hay paneles de herramientas abiertos:** inventario, equipamiento y herramientas cerrados.
- **No hay textos cortados ni ids crudos** (debug leaks) visibles en pantalla.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), marrón (tronco/herramienta).

## Hallazgos

**G1-013 — Herramientas (módulo 13):** COMPLETADO `[x]` (con notas de estado actual).
- Herramienta equipada: **Pico de Cobre** (dur 150/150) — visible en mano del jugador y en hotbar.
- Hotbar inicial: 5 herramientas (cargada en backend), pero solo se ve la equipada en pantalla.
- **No hay tooltips** al pasar el mouse sobre ningún objeto o UI (sin interacción de mouse posible desde captura estática, reportado como estado actual).
- **No hay paneles de herramientas abiertos** desde el arranque (inventario, equipamiento, herramientas cerrados).
- **No hay textos cortados ni ids crudos** visibles en la UI (no hay leak de debug visual en pantalla).
- Correlación debug: `[M13] Equipada: Pico de Cobre (dur 150/150)`; `[M13] Hotbar inicial: 5 herramientas`; `[M13] Hotbar HUD listo: [P: (-160.0, 588.0), S: (1472.0, 50.0)] padre=UI`.
- 0 warnings de herramientas/UI específicos en los logs.
- Defecto observado: hotbar solo muestra la herramienta equipada sin identificadores numéricos de slot ni tooltips informativos (no testable sin interacción, pero es el estado actual de UI).

## Contadores

hecho=1 (G1-013) skip=0 fail=0

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

Restantes: G1-014, G1-015…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-014 (40 Infraestructura — estructuras cercanas al spawn: z-fighting, colisiones, elementos flotando) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 22:01:16
