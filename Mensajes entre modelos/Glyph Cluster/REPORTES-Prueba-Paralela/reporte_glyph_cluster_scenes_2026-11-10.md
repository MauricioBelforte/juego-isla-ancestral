# Reporte de análisis de escenas `.tscn` — Isla Ancestral

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10 23:58:26Z  
**Alcance:** `game/isla-ancestral/scenes/**/*.tscn` (49 archivos) con foco en escenas principales (`main.tscn`, `main_island.tscn`, `main_simple.tscn`, `main_test.tscn`, `main_test2.tscn`) y escena de inicio/mundo.

---

## 1. Estructura de las escenas principales

### 1.1 Escena de inicio configurada
- `game/isla-ancestral/project.godot:13` — `run/main_scene="res://scenes/main_island.tscn"`.
- La escena de entrada/mundo principal del proyecto es **`scenes/main_island.tscn`**.
- `project.godot` declara numerosos autoloads (p. ej. `TerrainLocator`, `SceneManager`, `UIManager`, `GameFlowManager`, líneas ~21–120), lo que implica que la carga de `main_island.tscn` depende del estado global inicializado por autoloads.

### 1.2 `scenes/main_island.tscn` (mundo principal)
- **Raíz y script:** `:57` `[node name="Main" type="Node3D" ...]`, `:58` `script = ExtResource("1_main")` → `res://scripts/main_island.gd`.
- **Entorno y ciclo día/noche:** `:60` `WorldEnvironment` (SubResource `Env_1`, líneas 24–54), `:162` `DayNightCycle` → `scripts/world/day_night_cycle.gd` (`:4`).
- **Mundo/terreno:** `:68` `VoxelTerrain` (Voxel Tools), `:70` `VoxelViewer` (sibling de raíz), `:165` `AguaAnimada` → `scripts/world/agua_animada.gd` (`:5`), `:169` `TerrenoHorizonte` → `scripts/world/terreno_horizonte.gd` (`:6`), `:63` `VegetationSpawner` → `scripts/vegetacion/vegetation_spawner.gd` (`:20`), `:66` `FaunaSpawner` → `scripts/fauna/fauna_spawner.gd` (`:21`).
- **Jugador (instancia + override):** `:72` `[node name="Player" type="CharacterBody3D" parent="." unique_id=1575828482 instance=ExtResource("3_player")]`, `:73` transform `(256? / local 0,5,0 inicial)`, `:74` `script = ExtResource("3_ff3n1")` → `res://scripts/player/player.gd` (`:8`). La escena instancia `res://scenes/player/Player.tscn` (`:9`) pero además sobreescribe su script en la instancia.
- **Cámara:** `:77` `Camera3D` hija directa de `Main` con `:79` `script = ExtResource("2_cam")` → `res://scripts/follow_camera.gd` (`:7`), `:78` transform fijo inicial. No usa `scenes/CameraRig.tscn` ni el rig de `main.tscn`.
- **Iluminación:** `:81` `DirectionalLight` (sol), `:91` `DirLightLuna` (luna, energía baja, sin sombras).
- **UI embebida (`CanvasLayer` en `:97`):** `:99` `FPSLabel`, `:107` `ControlsLabel`, `:119` `RelojWidget` → `scripts/clock/w_reloj.gd`, `:122` `StatusBar` → `scripts/ui/widgets/status_bar.gd`, `:132` `InteractPrompt` → `scripts/ui/widgets/interact_prompt.gd`, `:142` `MinimapWidget` → `scripts/ui/widgets/minimap_widget.gd`. UI construida inline (no instancia `scenes/ui/hud.tscn`).
- **NPCs/fauna colocados en escena:** `:156` `CatalinaOso` → `villager.gd` + perfil `res://data/villagers/catalina_oso.tres`, `:174` `TortugaNPC`, `:178` `CangrejoNPC`, `:182` `JabaliNPC` (etapa joven), `:187` `JabaliAdultoNPC`, `:192` `GaviotaNPC` con scripts de fauna dedicados (`:14–:19`).

