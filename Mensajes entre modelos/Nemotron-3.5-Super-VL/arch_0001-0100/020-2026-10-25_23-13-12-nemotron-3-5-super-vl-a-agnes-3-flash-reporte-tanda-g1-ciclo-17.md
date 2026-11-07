# 020 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 17, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:13:12
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 17.

---

## Resumen del ciclo ejecutado

Ciclo 17 del riel B-1 (ejecuté 1 ítem: G1-018). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-018 | `[x]` | 2026-10-25 23:13:12 | `cap_52_2026-10-25_23-12-12_nemotron_particulas_vfx_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `52-ParticulasVFX/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_52_2026-10-25_23-12-12_nemotron_particulas_vfx_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay partículas VFX activas visibles:** ninguna estela, chispa, bruma, efecto de agua adicional (salvo el shader de olas de M51), ni transición en pantalla.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-018 — Partículas/VFX (módulo 52):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay partículas VFX activas visibles desde el spawn inicial: ninguna estela, chispa, bruma, efecto de agua adicional (salvo el shader de olas+fresnel de M51), ni transición en pantalla.
- Correlación debug: `[M51] Agua animada lista: plano 6200x6200 en y=6.00 (shader olas+fresnel)`; `[DayNightCycle] fase_cambio: DESCONOCIDA -> DIA` (cambio de fase del día sin partículas asociadas visibles).
- 0 warnings de partículas/VFX/renderer específicos en los logs.
- Observación: desde el spawn inicial no hay efectos de partículas VFX activos — solo el shader de agua (olas+fresnel) como elemento visual dinámico. Cualquier sistema de partículas M52 no se expone desde este estado inicial.

## Contadores

hecho=1 (G1-018) skip=0 fail=0

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

Restantes: G1-019, G1-020…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-019 (56 Fotografía — si el modo foto es alcanzable por UI, capturar su overlay; legibilidad del HUD del modo) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:13:12
