# 010 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 7, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 20:45:49
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 7.

---

## Resumen del ciclo ejecutado

Ciclo 7 del riel B-1 (ejecuté 1 ítem: G1-008). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-008 | `[x]` | 2026-10-25 20:45:49 | `cap_50_2026-10-25_20-45-49_nemotron_vegetacion_spawn_adyacente.png` |

Nota: la captura se guardó en la carpeta del módulo `50-Vegetacion/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_50_2026-10-25_20-45-49_nemotron_vegetacion_spawn_adyacente.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 59"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa de arena adyacente al spawn; tronco de árbol (bloque cilíndrico marrón simple, sin detalles) en centro izquierda; arbusto/bamboo bajo a la izquierda; jugador voxel (cabeza café, camisa verde, pantalón azul) en centro-derecha; agua azul al fondo; horizonte con islas distantes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), marrón (tronco), azul (agua), verde (arbusto, texto FPS, camisa jugador), gris claro (cielo).

## Hallazgos

**G1-008 — Vegetación (módulo 50):** COMPLETADO `[x]`.
- Vegetación adyacente al spawn: baja densidad (solo un tronco y un arbusto/bamboo bajo visibles cerca del jugador).
- Correlación debug: `[M50] VegetationSpawner: 65 instanciadas, 44 omitidas (44 en agua)`, `Plan generado: 109 items`, `TerrainLocator: found`. La mayoría de la vegetación se omite en agua (44 de 109 en agua).
- 0 warnings de vegetación/materiales/renderer específicos en los logs (grep sin hits de "vegetation"/"material"/"shader" relacionados a vegetación).
- Defectos observados:
  1. Baja densidad de vegetación cerca del spawn (arena casi vacía salvo 1 tronco + 1 arbusto).
  2. El tronco es un bloque cilíndrico simple sin respuesta de luz visible (material plano).
  3. Posibles impostores ocultos <400m (`[M09-IMP]`: ocultar impostor <400m, chunks reales mandan cerca) — puede causar popping al acercarse.
- No se observaron elementos flotando (todo snapped al terreno, con `Y=6` en los nodos de recurso).

## Contadores

hecho=1 (G1-008) skip=0 fail=0

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

Restantes: G1-009, G1-010…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-009 (49 Iluminación — condición de luz inicial, sombras, quemado por sol, zonas negras) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 20:45:49
