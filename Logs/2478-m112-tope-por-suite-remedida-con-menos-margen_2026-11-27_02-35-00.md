# Log 2478: M112 — la re-medición en serie tenía MENOS margen que el pool (fallo inexistente)

**Fecha:** 2026-11-27
**Hora:** 02:35
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Primer bloqueador de la lane de módulos (P13) corregido de raíz: **el runner reportaba fallos
inexistentes**. El tope de la re-medición en serie (180 s) era **MENOR** que el del pool (300 s):
la misma tarea, con menos tiempo, en la segunda vuelta → toda suite que agotaba el pool fallaba
también en la re-medición.

**M17 = 148/175, 0 `[?]`, 0 ítems inflados. M112: 0 flips.**

## El defecto

`_correr_scenetree()` (en `game/isla-ancestral/tests/run_tests.gd`): cuando una suite da TIMEOUT en
el pool, se re-mide en serie con `TIMEOUT_MS` (180 s) frente a `POOL_TIMEOUT_MS` (300 s) del pool.

Consecuencia observable: `FAIL TIMEOUT — suite colgada` **sin que haya ningún fallo de la suite**.
El reintento existe para descontar la contención del pool, así que debe dar **más** margen.

Además, ninguna suite podía pedir más tiempo: la baseline de memoria de M62 son **300 s POR DISEÑO**
(`MemoryMonitor.TIEMPO_BASELINE_S = 300.0`), de modo que una suite que la espere nunca cabe en un
tope de 300 s.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/tests/run_tests.gd` | `TIMEOUT_MS_REMEDIDA := 420000` para la re-medición. Nueva función pura `timeout_para_suite(ruta, en_pool)` y `suite_pide_timeout_largo(ruta)`: opt-in por suite con `const NECESITA_TIMEOUT_LARGO := true` → `TIMEOUT_MS_LARGO := 900000`. El opt-in se busca en las primeras 4000 líneas del archivo y **una línea de comentario no cuenta**. |
| `game/isla-ancestral/tests/test_m112_timeout_adaptativo.gd` (NUEVO) | **15 checks** + mínimo 10. |
| `.github/workflows/quality.yml` | Suite nueva cableada en el job `test-suite` (con su comentario de por qué). |
| `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` | Nueva sección con el defecto, la corrección y la verificación. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2478** reservado con `scripts/reservar_log.py --reservar`. |

## Verificación (Godot 4.7.2 headless, binario real)

**Suite nueva** `tests/test_m112_timeout_adaptativo.gd`: **15 checks, 0 fallos, EXIT 0**.
Checks: "A1: una suite normal NO pide timeout largo" · "A2: en el pool una suite normal usa el tope
de pool (300000 ms)" · "A3: en serie una suite normal usa el tope de serie (180000 ms)" · "B1: el opt-in
se detecta (const NECESITA_TIMEOUT_LARGO := true)" · "B2/B3: con opt-in el tope es el LARGO (900000 ms)
también en el pool / en serie" · "C1: una línea de COMENTARIO no cuenta como opt-in" · "C2: un opt-in en
false NO cuenta" · "C3: una ruta inexistente no revienta" · "D1: la re-medición en serie usa un tope
MAYOR que el del pool" · **"D4: la RE-MEDIDION usa de verdad el tope largo (el sitio de llamada, no solo
la constante)"**.

**ROJO-VERDE**: revirtiendo los dos arreglos → **3 fallos / EXIT 1** (B2, B3, D4). El check **D4**
existe porque comparar constantes no detecta que la llamada siga usando el tope viejo: mira el
**sitio de llamada** en el código del runner.

**Runner central** tras el cambio: **76/76 suites · 3095 tests · 0 fallos · 364,4 s** → **CUMPLE** el
presupuesto de 600 s. `validar_workflows.py`: 6 workflows válidos (el gate "trampa 98" correctly exige
que la suite referenciada esté versionada: encontró la nueva sin commitear y loDijo → se versionó y
pasó).

## Lo que NO se hizo (honestidad)

- **No se activó** la lane de módulos del runner (sigue apagada por defecto; la decisión es de la
  directora).
- **No se marcó** ninguna suite con `NECESITA_TIMEOUT_LARGO`: hoy ninguna lo pide (la que espera la
  baseline es un arnés de 30 min, `sesion_m62_30min.gd`, que no es una suite del runner).
- No se tocó `05-Checklist.md` de M112 ni la fila global (los conteos los selló agnes-3-flash).
- Quedan dos bloqueadores de la lane de módulos: los **2 rojos reales** de otros dueños
  (`test_debug_m110.gd` de M110, `test_generacion_m10_atria.gd` de M10) y el margen por suite contra
  la saturación.
