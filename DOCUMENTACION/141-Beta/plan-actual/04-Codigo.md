**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 141: Beta

## 1. Archivos involucrados

### 1.1 Nuevos (capas de cierre)
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/Beta/ContentRegister.cs` | Cierre de contenido | Inventario maestro por SO; genera reporte de gaps; tool Editor |
| `Assets/_Project/Scripts/Beta/Acto3Manager.cs` | Historia | Orquesta epílogo del faro, post-Sello 6 |
| `Assets/_Project/Scripts/Beta/RutasDeSellosVerifier.cs` | FF/M66 | Verifica 3 rutas sin softlock (PlayMode test) |
| `Assets/_Project/Scripts/Beta/StorePageData.cs` | Marketing (M149) | SO con textos, capturas, tags, requisitos |
| `Assets/_Project/Scripts/Beta/CertificationChecklist.cs` | Certificación | Checklist por plataforma (M149) |

### 1.2 Modificados (cierre sobre Alpha)
| Archivo | Cambio |
|---------|--------|
| `HistoriaMaster.cs` | Hooks de Acto 3 y epílogo; estado `EpílogoDisponible` |
| `SelloManager.cs` | Registro de cierre: `Sello6` → activa Acto 3 |
| `LocalizationManager.cs` | Modo multi-archivo por idioma; export/import CSV (M87) |
| `AccessibilityService.cs` | Completa M58: modos de color, reduce motion/flashing |
| `MusicDirector.cs` | Playlists por acto/zona; transición por Sello |
| `AmbientSystem.cs` | Biomas finales 6 islas + estación |
| `PlatformBridge.cs` | Logros, cloud saves, overlay, certificación |
| `SaveManager.cs` | Migración final v3.x; backup pre-certificación |
| `BugTrackerHook` (M101) | Severidades P0-P2; export para reporte |

## 2. Funciones clave
```csharp
// ContentRegister
public ReporteDeInventario VerificarInventario(List<SO> maestras, List<SO> escena)
public void GenerarReporteGaps(ReporteDeInventario reporte)   // CSV para tickets

// Acto3Manager
public void IniciarEpilogo()              // tras Sello6 → escena faro
public bool EpilogoCompletado { get; }

// RutasDeSellosVerifier
public ResultadoRuta VerificarRuta(List<SelloId> orden)        // 3 rutas

// LocalizationManager
public string Traducir(string key, Idioma idioma)
public void ExportarCSV();  public void ImportarCSV();

// AccessibilityService
public void AplicarModo(ModoAccesibilidad modo)   // color, motion, flashing

// PlatformBridge
public void DesbloquearLogro(string id);          // M59
public void GuardarCloud(byte[] datos);           // M60
public bool CertificacionOk(ChecklistPlataforma c); // M149
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Inventario maestro | SO (item/receta/coleccionable/evento/misión) | ContentRegister |
| Strings por idioma | JSON `{es, en, pt, fr, de, it}.json` (M87) | LocalizationManager |
| Playlists por acto/zona | SO `{actoId, temaId}` | MusicDirector |
| StorePage | SO (textos, capturas, tags, requisitos) | StorePageData |
| Checklist certificación | JSON por plataforma | CertificationChecklist |
| Bounce de rendimiento | ScriptableObject (presupuestos M61) | BuildGate |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `ContentRegisterTests` | EditMode | Inventarios 100%; gaps detectados; reporte CSV válido |
| `Acto3Tests` | PlayMode | Sello6 → epílogo; save antes/después |
| `RutasDeSellosTests` | PlayMode | 3 órdenes sin softlock; rama 4ta inválida rechazada |
| `LocalizationTests` | EditMode | 6 idiomas completos; claves sin huecos; CSV redondo |
| `AccessibilityTests` | PlayMode | Modos color/motion/flashing aplicados y revertidos |
| `PlatformBridgeTests` | PlayMode (mock) | Logros sin red; cloud con conflicto; overlay |
| `BugGateTests` | EditMode | P0/P1 = 0 en el cierre; P2 documentados |

## 5. CI/CD de Beta
- Job **ContentGate**: `ContentRegister` en cada build → gate si gaps > 0.
- Job **PerformanceGate**: ruta fija 20 min en hardware mínimo/recomendado → gate si se superan presupuestos (M61).
- Job **LocalizationGate**: verifica claves por idioma y JSON bien formado.
- Job **BugGate**: importa tracker (M101) → gate si P0/P1 abiertos > 0 (solo en W4-W6).

## 6. Notas de integración
- Beta hereda todo de Alpha: Silencio de build semanal, telemetría M104/M105, tracking M106, M107, M108 (más el ContentGate).
- La biblia (M147) es entrada obligatoria para el cierre de historia; no se aceptan desviaciones.
- El candidato a RC es la build del cierre de W6: tag `beta-rc-candidate` + guarda de `manifest.json` de contenido para M142.
- Los 2 logs de certificación (M149) se generan con `CertificationChecklist`.