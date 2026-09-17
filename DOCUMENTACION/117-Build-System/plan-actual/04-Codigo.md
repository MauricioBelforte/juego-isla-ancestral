**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 117: Build System

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Propósito |
|---------|-----------|
| `Assets/Editor/BuildScript.cs` _(diseno heredado)_ | Punto único: ejecuta builds por tipo/plataforma |
| `scripts/core/build_info.gd` | Escribe versión/changelog en el build |
| `scripts/core/build_info.gd` | Runtime: versión y canal expuestos (M104) |
| `scripts/build/package.ps1` | Packaging Windows/macOS + manifest |
| `scripts/build/sign.ps1` | Firmado (signtool/notarytool) |
| `scripts/build/smoke_test.py` | Smoke del artifact (boot+play+exit) |
| `scripts/build/retencion.ps1` | Rotación de artifacts por política |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `Assets/Editor` (M109) | Validadores como gate en BuildScript |
| CI (M118) | Invocar BuildScript con parámetros |
| `Instalador` (M116) | Consumir artifact packaging |
| `Assets/_Project/Scripts/Core/Telemetry` (M104) | Canal (dev/qa/staging/release) en métricas |

## 2. Funciones clave
```csharp
// BuildScript.cs _(diseno heredado)_
public static void DevBuild()      // dev, plataforma actual
public static void QaBuild()       // qa + símbolos + telemetría
public static void StagingBuild()  // release channel + firmado
public static void ReleaseBuild()  // release final + firmado + manifest
// todas: Preparar(), TestsAndGates(), Package(plataforma), Smoke()
public static void VersionDesdeTag();  // semver + build
```
```powershell
# package.ps1
New-Item zip | Add manifest SHA-256 | Purgar(dev)
# sign.ps1
signtool sign /f cert.pfx ...   # Windows
notarytool submit ...           # macOS
# smoke_test.py
boot → menú → nuevo mundo → 1 día → save/load → quit(0)
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Versión y canal | `scripts/core/build_info.gd` (runtime) | M104/telemetría |
| Changelog | Generado en CI desde git log → artifact | Conventional Commits |
| Manifest SHA-256 | `manifest.json` dentro del artifact | RF10 |
| Política de retención | Config de scripts/build | Tabla sección 8 |

## 4. Tests (M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `BuildScriptTests` | EditMode | 4 configs sin errores con escena de prueba |
| `BuildInfoTests` | EditMode | Versión escrita correcta |
| `SmokeTestTests` | PlayMode | Boot+save/load en build test |
| `ManifestTests` | EditMode | SHA-256 completo y correcto |

## 5. CI / gates (M118)
| Etapa | Comando | Gate |
|-------|---------|------|
| PR | `unity -executeMethod BuildScript.QaBuild -omit packaging` | Tests + validators |
| Nightly | `BuildScript.DevBuild` | Tests + smoke |
| Pre-release | `BuildScript.StagingBuild` | Tests + validators + stress rápido |
| Release | `BuildScript.ReleaseBuild` | Todo + smoke del artifact |

## Notas del Agente

**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 05:35:00
**Estado:** Parcial — núcleo cerrado con brecha M11/M18 documentada

### Lo que hice
- Creé `scripts/core/build_info.gd` como runtime de versión/canal/build_number, con fallback seguro si no existe `user://build_info.json`.
- Verifiqué el núcleo existente:
  - `scripts/build/build_config_manager.gd` (autoload `BuildConfigManager`)
  - `scripts/build/build_validator.gd` (`class_name BuildValidator`)
  - `data/build/build_targets.json` (4 targets)
  - `scripts/build/test_build_m117.gd` (test headless)
- Ejecuté headless: `=== TEST M117: 14 checks, 0 fallos ===` (script `res://scripts/build/test_build_m117.gd`).
- Cierre parcial de brecha M11/M18: núcleo M117 listo para orquestar builds; M11/M18 tienen sus dudas marcadas en sus propios módulos y quedan como follow-up con dueño.

### Lo que NO pude hacer (honestidad obligatoria)
- [RF9/RF13] Firmado real (signtool/notarytool): requiere certificados y plataforma específica — queda `[?]` documentado.
- [RF7] Packaging por plataforma completo: queda `[?]` hasta M96/M116 avanzar.
- [RF11] Smoke test del artifact: queda `[?]` hasta pipeline CI/artefacto operativo (M118).

### Intentos fallidos / decisiones
- No intenté modificar el test existente; aproveché el núcleo previo de Deepseek V4 Flash para no pisar trabajo.
- Decisión conservadora: cerrar V0 con test 0 fallos y documentar brechas en lugar de implementar gates externos no verificables headless.

### Recomendaciones para el próximo agente
- Ejecutar `scripts/build/test_build_m117.gd` tras cualquier cambio en `build_targets.json` o `export_presets.cfg`.
- Mover `BuildInfo` a `project.godot` autoload si M104/M142/M143 lo requieren.
- Resolver brecha M11/M18 antes de activar gates reales de packaging/firmado.

---

## Notas del Agente

**Modelo:** muse-spark-1.3-contributor
**Plataforma:** Cline
**Fecha:** 2026-09-16 20:45:00
**Estado:** Parcial (con dudas) — relevo de reserva huérfana 902, iter. 2

