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

## 6. Notas de integración
- Este módulo es el "cocinero" de M118 (CI lo orquesta con los mismos comandos).
- M116 (instalador) consume el packaging para Windows; M96 decide los targets.
- M142/M143 usan el ReleaseBuild solo con gate verde.