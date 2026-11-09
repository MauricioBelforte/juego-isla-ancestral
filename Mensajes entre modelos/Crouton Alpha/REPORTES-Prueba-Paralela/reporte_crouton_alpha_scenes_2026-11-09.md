# Reporte: Escenas principales Godot — Isla Ancestral

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09

## 1. Alcance y archivos leídos

Carpeta base: `game/isla-ancestral/scenes/` (36 entradas, 27 `.tscn` en raíz + subcarpetas `debug/`, `museo/`, `npc/`, `player/`, `prototipo/`, `terrain/`, `terrenos/`, `tests/`, `ui/`).

Archivos principales analizados (lectura completa):

| Archivo | Líneas | `load_steps` / `uid` | `ext_resource` | Rol |
|---|---|---|---|---|
| `game/isla-ancestral/scenes/main.tscn` | 83 | `load_steps=6`, `uid="uid://c1234568aa0"` (L1) | 4 (3 scripts + `Player.tscn`, L3-6) | Escena de inicio / mundo mínima viable |
| `game/isla-ancestral/scenes/main_island.tscn` | 194 | sin `load_steps`, sin `uid` (L1: `[gd_scene format=3]`) | 18 (14 scripts + `Player.tscn` + `catalina_oso.tres`, L3-21) | Escena-mundo real (Isla Raíz), la más completa |
| `game/isla-ancestral/scenes/main_simple.tscn` | 64 | `load_steps=4`, sin `uid` (L1) | 3 (2 scripts + `Player.tscn`, L3-5) | Variante mínima sin rig de cámara |
| `game/isla-ancestral/scenes/main_test.tscn` | 83 | `load_steps=8`, sin `uid` (L1) | 4 (3 scripts + `Player.tscn`, L3-5) | Test aislado con suelo propio, sin VoxelTerrain |

Escenas de inicio/mundo adicionales detectadas por `glob`: `minimal_test.tscn`, `main_test2.tscn`, `simple_walk.tscn`, `test_runner.tscn`, `test_terrain.tscn`, `test_arquitectura.tscn`, `test_anillo_arena.tscn`, `captura_playa.tscn`, `caso_reloj.tscn`, `CameraRig.tscn` (rig reutilizable, no instanciado por `main*.tscn`), `bench_scene_a.tscn`, `asset_preview.tscn`, más 8 `preview_*.tscn` / `ruina_preview.tscn` / `prueba_arquitectura.tscn` / `gaviota_demo_parada.tscn` (previews, no mundo).

## 2. Estructura de las escenas principales

### 2.1 `main.tscn` (L25-83)

```
Main (Node3D, script main.gd)
├─ WorldEnvironment (Environment Sky_1: ProceduralSkyMaterial + Sky, L17-29)
├─ VoxelTerrain (nodo sin configuración, L31)
├─ Player (instancia de Player.tscn, L33)
├─ CameraRig (Node3D, camera_rig.gd, L35)
│  ├─ CameraSpring (Node3D, camera_spring.gd, L38-44)
│  │  └─ RayCast3D (colisión cámara vs mundo, L46-50)
│  └─ Camera3D (fov 70, L52-54)
├─ DirectionalLight3D (sombras, L56-59)
└─ UI (CanvasLayer, L61)
   ├─ FPSLabel (L63-69)
   └─ ControlsLabel (L71-83)
```

Estructura clara y jerárquica real (CameraRig → CameraSpring → RayCast3D). `UI` mínimo: solo FPS + controles. `VoxelTerrain` no tiene ningún subrecurso configurador (generador, clima, materiales) — el terreno depende de la lógica de `main.gd` o nunca se genera en esta escena.

### 2.2 `main_island.tscn` (L57-194) — la escena-mundo

```
Main (Node3D, main_island.gd, L57-58)
├─ WorldEnvironment (Env completo: tonemap 3, glow 0.4, fog 0.001, adjustment, L35-53)
├─ VegetationSpawner (L63-64)
├─ FaunaSpawner (L66-67)
├─ VoxelTerrain (L68) + VoxelViewer (L70)
├─ Player (instancia Player.tscn, pos (0,5,0), L72-75)
├─ Camera3D (follow_camera.gd, L77-79)
├─ DirectionalLight (sol, L81-89) + DirLightLuna (L91-95)
├─ UI (CanvasLayer, L97)
│  ├─ FPSLabel (L99-105)
│  ├─ ControlsLabel (L107-117)
│  ├─ RelojWidget (L119-120)
│  ├─ StatusBar (L122-130)
│  ├─ InteractPrompt (L132-140)
│  └─ MinimapWidget (L142-154)
├─ CatalinaOso (CharacterBody3D, villager.gd + catalina_oso.tres, L156-160)
├─ DayNightCycle (L162-163)
├─ AguaAnimada (MeshInstance3D, L165-167)
├─ TerrenoHorizonte (L169-171)
├─ TortugaNPC (L174-176), CangrejoNPC (L178-180)
├─ JabaliNPC (L182-185), JabaliAdultoNPC (L187-190)
└─ GaviotaNPC (L192-194)
```

