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

## 8. Definiciones de la iteración 7 (2026-10-19 - Step-5-WorkBuddy / WorkBuddy, Log 2009)

Las 15 definiciones que cerraron los últimos `[ ]` del checklist (secciones 1, 6, 7, 8, 9,
11, 16, 17, 19, 20 y 23). Modulo design-heavy: diseño documentado = hecho (política del
director, M120).

### 8.1 Framework de editor (complementa la sección 2)

| Ítem | Definición |
|------|------------|
| Reutilización de lista vista/detalle en todos (L18) | Patron maestro-detalle único sobre `EditorToolBase`: panel izquierdo = lista filtrable (search por id/nombre/tag, sección 2), panel derecho = formulario del registro seleccionado. Al cambiar de registro se refresca el detalle sin reabrir ventana; filtro y seleccion sobreviven al cambio de editor via Ctrl+1..14. Aceptación: los 14 editores comparten la misma instancia del control de lista (0 código de lista duplicado por editor). |
| Rojo/amarillo por campo con error especifico (L21) | Cada campo del formulario se pinta segun el resultado de `Validate()`: rojo = error bloqueante (no deja guardar), amarillo = advertencia (guarda con confirmacion). El mensaje especifico del validador (id duplicado, referencia inexistente, fuera de rango) se muestra junto al campo, no como color generico. Aceptación: ningun campo en rojo sin mensaje legible; el mensaje nombra campo y regla. |

### 8.2 Vistas de los editores de dominio (secciones 6, 7, 8, 9 y 11)

| Ítem | Definición |
|------|------------|
| Vistas de misión principal vs secundarias (L62) | Filtro/agrupacion por tipo (principal/secundaria) en la lista del editor de misiones. La principal se fija arriba y no se puede archivar con objetivos abiertos. Aceptación: cambiar el tipo recalcula la agrupacion y la validación de prereq sigue viendo ambas. |
| Detección de recetas inalcanzables (L70) | Analisis estatico del grafo de recetas: una receta es inalcanzable si algun insumo no es obtenible (ninguna receta lo produce y no aparece en loot/tienda) o si la cadena tiene un ciclo. Hereda RecipeSchema y reporta el camino roto en el panel de validación. Aceptación: el reporte nombra receta e insumo sin origen; corre al guardar y desde el gate de CI (M112). |
| Vista por categoría de crafting (L71) | Lista de recetas agrupada por categoría (herramientas, construccion, cocina, etc.) en árbol plegable; la categoría es campo obligatorio del esquema. Aceptación: receta sin categoría cae en "Sin categoría" con advertencia. |
| Simulador de mercado rapido (L78) | Panel what-if del editor de economía: dados precios base e influencia de NPC, proyecta precios efectivos por dia y marca inflacion/deflacion fuera de umbral configurable (default +/-20 % en 7 dias). Corre en memoria sobre el dataset editado (no toca lo guardado) y exporta el resultado a CSV. Aceptación: la salida cuadra con el cálculo manual de un caso documentado. |
| Vista por NPC/vendedor (L86) | Lista de tiendas agrupada por el NPC/vendedor dueno del stock: permite ver todo lo que un NPC vende sin abrir tienda por tienda. Aceptación: la validación "NPC refere economía existente" sigue aplicando sobre la vista agrupada. |
| Vista de calendario anual (L100) | Línea de tiempo anual con las estaciones como franjas (duración + eventos M31); los solapamientos se marcan en rojo. Aceptación: la validación de no solapamiento se ve reflejada en la franja conflictiva. |

### 8.3 Runtime tools (secciones 16, 17, 19 y 20)

| Ítem | Definición |
|------|------------|
| Teleport con guardado del punto anterior (L137) | El teleport apila la posicion previa (pila de 1 elemento) con boton "volver"; se limpia al cambiar de escena o al morir. Aceptación: teleport -> volver deja al jugador en la posicion exacta de origen. |
| Spawn con cantidad y densidad editable (L144) | El spawn bajo cursor acepta cantidad N (1..100) y densidad (spawns por unidad de area) en el formulario flotante del tool; N>1 reparte en radio creciente alrededor del cursor. Aceptación: el reparto cabe en el radio y respeta la validación de entidad existente. |
| Validación de no duplicar entidades únicas (L145) | Las entidades marcadas `única` en su dataset (NPC con nombre propio, jefes) no admiten un segundo spawn: el tool lo bloquea con mensaje especifico. Aceptación: el segundo spawn de una única falla con error nombrado; las no únicas spawnean sin límite. |
| Copia de estado al portapapeles (L165) | Boton "copiar estado" del inspector: serializa componentes + variables de la entidad inspeccionada a JSON en el portapapeles, para pegar en issues. Aceptación: el texto pegado es JSON válido con el path de la entidad y sus variables editables. |
| Export de muestras a CSV (L171) | Las muestras de profiling (FPS, memoria, draw calls por chunk/NPC/AI) se exportan a CSV con cabecera (timestamp, métrica, valor) para análisis externo. Aceptación: el CSV se reabre y las filas cuadran con el overlay. |

### Specs items degradados T234 (2026-10-26, Reflection-Beam-1.0)
- **L219 (editores restantes bloques/biomas/NPC/diálogos/misiones/economía/tiendas/clima/estaciones/puzzles/ruinas/spawns/mapas/teleport/profiling 13+2):** siguen el patrón EditorBase con su propio schema validable — iteración 2 (dueño: deepseek-v4-flash-vision-exp, M109 iter 2).
