**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 109: Herramientas Internas

## 1. Arquitectura del toolset
```
Assets/_Project/Editor/  (asmdef: IslaAncestral.EditorTools)
├── Core/
│   ├── EditorToolBase.cs _(diseno heredado)_        ← base de ventanas (undo, save, validación)
│   └── DataValidator.cs _(diseno heredado)_         ← checker global (opción de menú + CI)
├── Editores/
│   ├── BlockEditorWindow.cs _(diseno heredado)_     ← bloques voxel (M08)
│   ├── BiomeEditorWindow.cs _(diseno heredado)_     ← biomas (M09/M10)
│   ├── NpcEditorWindow.cs _(diseno heredado)_       ← NPC (M19)
│   ├── DialogEditorWindow.cs _(diseno heredado)_    ← diálogos (M21)
│   ├── QuestEditorWindow.cs _(diseno heredado)_     ← misiones (M22/23)
│   ├── RecipeEditorWindow.cs _(diseno heredado)_    ← recetas (M16/17)
│   ├── EconomyEditorWindow.cs _(diseno heredado)_   ← precios/moneda (M38)
│   ├── ShopEditorWindow.cs _(diseno heredado)_      ← tiendas (M39)
│   ├── WeatherEditorWindow.cs _(diseno heredado)_   ← clima (M32)
│   ├── SeasonEditorWindow.cs _(diseno heredado)_    ← estaciones (M31)
│   ├── PuzzleEditorWindow.cs _(diseno heredado)_    ← puzzles (M24/25/26)
│   ├── RuinEditorWindow.cs _(diseno heredado)_      ← ruinas (M25)
│   ├── SpawnEditorWindow.cs _(diseno heredado)_     ← spawns (M36/65)
│   └── MapEditorWindow.cs _(diseno heredado)_       ← mapas/islas (M54)
├── RuntimeTools/                ← (Editor + Runtime, condicional)
│   ├── TeleportTool.cs _(diseno heredado)_          ← teleport por coords/isla/POI
│   ├── SpawnTool.cs _(diseno heredado)_             ← instanciar bajo cursor
│   ├── InspectorTool.cs _(diseno heredado)_         ← inspección de entidad
│   └── ProfilingTool.cs _(diseno heredado)_         ← stats de editor (M61/62)
└── Generador/
    └── ContentGenerator.cs _(diseno heredado)_      ← seed-driven (M10/25)
```

## 2. Framework de editor (EditorToolBase)
| Feature | Detalle |
|---------|---------|
| Ventana | EditorWindow con toolbar + search + listado |
| Undo | UnityUndo.RecordObject en cada mutate |
| Guardado | Escribe directo en SO/mods (M108) — mismo formato runtime |
| Validación | `Validate()` por editor: lista de errores con color (rojo=bloqueante, amarillo=advertencia) |
| Filtro | Search por nombre/id/tag |
| Export | JSON/CSV del dominio (para revisión/colab) |
| Shortcuts | Ctrl+1..14 abre cada editor (plantilla común) |

## 3. Editores — especificación por dominio
| Editor | Datos que edita | Validación clave |
|--------|-----------------|------------------|
| Bloques | id, nombre, textura/MOD, físico (sólido/transparente), tags | ids únicos; texturas existen |
| Biomas | id, paleta, vegetación, clima asociado, altura/piso | refere a bioma de terreno válido; vegetación refiere bloques |
| NPC | id, nombre, profesión, rutina (M19), relación (M20), economía | rutina refiere tiempo/POI válidos |
| Diálogos | nodos, línea, condiciones (flags), efectos (objetos/amistad) | referencias a flags/objetos/misiones existentes |
| Misiones | etapas, objetivos, condiciones, recompensas (M22/23) | objetivos refieren items/NPC/POI válidos; no ciclos en prerreq |
| Recetas | ingreso/salida, estación de trabajo, desbloqueo (M16/17) | ing/out refiere objetos; estación existe |
| Economía | precio base por objeto, influencia NPC (M38) | precios > 0; NPC refiere economía existente |
| Tiendas | inventario, restock, moneda (M39) | items existen; no duplicados |
| Clima | climas (M32), transiciones, FX | duración > 0; top - grade sin saltos |
| Estaciones | duración, eventos por estación (M31) | no solapamiento de fechas |
| Puzzles | condiciones, orden, recompensa (M24) | recompensa refiere ítem; solución alcanzable |
| Ruinas | layout, loot table, puzzles (M25) | loot refiere objetos; layout valida contra seed |
| Spawns | bioma/hora, entidad (M36/65), densidad | entidad existe; no rates > máximo |
| Mapas | islas (M27/54), puntos de interés, viajes (M28) | POI únicos; islas referenciadas por viajes |

## 4. Runtime tools
| Tool | Acción | Activa en |
|------|--------|-----------|
| TeleportTool | mover jugador a coords / isla / POI / sello | Editor Play + Debug build |
| SpawnTool | instanciar objeto/NPC/fauna bajo cursor | Editor Play |
| InspectorTool | árbol de componentes/variables de entidad | Editor Play |
| ProfilingTool | FPS, chunk stats, memoria, draw calls (M61/62) | Editor Play + Debug |
| DebugMenu (M110) | flags: dar objetos/dinero, completar misión, desbloquear isla/sello, hora/estación/clima, reset NPC/puzzle, regenerar chunk, mostrar colliders/FPS/chunks/navegación/hitboxes/IA, exportar diagnóstico | Debug build solo |

## 5. Validación global (DataValidator)
- Corre: en Editor (menú) y CI (M112) y como gate M151.
- Cross-checks: recetas→objetos; misiones→diálogos/objetivos; tiendas→items; econ→NPC; rutinas→POI; loot→items; puzzles→recompensas.
- Report: JSON por dominio + flag de bloqueo (rojo) si hay error de referencia.
- Integración: se suma a los gates del pipeline (M61/M112).

## 6. Generación de contenido (ContentGenerator)
- Semilla de M10 (mundo), con sub-seeds para ruinas (M25) y spawns.
- Comandos: regenerar con semilla X (reproducible), validar layout, exportar reporte.
- Uso: al crear mundo nuevo en dev/QA; guarda la semilla en la metadata del save.

## 7. Prohibiciones técnicas (RF12)
1. Ningún archivo de `Editor/` se referencia desde el runtime (asmdef separada).
2. El Debug Menu se compila solo en `ENABLE_DEBUG_MENU` (dev/demo/QA builds).
3. Las herramientas de teleport/spawn solo operan en Play Mode del Editor (o Debug build con flag).
4. Sin edición directa de datos en el runtime del jugador (siempre vía servicios M04).