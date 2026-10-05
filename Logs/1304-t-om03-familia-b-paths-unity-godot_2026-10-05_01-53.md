# Log 1304: T-OM03 Familia B — paths Unity→Godot stale corregidos en 3 modulos

**Fecha:** 2026-10-05
**Hora:** 01:53
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Prioridad 3 del director (canal 29): T-OM03, Familia B (120 items, 16 modulos).
Escanee los `plan-actual/04-Codigo.md` de los 16 modulos contra el codigo real y
corregi los paths Unity→Godot stale. Encontre **54 referencias** candidates y
verifique cada renombre contra el arbol antes de tocar nada.

## Cambios Realizados

### Metodologia

1. Escanee los 16 modulos de Familia B buscando `.cs`, `Assets/`, `MonoBehaviour`,
   `BuildPipeline` y los 3 renombres conocidos (`behavior.gd`, `balance.gd`,
   `isla_generador.gd`).
2. **Verifique cada path contra el arbol real** (glob recursivo) antes de cambiar la
   documentacion. Regla: la documentacion se alinea al codigo, no al reves.
3. Solo toque `plan-actual/` (los `plan-inicial/` son intocables por regla del proyecto).

### Renombres verificados

| Path en la doc | Existe? | Path real | Accion |
|---|---|---|---|
| `scripts/balance/balance.gd` | NO | `scripts/balance/balance_service.gd` | **M93 corregido** (3 refs) |
| `isla_generador.gd` | NO | `scripts/world/island_generator.gd` | **M167 corregido** (1 header) |
| `fauna_behavior.gd` | SI | `scripts/fauna/fauna_behavior.gd` | Ya correcto (M36/M65) |

### M93-Balance (plan-actual/04-Codigo.md)

3 referencias a `balance.gd` actualizadas a `balance_service.gd`:
- L29 (tabla de archivos: Autoload)
- L37 (header de seccion 2.1)
- L196 (nota de implementacion)

Cuidado con no romper `validate_balance.gd`, `test_balance.gd`,
`test_balance_m93_iter3/4.gd` y `balance_report.gd`: todos **existen** y contienen
"balance.gd" como subcadena. Verifique que no quedo ningun residual falso.

### M167-Isla-Raiz (plan-actual/04-Codigo.md)

L31: header `### isla_generador.gd` → `### island_generator.gd`. Es el unico punto
donde el plan nombra el generador; el resto del modulo ya usa `get_height` y el
autoload `mundo_raiz.gd` (fuente unica de verdad, P-39).

### M118-CI-CD (plan-actual/04-Codigo.md) — correccion mayor

**Era mi modulo y estaba completamente stale.** Describia:
- `assets/editor/BuildScript.cs` con `BuildPipeline.BuildPlayer`,
  `BuildTarget.StandaloneWindows64`, `BuildOptions.DevelopmentBuild` — **API de Unity**.
- `.github/workflows/ci-cd.yml` — **no existe** (el real es `quality.yml`).
- `scripts/build_dev.ps1` / `build_release.ps1` — no existen.
- `tests/run_tests.gd` con funciones `pass` vacias — no existe.
- Todo marcado "Pendiente de implementacion".

**Verificado contra el arbol:** `BuildScript.cs` nunca existio. La realidad Godot:
- 6 workflows operativos: `quality.yml` (848 lineas), `bug_metrics.yml` (226),
  `release-build.yml` (140), `dev-build.yml` (113), `backup.yml` (99), `testing.yml` (76).
- `export_presets.cfg` con presets **Web** y **Windows** (versionado en mi Log 1290).
- Las suites de tests son GDScript headless reales (patron SceneTree + `_check`).

Reescribi secciones 1-4 con la realidad Godot:
- Tabla de los 6 workflows + presets, todos ✅ operativos.
- API de builds con `godot --headless --export-release "<preset>"` (incluye el fallback
  `--export-debug` que usa `release-build.yml`).
- Patron real de suites headless (SceneTree + `_check` + `quit(1 if _fallos else 0)`).
- Pendientes reales: gate M151 + versionado del addon voxel.
- Anadi una nota explicita de la correccion Unity→Godot para el proximo agente.

### Modulos sin cambios (verificados limpios)

M32, M78, M81, M82, M85, M94, M114, M116, M119, M145, M146, M154: sus referencias
`.cs`/`Assets/` ya estan marcadas `_(diseno heredado)_` con su equivalente `.gd`
(migracion documentada, no stale). M94 incluye la flecha explicita
`ObjetivoDiario.cs → objetivo_data.gd`.

M36/M65: `fauna_behavior.gd` ya correcto (el renombre ya estaba aplicado en la doc).

### P-40.6 — cerrado

El director me pidio verificar el canal 18 de mimo. Leido: es sobre M55 (diario UI),
**el director ya verifico la fila 55** (`🟡 33/131`, invariante EOL CRLF=231). Mi
backlog ya tenia P-40.6 cancelado (M07, sello de mimo Log 1148 valido). **No requiere
accion.** Cierro la tarea en mi backlog.

## Lo que NO pude hacer (honestidad)

- Quedan ~120 items Familia B cuya justificacion es "KnownIssue no bloqueante — item de
  diseno/documentacion (no es de codigo)". Reevaluar uno por uno si la justificacion
  sigue siendo valida es trabajo de otra iteracion; este log cubre solo los paths
  stale de `04-Codigo.md`, que era el defecto concreto.
- T-OM04 (re-auditar con `verificar_checklist.py`) queda pendiente: el director pidio
  "inmediatamente despues de OM03", pero el script es de space-bunny y los cambios de
  este log no tocan `05-Checklist.md` (solo `04-Codigo.md`), asi que los conteos no
  cambian. Lo dejo para la proxima iteracion con su log.

## Archivos Modificados/Creados

- `DOCUMENTACION/93-Balance/plan-actual/04-Codigo.md` (3 refs balance.gd)
- `DOCUMENTACION/167-Isla-Raiz/plan-actual/04-Codigo.md` (header L31)
- `DOCUMENTACION/118-CI-CD/plan-actual/04-Codigo.md` (secciones 1-4 + notas)
- `Logs/1304-t-om03-familia-b-paths-unity-godot_2026-10-05_01-53.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1304 consumido; nueva cabeza 1305)

## Huella de push (AGENTS.md seccion 4.3)

Se completa tras el push.
