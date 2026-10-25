# 005 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 2, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 19:22:42
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 2.

---

## Resumen del ciclo ejecutado

Ciclo 2 del riel B-1 (G1-001, G1-002, G1-003). Flujo MCP de Godot:
`run_project` → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → enviar Escape → `screen_capture_window` → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-001 | `[x]` | 2026-10-25 19:20:56 | `cap_53_2026-10-25_19-20-56_nemotron_scena_principal.png` |
| G1-002 | `[?]` | 2026-10-25 19:22:42 | `cap_53_2026-10-25_19-22-42_nemotron_escape_no_menu_pausa.png` |
| G1-003 | `[x]` | 2026-10-25 19:17:43 | get_debug_output (boot + post-carga) |

## Contenido exacto de la escena principal (de la captura `cap_53_2026-10-25_19-20-56_nemotron_scena_principal.png`)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: jugador voxel (cabeza café, camisa verde, pantalón azul) de pie sobre terreno verde; agua azul alrededor; isla en el horizonte; cielo claro.
- HUD inferior: barra de salud/energía (roja y verde) en la parte inferior izquierda.
- Colores prominentes: verde (terreno, texto FPS), azul (agua, pantalón del jugador), gris claro (cielo), café/crema (barra lateral VS Code de fondo).

## Hallazgos

**G1-001 — Abrir el juego y capturar HUD/base:** COMPLETADO `[x]`.
- Juego arrancado correctamente en modo debug.
- Ventana traída al frente con la técnica documentada en `GUIA-GODOT/20-ventana-juego-al-frente.md` (ALT-trick + minimize/restore del propio juego).
- Captura exitosa con `screen_capture_window("isla-ancestral (DEBUG)")`.
- UI legible: título, FPS, panel de controles con 4 líneas, escena 3D renderizada, HUD inferior.

**G1-002 — Capturar el menú de Pausa/Settings:** `[?]` NO RESUELTO.
- Razón: se envió la tecla Escape pero NO abrió ningún menú de pausa. El UI muestra **"Escape - Liberar mouse"** — Escape libera el cursor del mouse, no abre pausa.
- No se encontró ninguna tecla de pausa visible en el UI de controles (solo WASD, Scroll, Escape, F).
- Evidencia: `cap_53_2026-10-25_19-22-42_nemotron_escape_no_menu_pausa.png` (escena igual, sin menú de pausa abierto).

**G1-003 — get_debug_output al arrancar y correlacionar:** COMPLETADO `[x]`.
- Boot exitoso, 0 errores críticos.
- Warnings: 20+ señales declaradas pero nunca usadas en `event_bus.gd`; división entera en `stock_generator.gd:71` y `mining_manager.gd:579`; narrowing conversion en `fauna_catalog.gd:48` y `memory_monitor.gd:578/581`; variables shadoweando propiedades de Node (`name`, `visible`); parámetros nunca usados en múltiples funciones.
- Logs de mundo: spawn en (3860, 3860) Y=8, 7 vecinos activados, equipamiento 16 prendas cargado, 22 eventos cargados, 12 capas de UI montadas (dialogo, pausa, menus, confirm, crafting, inventario, tienda, equipamiento, diario, carga, creditos, ajustes).

## Contadores

hecho=2 (G1-001, G1-003) skip=1 (G1-002) fail=0

## Notas

- El riel B-1 (G1-001 a G1-003) está ahora completo: 2 [x], 1 [?]. Queda [?] en G1-002 porque el menú de pausa no se alcanzó desde el arranque (Escape no abre pausa; hay que investigar qué tecla/acción lo abre, probablemente en el UI de controles o en un botón no visible).
- El cron está programado (cada 25 min, próximo disparo ~2026-10-25T22:25:14Z).
- No se encontró ningún mensaje de agnes en este canal.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 19:22:42
