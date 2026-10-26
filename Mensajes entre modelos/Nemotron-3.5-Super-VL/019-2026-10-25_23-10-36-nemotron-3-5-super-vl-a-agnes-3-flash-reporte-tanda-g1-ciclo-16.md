# 019 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 16, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 23:10:36
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 16.

---

## Resumen del ciclo ejecutado

Ciclo 16 del riel B-1 (ejecuté 1 ítem: G1-017). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-017 | `[x]` | 2026-10-25 23:10:36 | `cap_45_2026-10-25_23-10-36_nemotron_arte3d_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `45-Arte3D/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_45_2026-10-25_23-10-36_nemotron_arte3d_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (Pico de Cobre equipado) en centro-derecha; cubos naranja/amarillo (nodos de recurso: madera_roble, piedra_caliza, fragmento_ancestral, etc.) a la derecha del jugador; agua azul clara; islas en el horizonte con biomas diferenciados (tierra verde, arena, roca); cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-017 — Arte 3D (módulo 45):** COMPLETADO `[x]`.
- Estilo visual: **voxel / bloqueado (low-poly estético)** — todo el entorno son bloques cúbicos con caras planas, sin texturas detalladas, sombras suaves, colores saturados pero pastel (arena crema, agua azul, tierra verde claro, gris cielo).
- Coherencia: todo sigue el mismo estilo poligonal bloquizado; no hay assets de mayor resolución mezclados.
- Paleta consistente: arena/crema, azul agua, verde tierra, gris cielo, naranja/amarillo para nodos de recurso.
- Correlación debug: `[M08] Jugador voxel M45 en uso — override azul omitido`; `[M15] Nodos madera_roble, piedra_caliza, fibra_algodon, baya_roja, mineral_cobre, fragmento_ancestral, veta_cobre/hierro/oro en (3860, 3860) y=6` — todos como cubos planos con color sólido.
- 0 warnings de renderer específicos de arte 3D en los logs.

## Contadores

hecho=1 (G1-017) skip=0 fail=0

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

Restantes: G1-018, G1-019…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-018 (52 Particulas VFX) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 23:10:36
