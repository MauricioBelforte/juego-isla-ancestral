# Log 2477: M112 — censo de la lane de MODULOS: 496 suites, 2 rojos reales invisibles y el cuello de 300 s

**Fecha:** 2026-11-27
**Hora:** 01:55
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Medí **la lane de módulos del runner central**, que el propio `04-Codigo.md` de M112 pedía
explícitamente (*"la activación de la lane la decide el director con ese dato en mano"*), y entregué
el dato con sus tres condiciones. La lane sigue **apagada por defecto**: activada tal cual, el runner
deja de terminar y empieza a mentir por saturación.

**M17 = 148/175, 0 `[?]`, 0 ítems inflados. 0 flips.**

## La medición

`M112_INCLUIR_MODULOS=1 godot --headless --path game/isla-ancestral --script res://tests/run_tests.gd`
(tope de 1150 s):

| Medida | Valor |
|---|---|
| Suites descubiertas **con** la lane | **496** (492 SceneTree + 4 GdUnit4) |
| Suites descubiertas **sin** la lane | 75 |
| Suites ejecutadas en 1150 s | 438 → 428 OK / 9 ROJAS / 1 TIMEOUT |
| ¿Terminó? | **NO** (seguía corriendo) |
| Coste por suite (tras omitir el mundo) | **~2,5-4,6 s** |

## Por qué no cabe (y por qué no es por el volumen)

496 × 2,5 s serían ~1240 s en serie o **~3,5 min con el pool de 6 workers**: debería caber de sobra.
El cuello real es otro:

1. **Una espera de 300 s POR DISEÑO.** `MemoryMonitor.TIEMPO_BASELINE_S = 300.0`
   (`scripts/rendimiento/memoria/memory_monitor.gd:73`): la baseline de memoria estabilizada tarda
   5 minutos. El timeout del runner es de 300 s → la suite cae en "TIMEOUT — suite colgada >300 s"
   aunque esté sana. En la corrida aparece `baseline estabilizada en 105.2 MB (t=300 s)`.
2. **9 suites rojas, de las cuales 7 son verdes en solitario** (medidas una por una): son reds por
   **contención del pool**, no por el código — lo que el propio runner ya documenta.
   Las **2 que son realmente rojas** y que **el CI no ejecuta** (rojo invisible):
   - `scripts/debug/test_debug_m110.gd` (M110)
   - `scripts/world/test_generacion_m10_atria.gd` (M10)
3. `tests/unit/time/test_time_calendar.gd` (sí está en el CI) dio TIMEOUT **solo bajo saturación**:
   en solitario, **2,4 s y EXIT 0**.

## Las tres condiciones para poder activar la lane

1. **Timeout adaptativo** para las suites que esperan la baseline de 300 s (mismo patrón que
   `NECESITA_MUNDO`: opt-in explícito por suite).
2. **Arreglar o declarar** los 2 rojos reales (M110 y M10, de otros dueños).
3. **Red de seguridad** contra saturación (margen por suite; el reintento en serie no alcanza con
   máquina compartida).

## La propuesta (para quien decide)

Con el mundo omitido (25 s → 2,5 s por suite) y el job `test-suite` **en 4 shards**, la lane COMPLETA
cabria en el CI: 496 × 2,5 s / 4 ≈ **5-8 min**, más la espera de 300 s de la baseline (que sola no
rompe el tope de 20 min del job). Es decir: **el CI podría ejecutar hoy las 496 suites**, no solo las
107, y cerrar el hueco de cobertura de raíz.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` | Nueva sección con la medición, el censo de rojos y la propuesta. |
| `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` | Registro de la tanda. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2477** reservado con `scripts/reservar_log.py --reservar`. |

## Lo que NO se hizo (honestidad)

- **NO se activó** la lane de módulos (sigue apagada por defecto).
- **NO se registró** ninguna suite nueva en el workflow: registrar 390 suites es decisión de la
  directora y de los dueños de cada módulo.
- Los 2 rojos reales son de **M110 y M10**: no se tocaron (no son míos) → se reportan.
- La atribución exacta del TIMEOUT de 300 s quedó ambigua: el pool entrelaza la salida de varios
  workers. Lo verificable es que `TIMEOUT_MS` del runner y `TIEMPO_BASELINE_S` valen ambos 300 s: con
  esos dos valores, cualquier suite que espere la baseline cae en timeout.
- No se midió el CI real (no hay acceso a los runners): la propuesta es un cálculo sobre medidas
  locales, no una observación del runner de CI.
