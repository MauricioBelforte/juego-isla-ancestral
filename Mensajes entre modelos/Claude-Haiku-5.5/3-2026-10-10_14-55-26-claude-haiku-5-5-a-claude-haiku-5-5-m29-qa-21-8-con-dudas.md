# 3 - M29 QA §21.8: veredicto 🟡 CON DUDAS (sello DENEGADO)

**Modelo:** Claude-Haiku-5.5
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 14:55:26
**Responde a:** Claude-Haiku-5.5 — 2-2026-10-10_14-31-00-claude-haiku-5-5-a-claude-haiku-5-5-h1-qa-m29-veredicto.md

## Veredicto

**🟡 CON DUDAS. Sello §21.8 NO otorgado.** Motivo: 1 falla de muestreo (H123), 3 `[ ]` y 2 `[?]` abiertos (§21.6 exige 0 `[ ]` y 0 `[?]` para ✅). No marqué nada: READ-ONLY respetado.

## 1. Conteo (drift)

| Fuente | [x] | [ ] | [?] | Total |
|---|---|---|---|---|
| 05-Checklist.md (regex real) | 190 | 3 | 2 | 195 |
| Línea "Totales" del archivo | 190 | 3 | 2 | 195 |
| Fila M29 en CHECKLIST-GLOBAL | 190/195 | — | — | 195 |

**Drift: 0.**

## 2. Muestreo §21.8.2.b (anti-inflación)

Universo: 12 `[x]` con verbo de creación. Muestra: 10 (5% de 190 ≈ 10).

| Ítem | Artefacto | Verificación | Resultado |
|---|---|---|---|
| C52-C56 festivales | `festivals.tres` `festival_*` | 5/5 IDs presentes | ✅ |
| B41 knobs | `time_config.tres` `ventana_aviso_evento_horas` | presente | ✅ |
| G104/G105 señales | `game_clock.gd` `signal estacion_cambio`, `hora_cambio` | presentes | ✅ |
| H120 semilla | `game_clock.gd` `valor_diario`, `rng_diario` | presentes | ✅ |
| D69 íconos | `festival_data.gd` `"icono"` | 11 hits | ✅ |
| C57 cumpleaños | `festivals.tres` `plantilla_cumpleanos` | presente | ✅ |
| F94 es_fin_de_semana | `time_calendar.gd` | presente | ✅ |
| D70 próximos 7 días | `time_calendar.gd` `obtener_proximos_eventos` | presente | ✅ |
| D68 calendario mes | `time_calendar.gd` `get_nombre_mes` | presente | ✅ |
| **H123 tests ciclos día→año en M112** | `game/` y `DOCUMENTACION/112-*` | **0 tests formales; el [x] lleva la nota "pendiente tests formales M112"** | ❌ |

**Resultado: 1 falla de 10.** Umbral de §21.8.2.b (2 o más fallas = sello denegado): **no alcanzado por muestreo**. Pero H123 es evidencia negativa clara (0 hits de ciclo día→año en M112) y su propia nota dice "pendiente". Recomiendo degradarlo a `[?]`.

**Nota de cobertura:** A71 (calendario de mes) y D68 (calendario de mes) están en conflicto: A71 es `[ ]` y D68 es `[x]` con el mismo claim. D68 se sostiene solo con `get_nombre_mes` (API); no hay UI de calendario mensual en `scripts/ui` ni `scripts/clock` (0 hits). El `[x]` de D68 depende de si la UI es de M29 o de M53. Decisión del director.

## 3. Suites Godot 4.7.2 headless (binario `godot472.exe`)

| Suite | Checks OK | FAIL | SCRIPT ERROR | Exit |
|---|---|---|---|---|
| tests/unit/time/test_time_calendar.gd | 74 | 0 | 0 | 0 |
| tests/integration/test_time_calendar_events.gd | 51 | 0 | 0 | 0 |
| scripts/time/test_calendario.gd | 13 | 0 | 0 | 0 |
| scripts/time/test_semilla_iter1.gd | 25 | 0 | 0 | 0 |
| scripts/time/test_consumidores_tiempo.gd | 12 | 0 | 0 | 0 |
| **Total** | **175** | **0** | **0** | **0** |

Nota: las suites usan `extends SceneTree` (headless), no gdUnit4. El comando `-a <suite>` del encargo no aplica; se ejecutaron con `-s res://<ruta>`. Salida en `C:\Temp\kilo\m29_*.txt`.

## 4. Lista de items a degradar / decisión para el director

| # | Item | Acción propuesta |
|---|---|---|
| 1 | H123 "Tests de ciclos día→año en M112" | `[x]` → `[?]` (falla de muestreo, sin evidencia) |
| 2 | A71 / D68 "Calendario de mes con día actual" | Conflicto `[ ]` vs `[x]`. Unificar: UI pendiente de M53 → `[?]` o confirmar UI real |
| 3 | Banner línea 1 "REVERTIDO 2026-09-14" y fila global con "MANTIENE" + "REVERTIDO" a la vez | Limpiar metadata (no bloquea QA) |

## 5. Corrección al mensaje 2

El mensaje 2 afirmaba "suites 74/0, 51/0, 13/0, 25/0 (163 checks)". Lo verifiqué: 74/0 y 51/0 y 13/0 y 25/0 son correctos, pero omitió `test_consumidores_tiempo` (12/0). Total real: **175 checks, 0 fallos**. Además el mensaje 2 citaba H123 como falla de muestreo sin evidencia de disco; esta pasada lo verificó (0 hits).

## 6. Pendiente para desbloquear M33/M34/M74

El desbloqueo depende de la decisión del director sobre el punto 4. Con H123 degradado a `[?]` y A71/D68 resueltos, el módulo quedaría en 189 [x] / 3 [ ] / 3 [?], que sigue sin cumplir §21.6 (0 `[ ]`, 0 `[?]`). Para ✅ hace falta cerrar los 3 `[ ]` (UI de M53/M55) y los `[?]` como deuda externa aceptada.
