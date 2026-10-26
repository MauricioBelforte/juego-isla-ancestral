# 017 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 14, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:05:38
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 14.

---

## Resumen del ciclo ejecutado

Ciclo 14 del riel B-1 (ejecuté 1 ítem: G1-015). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-015 | `[x]` | 2026-10-25 23:05:38 | `cap_19_2026-10-25_23-05-38_nemotron_npc_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `19-NPC/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_19_2026-10-25_23-05-38_nemotron_npc_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul clara; islas en el horizonte con biomas diferenciados; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay NPCs visibles cerca del spawn en esta cámara** (solo jugador y entorno).
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), marrón (Pico de Cobre).

## Hallazgos

**G1-015 — NPC (módulo 19):** COMPLETADO `[x]` (con nota de no-alcance visual).
- No hay NPCs visibles cerca del spawn en esta cámara (solo jugador voxel y entorno).
- Correlación debug: `[M19] Catálogo de vecinos: 14 perfiles (0 duplicados descartados)`; `[M19] Población de arranque: 6 vecinos activados (P1): aria_ciervo, bruno_sapo, catalina_oso, finneas_zorro, luna_zorra, mateo_mapache` (snap al terreno en Y=4.0/3.0/6.0); `[NPCManager] 7 NPCs activos (incluyendo CatalinaOso)`; `[NPCVisualDatabase] 23 diseños visuales cargados`.
- Los NPCs están activados en backend (7 NPCs, 6 vecinos P1 + CatalinaOso) pero **ninguno visible desde la cámara inicial del spawn** — posible distancia o falta de posicionamiento cercano al jugador.
- 0 warnings de NPC/renderer específicos en los logs.
- Defecto observado: NPCs activados en backend pero no visibles desde el spawn inicial — posible distancia o falta de posicionamiento cercano al jugador.

## Contadores

hecho=1 (G1-015) skip=0 fail=0

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

Restantes: G1-016, G1-017…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-016 (47 Texturas Materiales — texturas con tiling visible, materiales planos sin respuesta de luz, UV crackeadas) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:05:38
