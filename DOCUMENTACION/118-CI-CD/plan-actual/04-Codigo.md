**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 118: CI/CD

## 1. Archivos del sistema (estado real, Godot 4.x)

| Archivo | Descripción | Estado |
|---|---|---|
| `.github/workflows/quality.yml` (848 líneas) | CI principal: 12 jobs (linter headless, suites, gates de protocolo, encoding, legal) | ✅ Operativo |
| `.github/workflows/release-build.yml` (140) | Build de release en tags: jobs `test` → `build` (matriz de export) → `checksum` | ✅ Operativo |
| `.github/workflows/dev-build.yml` (113) | Build de desarrollo | ✅ Operativo |
| `.github/workflows/backup.yml` (99) | Backup 3-2-1 (gate `backup_configurado` de M151) | ✅ Operativo |
| `.github/workflows/testing.yml` (76) | Workflow de testing auxiliar | ✅ Operativo |
| `.github/workflows/bug_metrics.yml` (226) | Métricas de bugs | ✅ Operativo |
| `game/isla-ancestral/export_presets.cfg` | Presets de export Godot: **Web**, **Windows** | ✅ Versionado (Log 1290) |
| `game/isla-ancestral/project.godot` | Config del proyecto (autoloads, plugins) | ✅ Versionado |

> ⚠️ **Corrección de paths Unity→Godot (T-OM03, Log posterior):** la versión original de
> este archivo describía `assets/editor/BuildScript.cs` con `BuildPipeline.BuildPlayer`
> (`BuildTarget.StandaloneWindows64`, `BuildOptions.DevelopmentBuild`) — **API de Unity**,
> no de Godot. En Godot 4.x los builds se definen con `export_presets.cfg` y se disparan
> con `godot --headless --export-release "<preset>" <salida>`. `BuildScript.cs` **nunca
> existió** (verificado contra el árbol). Esta tabla reemplaza la spec Unity por la
> implementación Godot real.

## 2. API de builds (Godot, reemplaza a BuildScript.cs)

```bash
# Build de release (preset "Windows")
godot --headless --path game/isla-ancestral --export-release "Windows" build/release/IslaAncestral-windows.exe

# Build de release (preset "Web")
godot --headless --path game/isla-ancestral --export-release "Web" build/web/index.html

# Fallback a debug si el release falla (patrón usado en release-build.yml)
godot --headless --path game/isla-ancestral --export-debug "Windows" build/release/IslaAncestral-windows.exe
```

## 3. API de tests (suites headless reales)

Los tests no son un único `run_tests.gd` con `pass`; son suites GDScript reales
ejecutadas con `godot --headless --script` desde `quality.yml` (job "Run Test Suite
M112 Integration"). Ejemplo del patrón usado:

```gdscript
extends SceneTree

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	# ... checks ...
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
```

## 4. Pendientes reales

- Release gate M151: el paso de CI que escribe `estado_release.json` (implementado:
  `scripts/regenerar_estado_release.py`, pendiente de cablear — ver frente M151).
- Versionar el addon `zylann.voxel` con sus binarios para que el linter y las suites
  voxel-dependientes pasen en CI (decisión del fundador, en curso).

## 4. Notas del Agente

**Modelo:** Nemotron 3.5 Lightning  
**Plataforma:** Cline  
**Fecha:** 2026-08-16 20:12:31  
**Estado:** Diseño completado, documentación lista para agente delegado

### Lo que hice
- Definí la arquitectura completa del sistema CI/CD
- Establecí 7 requisitos funcionales y 4 no funcionales críticos
- Diseñé la arquitectura Godot-centric para builds
- Definí la API pública y archivos previstos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé el Godot Editor script BuildScript.cs _(diseno heredado)_ (pending)
- No creé el GitHub Actions workflow (pending)
- No creé los scripts de build optimizados (pending)

### Recomendaciones para el próximo agente
- Implementar BuildScript.cs _(diseno heredado)_ en assets/editor/ con BuildPipeline.BuildPlayer
- Crear .github/workflows/ci-cd.yml con steps completos
- Implementar tests run_tests.gd con coverage mínimo 80%
- Conectar con M111 para verificación automática de quality

---

## Notas del Agente (T-OM03, reevaluación Familia B)

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 00:20:00
**Estado:** Parcial (4 ítems Familia B reevaluados, paths Unity→Godot corregidos)

### Lo que hice
- **Reemplacé la spec Unity por la realidad Godot.** El `04-Codigo.md` describía
  `assets/editor/BuildScript.cs` con `BuildPipeline.BuildPlayer`/`BuildTarget`/
  `BuildOptions` — API de Unity que **nunca existió** en el repo (verificado contra el
  árbol). Ahora documenta los 6 workflows reales, `export_presets.cfg` (presets Web +
  Windows) y el patrón de suites headless que de verdad se usa.
- Marqué los 6 workflows y los presets como ✅ operativos (estaba todo "Pendiente de
  implementación").
- Verifiqué los renombres de la Familia B contra el código real:
  - `balance.gd` → **no existe**; el real es `balance_service.gd` (M93 corregido, 3 refs).
  - `isla_generador.gd` → **no existe**; el real es `island_generator.gd` (M167 corregido).
  - `fauna_behavior.gd` → **ya correcto** en M36/M65 (el renombre ya estaba aplicado en la doc).

### Lo que NO pude hacer
- Quedan ítems Familia B en otros módulos (M32, M78, M81, M82, M85, M93, M94, M114, M116,
  M119, M145, M146, M154) cuya justificación es "KnownIssue no bloqueante — item de
  diseño/documentación". Reevaluar esos requiere revisar uno por uno si la justificación
  sigue siendo válida; es trabajo de otra iteración.

### Recomendaciones para el próximo agente
- Los `plan-inicial/` NO se tocan (regla del proyecto); los stale de Unity allí son
  históricos y correctos.
- Si se añade un preset de export nuevo, actualizar la tabla de este archivo.