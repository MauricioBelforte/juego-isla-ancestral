**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 117: Build System

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Propósito |
|---------|-----------|
| `Assets/Editor/BuildScript.cs` | Punto único: ejecuta builds por tipo/plataforma |
| `Assets/Editor/BuildInfo.cs` | Escribe versión/changelog en el build |
| `Assets/_Project/Scripts/Core/BuildInfo.cs` | Runtime: versión y canal expuestos (M104) |
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
// BuildScript.cs
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
| Versión y canal | `BuildInfo.cs` (runtime) | M104/telemetría |
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
