# Log 2465: M112 — el CI en shards + el mundo NO se carga en los procesos de test

**Fecha:** 2026-11-25
**Hora:** 16:50
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Cierra el pendiente que el propio `04-Codigo.md` de M112 dejaba escrito: *"el tiempo total del CI quedó
en ~872-878 s, por encima del presupuesto de 600 s; el costo dominante es la lane voxel (6 suites x
~72 s de deinit). Medir y decidir le corresponde al dueño de M112"*. Ese ítem estaba en mi backlog
("dueño a definir") y M112 no tenía agente asignado.

**Resultado medido: el runner central bajó de 771 s a 366,7 s y ahora CUMPLE el presupuesto de 600 s.**
El tiempo del *job* de CI es una proyección (~110-150 s): no hay acceso a los runners.

## 1. La medición (lo que nadie había medido)

Sonda temporal sobre el proceso real (ya borrada):

| Medida | Valor |
|---|---|
| Arranque puro del motor (sin escena) | **3,8 s** |
| Carga de `main_island.tscn` (Bootstrap) | **5,3 s** (2 frames) |
| **DEINIT** al salir el proceso (con el mundo cargado) | **~19,6 s** |
| Suite típica de M17, ANTES | **~25-30 s** |
| Suite típica de M17, DESPUÉS | **~2,5 s** |

**El 79% del costo de cada proceso de test era el TEARDOWN de un mundo que las suites no usan.** El
Bootstrap carga `main_island.tscn` (la isla de 5120x5120) en TODOS los procesos, y las suites no la
usan. Con ~90 suites en el CI: ~2250 s locales (~6500 s en el runner de CI, donde el deinit se mide en
~72 s por suite).

## 2. Las dos correcciones (opt-in y reversibles)

### (a) El mundo NO se carga en los procesos de test

`game/isla-ancestral/scripts/core/bootstrap.gd`: `_load_main_scene()` consulta
`_debe_cargar_escena_principal()`. Si el script que conduce el proceso es una suite
(`res://tests/...`, `test_*.gd`, `qa_*.gd`), la escena principal **no** se carga.

- El **juego normal no cambia**: verificado (sigue imprimiendo "Cargando escena principal").
- **Opt-in**: una suite que necesite el mundo declara `const NECESITA_MUNDO := true` y entonces se
  carga como siempre (el Bootstrap lo lee con `get_script().get_script_constant_map()`).
- Solo **2** suites lo necesitan (ambas AFIRMAN sobre `current_scene` real): se les agregó el const
  → `game/isla-ancestral/tests/test_bug128_hud_real.gd` y `game/isla-ancestral/tests/test_m56_tomar_foto.gd`
  (6 líneas cada uno, sin tocar su lógica).

### (b) El job `test-suite` se reparte en 4 shards en paralelo

`.github/workflows/quality.yml`: matrix `shard: [1,2,3,4]`, `fail-fast: false`.

- Las invocaciones (`suite --script ...` y `py_suite ...`) se reparten con **dos contadores
  round-robin independientes**: uno para las suites **ligeras** y otro para las **pesadas**
  (voxel/rendimiento/memoria). Así la cola larga no cae entera en un shard aunque las suites pesadas
  se separen en el archivo.
- Cada invocación la corre **exactamente un** shard (`indice % TOTAL`). Verificado por simulación con
  el bloque REAL del workflow: la unión de los 4 shards es **idéntica** al conjunto original.
- **Aislamiento de `user://` por shard**: cada shard exporta su `XDG_DATA_HOME` y `XDG_CONFIG_HOME`
  (en Linux `user://` cuelga de `XDG_DATA_HOME`). Sin esto, los shards en paralelo se pisan los slots
  de guardado y las suites se cuelgan — el mismo problema que ya aislaba `tests/run_tests.gd` por
  worker.
- El reparto es **dinámico**: si la lista de suites del job cambia, se reacomoda solo (no hay lista
  que mantener).

## 3. Verificación (medida)

| Comprobación | Resultado |
|---|---|
| Las 108 suites del CI, una por una, con el mundo omitido | **108/108 EXIT 0** (0 rojos) |
| Las 2 suites con `NECESITA_MUNDO` | EXIT 0 (~70 s cada una, mundo incluido) |
| Bloque real del workflow ejecutado en 4 shards locales | cada invocación una vez y solo una |
| Runner central `res://tests/run_tests.gd` | **74/74 suites · 3080 tests · 0 fallos · EXIT 0** |
| Tiempo del runner central | **366,7 s** (antes 771 s) → **CUMPLE** el presupuesto de 600 s |
| Suite típica suelta | 25-30 s → **~2,5 s** |
| Regresión M17 | 7/7 verdes (fantasma, cache, atomicidad, terreno, contenido, integración, iter3) |
| Juego normal (sin `--script`) | carga la escena principal **igual que antes** |
| Validador de workflows | `scripts/validar_workflows.py` → 6 workflows válidos |

**Sobre la proyección del job**: 875 s / 4 shards + la cola pesada ≈ **110-150 s**. No se midió en los
runners reales (no hay acceso); lo medido es el costo por proceso y el runner central.

## 4. Lo que NO se hizo (honestidad)

- **No se midió el CI real**: la reducción del job es una proyección.
- **No se tocó `05-Checklist.md` de M112 ni la fila global**: los conteos de M112 los selló
  agnes-3-flash; este log y `04-Codigo.md` son la evidencia, el flip lo decide quien selló el módulo.
- **No se cambió la lista de suites del CI**: se ejecutan **las mismas**, las mismas veces.
- El reparto en 4 shards multiplica por 4 los **runner-minutes** de GitHub (mismo trabajo, más
  paralelismo): es un trade-off consciente, no gratis.
- `scripts/test_muestreo_p100.py` falla **en local** por la consola cp1252 (AGENTS §28.2): el archivo
  está bien, la consola no. En CI (ubuntu, UTF-8) no aplica.

## 5. Aviso de coordinación

`GLM-5.3-Flash` está editando los mismos archivos (`quality.yml` y M56). El mensajería entre pares no
estaba disponible en esta sesión, así que el aviso quedó en `Mensajes entre modelos/ESTADO-PARALELO.md`
y en el canal: **no borrar** el bloque `strategy`/`fail-fast`, los contadores `me_toca`/`es_pesada` ni
los `export XDG_*` de `quality.yml`, y **conservar** el const `NECESITA_MUNDO` en
`tests/test_m56_tomar_foto.gd` y `tests/test_bug128_hud_real.gd`.
