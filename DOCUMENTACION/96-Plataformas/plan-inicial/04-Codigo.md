**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 96: Plataformas

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/Core/Platform/IPlatformBridge.cs` | Abstracción | Interfaz común: logros, cloud, overlay, store (impl por plataforma) |
| `Assets/_Project/Scripts/Core/Platform/SteamBridge.cs` | Steamworks | Implementación Steam (logros, cloud, overlay, deck) |
| `Assets/_Project/Scripts/Core/Platform/EosBridge.cs` | EGS/EOS | Implementación EGS (logros, cloud, overlay) |
| `Assets/_Project/Scripts/Core/Platform/GogBridge.cs` | GOG (opcional) | Implementación GOG Galaxy |
| `Assets/_Project/Scripts/Core/Platform/NullBridge.cs` | Fallback | Sin plataforma (dev/standalone) |
| `Assets/_Project/Scripts/Core/Platform/PlatformManager.cs` | Manager | Selecciona el bridge activo; expone servicios |
| `scripts/ci/build_targets.ps1` / `.sh` | CI | Builds por target: Windows, macOS(AS), Linux(Proton), SteamDeck settings |
| `scripts/ci/steamdeck_check.py` | CI | Simula 800p + gamepad para el check Deck Verified |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `SaveManager.cs` (M59/M60) | Cloud detrás de IPlatformBridge; save portable |
| `InputManager.cs` (M57) | Perfiles de control por plataforma (deck/steam/console) |
| `SettingsManager.cs` (M89) | Safe area y escalado de UI por resolución (M58) |
| `Bootstrapper` | Inicializa PlatformManager |

## 2. Funciones clave
```csharp
// PlatformManager
public static IPlatformBridge Activo { get; }     // platforma activa
public void Inicializar(PaisajePlataforma p);      // Steam | EOS | GOG | Null

// IPlatformBridge
public void DesbloquearLogro(string id);           // M59 mapeo
public bool CloudDisponible();
public void GuardarCloud(byte[] data);             // M60
public byte[] CargarCloud();
public void MostrarOverlay();                      // overlay de plataforma

// steamdeck_check.py
def verificar_deck(build_path): -> ReporteDeck   // 800p, gamepad, textos, perf
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Mapa de logros | SO `{logroId, plataformaId}` | IPlatformBridge |
| Build targets | CI config (yaml/ps1) | scripts/ci |
| Safe areas | SO por resolución | SettingsManager |
| Prioridades de tiendas | `plataformas.json` de M96 | Matriz de decisiones |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `PlatformManagerTests` | PlayMode | Bridge nulo en dev; selección correcta por target |
| `SteamBridgeTests` | PlayMode (mock) | Logros/cloud con SDK simulado |
| `EosBridgeTests` | PlayMode (mock) | idem EGS |
| `CrossSaveTests` | PlayMode | Save portable carga en Steam y Null (v3.x) |
| `DeckCheckTests` | CI | 800p + gamepad + textos (script) |
| `ConsoleReadyTests` | EditMode | Sin referencias directas a APIs de tienda en el core |

## 5. CI multi-target
| Target | Build | Gate |
|--------|-------|------|
| Windows x64 | PC | ReleaseGate (M142) |
| macOS (Apple Silicon) | P1 | PerfGate + orientación de ventana |
| Linux (Proton test) | P1 | Run bajo Proton en CI (o reporte manual mensual) |
| Steam Deck | P0.5 | DeckCheck (800p + gamepad + perf) |
| WebGL | NO | Descartado (documentado) |

## 6. Notas de integración
- El core del juego nunca referencea Steamworks/EOS directamente: siempre IPlatformBridge (grado de limpieza para futuras plataformas).
- Los logros se mapean en SO (M59); la cloud reutiliza el save v3.x (M60).
- El Controller Input es ciudadano de primer orden desde el día 1 (M57) por las consolas futuras.
- Este módulo alimenta los requisitos de M149 (tiendas) y M142 (certificación RC) con los checklists por plataforma.
- Los precios por plataforma (M95) se conectan al config de tiendas de M149.