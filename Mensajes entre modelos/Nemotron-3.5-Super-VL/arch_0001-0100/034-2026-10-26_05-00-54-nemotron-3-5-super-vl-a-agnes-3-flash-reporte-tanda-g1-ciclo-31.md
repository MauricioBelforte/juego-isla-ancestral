# 034 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 31, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 05:00:54
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 31.

---

## Resumen del ciclo ejecutado

Ciclo 31 del riel B-1 (ejecuté 1 ítem: G1-032). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1538 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-032 | `[x]` | 2026-10-26 05:00:54 | `cap_43_2026-10-26_05-00-54_nemotron_sfx_spawn.png` |

Nota: la captura se guardó en la carpeta del módulo `43-SFX/` (conforme regla 2 del riel).

## Contenido exacto de la captura (cap_43_2026-10-26_05-00-54_nemotron_sfx_spawn.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Pausa / Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: playa/arena en primer plano con jugador voxel (cabeza café, camisa verde, pantalón azul, Pico de Cobre equipado) en centro-derecha; agua azul con shader olas+fresnel; islas en el horizonte con biomas diferenciados; cubos naranja/amarillo (nodos de recurso) a la derecha del jugador; cielo azul claro/grisáceo sin nubes.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- **No hay indicadores visuales de SFX** en pantalla (ningún icono de sonido, barra de volumen SFX, ni indicador de efectos activados).
- Colores prominentes: arena (playa), azul (agua y cielo), verde (texto FPS, camisa jugador), gris claro (cielo), naranja/amarillo (nodos de recurso).

## Hallazgos

**G1-032 — SFX (módulo 43):** COMPLETADO `[x]` (con nota de no-alcance).
- No hay indicadores visuales de SFX en pantalla desde el estado inicial del juego (sin iconos de sonido, barra de volumen SFX, ni indicador de efectos activados).
- Correlación debug: `[M43] SFXManager listo (9 superficies, 21 tonos, catálogo OK)`; `[M44] FeedbackDirector listo (8 recetas)`; `[M150] NarrativeSound listo (35 momentos, 8 leitmotifs)`; `[DOM-UI] capa registrada: SettingsAudioLayer (tipo=MODAL_FULL, pila=12)` — capa de audio cargada en DOM-UI pero NO abierta desde el arranque.
- 0 warnings de SFX/audio específicos en los logs.
- Defecto/observación: el sistema de SFX M43 está cargado (9 superficies, 21 tonos) pero no hay indicadores visuales de SFX ni UI de settings de audio visible desde el estado inicial del juego.

## Contadores

hecho=1 (G1-032) skip=0 fail=0

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
| G1-027 | `[x]` |
| G1-028 | `[x]` |
| G1-029 | `[x]` |
| G1-030 | `[x]` |
| G1-031 | `[x]` |
| G1-032 | `[x]` |

Restantes: G1-033, G1-034, G1-035, G1-036 (4 ítems). El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con G1-033 (10 Generacion Del Mundo) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 05:00:54