Jerarquía **plana**: 18 nodos hijos directos de `Main`, sin contenedores (`World`, `NPCs`, `Spawners` son nodos sueltos). Es la escena de producción (más entorno, más spawners, ciclo día/noche, agua, fauna). Incluye subrecurso `StyleBoxFlat_controls_d102` (L55) que **no se referencia en ningún nodo** (huérfano de contenido, ver §3).

### 2.3 `main_simple.tscn` y `main_test.tscn`

- `main_simple.tscn`: idéntica a `main.tscn` pero con `SimpleCamera` (simple_camera.gd, L34-38) en lugar de CameraRig/CameraSpring. Sin UI de reloj, sin terreno útil (VoxelTerrain vacío, L30). Variante de depuración.
- `main_test.tscn`: no usa VoxelTerrain; crea `Floor` (StaticBody3D + FloorMesh BoxMesh 60x1x60 + FloorCollision BoxShape3D, L40-48), `Player`, `SimpleCamera`, `UI` mínimo. Es el patrón recomendado para tests: geometría propia, sin dependencia del terreno procedural.

## 3. Nodos huérfanos o sin padre

**Sin padre roto: ninguno.** Todos los nodos de las 4 escenas tienen `parent="."` o una ruta `parent` válida (`CameraRig/CameraSpring`, `UI`, `Floor`). No hay `parent` a un nodo eliminado o a una ruta inexistente.

**Huérfanos reales (otros tipos), §3.1–3.3:**

1. **Subrecurso huérfano** — `main_island.tscn` L55: `[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_controls_d102"]` sin ninguna referencia `SubResource("StyleBoxFlat_controls_d102")` en el resto del archivo (194 líneas). Resto de un estilo de controles eliminado. No rompe nada, pero contamina el parse y el diff.
2. **Identificadores de `ext_resource` duplicados (colisiones nominales)** — `main_island.tscn`:
   - L15: `id="14_minimap"` y L16: `id="14_tortuga"` (mismo prefijo numérico 14).
   - L4: `id="17_dnc"` y L19: `id="17_gaviota"`.
   - L5: `id="18_agua"` y L20: `id="18_vegspawn"`.
   Godot los tolera porque la clave es el string completo, pero dificultan el mantenimiento: un editor o script que busque por id numérico o regex `14_` encuentra dos recursos distintos. En `main.tscn`/`main_simple.tscn` los ids son únicos y secuenciales (L3-6 / L3-5).
3. **`VoxelTerrain` efímero** — `main.tscn` L31, `main_simple.tscn` L30, `main_island.tscn` L68: el nodo está sin instancia de `VoxelTerrain` configurado en el propio `.tscn` (sin `Terrain3D`/VoxelTools, sin materiales). Si la generación del terreno no la hace el script raíz, el nodo es decorativo o queda vacío en runtime. No se encontró `instance=ExtResource(...)` en ningún `VoxelTerrain` de las 4 escenas.

Los IDs `unique_id` de `main_island.tscn` (L57, L60, L63, L68 etc.) están bien, pero es la **única escena sin `uid` en la cabecera**: `main.tscn` tiene `uid://c1234568aa0` (L1) y las otras 3 no. **Inconsistencia grave** para trazabilidad de logs y referencias cruzadas.

## 4. Dependencias entre escenas y riesgos de carga

**No hay dependencias escena→escena principal.** Ningún `main*.tscn` incluye otro `main*.tscn` como `ext_resource`. La única dependencia de escena es **todas instancian** `res://scenes/player/Player.tscn`:
- `main.tscn` L6 / L33 · `main_simple.tscn` L5 / L32 · `main_test.tscn` L5 / L50 · `main_island.tscn` L9 (`id="3_player"`) / L72.

**Consecuencia:** cero riesgo de ciclo de carga o reentrada entre escenas principales; Godot puede cargar cualquiera de las 4 sin arrastrar otra main. El riesgo real es otro:

1. **Cuatro "mains" sin declaración.** `main.tscn`, `main_island.tscn`, `main_simple.tscn`, `main_test.tscn` coexisten sin que el propio `.tscn` diga cuál es la escena de inicio del proyecto. Si `project.godot` (`main_scene`) no apunta a `main_island.tscn`, el jugador arranca con la variante mínima y nunca ve spawners, fauna ni UI completa. **Verificación pendiente** (ver §5-A).
2. **Fragmentación de la cámara.** `main.tscn` usa CameraRig + CameraSpring + RayCast3D (L35-54); `main_simple.tscn` / `main_test.tscn` usan `SimpleCamera`; `main_island.tscn` usa `Camera3D` con `follow_camera.gd` (L77-79). Hay 3 políticas de cámara distintas y `CameraRig.tscn` existe como escena aparte sin ser instanciada por ninguna main: la lógica de rig está duplicada a mano en `main.tscn` (L35-54) en lugar de `instance=ExtResource("CameraRig")`. Cambiar el rig obliga a editar cada main.
3. **Discrepancia de escala de mundo en `main_island.tscn`.** `AguaAnimada` en (2560, 4.05, 2560) (L166) y `TerrenoHorizonte` en (2560, 0, 2560) (L170) — coordenadas de Isla Raíz 5120×5120 — contra `CatalinaOso` en (268, 30, 268) (L157) y fauna en (232-285, 16, 224-262) (L174-194). Los NPCs están a ~256 y el agua/horizonte a 2560: están a ~3200 unidades del centro, fuera de la isla. Coherente con el error P-39 documentado en `AGENTS.md` §26 (L184/L205 en centro viejo 256). Los NPCs flotarán o caerán al vacío si el terreno se genera en 2560.
4. **`main_island.tscn` sin `uid` y sin `load_steps`.** L1 es `[gd_scene format=3]` pelado: Godot reescribirá el archivo al guardarlo desde el editor (añade `uid` + `load_steps`), generando un diff fantasma y perdiendo la referencia estable en logs/errors (`uid://` ausente). Las escenas editadas a mano sin reexportar desde Godot quedan en este estado.
5. **Idempotencia del `Player`.** `main_island.tscn` instancia `Player.tscn` (L72) **y** le pega `script = ExtResource("3_ff3n1")` (`player.gd`) con `move_speed = 5.0` (L74-75) sobre una escena que ya trae su propio script. Si `Player.tscn` ya define `player.gd`, hay doble script (override silencioso). En `main.tscn` (L33) y `main_simple.tscn` (L32) el Player va sin override de script: comportamiento distinto entre mains para el mismo recurso.

## 5. Acciones de verificación sugeridas

**A. Validador headless de escena de inicio y huérfanos de runtime.**
Comando: ejecutar con el Godot del proyecto `godot --headless --quit-after 5 game/isla-ancestral/scenes/main_island.tscn` (y lo mismo con `main.tscn`) y capturar `get_debug_output` vía MCP. Antes, leer `game/isla-ancestral/project.godot` y confirmar que `main_scene` apunta a `main_island.tscn`. Criterio: 0 errores de `ext_resource` no encontrado (falla típica: `res://scripts/world/day_night_cycle.gd` L4, `catalina_oso.tres` L12, scripts de fauna L16-19), 0 warnings de ids duplicados (L15/L16, L4/L19, L5/L20), y `Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) = 0` tras 5 s de juego (detecta los `Node` crear-sin-parentar de BUG-129 documentado en CHECKLIST-GLOBAL M64, no reproducido en estos `.tscn` pero sí posible vía `VegetationSpawner`/`FaunaSpawner` L63-67).

**B. Script de consistencia `.tscn` en CI (estático, sin Godot).**
Python que para cada `main*.tscn`: (1) verifica que todo `ext_resource path="res://..."` exista en disco (`game/isla-ancestral/` + `Test-Path`); (2) verifica unicidad de `id="..."` de `ext_resource` y de `sub_resource id=`; (3) verifica que cada `parent="X"` resuelva a un nodo declarado; (4) flag si falta `uid=` en L1 o si hay `sub_resource` sin referencia (catch: `StyleBoxFlat_controls_d102`, `main_island.tscn` L55). Criterio: sale con código 1 si hay ids duplicados, `uid` ausente o subrecurso huérfano; se integra como paso previo a `quality.yml` para que ninguna main futura entre con colisiones. Extra: normalizar `main_island.tscn` re-guardándolo desde Godot (regenera `uid` + `load_steps`) y alinear los transform de NPCs (L157, L174-194) al centro 2560 o declarar la isla en 256 según el autoload `mundo_raiz.gd`.

## 6. Conclusión final

Las 4 escenas principales están **estructuradas sin nodos sin padre** y no tienen dependencias entre sí, por lo que **no hay riesgo de ciclo de carga**: la única dependencia compartida es `Player.tscn`. La estructura es sana en `main.tscn` (rig de cámara jerárquico), aceptable en `main_test.tscn` (test aislado con suelo propio) y **deuda concentrada en `main_island.tscn`**: sin `uid`/`load_steps`, con 3 ids de `ext_resource` duplicados, un subrecurso huérfano, 18 nodos en plano sin contenedores, NPCs en coordenadas 256 contra agua/horizonte en 2560, y triple política de cámara entre mains sin instanciar `CameraRig.tscn`. Prioridad: (1) confirmar `main_scene` en `project.godot`, (2) re-guardar `main_island.tscn` desde Godot y corregir ids/uid, (3) realinear NPCs a 2560 o documentar la escala vigente, (4) unificar la cámara (instanciar `CameraRig.tscn` en vez de duplicar nodos). Verificación A (headless + orphans) y B (script estático) son ejecutables hoy sin tocar código del juego.