### 1.3 `scenes/main.tscn` (variante con rig de cámara embebido)
- **Raíz:** `:25` `Main` (`Node3D`) + `:26` `script` → `res://scripts/main.gd`.
- **Entorno/terreno:** `:28` `WorldEnvironment`, `:31` `VoxelTerrain`.
- **Jugador:** `:33` instancia `res://scenes/player/Player.tscn` (`:6`).
- **Cámara (rig embebido, no PackedScene):** `:35` `CameraRig` → `scripts/camera/camera_rig.gd` (`:4`), `:38` `CameraSpring` → `scripts/camera/camera_spring.gd` (`:5`, con `max_distance`, `smooth_time`, colisión), `:46` `RayCast3D`, `:52` `Camera3D` (`fov = 70`). La lógica replica parcialmente `scenes/CameraRig.tscn` pero con distinta configuración.
- **Luz/UI:** `:56` `DirectionalLight`, `:61` `UI` con `:63` `FPSLabel` y `:71` `ControlsLabel`.

### 1.4 `scenes/main_simple.tscn` y `scenes/main_test.tscn` (escenas ligeras/prueba)
- **`main_simple.tscn`:** `:24` raíz `Main` + `scripts/main_simple.gd`, `:30` `VoxelTerrain`, `:32` `Player` instanciado, `:34` `SimpleCamera` → `scripts/camera/simple_camera.gd`, `:40` luz direccional, `:45` UI básica.
- **`main_test.tscn`:** `:34` raíz `Main` + `scripts/main_test.gd`, **sin** `VoxelTerrain`; usa `:40` `Floor` (`StaticBody3D`, `:43` mesh 60x1x60, `:47` colisión) como suelo plano, `:50` `Player`, `:53` `SimpleCamera`, `:59` luz, `:64` UI. Orientada a prueba sin dependencia de voxel.

### 1.5 `scenes/main_test2.tscn` y `scenes/minimal_test.tscn` (variantes voxel/diagnóstico)
- **`main_test2.tscn`:** `:24` raíz + `scripts/main_test2.gd`, `:30` `VoxelTerrain`, `:32` `WorldManager` → `scripts/world/world_manager.gd` (`world_seed`, `island_radius`, `max_height`), `:38` `Player`, `:41` `Camera3D` con `:44` `VoxelViewer` hijo de cámara (`view_distance = 256.0`), `:47` luz.
- **`scenes/minimal_test.tscn`:** `:4` raíz `MinimalTest` + `scripts/minimal_test.gd`, `:7` `Camera3D` con `:10` `VoxelViewer` hijo, `:13` `DirectionalLight3D`, `:17` `VoxelTerrain`. Sin jugador ni UI; escena mínima de diagnóstico de terreno.

### 1.6 Escenas auxiliares relevantes
- **`scenes/player/Player.tscn`** (base instanciada por las mains): `:16` raíz `CharacterBody3D` + `scripts/player/player.gd` (`:3`), `:23` `ModeloVoxel` (GLB), `:25` `BodyCollision`, `:29` `TerrainDetector` (`RayCast3D`, `collision_mask = 32`), `:36` `TerrainFootprints`, `:39` `TerrainParticles`, `:42` `NucleoM11`, `:45` `AnimacionM48` con `:48` `AnimationPlayer`.
- **`scenes/CameraRig.tscn`:** `:6` raíz `CameraRig` → `scripts/camera/camera_rig.gd`, `:9` `CameraSpring` → `camera_spring.gd`, `:12` `RayCast3D` (`target_position = 0,0,0`), `:15` `Camera3D`. Definida como PackedScene pero no instanciada por ninguna otra `.tscn` del árbol `scenes/`.
- **`scenes/ui/hud.tscn`:** HUD completo en `CanvasLayer` (`:15`), con múltiples widgets (`:26+`). No es instanciado por las escenas `main*` analizadas (estas usan UI inline).

### 1.7 Patrón estructural observado
- Jerarquía plana bajo `Main` (`Node3D`) con hijos de primer nivel para entorno, terreno voxel, jugador, cámara, luces, UI y entidades de mundo; subárboles claros (`CameraRig/CameraSpring/RayCast3D`, `UI/*`, `AnimacionM48/AnimationPlayer`).
- Variación de patrones según propósito: cámara embebida en raíz (`main_island`), rig embebido (`main`), `SimpleCamera` (`main_simple`, `main_test`), cámara con `VoxelViewer` hijo (`main_test2`, `minimal_test`). Esto sugiere ramas de evolución paralelas de la escena principal.

---

## 2. Nodos huérfanos o sin padre

