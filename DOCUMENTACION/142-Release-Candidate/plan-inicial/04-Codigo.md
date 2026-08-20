**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 142: Release Candidate

## 1. Archivos involucrados

### 1.1 Nuevos (capa RC)
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/Release/ReleaseGate.cs` | Validación CI | Orquesta los 7 tests de G2 en la build final |
| `Assets/_Project/Scripts/Release/VersionManifest.cs` | Auditoría | Genera/valida `version-manifest.json` (buildId, sha, hash) |
| `Assets/_Project/Scripts/Release/CrashHandler256.cs` | Telemetría (M105) | Captura crashes, sube stacktrace con símbolos |
| `Assets/_Project/Scripts/Release/ComiteRelease.cs` | Gobernanza | Workflow de aprobación de hotfixes (meta) |
| `Assets/_Project/Scripts/Release/CertificationChecklist.cs` | Certificación (M149) | Checklist por plataforma con firma |
| `Assets/_Project/Scripts/Release/LegalChecklist.cs` | Legal (M149) | Términos, privacidad, atribuciones, clasificación |

### 1.2 Modificados (validación sobre Beta)
| Archivo | Cambio |
|---------|--------|
| `PlatformBridge.cs` | Modo validación: logros/saves mock vs real; telemetría de versión |
| `SaveManager.cs` | Reporte de versión de save; backup automático pre-migración |
| `LocalizationManager.cs` | Modo auditoría: dump de claves sin resolver |
| `BugTracker` (M101) | Campo `buildId` obligatorio en reportes |
| `ProfilerGate` (M61) | Umbrales finales de RC (legacy `enableAssert` OFF) |

## 2. Funciones clave
```csharp
// ReleaseGate
public bool EjecutarChecklistRC(BuildManifest b, Plataforma p)   // G2 (7 tests)
public bool PirometriaAprobada(double crashRate, int sesiones)   // G4: < 0.5%

// VersionManifest
public void Generar(BuildId b, string gitSha, string hashContenido)
public bool Validar(BuildId b)             // contra expected manifest

// CrashHandler256
public void Iniciar()                      // hook de crashes de la plataforma
public void SubirCrash(string stack)       // con símbolos, M105

// CertificationChecklist
public bool Aprobar(Plataforma p, string firmante)
public void GenerarInforme(Plataforma p)

// LegalChecklist
public bool Aprobado(RegionEtaria r)       // ESRB/PEGI/otros
public void RegistrarAtribuciones(List<AssetAttr>)

// SaveManager
public VersionDeSave VerificarVersion(byte[] save)    // Beta vs RC
public byte[] MigrarConBackup(byte[] save)            // anticorrupción
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Manifest de build | `version-manifest.json` | VersionManifest |
| Checklist RC por plataforma | JSON firmado | CertificationChecklist |
| Checklist legal | JSON firmado | LegalChecklist |
| Umbrales de piloto | SO `{crashObjetivo: 0.005, sesiones: 1000}` | ReleaseGate |
| Marco de cloud saves | API de plataforma (M60) | PlatformBridge |
| Backend de telemetría | M104/M105 | CrashHandler256 |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `ReleaseGateTests` | EditMode | 7 tests de G2 ejecutables en CI; resultados agregados |
| `SaveCompatTests` | PlayMode | Save Beta v3.x → RC → re-guardado → recarga (30 ciclos) |
| `CloudSyncTests` | PlayMode (mock) | 30 sincronizaciones con latencia; conflicto resuelto; sin pérdida |
| `AchievementMatrixTests` | PlayMode (mock) | 100% de logros desbloqueables sin red |
| `LangMatrixTests` | EditMode | 6 idiomas × pantallas clave, 0 claves rotas |
| `CrashHandlerTests` | PlayMode | Crash simulado → stacktrace completo subido |
| `LegalCertificateTests` | EditMode | Checklists sin items vacíos; firmas requeridas |

## 5. CI/CD de RC
- Job **ReleaseGate**: corre en cada build `rc-*` → verde = candidato a validación humana.
- Job **DiffAudit**: compara contra `beta-rc-candidate` → si hay diffs no autorizados, falla (freeze).
- Job **ManifestCheck**: valida `version-manifest.json` contra el checkout.
- Job **PerfGate** y **LangGate**: heredados de Beta con umbrales finales.
- Los tests de regresión de hotfix corren dentro del mismo pipeline del hotfix (M112).

## 6. Notas de integración
- El RC se construye desde `main` con tag `release-candidate-N`; jamás desde ramas de desarrollo.
- Los backends (telemetría M104, crashes M105, cloud M60) deben estar en **producción real** desde G4 (no staging).
- La certificación se documenta con capturas de la build final (políticas de plataforma).
- A M143 (Lanzamiento) llegan: build `rc-final` + hash, checklist RC firmado, runbook y accesos de plataforma.