# 006 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 3, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 19:28:05
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 3.

---

## Resumen del ciclo ejecutado

Ciclo 3 del riel B-1 (ejecuté 1 ítem, prioridad de arranque G1-006). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-006 | `[x]` | 2026-10-25 19:28:05 | `cap_53_2026-10-25_19-28-05_nemotron_agua_shader_olas_fresnel.png` |

## Contenido exacto de la captura (cap_53_2026-10-25_19-28-05_nemotron_agua_shader_olas_fresnel.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: jugador voxel (cabeza café, camisa verde, pantalón azul) sobre terreno verde claro; agua azul extendida; costas formadas por bordes de bloques de terreno voxel (sin espuma de olas); isla en el horizonte con biomas (tierra, arena, roca); cielo claro.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: azul (agua), verde (terreno, texto FPS), gris claro (cielo), crema/café (barra lateral VS Code de fondo).

## Hallazgos

**G1-006 — Agua (módulo 51):** COMPLETADO `[x]`.
- Shader de agua activo: olas + fresnel visible (superficie azul con movimiento y reflexión).
- Plano de agua: 6200x6200 en y=6.00 (corroborado por log `[M51] Agua animada lista: plano 6200x6200 en y=6.00 (shader olas+fresnel)`).
- Defecto visual observado: **costas sin espuma** — la interfaz agua/terreno es el borde recto de bloques voxel, sin efecto de espuma de olas en la orilla. Esto es consistente con el shader descrito (olas+fresnel) pero sin espuma de orilla.
- 0 warnings de materiales/renderer específicos de agua en los logs.
- No se observó z-fighting ni texturas planas repetidas en esta vista.

## Contadores

hecho=1 (G1-006) skip=0 fail=0

## Estado del riel B-1

| Ítem | Estado |
|------|--------|
| G1-001 | `[x]` |
| G1-002 | `[?]` (Escape no abre menú de pausa; "Escape - Liberar mouse") |
| G1-003 | `[x]` |
| G1-006 | `[x]` |

Restantes: G1-004, G1-005, G1-007…G1-036. El riel NO está agotado (quedan 32 ítems [ ]).

## Siguientes pasos

- Próximo ciclo del cron (cada 25 min): continuar con G1-004 (cámara) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 19:28:05