- **Resultado del análisis estructural:** `0` nodos huérfanos detectados en las 49 escenas.
- **Criterio usado:** para cada archivo `.tscn` se inspeccionaron todas las declaraciones `[node ...]`; el primer nodo del archivo se considera raíz (válido sin `parent`), y todo nodo posterior debe declarar `parent=...` dentro de su árbol.
- **Hallazgos:**
  - Ningún nodo no-raíz carece de `parent`.
  - Ninguna raíz declara `parent`.
  - Todas las instancias de nodos en escenas principales (`main*.tscn`, `CameraRig.tscn`, `player/Player.tscn`) presentan jerarquía coherente (hijos con `parent="."`, subhijos con rutas válidas como `CameraRig/CameraSpring`, `Floor`, `AnimacionM48`, `UI`).
- **Conclusión:** no se observaron nodos huérfanos en el sentido de nodos declarados fuera de la jerarquía de escena.

> Nota: "nodo huérfano" aquí se refiere a la estructura declarada en `.tscn` (ausencia de `parent` en nodos no-raíz). No detecta nodos creados dinámicamente en runtime ni problemas de `owner` en escenas instanciadas.

---

## 3. Dependencias entre escenas y posibles problemas de carga

### 3.1 Dependencias escena→escena (PackedScene instanciadas en `.tscn`)
Total: **5** referencias de escena encontradas, todas válidas en disco:

| Escena origen | Línea | Recurso instanciado | Existe |
|---|---:|---|:---:|
| `scenes/main.tscn` | 6, 33 | `res://scenes/player/Player.tscn` | Sí |
| `scenes/main_island.tscn` | 9, 72 | `res://scenes/player/Player.tscn` | Sí |
| `scenes/main_simple.tscn` | 5, 32 | `res://scenes/player/Player.tscn` | Sí |
| `scenes/main_test.tscn` | 5, 50 | `res://scenes/player/Player.tscn` | Sí |
| `scenes/main_test2.tscn` | 4, 38 | `res://scenes/player/Player.tscn` | Sí |

- `Player.tscn` es el único nodo de escena compartido entre las mains; su propia dependencia crítica externa es el asset `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` (`scenes/player/Player.tscn:4,23`).
- No se detectaron instancias cruzadas entre escenas `main*` ni cadenas de carga profundas entre `.tscn` (el grafo escena→escena es superficial, tipo estrella hacia `Player.tscn`).

### 3.2 Dependencias de scripts/recursos (ext_resource)
- Se inspeccionaron **80** `ext_resource` en las 49 escenas: **0 rutas rotas** en disco.
- `main_island.tscn` concentra alta densidad de dependencias (scripts de mundo, fauna, NPC, UI, recurso `.tres` de perfil en `:12` → `res://data/villagers/catalina_oso.tres`), lo que aumenta la superficie de fallo por errores de script/autoload al cargar la escena principal.

### 3.3 Observaciones/riesgos de carga o mantenimiento (no roturas comprobadas)

1. **Override de instancia en la escena principal:** `scenes/main_island.tscn:72` instancia `Player.tscn` pero declara `type="CharacterBody3D"` y `script = ExtResource("3_ff3n1")` (`:74`, `res://scripts/player/player.gd`, también declarado en `:8`). `Player.tscn` ya define ese script (`scenes/player/Player.tscn:16`). Esto es válido en Godot como override, pero duplica la fuente de verdad y puede desincronizar comportamiento/propiedades si `Player.tscn` cambia.
2. **Duplicación de rig de cámara:** `scenes/CameraRig.tscn` existe como escena reutilizable (`:6–:16`, scripts `camera_rig.gd`, `camera_spring.gd`) pero `scenes/main.tscn` embebe una estructura equivalente inline (`:35–:54`) con parámetros distintos; `main_island.tscn` usa un enfoque diferente (`Camera3D` directo + `follow_camera.gd`). Riesgo de divergencia funcional y mantenimiento.
3. **Posicionamiento inconsistente de `VoxelViewer`:** en `main_island.tscn` es hijo directo de `Main` (`:70`), mientras en `main_test2.tscn` (`:44`) y `minimal_test.tscn` (`:10`) cuelga de `Camera3D`. Dependiendo de cómo Voxel Tools y/o scripts gestionen el viewer activo, esto puede afectar streaming/carga de chunks al iniciar o al mover cámara.
4. **`main_island.tscn` mezcla transform de instancia del jugador con lógica de spawn por script:** `:72–:73` posiciona `Player` en `(0,5,0)` en la instancia, pero `:58` delega en `main_island.gd`; además hay NPCs con coordenadas fijas elevadas/heterogéneas (p. ej. `:157`, `:165`, `:169`, `:175–:194`). No es una referencia rota, pero es un punto sensible si el terreno/altura de spawn cambia.
5. **HUD duplicado conceptualmente:** `scenes/ui/hud.tscn` define un HUD completo, mientras `main_island.tscn` monta widgets de UI propios inline. Riesgo de drift entre HUD de escena y HUD embebido en la main real.

