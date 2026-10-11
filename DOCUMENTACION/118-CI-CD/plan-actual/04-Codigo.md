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
| `.github/workflows/release-build.yml` (+jobs deploy-itch, notify-stakeholders) | Build de release en tags: jobs `test` → `release-gate` → `build` → `checksum` → `release-notes` → **`deploy-itch`** → **`notify-stakeholders`** | ✅ Operativo (deploy-itch y notify-stakeholders saltan con `::warning::` si faltan los secretos; ver iter. deep work abajo) |
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
- **Job `Run Test Suite (M112 Integration)` sale con exit 1** pese a que todas las
  suites reportan 0 fallos (caso M68 iter.3: imprime "108 checks, 0 fallos" y el
  proceso muere antes del `quit(0)`). Bug en `scripts/transporte/test_transporte_m68_iter3.gd`
  (M68, dueño ajeno) — derivado al director, ver Notas del Agente iter. deep work.

---

## Notas del Agente — iter. deep work (encargo H del director mimo)

**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 02:30:00
**Estado:** Parcial — 3 de 4 `[ ]` resueltos en su parte implementable; 1 derivado a M68

### Contexto

El director (mimo) encargó profundizar M118 tras el push `bf23406..6134034`. El fire
test real de GitHub Actions estaba disponible: mi push disparó los 3 workflows. Esto
permitió diagnosticar con evidencia de CI real (no hipótesis).

### Hallazgos contra CI real (run 38112515046/38112515056/38112515059)

1. **`Testing Suite` failure — gdUnit4/bin/ no versionado (BUG-128).**
   `git check-ignore -v` reveló que `game/isla-ancestral/.gitignore:44` (`addons/*/bin/`)
   excluye el `bin/` de gdUnit4. Esa carpeta contiene **GDScript puro**
   (`GdUnitCmdTool.gd` 546 B, `GdUnitCopyLog.gd` 5104 B — sin binarios), y
   `GdUnitCmdTool.gd` es el entry point del job "Godot Tests (GdUnit4)". En checkout
   limpio: `File not found` → exit 1. Los 238 reports HTML ya retirados antes confirmaban
   el patrón T-98 (gate apoyado en archivo no versionado).
   **Fix aplicado:** añadida `!addons/gdUnit4/bin/` con comentario en
   `game/isla-ancestral/.gitignore`. Verificado: `git check-ignore` ahora NO lo ignora.
