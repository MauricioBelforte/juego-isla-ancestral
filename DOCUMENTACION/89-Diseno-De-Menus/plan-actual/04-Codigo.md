**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 89: Diseño de Menús

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/UI/Shell/ShellManager.cs` _(diseno heredado)_ | Shell | Abre/cierra pantallas; estados; reapertura tras pausa |
| `Assets/_Project/Scripts/UI/Shell/NavigatorManager.cs` _(diseno heredado)_ | Navegación | Grafo de adyacencia + atajos; foco visible |
| `Assets/_Project/Scripts/UI/Shell/SettingsManager.cs` _(diseno heredado)_ | Ajustes | settings.json local; aplicación en vivo |
| `Assets/_Project/Scripts/UI/Shell/ProfileManager.cs` _(diseno heredado)_ | Perfiles | perfiles 1-3, slots 3-6 (M59) |
| `Assets/_Project/Scripts/UI/Shell/Views/*.cs` | Vistas | PrincipalView, NuevaView, CargarView, CreditosView, PausaView, InventarioView, MapaView, DiarioView, ColeccionView, HabilidadesView, RelacionView, ConfigView |
| `Assets/_Project/UI/Prefabs/Menus/*.prefab` | Prefabs | 21 pantallas (plantilla Header/Cuerpo/Footer) |
| `Assets/_Project/Data/Settings/AjustesGlobales.cs` _(diseno heredado)_ | SO/MODELO | Modelo de settings.json |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `Bootstrapper` (Core) | Llama a ShellManager al inicio |
| `GameManager` (M07) | Enganches de pausa/reapertura |
| `scripts/saving/save_manager.gd` (M59) | API de perfiles/slots (Listar, UltimoValido, CrearPerfil) |
| `WorldTime.cs` _(diseno heredado)_ (M29/reloj) | Pausar()/Reanudar() para Pausa |

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

## 6. Estado real en Godot (auditoría T-M2 — 2026-10-05)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

Las secciones 1-5 describen el diseño **heredado de Unity** (C#, prefabs, `ShellManager.cs`). El repo real es Godot 4.7.2 con GDScript. Mapeo verificado contra disco:

| Diseño (Unity, §1-5) | Realidad en Godot | Estado |
|---|---|---|
| `ShellManager` singleton de pantallas | `scripts/ui/core/ui_manager.gd` (pila de capas + `MODAL_FULL`) + `scripts/ui/ui_root.gd` (montaje y wiring) | ✅ equivalente |
| enum `IdPantalla` con 21 pantallas | No existe enum; las pantallas son `UILayer` (12 MODAL_FULL al montar UIRoot) | ❌ no existe |
| `NavigatorManager` con grafo á/adyacencias | `scripts/ui/core/menu_navigator.gd`: estáticas `focus_first/focus_last/wrap_focus/move_tab` (columnas por posición x, sin grafo) | ⚠️ parcial |
| Portada M147 + versión visible en P1 | No implementados | ❌ gap |
| Botones P1: Continuar/Nueva/Cargar/Ajustes/Créditos/Salir (6) | `menus_layer.gd`: Jugar/Continuar/Ajustes/Créditos/Salir (5, falta "Cargar") | ⚠️ 5/6 |
| P4 pantalla Cargar con lista de slots | No existe pantalla; API de slots en `saving/save_manager.gd` | ❌ gap |
| P8 selector de perfiles 1-3 | No existe (M59 solo slots) | ❌ gap |
| P5/P17 ajustes con 4 categorías | Solo `settings_audio_layer.gd` (Audio) | ⚠️ 1/4 |
| P10 pausa con 9 opciones + Esc/Start | `pause_layer.gd` 4 opciones; abre solo vía RF18 (M58), Esc/Start solo cierra capas | ⚠️ parcial |
| Tests Unity (Navigator 21, perfiles 30 ciclos, PerfUITests) | `test_m89_menus.gd` (48 checks), `test_slots_m59`, `test_settings_audio_roundtrip` (51), casos E91/C10; Navigator-21 y perfiles → `[?]` | ⚠️ parcial |
| `settings.json` SO Unity | `core/game_settings.gd` (autoload GameSettings) + roundtrip audio | ✅ |

- **Archivos Godot reales del módulo:** `ui/layers/menus_layer.gd`, `pause_layer.gd`, `credits_layer.gd`, `inventory_layer.gd`, `settings_audio_layer.gd` · `ui/core/ui_manager.gd`, `ui_layer.gd`, `menu_navigator.gd` · `ui/ui_root.gd` · tests `ui/test_m89_menus.gd` (nuevo, T-M2).
- **Suite T-M2:** `test_m89_menus.gd` — verde 48/0 `exit=0`; sonda rojo 48/1 `exit=1`; regresión M53 0 fallos, M55 89/0.
- **Zona s2:** `ui_manager.gd` pertenece a M53 (framework, canal 25) — solo lectura en T-M2.

## 7. Notas del Agente — T-M3 (cierre, mensaje 35)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** OpenCode
**Fecha:** 2026-10-06 17:25
**Estado:** Cerrado — 124 [x] / 1 [?] / 0 [ ] = 125; candidato a ✅ pendiente QA §21.8.

### Lo que hice

- Cierre documental de los 93 `[ ]` con cita por ítem (01/03/04 + **§9 nuevo del 03**,
  ~35 definiciones que faltaban: ver `05-Checklist.md` §Notas T-M3).
- Resolví los 2 `[?]` inflados de T-M2: `NavigatorTests` y `ProfileSlotTests` **están
  diseñados en §4** (el ítem es «Definir», no «ejecutar»); advertencias de implementación
  conservadas en las citas (Navigator parcial, perfiles sin RF3).
- Corregí 1 `[x]` falso: dependencia M154 → `[?]` (M154 caído, dueño visión).
- Suites re-coradas: `test_m89_menus` 48/0 exit 0, `test_settings_audio_roundtrip` 51/0
  exit 0; sonda roja `ESPERA_BOTONES_MENUS` 5→6 → exit 1 (restaurado byte-exact).

### Lo que NO pude hacer

- Nada de implementación (P4/P8/ajustes 1/4, enum, grafo): fuera de alcance documental.
- Pruebas visuales: sin M154.
- P12 mapa: zona DeepSeek (no tocar).

### Recomendaciones

- QA §21.8 con verificador ≠ mimo; muestrear §9.
- El §9 nuevo es diseño mío: si un implementador lo contradice con mejor idea, actualizar
  §9 y este módulo en el mismo commit.