### Lo que hice
- Relevo de la reserva 902 (2026-09-15) que quedó **consumida sin log**; el trabajo de
  aquella sesión (fix `bump_version.py` cwd-first + checklist personal M117) se retoma y
  cierra en el Log 941.
- **Auditoría de los 53 `[ ]`** del `05-Checklist.md` contra **código/config real**:
  **33 cerrados `[x]` con evidencia** + **20 `[?]` honestos con dueño**. Ningún `[ ]` restante.
- Checklist del módulo (**110 ítems reales**, secciones 1-17): **`92 [x]` / `0 [ ]` / `18 [?]`**.
  Archivo completo (126 líneas = módulo + Evidencia + Reserva): `106 [x]` / `0 [ ]` / `20 [?]`.
- **Corrección de conteo (§21.6):** la fila global declaraba `66/119`; el denominador real son
  **110 ítems** (119 sumaba las secciones de Evidencia y Reserva, que no son ítems del módulo).
  Recalculado con script de verificación por sección.
- **FIX de código:** `tools/ci/bump_version.py` — el `PROJECT_ROOT` se derivaba solo de la
  ubicación del script (`HERE/../..`), ignorando el `cwd`. Un runner CI o un test con
  `tempdir` hacían que el script leyera/escribiera **siempre** el `project.godot` del repo
  real. Ahora es **cwd-first** (si el `cwd` tiene `config/version=` se usa ese árbol) con
  fallback al layout clásico. Test afectado: `tools/ci/test_bump_version.py` (7/11 → **11/11**).
- Evidencia ejecutada esta sesión:
  - `python -X utf8 tools/ci/test_bump_version.py` → **11/11 OK**
  - `python -X utf8 tools/ci/test_changelog.py` → **6/6 OK**
  - `python tools/ci/changelog.py --to HEAD --version unreleased --out out/changelog_m117_iter2.md`
    → `[changelog] 403 commits -> ...`

### Lo que NO pude hacer (honestidad obligatoria)
- **20 `[?]` con dueño** — ninguno es implementable headless/local en este host:
  - **M118**: smoke test operativo del artifact, nightly schedule, enforcement de commits,
    permisos de CI, keystore central de firmado.
  - **M96 + infra**: presets y firmado macOS/Linux (el `export_presets.cfg` real solo tiene
    **Web + Windows**; el preset Windows lo agregó M116 en el Log 877).
  - **M116**: firmado real con signtool (requiere certificado).
  - **M113**: suite de stress para los gates de pre-release.
  - **build real**: medición de T-029/T-030 (tiempos de build por plataforma).
- **`test_build_m117.gd` existente NO corre aislado:** con `--script` bootea la escena
  principal (bootstrap completo + 58 leaks de ObjectDB **preexistentes ajenos a M117**).
  Queda `[?]` para M118/M117-test: migrarlo a un test `SceneTree` aislado o cablearlo en CI.
  **No lo reporto como verde.**

### Intentos fallidos / decisiones
- Intenté contar con regex inline y obtuve cifras infladas (`?=22`, personal `35/2/23`) porque
  el patrón matcheaba `[?]`/`[x]` **dentro de líneas de prosa** (secciones de Evidencia, Reserva
  y notas). Reconté con un script que clasifica **por sección**: las cifras reales son
  `106 [x] / 0 [ ] / 20 [?]` y `33 [x] + 20 [?]` de 53. **Las cifras del log son las correctas.**
- Detecté y corregí una **colisión de numeración de log**: había reservado 938, pero
  `Logs/938-Hy3-M103.md` ya existía → renumeré a **941** (protocolo §6.1.b.1). Verificado que
  no queda ninguna referencia a 938 en mis registros.
- Corregí un **BOM incrustado (U+FEFF)** que yo mismo había introducido en mi fila de
  `ESTADO-PARALELO.md` (§28). Verificado: `BOM: False`, sin U+FEFF incrustado.
- Sospeché daño de columnas en la fila 117 de `CHECKLIST-GLOBAL.md`. **Verificado que NO hay
  daño:** el header de esa tabla tiene **11 columnas** (incluye `Recom`) y la fila 117 tiene 11.
  Las filas vecinas con 12/13/14 son por `|` dentro del texto de Notas (preexistente, no mío).

### Recomendaciones para el próximo agente
- **QA cruzado §21.8 pendiente:** M117 está `🟡 Con dudas` con **20 `[?]`** — lo debe verificar
  un **modelo distinto** a muse-spark-1.3-contributor.
- Al tocar `tools/ci/bump_version.py`, correr **siempre** `python -X utf8 tools/ci/test_bump_version.py`
  desde la raíz del repo (el fix cwd-first solo se valida con `cwd` correcto).
- Los `[?]` de firmado/packaging **no** se pueden cerrar localmente: necesitan certificados,
  runners Windows/macOS y presets que hoy no existen. No marcarlos `[x]` sin eso.
- Antes de dar por verde el smoke test, migrar `test_build_m117.gd` a un harness `SceneTree`
  aislado (modelo: `game/isla-ancestral/tests/test_m111_utils_headless.gd`, Log 909).