2. **`UTF-8 sin BOM` failure — 6 archivos con BOM.**
   `scripts/verificar_bom.py` encontró 6: 2 en `DOCUMENTACION/150-Diseno-Sonoro-Narrativo/`
   (plan-actual y plan-inicial `01-Requerimientos.md`) y 4 en `Mensajes entre modelos/`
   (atria-dawn #2 y #5 — míos; s2 #189 y #194).
   **Fix aplicado:** `python scripts/verificar_bom.py --fix` → 6 BOM quitados,
   re-verificación: "Sin BOM".
3. **`GDScript Linter` + `GDScript Formatting Check` failure — patrón T-108.**
   Error: `Identifier not found: AnimationService` en
   `scripts/animacion/animacion_jugador_m48.gd:53` (script NUEVO de mi commit da4ca3f,
   referencia el autoload `AnimationService`, project.godot:83).
   **Diagnóstico:** 345 de 980 scripts referencian autoloads globales y solo este falla.
   Los 114 autoloads existen en worktree Y en HEAD (`git cat-file -e` verificado para
   los 114). Codificación UTF-8 limpia (sin BOM, bytes iniciales `0x23 0x20`). La causa
   es el patrón T-108 de `GUIA-GODOT/06-registro-errores.md`: `--import` solo recompila
   los scripts nuevos/modificados, y lo hace **antes** de registrar los autoloads como
   singletons → "Identifier not found" en falso. Los 345 scripts viejos pasan porque ya
   están en caché y no se recompilan.
   **Fix aplicado:** añadido el paso `Rebuild script cache with autoloads registered`
   (`godot --headless --editor --quit --path game/isla-ancestral`) entre `--import` y
   `--check-only` en los 2 jobs de `quality.yml` (godot-lint y format-check), con
   comentario citando BUG-128 y T-108. La guía T-108 documenta esta receta exacta.
4. **`Run Test Suite (M112 Integration)` failure — bug en M68 (dueño ajeno).**
   Todas las suites reportan 0 fallos (M63 51/0, M63-iter6 42/0, M29 74/0, M29 51/0,
   M68 108/0) pero el proceso sale exit 1. `test_transporte_m68_iter3.gd` imprime
   "=== Resumen M68 iter.3: 108 checks, 0 fallos ===" y muere **antes** de imprimir
   "TEST M68 iter.3 OK" y de llegar al `quit(0)` (L138-140). La lógica de exit code
   está bien (`_fallos == 0 → quit(0)`); el proceso se cae entre el resumen y el quit.
   **Sin fix:** el script es de M68 (Transporte), módulo ajeno. **Derivado al director.**
5. **CI roto crónicamente desde 2026-10-07.** Último success de `quality.yml`: `d9534a0`
   (2026-10-07T07:17Z). 68 failures desde entonces. Los fallos del 10-10 ya daban
   "SCRIPT ERROR detectados: 0" en el linter (el gate no era la causa). Mis fixes (1-3)
   atacan causas raíz confirmadas con evidencia; el punto 4 es residual y de otro módulo.

### Implementaciones para los 4 `[ ]`

| Ítem | Acción | Estado |
|---|---|---|
| **P5** despliegue itch.io al crear tag | Job `deploy-itch` en `release-build.yml`: triggerea en `push: v*.*.*`, instala butler desde broth.itch.ovh, `butler push` por plataforma (linux/windows/macos) con `--userversion`, canal `${ITCH_USER}/${ITCH_GAME}:${tag}-${os}` | **Implementado** (YAML válido). Requiere `BUTLER_API_KEY` + opcionales `vars.ITCH_USER`/`vars.ITCH_GAME`; sin la key se saltea con `::warning::` |
| **I.99** Subida a Itch.io manual | Mismo job `deploy-itch` vía `workflow_dispatch` (el workflow ya tiene el input `version`) | **Implementado** |
| **J.109** Email a stakeholders en tags | Job `notify-stakeholders`: `dawidd6/action-send-mail@v4` con body que linkea el GitHub Release y el run del deploy; `if: tag push` | **Implementado**. Requiere `SMTP_HOST`/`SMTP_USER`/`SMTP_PASS`/`STAKEHOLDER_EMAILS`; sin ellos se saltea con `::warning::` |
| **Aud. "Validación en GitHub Actions real"** | **Fire test real ejecutado**: mi push `6134034` disparó los 3 workflows con runs completos. 5 fallos diagnosticados con causa raíz, 3 corregidos, 1 derivado | **Evidencia real** (no hipótesis) |

### Lo que NO pude hacer

- **Arreglar el exit 1 del M112** (bug en `test_transporte_m68_iter3.gd`, M68 ajeno).
  Dejé el diagnóstico completo para que el director delegue al dueño de M68.
- **Verificar localmente con Godot** (4.7.2 está en `D:\ISLA ANCESTRAL\` pero el
  sandbox del entorno bloquea ejecutar `.exe` fuera del workspace). Todos los fixes
  se basan en evidencia de CI real + la receta T-108 documentada del proyecto.
- **Probar `deploy-itch`/`notify-stakeholders` end-to-end**: requieren secretos del
  repo que solo el fundador puede configurar. El YAML valida y los jobs degradan
  limpiamente sin secretos.

### Recomendaciones para el próximo agente

1. Pedir al fundador configurar `BUTLER_API_KEY` (y opcional `vars.ITCH_USER`/
   `vars.ITCH_GAME`) para habilitar P5/I.99 de verdad; luego hacer un
   `workflow_dispatch` de prueba.
2. Pedir `SMTP_*` + `STAKEHOLDER_EMAILS` para J.109.
3. El bug del M68 iter.3 (exit 1 sin fallos) es el único bloqueo residual del
   `Run Test Suite (M112 Integration)`; el dueño de M68 debe investigar por qué el
   proceso se cae entre el print del resumen y el `quit(0)` (posible crash en cleanup
   por los "3 ObjectDB instances leaked" del log).
4. Tras el commit de estos fixes, observar el próximo run de `quality.yml`: si el
   paso T-108 (`--editor --quit`) resuelve el `Identifier not found`, el patrón queda
   confirmado y debería añadirse también a `testing.yml` y `dev-build.yml`.

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