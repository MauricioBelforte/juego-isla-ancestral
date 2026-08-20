**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 89: Diseño de Menús

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/UI/Shell/ShellManager.cs` | Shell | Abre/cierra pantallas; estados; reapertura tras pausa |
| `Assets/_Project/Scripts/UI/Shell/NavigatorManager.cs` | Navegación | Grafo de adyacencia + atajos; foco visible |
| `Assets/_Project/Scripts/UI/Shell/SettingsManager.cs` | Ajustes | settings.json local; aplicación en vivo |
| `Assets/_Project/Scripts/UI/Shell/ProfileManager.cs` | Perfiles | perfiles 1-3, slots 3-6 (M59) |
| `Assets/_Project/Scripts/UI/Shell/Views/*.cs` | Vistas | PrincipalView, NuevaView, CargarView, CreditosView, PausaView, InventarioView, MapaView, DiarioView, ColeccionView, HabilidadesView, RelacionView, ConfigView |
| `Assets/_Project/UI/Prefabs/Menus/*.prefab` | Prefabs | 21 pantallas (plantilla Header/Cuerpo/Footer) |
| `Assets/_Project/Data/Settings/AjustesGlobales.cs` | SO/MODELO | Modelo de settings.json |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `Bootstrapper` (Core) | Llama a ShellManager al inicio |
| `GameManager` (M07) | Enganches de pausa/reapertura |
| `SaveManager.cs` (M59) | API de perfiles/slots (Listar, UltimoValido, CrearPerfil) |
| `WorldTime.cs` (M29/reloj) | Pausar()/Reanudar() para Pausa |

## 2. Funciones clave
```csharp
// ShellManager
public void Abrir(IdPantalla id);        // activa pantalla (grafo de navegación)
public void Cerrar();                    // vuelve a la pantalla anterior o al shell
public void AbrirPausa();                // pausa mundo + estado
public void AbrirAjustes(Categoria cat); // configuración directa

// NavigatorManager
public void Fitocar(ElementoUI e);       // setea foco visible
public bool Mover(Direccion d);          // grafo de adyacencia
public void Atajo(AccionGlobal a);       // Tab/B/Esc/A/Start

// SettingsManager
public void Cargar();  public void Guardar();
public T Obtener<T>(Categoria c, string key);
public void AplicarEnVivo(Categoria c, object valor);

// ProfileManager
public List<PerfilInfo> ListarPerfiles();        // M59
public SlotInfo[] SlotsDelPerfil(int perfilId);  // resumen por slot
public string UltimoSaveValido(int perfilId);    // Continuar
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Ajustes globales | `settings.json` (local) | SettingsManager |
| Perfiles/slots | Directorio de saves (M59) | ProfileManager |
| Grafo de navegación | SO | NavigatorManager |
| Resúmenes de slot | metadatos del save (isla, horas, sellos, temporada) | ProfileManager |
| Atajos | Input System actions (M58) | NavigatorManager |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `ShellManagerTests` | PlayMode | Abrir/Cerrar/estados; reapertura tras pausa |
| `NavigatorTests` | PlayMode | Recorre las 21 pantallas con gamepad (0 atascos); atajos; foco visible |
| `ProfileSlotTests` | PlayMode | Crear/borrar perfiles y slots; 30 ciclos sin pérdida |
| `SettingsTests` | EditMode | settings.json ida y vuelta; aplicar en vivo |
| `PausaTests` | PlayMode | Mundo congelado → reanudar sin saltos (M07/M29) |
| `ViewsContentTests` | PlayMode | Vistas responden a datos de managers (sin lógica própria) |
| `PerfUITests` | EditMode | Apertura < 300 ms; sin picos de memoria (M61-M63) |

## 5. Notas de integración
- El ShellManager sustituye el flujo "menú de Unity + escenas" actual (M53) sin reemplazar sus modales.
- La pantalla de diario se extiende en M148 (Lore Ambiental) sin conflicto de archivos (additive view).
- El mapa (M28), colecciones (M73), habilidades (M71) y relación (M20) ya tienen managers; las Views solo llaman APIs.
- El remapeo de M58 alimenta la pantalla de controles (los campos de escucha sobreescriben el action map).
- CI: el test Navigator se ejecuta en build (gate de menús).