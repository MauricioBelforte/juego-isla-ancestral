# Auditoría de Contadores de Tests Automáticos — M112 Testing Automático

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18
**Alcance:** `game/isla-ancestral/tests/run_tests.gd` (runner v2c), `tests/` (descubrimiento), `scripts/verificar_hooks_m105.py`, `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`, fila `CHECKLIST-GLOBAL.md`.

## 1. Verificación de conteos

- `05-Checklist.md` (M112): `228 [x] / 0 [ ] / 4 [?] = 232`. `CHECKLIST-GLOBAL.md` fila 112: `228/232`. Sin drift.
- Runner declara evidencia `suites descubiertas: 26 (22 SceneTree + 4 GdUnit4)`, `checks SceneTree: 697`, `GdUnit4: 21`, `tests totales: 718`. La descubierta es dinámica (depende de `_barrer` y del flag `--incluir-modulos`), por lo que el número varía entre corridas; no es un conteo fijo auditable. La anti-falsificación (`tests_total <= 0 → quit(2)`) es correcta.
- `CHECKS_MINIMOS` en suites de `scripts/` (telemetría, etc.) son pisos medidos, no conteos exactos; el runner no verifica igualdad con un esperado. Consistente con el patrón del proyecto (piso, no exacto).

## 2. Hallazgos (archivo:línea, severidad, accionable)

### Alto

1. `run_tests.gd` (descubrimiento `_barrer`, línea ~230) — `IGNORAR_DIRS = ["helpers"]` **no incluye `Obsoletos`**. La carpeta `tests/Obsoletos/` contiene suites legacy (`2026-09-01_..._test_debug_menu_v1_api_muerta.gd`, etc.) que se descubren y ejecutan, inflando el conteo de tests y pudiendo resucitar fallos ya archivados. **Severidad: Alto.** Accionable: añadir `"Obsoletos"` (y `"backup"`) a `IGNORAR_DIRS`.

2. `run_tests.gd:~230` (`_barrer`) — no filtra por prefijo de carpeta de obsoletos ni por archivos con sufijo `_v1`/`_muerta`. Solo filtra por nombre de directorio. **Severidad: Medio.** Accionable: centralizar exclusión en un conjunto `EXCLUIR_GLOBS`.

### Medio

3. `run_tests.gd:_analizar_salida` (regex de fallos) — reconoce `"fallos"` y `"[FAIL]"`/`"FALLO:"` pero **no reconoce `"failures"`/`"errors"` en inglés**. Suites que imprimen `N failures`/`M errors` pueden ser contadas como OK con 0 fallos si su salida no contiene los tokens en español. **Severidad: Medio.** Accionable: añadir regex para `failures?`/`errors?` en inglés.

4. `run_tests.gd:_resumen` (guard `not _gdunit_ok`) — `_gdunit_ok` se inicializa en `false` y solo se pone `true` si se ejecuta `_correr_gdunit()`. Si `_gdunit_dirs` está vacío, el guard siempre falla → reporte FALLO aunque todas las suites SceneTree pasen. **Severidad: Medio.** Accionable: inicializar `_gdunit_ok = true` cuando `_gdunit_dirs.is_empty()`.

5. `run_tests.gd:_correr_scenetree` — `_checks_total` solo acumula en suites OK; las suites fallidas no aportan sus checks al total, subreportando el volumen de tests ejecutados. **Severidad: Bajo-Medio.** Accionable: acumular checks en un contador separado `_checks_ejecutados` independientemente del OK, y reportar ambos.

6. `run_tests.gd:_instancia_voxel` — detección por `txt.contains("main_island")` puede marcar como voxel una suite que solo menciona el término en un comentario. **Severidad: Bajo.** Accionable: buscar `VoxelTerrain`/`VoxelViewer` solamente.

7. `run_tests.gd:_es_segura_para_pool` — check estático de `"user://"`/`"OS.execute"` no detecta escrituras indirectas vía autoloads (SaveManager, DataStore); mitigado por `aislar_user` en el pool, pero la clasificación puede ser optimista. **Severidad: Bajo.** Accionable: documentar o añadir heurística de autoloads.

8. `run_tests.gd:_correr_pool` — si un `_worker_suite` lanza excepción, `_pool_en_curso` no se decrementa → posible deadlock del pool. **Severidad: Bajo.** Accionable: envolver en try/finally (o equivalente) para garantizar decremento.

### Bajo / Ruido

9. `run_tests.gd:_ejecutar_con_redirect` — `timeout_ms <= 0` no se valida; un 0 produce timeout inmediato. **Severidad: Ruido.**

10. `run_tests.gd:_descubrir` (lane de módulos, opt-in) — default apagado por presupuesto de tiempo (600s). Los 422 tests de módulos quedan invisibles por defecto; los totales declarados (718) no los incluyen. Documentado, pero es un drift potencial entre "tests del proyecto" y "tests corridos por defecto". **Severidad: Bajo.** Accionable: exponer en el banner el número de suites disponibles en modo módulos.

11. `run_tests.gd:_correr_gdunit` — timeout fijo de 300000 ms sin reintento en serie (a diferencia del pool SceneTree). Inconsistencia de política de timeout. **Severidad: Ruido.**

## 3. Veredicto

El runner v2c es veraz (anti-falso-verde estructural) y los conteos del checklist son consistentes con la tabla global. Los principales riesgos de conteo son: (a) descubrimiento de suites obsoletas en `tests/Obsoletos/`, (b) subreporte de checks en suites fallidas, y (c) falsa negativa por `_gdunit_ok` cuando no hay suites GdUnit4. No se detectaron off-by-one en los umbrales de timeout (pool 300s, serie 180s) ni en el reintento.

## 4. Dos mejoras de diseño concretas

1. **Exclusión centralizada y explícita de obsoletos**: convertir `IGNORAR_DIRS` en un conjunto que incluya `Obsoletos`, `backup`, `Obsoletos` (anidado) y validar en `_descubrir` que ninguna ruta descubierta contenga un segmento de obsoleto. Añadir un contador `suites_obsoletas_ignoradas` al banner para trazabilidad.

2. **Conteo exacto con dos contadores**: separar `_checks_ejecutados` (todos los checks reportados por suites que corrieron, OK o no) de `_checks_ok` (solo OK), y en `_resumen` reportar ambos. Añadir además `CHECKS_ESPERADOS` opcional por suite (cuando se declara) para detectar suites que se saltan/duplican checks (assert `_checks == CHECKS_ESPERADOS`), no solo piso.

**No se modificó código del juego.** Solo supervisión y validación.