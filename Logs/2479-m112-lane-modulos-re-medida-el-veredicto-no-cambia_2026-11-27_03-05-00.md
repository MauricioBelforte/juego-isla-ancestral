# Log 2479: M112 — re-medición de la lane de MÓDULOS con el tope ya corregido: el veredicto no cambia, el motivo sí

**Fecha:** 2026-11-27
**Hora:** 03:05
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Volví a medir la lane de módulos **después** de corregir el tope por suite (Log 2478) para
actualizar el dato de decisión. **El veredicto no cambia** (la lane sigue sin cerrar en el runner
central) pero el motivo queda claro y la propuesta se afina.

**M17 = 148/175, 0 `[?]`, 0 ítems inflados. M112: 0 flips.**

## La medición (con el tope ya corregido)

`M112_INCLUIR_MODULOS=1 ... --script res://tests/run_tests.gd` (tope 1150 s):

| Medida | Valor |
|---|---|
| Suites descubiertas | **498** (494 SceneTree + 4 GdUnit4) |
| Suites ejecutadas en 1150 s | 420 |
| Rojas | **10** (una de ellas TIMEOUT) |
| Terminó | **NO** |

## El hallazgo: los rojos NO son deterministas

| Corrida | Rojos | Observación |
|---|---|---|
| 1 (Log 2477) | 9 | mayormente suites que el CI corre en VERDE |
| 2 (Log 2479) | 10 | **set distinto**: entraron `test_balance_m93_iter3.gd`, `test_event_manager_verificacion.gd`, `test_amistad_eventos.gd`, `test_logros_m72_statids.gd`, `test_vfx_m52_iter6.gd` y se fueron otros |

**El set de rojos cambia entre corridas**: es la firma de la **contención del pool** (6 workers
compitiendo por la CPU en una máquina compartida), no de fallos de código.

De 10 rojos, solo **2 son estables** (rojos también **en solitario**, en ambas corridas):
- `scripts/debug/test_debug_m110.gd` (M110)
- `scripts/world/test_generacion_m10_atria.gd` (M10)

Y dos de los rojos **variables los corre el CI** (`test_amistad_eventos.gd`,
`test_logros_m72_statids.gd`), donde pasan en **VERDE** porque el CI los ejecuta **en serie**, sin pool.

## La conclusión que afina la propuesta

**La lane de módulos NO pertenece al POOL del runner central: pertenece al CI.**

- Runner central: pool de 6 workers → contención → rojos que no existen.
- CI (`quality.yml`, job `test-suite`): invocaciones **secuenciales dentro de cada shard** → sin
  contención. Con 4 shards, las 498 suites (~2,5 s cada una) ≈ **5-6 min por shard**, dentro del
  tope de 20 min del job.

Por tanto la salida correcta es **registrar en el CI las ~390 suites que faltan** (decisión de la
directora y de los dueños de cada módulo) y **NO** activar la lane de módulos en el runner central.
El runner central queda como verificador rápido (76 suites, 364 s) y el CI como verificador completo.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` | Nueva sección con la re-medición y el análisis de no-determinismo de los rojos. |
| `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` | Registro de la tanda. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2479** reservado con `scripts/reservar_log.py --reservar`. |

## Lo que NO se hizo (honestidad)

- **NO se registró** ninguna suite nueva en el workflow: es decisión de la directora y de los dueños
  de cada módulo.
- **NO se activó** la lane de módulos en el runner central (sigue apagada por defecto).
- No se tocaron los 2 rojos reales (M110 y M10, de otros dueños) → se reportan.
- No se tocó `05-Checklist.md` de M112 ni la fila global (los conteos los selló agnes-3-flash).
- La atribución del TIMEOUT restante sigue siendo ambigua (el pool entrelaza la salida de varios
  workers); lo verificable es que las suites que lo producen pasan en solitario en 2,4 s.
