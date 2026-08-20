**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 123: Modding

## 1. Archivos involucrados

### 1.1 Nuevos (post-V2, para referencia de diseño)
| Archivo | Propósito |
|---------|-----------|
| `Assets/_Project/Scripts/Core/Modding/ModManifest.cs` | Modelo del manifiesto (id, versión, minBuild, override[]) |
| `Assets/_Project/Scripts/Core/Modding/ModLoader.cs` | Carga/orden/validación/conflictos |
| `Assets/_Project/Scripts/Core/Modding/ModValidator.cs` | Wrapper de M109 para mods |
| `Assets/_Project/Scripts/Core/Modding/ModContext.cs` | Runtime: dominios modables + flags |
| `Assets/_Project/Scripts/UI/ModsScreen.cs` | Pantalla de mods (M89): lista, errores, prioridad |
| `scripts/mods/modchecker.py` | CLI validate (CI + modo local) |
| `docs/mods/README.md` | Guía de modding + ejemplo |

### 1.2 Modificados (proyección)
| Archivo | Cambio (en V2) |
|---------|----------------|
| `M109` editores | Comando "Exportar a Mod" |
| `SaveManager` (M59) | Marca `modsActive[]` en v3.x |
| `Bootstrapper` | Inicializar ModLoader (M63) |
| `M104` Telemetría | Flag de mods activos en sesión |
| `M97` Steamworks | Integración Workshop |

## 2. Funciones clave
```csharp
// ModManifest
public string Id; public string Version;   // semver
public string MinBuild;                    // compatibilidad M117
public List<string> Override;              // conflictos explícitos

// ModLoader
public void Inicializar();                       // ordena y valida
public List<Mod> CargarMods(List<string> rutas); // omite inválidos con error
public bool CargarEnCaliente(Mod m);             // solo contenido
public List<Conflicto> DetectarConflictos();     // id vs id
public static bool Compatible(Mod m, string build);

// ModValidator (M109 reutilizado)
public ReporteValidacion ValidarMod(Mod m);      // errores bloqueantes

// ModsScreen (M89)
public void MostrarEstado(List<Mod> mods, List<Conflicto> conflictos);
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Mods instalados | `persistentDataPath/mods/` o `Workshop/` | M59/M97 |
| Manifiesto | `manifest.json` dentro del paquete | formato M108 |
| Lista de mods activos | Save v3.x `modsActive[]` | M59 |
| Límites | `modding_limits.json` (100 MB/mod, 100 mods) | Config |

## 4. Tests (M112 — proyección V2)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `ModLoaderTests` | PlayMode | Orden de prioridad/override |
| `ModValidatorTests` | EditMode | Mod inválido omitido con error claro |
| `ConflictTests` | EditMode | Duplicados sin override → warning |
| `SaveWithModsTests` | PlayMode | Marca + carga sin mods con advertencia |
| `WorkshopTests` | PlayMode (mock) | Subida/descarga simulada |

## 5. CI / gates (M117/M118 — post-V2)
- `modchecker` corre sobre cualquier mod candidato en CI (mismo de M109).
- Gate de build: si un mod exige funcionalidad inexistente → warning en release de V2.
- La telemetría de mods (M104) llega con flag `env=mods`.

## 6. Notas de integración
- Diseño 100% sobre M108/M109: no re-arquitectura.
- Sin modding en V1 (M143): solo queda este diseño y la marcación técnica en M59 (sin activar).
- El Worksnow de Steam se integra en V2 con M97; la comunidad (M100) tendrá canal #modding.