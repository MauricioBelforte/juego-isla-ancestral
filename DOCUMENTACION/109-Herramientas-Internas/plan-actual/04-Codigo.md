**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 109: Herramientas Internas

## 1. Archivos involucrados

### 1.1 Nuevos (`Assets/_Project/Editor/` — asmdef IslaAncestral.EditorTools)
| Archivo | Propósito |
|---------|-----------|
| `Core/EditorToolBase.cs` _(diseno heredado)_ | Base EditorWindow: undo, guardado SO, validación con colores |
| `Core/DataValidator.cs` _(diseno heredado)_ | Checker global (Editor menu + CI) |
| `Editores/BlockEditorWindow.cs` _(diseno heredado)_ | Editor de bloques voxel (M08/M47) |
| `Editores/BiomeEditorWindow.cs` _(diseno heredado)_ | Editor de biomas (M09) |
| `Editores/NpcEditorWindow.cs` _(diseno heredado)_ | Editor de NPC (M19) |
| `Editores/DialogEditorWindow.cs` _(diseno heredado)_ | Editor de árboles de diálogo (M21) |
| `Editores/QuestEditorWindow.cs` _(diseno heredado)_ | Editor de misiones (M22/23) |
| `Editores/RecipeEditorWindow.cs` _(diseno heredado)_ | Editor de recetas (M16/17) |
| `Editores/EconomyEditorWindow.cs` _(diseno heredado)_ | Editor de economía (M38) |
| `Editores/ShopEditorWindow.cs` _(diseno heredado)_ | Editor de tiendas (M39) |
| `Editores/WeatherEditorWindow.cs` _(diseno heredado)_ | Editor de clima (M32) |
| `Editores/SeasonEditorWindow.cs` _(diseno heredado)_ | Editor de estaciones (M31) |
| `Editores/PuzzleEditorWindow.cs` _(diseno heredado)_ | Editor de puzzles (M24) |
| `Editores/RuinEditorWindow.cs` _(diseno heredado)_ | Editor de ruinas (M25) |
| `Editores/SpawnEditorWindow.cs` _(diseno heredado)_ | Editor de spawns (M36/65) |
| `Editores/MapEditorWindow.cs` _(diseno heredado)_ | Editor de mapas/islas (M54) |
| `RuntimeTools/TeleportTool.cs` _(diseno heredado)_ | Teleport por coords/isla/POI |
| `RuntimeTools/SpawnTool.cs` _(diseno heredado)_ | Spawn bajo cursor |
| `RuntimeTools/InspectorTool.cs` _(diseno heredado)_ | Inspección de entidad |
| `RuntimeTools/ProfilingTool.cs` _(diseno heredado)_ | Stats de editor (M61/62) |
| `Generador/ContentGenerator.cs` _(diseno heredado)_ | Regen seed-driven (M10/25) |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `Data/Mods/ScriptableObjects` (M108) | Soporte para escritura de editor (mismo formato) |
| `Core/Bootstrapper` | Registro de herramientas en Play Mode (solo Editor) |
| CI (M112/M61) | Gate `data_validator` |

## 2. Funciones clave
```csharp
// EditorToolBase — núcleo de editores
public abstract class EditorToolBase : EditorWindow {
    protected abstract bool Validar(out List<string> errores, out List<string> advertencias);
    protected void RegistrarCambio(Object target);   // UnityUndo.RecordObject
    public void Guardar();                           // escribe SO/Mods
    protected void MostrarErrores(List<string> err, List<string> warn); // colores
}

// DataValidator
public static ReporteValidacion ValidarTodo();      // cross-checks globales
// reportes: {dominio, ok, errores[], advertencias[]}

// ContentGenerator
public static void RegenerarMundo(int seed, bool ruinas, bool spawns);

// TeleportTool / SpawnTool / InspectorTool / ProfilingTool
public static void Teleportar(Vector3Int coords | string islaId | string poiId);
public static void InstanciarEnCursor(string assetId, bool npc, bool fauna);
public static string Inspeccionar(Transform target); // árbol de componentes
public static void AbrirProfiler();                  // stats M61/M62
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| SO de contenido | `Assets/_Project/ScriptableObjects/` | M108 |
| Mods importados | `Assets/StreamingAssets/mods/` | M108 |
| Seeds | metadata del mundo/save | M59 |
| Reporte de validación | `Temp/validacion-*.json` + salida CI | DataValidator |
| Shortcuts | Pref de editor (persistent) | EditorToolBase |

## 4. Tests (M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `EditorToolCoreTests` | EditMode | Undo/guardado/validación incremental |
| `BlockBiomeNpcTests` | EditMode | Editores con SO de prueba |
| `DialogQuestRecipeTests` | EditMode | Edición de árboles/recetas sin corrupción |
| `EconomyShopWeatherTests` | EditMode | Precios/tiendas/clima válidos |
| `PuzzleRuinSpawnMapTests` | EditMode | Puzzles/ruinas/spawns/mapas |
| `DataValidatorTests` | EditMode | Cross-checks (receta→objeto inexistente falla) |
| `ContentGeneratorTests` | EditMode | Same seed → mismo mundo |
| `BuildExclusionTests` | EditMode | Ningún código Editor en build de jugador |

## 5. CI / gates
- `data_validator` corre en cada PR (M112): falla si hay errores bloqueantes.
- El build de jugador verifica (script) que no existan tipos del asmdef Editor en el ensamblado runtime.
- El profiling del editor consume los providers de M61/M62 (sin duplicar).

## 6. Notas de integración
- Compatibilidad total con M108 (mismos SO/Mods dentro y fuera de Unity).
- El Debug Menu (M110) en Runtime reutiliza Teleport/Spawn del toolset vía API compartida.
- La validación global es insumo de M102 y gate de M151 (control final).