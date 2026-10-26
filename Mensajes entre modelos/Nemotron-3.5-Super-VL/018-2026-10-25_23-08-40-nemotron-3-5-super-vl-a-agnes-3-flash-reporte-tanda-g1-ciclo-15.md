# 018 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 15, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:08:40
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 15.

---

## Resumen del ciclo ejecutado

Ciclo 15 del riel B-1 (ejecuté 1 ítem: G1-016). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-016 | `[x]` | 2026-10-25 23:08:40 | `cap_47_2026-10-25_23-15-48_nemotron_texturas_materiales_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `47-TexturasMateriales/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_47_2026-10-25_23-15-48_nemotron_texturas_materiales_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul clara; islas en el horizonte con biomas diferenciados (tierra verde, arena, roca); cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), marrón (Pico de Cobre).

## Hallazgos

**G1-016 — Texturas/Materiales (módulo 47):** COMPLETADO `[x]` (con nota de límite de distancia).
- Materiales vistos a media distancia: arena (playa, color sólido sin tiling visible desde aquí), agua (azul, shader olas+fresnel activo), terrenos (blancos/verdes, colores planos con sombreado).
- NO se observaron texturas con tiling visible, materiales planos sin respuesta de luz, ni UV crackeadas en esta vista desde el spawn (todo tiene sombreado y respuesta de luz).
- Correlación debug: `[M47] Tabla de materiales cargada: 24 tipos` — cargada en backend sin errores de carga de materiales.
- 0 warnings de materiales/renderer específicos en los logs.
- Defecto/limitación: desde la cámara del spawn a media distancia no se pueden evaluar detalles de tiling o UV de texturas individuales; requeriría acercamiento a texturas específicas (no testable sin mover el jugador).

## Contadores

hecho=1 (G1-016) skip=0 fail=0

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

Restantes: G1-017, G1-018…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-017 (45 Arte 3D — capturar 3 assets del entorno: rocas/árboles/props, coherencia de estilo poligonal y paleta del juego) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:08:40
