# Log 2460: el step de tests de dev-build era un gate que siempre decía rojo

**Fecha:** 2026-11-25
**Hora:** 15:14
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Síntoma

`dev-build.yml:61` corre `python tools/ci/run_tests.py --out out/ci-report-dev.json 2>&1 ||
echo "Some tests failed"`. Y `run_tests.py` descubre **todos** los `test_*.gd` de `scripts/` y
`tests/` y los corre con `--script`. Medido hoy: de 527 archivos, **11 no se pueden correr así**:

| Archivo | `extends` | Por qué no corre con `--script` |
|---|---|---|
| `tests/unit/{debug,foto,inventario,ui}/test_*.gd` | `GdUnitTestSuite` | exit 1: "doesn't inherit from SceneTree or MainLoop" |
| `scripts/test_arquitectura.gd`, `scripts/test_terrain.gd`, `scripts/test/test_anillo_arena.gd`, `scripts/interacciones/test_mock_interactable.gd` | `Node3D` | ídem |
| `scripts/core/test_m66_handler.gd` | `IRecoverable` | ídem |
| `scripts/core/test_m66_inv_ruta.gd` | `InvariantBase` | ídem |
| `tests/helpers/test_helpers.gd` | `RefCounted` | ídem |

Con ~11 fallos garantizados, `run_tests.py` salía **1 siempre**, y el `|| echo` del workflow lo
tapaba. Resultado: un step que nunca podía estar verde y que nadie miraba. Un gate que siempre
dice rojo no es un gate.

## Arreglo

`tools/ci/run_tests.py`:

1. Filtra por cabecera: solo corre archivos que hacen `extends SceneTree` o `MainLoop`
   (`es_ejecutable_con_script`). Lee el **archivo completo**: con una ventana de 4000 caracteres
   clasificaba mal `scripts/historias/test_historias.gd` (200 líneas de comentario antes del
   `extends`). Corregido: 516 ejecutables / 11 omitidas.
2. Informa las omitidas en vez de descartarlas en silencio, con `--incluir-gdunit` para forzarlas
   (diagnóstico; puede tardar: el runner de GdUnit sin el addon se cuelga hasta el timeout).
3. **Reintento único de las rojas**: si pasa al segundo intento se marca `flaky` y se informa; si
   falla otra vez, es rojo real.

## Medición

```
--module tests/unit ...... 19 suites | 19 OK, 0 FAIL | 204 s | EXIT=0
--module tests/ .......... 68 suites | 67 OK, 1 FAIL | 1050 s | EXIT=1
  roja: test_m17_hud_categorias (rc=1 en el lote)
  sola, dos veces seguidas: EXIT=0, "22 checks, 0 fallos"
```

La roja del lote fue **contención**, no defecto: varios agentes con Godot sobre el mismo árbol
(`.godot/` a medio escribir, "Waiting for all tasks to be picked"). Ese es exactamente el motivo
del reintento: un falso rojo recurrente entrena a ignorar el gate.

## Auditoría de los otros workflows

Busqué todo `|| true`, `|| echo`, `continue-on-error` y `set +e` en `.github/workflows/`:

| Workflow:línea | Qué es | Veredicto |
|---|---|---|
| `dev-build.yml:61` | `run_tests.py || echo` | **agujero real** (mitigado por este log) |
| `release-build.yml:97` | gate con `|| true` + `grep "CONTROL FINAL: BLOQUEADO"` | deliberado: el veredicto se lee del texto, y sí aborta el release |
| `quality.yml:1235` | mismo patrón, acta informativa | deliberado, documentado en el YAML |
| `quality.yml:1031` | `continue-on-error: true` en el reporte del pool | deliberado, informativo |
| `backup.yml:57,98` | `|| true` en limpieza de backups | aceptable (limpieza best-effort) |

## Pendiente de decisión

Ahora que `run_tests.py` es honesto, `dev-build.yml:61` puede dejar de tapar. Pero el lote
completo son ~516 suites y 68 tardaron 17 min: el run entero ronda las 2 h. Propuesta al
director: que dev-build corra `--module tests/` (17 min, cubre la regresión real) y falle de
verdad, en vez de correr 516 probes bajo `scripts/` con el resultado tirado a la basura.

## Archivos

- Modificado: `tools/ci/run_tests.py` (filtro + omitidas + reintento + cabecera documentada).
- Reportes temporales en `out/` (ignorado por git), borrados al cerrar la tanda.