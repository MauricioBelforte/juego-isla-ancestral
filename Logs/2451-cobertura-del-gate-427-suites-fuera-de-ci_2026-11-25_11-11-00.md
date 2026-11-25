# Log 2451: Cobertura del gate — 427 suites que CI no ejecuta, y el hueco que esconden

**Fecha:** 2026-11-25
**Hora:** 11:11
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Punto de partida

Con los 4 jobs de CI en verde, la pregunta que sigue no es "¿pasa CI?" sino "¿qué ve CI?".
El job `Test Suite` ejecuta **101** suites; el repo tiene **524** scripts `test_*.gd`.
Lo que no está registrado no se ejecuta, y lo que no se ejecuta no puede ponerse rojo.

## Medición

```
suites en disco ......... 524
suites en el workflow ... 101
FUERA del workflow ...... 427
```

Nueva herramienta: `tools/quality/auditar_cobertura_suites.py` (report, `--fuera` para el listado
y `--check` que falla solo si el workflow referencia una suite que no existe — el doctor del
rot: una entrada con la ruta mal escrita se salta en silencio y parece que corre).

## El hueco real, encontrado por casualidad y no por el gate

`tests/test_m17_categorias.gd` estaba **en rojo** (24 checks, 3 fallos) y **no estaba registrada**
en el workflow. Fallaba desde antes de hoy: exigía `BuildHudModel.filas_categorias()`, una API
que nunca existió. Nadie lo veía porque el job no la ejecuta.

Cronología medida de esta ronda (todo con el mismo arnés `& godot --headless --script`):

| Hora | Estado de `test_m17_categorias.gd` | Quién |
|---|---|---|
| 10:47 | 24 checks, **3 fallos** (`filas=0`, suma 0) | yo (cross-QA) |
| 11:05 | aparece `tests/test_m17_hud_categorias.gd` en `tests/` | minimax-m3-1-flash |
| 11:10 | 24 checks, **0 fallos** | yo (confirmación) |

No lo arreglé: es M17, reclamado por minimax-m3-1-flash hoy (§21.4). Lo verifiqué de forma
independiente (§21.8) y el arreglo que hicieron **es el honesto**: implementaron la API que el
test pedía (`filas_categorias`, 4 filas en orden canónico, `cantidad` del catálogo real = 46,
`cantidad_modo` filtrada por `es_mueble`, tolerancia sin manager → `[]`, `resumen()` intacto) y
sumaron una suite propia de 22 checks. No borraron el test rojo.

## Barrido de suites de `tests/` fuera de CI

40 suites de `tests/` que el workflow no ejecuta (sin `tests/unit/**`, que son GdUnit4 y no son
`--script`, ni `tests/helpers/**`): **0 rojas, 0 timeouts**, con timeout de 120 s por suite.

El barrido dejó una lección de arnés: la primera versión usaba `Start-Process` con
`-RedirectStandardOutput` y **reportaba exit 1 en suites que daban 0** (marcó roja a
`test_m17_circulacion.gd`, que con `&` da 0). Se reescribió con `& ... ; $LASTEXITCODE` dentro de
`Start-Job` (exit code real + timeout real). Un auditor que inventa rojos es tan malo como uno
que no ve rojos.

## BUG-069 — estado medido y una entrada muerta menos

- Documento nuevo: `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash-DeepAI/BACKLOGS/evidencias/BUG-069-estado-2026-11-25.md`
  con el grafo medido (117 autoloads, 254 aristas, **1 SCC** `DataStore`↔`SaveManager`, **10 refs**
  fuera de orden, 0 hallazgos nuevos).
- Se **retiró** de `PERMITIDOS` la entrada obsoleta `A1|ThemeService,UIManager`: sostenía un ciclo
  cerrado en Log 1391 por código muerto. El auditor hacía rondas avisando que ya no la observaba.
  Medido después: 1 SCC, 0 hallazgos nuevos, **exit 0**. Anotado en `DOCUMENTACION/11-BUGS.md`.
- El ciclo `DataStore`↔`SaveManager` sigue declarado: cerrarlo es un mediador en la ruta de
  guardado, no un fix de gate. Las 10 A2 son módulos ajenos y no hay fallo medido que las urja.

## Archivos

- `tools/quality/auditar_cobertura_suites.py` (nuevo, `git add`; 0 huérfanos)
- `scripts/auditar_arquitectura_m62.py` (entrada obsoleta retirada)
- `DOCUMENTACION/11-BUGS.md` (nota de resolución firmada)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash-DeepAI/BACKLOGS/evidencias/BUG-069-estado-2026-11-25.md`

## Pendiente

Decidir con el director si (a) se registran en `quality.yml` las suites de M17 hoy verdes, y
(b) se agrega el paso de cobertura al CI. `quality.yml` tiene un diff ajeno sin commitear, así
que no lo toco sin acuerdo.