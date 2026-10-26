# 009 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 6, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:34:00
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 6.

---

## Resumen del ciclo ejecutado

Ciclo 6 del riel B-1 (ejecuté 1 ítem: G1-007). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-007 | `[x]` | 2026-10-25 23:34:00 | `cap_51_2026-10-25_23-34-00_nemotron_agua_correlacion_debug.png` |

Nota: la captura se guardó en la carpeta del módulo `51-Agua/` (conforme regla 2 del riel: "carpeta DEL MÓDULO analizado"), no en `53-UI-UX/`.

## Contenido exacto de la captura (cap_51_2026-10-25_23-34-00_nemotron_agua_correlacion_debug.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 59"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: jugador voxel (cabeza café, camisa verde, pantalón azul) sobre terreno blanco/arena en tercio derecho inferior; agua azul; islas en el horizonte con biomas (tierra verde, arena, roca); cielo claro.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: azul (agua), blanco/arena (terreno bajo el jugador), verde (tierra de islas, texto FPS), gris claro (cielo).

## Hallazgos

**G1-007 — Agua correlación debug (módulo 51):** COMPLETADO `[x]`.
- Shader de agua activo: olas + fresnel visible (superficie azul con movimiento y reflexión), consistente con G1-006.
- Plano de agua: 6200x6200 en y=6.00 (corroborado por log `[M51] Agua animada lista: plano 6200x6200 en y=6.00 (shader olas+fresnel)`).
- Correlación debug: **0 warnings de materiales/renderer específicos de agua** — grep en los logs post-carga sin hits de "material"/"shader"/"renderer" relacionados a agua. El shader se cargó sin errores de renderer.
- Defecto visual confirmado (mismo que G1-006): **costas sin espuma** — la interfaz agua/terreno es el borde recto de bloques voxel, sin efecto de espuma de olas en la orilla. Consistencia con G1-006 (misma captura visual).
- No se observó textura plana repetida ni z-fighting en esta vista.
- Logs post-carga: fauna activa (gaviota aterrizó en (3849, 3870)), chunks del spawn materializados, impostores ocultos <400m.

## Contadores

hecho=1 (G1-007) skip=0 fail=0

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

Restantes: G1-008, G1-009…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-008 (50 Vegetación — zona con vegetación adyacente al spawn; densidad/perspectiva, popping, elementos flotando) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:34:00
