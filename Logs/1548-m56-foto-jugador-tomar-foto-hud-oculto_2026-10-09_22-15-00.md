# Log 1548: M56 iter. 3 — foto del jugador (tomar_foto con HUD oculto)

**Fecha:** 2026-10-09
**Hora:** 22:15
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo msg 88 del director (atria-dawn): implementar en M56 la **foto del jugador** —
al presionar una tecla (P) el HUD se oculta, se captura el viewport, se guarda la foto en
disco y el HUD se restaura exacto. Se implementó `tomar_foto()` en el autoload
`PhotoService` (extensión del archivo existente, sin tocar lo avanzado en iter. 1/2),
con suite adaptativa headless/render, evidencia visual sin HUD, cierre de 5 ítems del
checklist y dos lecciones nuevas (E-24, E-25) en la guía de registro de errores de Godot.

## Cambios Realizados

- **`scripts/foto/photo_service.gd`** (extendido):
  - `signal foto_tomada(ruta, resultado)` — emisor real de PHOTO_TAKEN (faltaba).
  - `const CARPETA_FOTOS := "user://fotos/"` (PNG, ruta del encargo del director).
  - `var _en_captura` — guard anti-doble captura (K94).
  - `var _hud_visible_antes_modo` — estado del HUD previo al modo foto (G61).
  - `_unhandled_input()` — consume la acción `tomar_foto` (P) sin pisar UI.
  - `tomar_foto()` (async): oculta HUD vía `UIManager.set_hud_visible(false)` →
    `await process_frame` ×2 (lag de 1 frame de `get_texture()` documentado en BUG-128) →
    `get_viewport().get_texture().get_image().save_png()` → restaura HUD exacto → emite
    `foto_tomada`. En `--headless` devuelve `ok=false, motivo="sin_textura_render"` sin
    crear archivo falso. Reporta `ms` (medido 100-219 ms con render).
  - `_ruta_foto_unica()` — `foto_<AAAA-MM-DD_HH-MM-SS>[_N].png` con fallback a ticks si el
    reloj está en 1970/vacío (L105).
  - `_entrar_modo_foto()` / `_salir_modo_foto()` — ahora ocultan/restauran el HUD (G61).
- **`project.godot`**: acción `tomar_foto` = tecla P (`physical_keycode:80`, verificada
  libre en todo el mapa de acciones).
- **`tests/test_m56_tomar_foto.gd`** (nuevo): T1 flujo directo (await), T2 input real P
  (pipeline + fallback directo), T3 doble pulsación (guard). Adaptativa al renderer:
  headless aserta flujo/HUD/guard; con render aserta además el PNG.
- **Suite ejecutada 2 veces** (patrón obligatorio del encargo): headless **26 checks 0
  fallos**; sin `--headless` (render) **31 checks 0 fallos**; 0 SCRIPT ERROR en ambas.
- **Evidencia:** 3 fotos reales producidas (86-150 KB, PNG decodifica, sin HUD visible);
  2 copiadas a `tools/mcp/godot-mcp/capturas/56-Fotografia/` con nomenclatura del proyecto
  (`cap_56_2026-10-09_21-47-29_flujo-directo-tomar-foto-sin-hud.png` y
  `cap_56_2026-10-09_21-47-30_1_doble-pulsacion-guard-k94.png`).
- **Checklist M56:** cerrados L64 (ocultar HUD con tecla), L67 (restaurar HUD al salir del
  modo foto), L88 (capturar escenas completas sin HUD), L100 (evitar capturas
  simultáneas), L105 (nombre único timestamp) → 21→26 [x] de 137 (2 [?] intactos). Header
  corregido (decía "130/130" falso). K92 queda [ ] honesto (100-219 ms > 50 ms objetivo).
- **Guía 06 registro de errores:** +E-24 (Godot 4.7: llamar corutina externa sin `await`
  lanza SCRIPT ERROR que aborta al caller — el auto-call interno descartado en
  `_unhandled_input` NO falla; tests: dispatch por `_unhandled_input`, no llamada directa)
  y +E-25 (headless: `get_texture().get_image()` devuelve NULL y el dummy renderer imprime
  `ERROR: Parameter "t" is null` inofensivo — suites adaptativas al renderer). Título
  actualizado a "E-11 a E-25".
- **Reserva/cierre en los 4 registros** (guía 08, CHECKLIST-GLOBAL fila 56, 05-Checklist,
  ESTADO-PARALELO) + BACKLOG personal cerrado.
- **Sondas monouso borradas** (`sonda_m56_probe_headless.gd`, `sonda_m56_dispatch_directo.gd`).

## Hallazgo ajeno (no tocado — aviso al director)

El **runner completo** (`tests/run_tests.gd`) da 25/29 suites OK: el único fallo es
**preexistente y ajeno a M56** — `tests/unit/debug/test_debug_menu.gd` (M110, WIP sin
commitear de otro agente) tiene un parse error en `_limpiar_huerfanos_boot` que revienta
toda la suite GdUnit4 (rc=105, 0 tests). Mi suite SceneTree corrió dentro del runner:
`[OK] rc=0 checks=26`. No se tocó ese archivo (módulo en vuelo de otro agente).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/foto/photo_service.gd` (modificado)
- `game/isla-ancestral/project.godot` (modificado — acción tomar_foto)
- `game/isla-ancestral/tests/test_m56_tomar_foto.gd` (creado)
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md` (modificado)
- `DOCUMENTACION/56-Fotografia/plan-actual/04-Codigo.md` (modificado)
- `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md` (modificado — E-24, E-25)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (modificado — reserva/cierre)
- `CHECKLIST-GLOBAL.md` (modificado — fila 56)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (modificado — 2 entradas)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` (modificado)
- `tools/mcp/godot-mcp/capturas/56-Fotografia/cap_56_2026-10-09_21-47-29_flujo-directo-tomar-foto-sin-hud.png` (evidencia)
- `tools/mcp/godot-mcp/capturas/56-Fotografia/cap_56_2026-10-09_21-47-30_1_doble-pulsacion-guard-k94.png` (evidencia)
