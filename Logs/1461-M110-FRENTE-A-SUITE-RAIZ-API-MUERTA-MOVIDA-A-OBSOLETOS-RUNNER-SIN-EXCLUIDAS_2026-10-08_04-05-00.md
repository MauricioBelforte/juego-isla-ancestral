# Log 1461: Frente A M110 — suite test_debug_menu.gd (raíz) diagnosticada stale (API v1 muerta) y movida a Obsoletos con evidencia; runner sin excluidas

**Fecha:** 2026-10-08
**Hora:** 04:05
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Frente A del msg 65 (director): resolver el `[?]` de M112 por
`tests/test_debug_menu.gd` (raíz) — "API muerta, excluida del runner". Se
diagnosticó con evidencia, se optó por **obsolescencia documentada** (opción B
del encargo) en vez de reescritura, y se limpió la exclusión del runner.

## Diagnóstico (medido, no supuesto)

1. **La suite quedó stale, no la API "borrada arbitrariamente":**
   - `tests/test_debug_menu.gd`: **1 solo commit** (`9450f6a`), creado
     2026-09-01 por agnes, nunca actualizado.
   - `scripts/debug/debug_menu.gd`: refactorizado **después** a API v2
     data-driven (commits `f02b4ca`, `64ce433`, `72a6fea`, ...).
2. **La suite llama a la API v1 completa, casi nada existe hoy:**

   | Llamada de la suite (v1) | API viva (v2) |
   |---|---|
   | `is_visible()` / `show_menu()` / `hide_menu()` / `toggle_menu()` | `esta_visible()` / `alternar()` |
   | `get_current_panel()` / `set_panel(n)` | `pestanas()` / `pestanas_ids()` / `ejecutar_comando(id)` |
   | `_tp_pos()` / `_tp_center()` | `teleport_player(pos)` / `_tp_center()` |
   | `_hora()` / `_dia_siguiente()` / `_estacion()` / `_clima()` | `set_game_time(h)` / `avanzar_dia(d)` / `set_season(t)` / `set_weather(c)` |
   | `_dar()` / `_dar_ao()` | `dar_objetos(item,cant)` / `dar_dinero(cant)` |
   | `_stub.call(...)` / `_reset_npc()` | `completar_mision()/desbloquear_*()` / `reset_npc(id)` |
   | `_toggle_*(sin args)` | `toggle_*(enabled: bool)` |
   | `_exportar_diagnostico()` / `_info_sistema()` / `_list_npcs()` | `_export_diag()` / `metricas_sistema()` |
   | señal `debug_action` | `toggle_visual_cambiado` / `estacion_solicitada` / `clima_solicitado` |

   Consecuencia medida antes: SCRIPT ERROR sin `quit()` → colgaba el runner
   (por eso `EXCLUIR` la documentaba).
3. **Cobertura viva redundante (no se pierde nada):**
   - `tests/unit/debug/test_debug_menu.gd` (GdUnit4) — 21/21 tras mi fix del
     2026-10-07 (Log 1451).
   - `scripts/debug/test_debug_m110.gd` (SceneTree, corre en el runner).
   - `scripts/debug/test_debug_menu_headless.gd` y `test_m110_iter_atria.gd`.

## Decisión: obsolescencia (opción B del encargo) — no reescritura

Reescribir la suite a API v2 = **duplicar** lo que ya hacen 3 suites vivas
(política de calidad/optimización §21.4: no hacer por hacer). Se aplicó la
misma receta aprobada para `run_tests.gd` v1: mover a `tests/Obsoletos/` con
cabecera que explica qué murió, por qué, y dónde está la cobertura hoy.

## Cambios realizados

1. **Movido** `tests/test_debug_menu.gd` →
   `tests/Obsoletos/2026-09-01_00-00-00_test_debug_menu_v1_api_muerta.gd`
   (nomenclatura de respaldo §5) con **cabecera de obsolescencia** firmada
   (mapeo v1→v2, commits, cobertura viva, dueño M110).
2. **`tests/run_tests.gd`:** `EXCLUIR` → `{}` con comentario del porqué;
   comentario del header actualizado al nuevo estado. El runner ahora
   descubre y ejecuta todo lo que hay.
3. **M112 `05-Checklist.md`:** el `[?]` de la raíz → `[x]` con resolución;
   totales T-M112 → **14 [x] / 3 [?]**. (El `05-Checklist` de M110 NO se tocó
   — restricción del msg 65 por la auditoría Ling L-05/s3.)

## Evidencia (antes → después, mismo build Godot 4.7.2)

| Métrica | ANTES | DESPUÉS |
|---|---|---|
| Suites descubiertas | 26 (22 SceneTree + 4 GdUnit4) | **25 (21 + 4)** |
| Excluidas documentadas | 1 (la raíz) | **0** |
| Suites ejecutables / OK | 25 / 19 | 25 / 19 |
| Tests corridos | 718 | **718** |
| Fallos runner | 3 (npcviz rc=1, equip rc=1, GdUnit debug rc=101 orphans) | **mismos 3 (preexistentes, sin regresión)** |
| Exit runner | 1 | 1 |
| Gate `test_regresion_templos.gd` | 76 checks, 0 fallos, EXIT 0 | **76 checks, 0 fallos, EXIT 0** |

Logs de corrida: `bug119\runner_antes_m110.log`, `runner_despues_m110.log`,
`gate_antes_m110.log`, `gate_despues_m110.log`.

## Pendientes heredados (no tocados en este frente)

- Los 3 fallos del runner siguen delegados: npcviz (`[?]` suite visual/NPC),
  equip (`[?]` M59), y **GdUnit debug rc=101 por 201 orphans** (`[?]` dueño
  M110) — éste último sigue abierto; es distinto de la suite raíz resuelta hoy.
- `quality.yml` intocado. `testing.yml` sin cambios en este frente.

## Archivos modificados/creados

- `game/isla-ancestral/tests/Obsoletos/2026-09-01_00-00-00_test_debug_menu_v1_api_muerta.gd` (movido + cabecera; `git mv`)
- `game/isla-ancestral/tests/run_tests.gd` (EXCLUIR vaciado)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md` (14 [x] / 3 [?])
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Mensajes entre modelos/mimo-v2.6-flash-free/67-…` (informe de cierre)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1461)

## Reglas

Commits locales selectivos autorizados (msg 63/65), **sin push** (lo
centraliza el director con huella §4.3). Sin pisar worktrees ajenos.
`11-BUGS.md` y `ESTADO-PARALELO.md` NO se commitean (saneo del director).