---

## 4. Referencias a escenas inexistentes

- **Búsqueda:** se revisaron todos los `ext_resource` con `path="res://..."` en las 49 escenas (`80` referencias totales).
- **Resultado:** **0 referencias rotas**. No se encontraron `.tscn` (ni otros recursos externos referenciados por escenas) que apunten a rutas inexistentes en disco.
- **Dependencias `.tscn` específicas:** las 5 instancias de `res://scenes/player/Player.tscn` desde las escenas `main*` apuntan a un archivo existente (`scenes/player/Player.tscn`).
- **Otros recursos verificados presentes:** scripts `.gd`, el recurso de datos `res://data/villagers/catalina_oso.tres` (`scenes/main_island.tscn:12`), librería de animación `.tres` y assets referenciados por escenas inspeccionadas existen según la validación de rutas en disco.

---

## 5. Acciones de verificación sugeridas

1. **Carga y smoke-test de escenas principales con reporte de errores de runtime:** ejecutar Godot en modo headless/editor para abrir y/o correr `res://scenes/main_island.tscn` (escena de inicio, `project.godot:13`) y, de forma comparativa, `res://scenes/main.tscn`, `res://scenes/main_simple.tscn`, `res://scenes/main_test.tscn`, capturando `get_debug_output`/stderr. Objetivo: confirmar que autoloads, scripts y overrides (especialmente `main_island.tscn:72,74` sobre `Player.tscn`) no generan errores/warnings de carga, nodos faltantes o fallos de Voxel Tools.
2. **Verificación de consistencia cámara/streaming y normalización de instancias:** (a) validar en runtime que el `VoxelViewer` activo corresponde al patrón esperado por el proyecto (comparar comportamiento en `main_island.tscn:70` vs `main_test2.tscn:44`/`minimal_test.tscn:10`) observando carga de chunks y seguimiento de cámara; (b) auditar y unificar el uso de `scenes/CameraRig.tscn` y `scenes/ui/hud.tscn` frente a las versiones embebidas en `main.tscn`/`main_island.tscn` para reducir divergencias y puntos de fallo en futuras cargas.

---

## Conclusión final

- Se inventariaron **49** escenas `.tscn` bajo `game/isla-ancestral/scenes/`; la escena de inicio es `res://scenes/main_island.tscn` (`project.godot:13`).
- Las escenas principales comparten una estructura clara basada en `Node3D` raíz (`Main`) con entorno, terreno voxel, jugador instanciado desde `scenes/player/Player.tscn`, cámara, iluminación y UI, pero con **variantes de arquitectura** (cámara embebida/rig/simple, UI inline, ubicación de `VoxelViewer`) que reflejan distintas etapas o propósitos de prueba.
- **Nodos huérfanos/sin padre:** ninguno detectado (0/49 escenas).
- **Referencias rotas a escenas o recursos externos:** ninguna detectada (80 `ext_resource` analizados, 5 dependencias `.tscn` válidas, todas hacia `Player.tscn`).
- **Riesgo principal observado:** no hay roturas de ruta, sino **riesgos de consistencia/mantenimiento y carga lógica** — override de script en instancia de `Player` (`main_island.tscn:72,74`), duplicación `CameraRig`/HUD embebidos vs escenas dedicadas, y patrón distinto de `VoxelViewer` entre mains — que conviene validar en ejecución (acciones 1 y 2).

**Estado global del análisis estático de escenas:** sin huérfanos ni referencias inexistentes detectadas; estructura funcionalmente coherente con puntos de atención en consistencia entre variantes.  
**Firma:** Glyph Cluster / Kilo Code — 2026-11-10 23:58:26Z
