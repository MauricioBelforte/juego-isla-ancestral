**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12

# 07-Resultados-Testings.md — Módulo 74: Eventos

## 1. Suites ejecutadas (por stepfun-step-5-preview / Kilo Code, 2026-10-11)

Resultados extraídos de los Logs 1690, 1694, 1697 y 1699 y de las notas del propio checklist
(atribución textual; este entorno no tiene Godot y no las re-ejecutó).

| Suite | Checks | Fallos | Log |
|---|---|---|---|
| `test_event_manager_pure.gd` | — (escaneo de `data/`, 0 fallos) | 0 | 681 |
| `test_capitulos_m74.gd` | 23 | 0 | iter-2 (2026-09-06) |
| `test_event_manager_verificacion.gd` | 58 | 0 | 1690 |
| `test_solapes_m74.gd` | 33 | 0 | 1699 |
| `test_eventos_relativos_m74.gd` | 38 | 0 | 1697 |
| `test_buzon_entregas.gd` | 31 | 0 | 1694 |
| **Subtotal (7 suites)** | **212 checks declarados** | **0** | — |

Bugs reales corregidos por esas pasadas (documentados en el checklist):
`_set_estado` no escribía si el año ya existía; división entera en `dias_hasta`;
`restore_save_data` crasheaba con save corrupto; `RecompensaDef.entregar()` llamaba APIs
inexistentes de M14/M38; la compensatoria pisaba `CANCELADO` con `PARTICIPADO`.

## 2. Suite nueva del barrido — `test_barrido_m74.gd` (atria, 2026-10-12)

| Métrica | Valor |
|---|---|
| Bloques | 13 |
| `CHECKS_MINIMOS` (piso) | 45 |
| **Resultado** | **PENDIENTE DE EJECUCIÓN** |

**No se ejecutó:** este entorno no tiene Godot. La suite está escrita con el mismo patrón que
las 7 existentes (SceneTree puro, `_ok`/`_abrir`/`_fin`, `CHECKS_MINIMOS`, `quit(1)` en fallo)
y debe correr en CI/headless.

## 3. Verificación estática realizada en este barrido (sí ejecutada)

Cada flip `[?]` → `[x]` se justificó con evidencia en disco:

- Conteo estricto del checklist con regex (`^- \[([ x?])\]`): 285 ítems, antes 128/2/155,
  después 224/2/59.
- APIs externas verificadas por grep: `depositar_monedas` existe en `economy_manager.gd:101`;
  `Friendship` **sin** `modificar`/`sumar_puntos`; **sin** autoload `Museo` en `project.godot`;
  señales de M29/M30 son `dia_cambio`, `hora_cambio`, `minuto_cambio`, `estacion_cambio`,
  `evento_activado` (**no** existe `año_cambio`).
- `_process`/`_physics_process` ausentes en `event_manager.gd` (cero polling, K1).
- Sin referencias a posición/isla del jugador en `scripts/eventos/*.gd` (J26).
- Sin ocurrencias de "última oportunidad" en `strings_es.json` (I22).
- Catálogo real: 22 `.tres` en 7 categorías; capítulos con `flags.capitulo`/`gatillo`
  (historia, fuera del ciclo anual); ningún `.tres` con flag `unico`/`irrecuperable`.

## 4. Pendiente de validación runtime

- Ejecutar las 8 suites en Godot headless (incluida la nueva).
- M9 (clima) y M27 (FOMO end-to-end) requieren escenas/runtime.
- M21/M22 (consola y NullReference en Play Mode) requieren el editor.
