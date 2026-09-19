**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 109: Herramientas Internas

## 1. Archivos involucrados

> **Trazabilidad corregida (hy3 / WorkBuddy, 2026-09-19, Log 1075):** la
> seccion anterior describia el diseno **Unity heredado**
> (`Assets/_Project/Editor/`, `.cs`, `asmdef IslaAncestral.EditorTools`) que
> **no existe en este repo Godot**. El codigo real de M109 es un **toolset
> GDScript** bajo `scripts/editor/`. Las Secciones 2-6 de este archivo aun
> describen ese diseno Unity como referencia historica y NO reflejan el
> estado actual; usar la tabla de abajo como fuente de verdad de archivos.

### 1.1 Archivos reales (Godot GDScript — `scripts/editor/`)
| Archivo | Proposito (verificado en el codigo) |
|---------|--------------------------------------|
| `scripts/editor/plugin_herramientas.gd` (@tool EditorPlugin) | Registra el dock del editor con el catalogo de editores internos (RF1). Editor de Recetas operativo; los demas editores siguen el patron EditorBase. |
| `scripts/editor/tools/editor_base.gd` (@tool PanelContainer) | Base comun data-driven de editores internos: lista de entradas + formulario + guardado con backup `.bak` + reportes. Los editores concretos la extienden. |
| `scripts/editor/tools/recipe_tool.gd` (@tool extends EditorBase) | Editor de recetas del crafting (RF6 / M93 `crafting.json`): lista + formulario con validacion `RecipeSchema` + guardado `.bak`. |
| `scripts/editor/tools/dialogos_auditor.gd` (SceneTree headless) | Recorre `data/dialogues/` + `data/dialogues/contextual/` sin recursion, valida cada grafo con `DialogoSchema` y escribe `tools/reportes/dialogos_audit.txt`. |
| `scripts/editor/tools/prueba_dir.gd` (SceneTree) | Utilidad de prueba/diagnostico de listado de directorio (`DirAccess` sobre `res://data/dialogues/`). Scratch de desarrollo. |
| `scripts/editor/support/dialogo_schema.gd` (class_name DialogoSchema, RefCounted) | Valida grafos de dialogo (M21/M23): root/id/start, referencias, nodos inalcanzables, loops peligrosos. |
| `scripts/editor/support/recipe_schema.gd` (class_name RecipeSchema, RefCounted) | Valida recetas de `crafting.json` (M93/M16): id, categoria, nivel>=1, estacion, coste>0, resultado>=1. |
| `scripts/editor/code_quality_check.gd` (@tool EditorScript, class_name CodeQualityCheck) | Analisis estatico de GDScript (M111 Codigo de Calidad): metricas de lineas/complejidad/anidacion; escanea `res://scripts/`. |
| `scripts/editor/_colector_sintaxis.gd` (SceneTree, ~57 KB) | **GENERADO** por `tools/quality/gen_colector_sintaxis.py` (fix BUG-051, atria-dawn). Preload de cada `.gd` para validacion de parseo en `--check-only`; se regenera en CI. **NO EDITAR A MANO.** |

### 1.2 Dependencias / integracion
| Archivo / sistema | Relacion |
|-------------------|----------|
| `data/balance/crafting.json` (M93/M16) | Datos editados por `recipe_tool.gd`. |
| `data/dialogues/` + `data/dialogues/contextual/` (M21/M23) | Grafos auditados por `dialogos_auditor.gd` via `dialogo_schema.gd`. |
| `tools/quality/gen_colector_sintaxis.py` | Generador de `_colector_sintaxis.gd` (CI). |
| CI (M112) | Gates de calidad consumen `code_quality_check.gd` + `_colector_sintaxis.gd`. |
| M110 Debug Menu | Reutiliza patrones de las herramientas internas en runtime (no se modifica M110). |

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