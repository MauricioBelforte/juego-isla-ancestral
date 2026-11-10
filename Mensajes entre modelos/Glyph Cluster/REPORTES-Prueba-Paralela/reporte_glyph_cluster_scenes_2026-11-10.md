# Reporte de análisis de escenas `.tscn` (Godot) — Isla Ancestral

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Vercel AI Gateway)  
**Fecha:** 2026-11-10 03:50 (UTC)  
**Alcance solicitado:** `game/isla-ancestral/scenes/` — escenas principales (`main.tscn`, `main_island.tscn`) y escenas de inicio/mundo.  
**Método:** análisis estático de archivos `.tscn` y `project.godot` (lectura de estructura, recursos externos, instancias y referencias `res://`). No se ejecutó Godot en runtime.

---

## 1) Estructura de las escenas principales

### 1.1 Configuración del proyecto
- **Escena principal configurada:** `run/main_scene="res://scenes/main_island.tscn"` (`game/isla-ancestral/project.godot:15`).
- **Nombre/versión:** `config/name="isla-ancestral"`, `config/version="0.0.6"` (`project.godot:13-14`).
- **Motor/features:** Godot 4.7, Forward+ (`project.godot:16`).
- **Autoloads:** extensa lista de singletons/scripts globales (`project.godot`, sección `[autoload]`, ~líneas 20-120 aprox.), lo que implica fuerte acoplamiento de arranque a servicios globales.

### 1.2 `scenes/main_island.tscn` (escena de inicio/mundo principal)
- **Archivo:** `game/isla-ancestral/scenes/main_island.tscn` (210 líneas).
- **Cabecera:** `[gd_scene format=3]` (sin `load_steps`/`uid` explícitos en cabecera) (`main_island.tscn:1`).
- **Raíz:** `Main` (`Node3D`) con script `res://scripts/main_island.gd` (`:3`, `:56-57`).
- **Recursos externos declarados (19):** scripts de mundo/cámara/jugador/NPC/UI/fauna/vegetación y recursos (`day_night_cycle.gd`, `agua_animada.gd`, `terreno_horizonte.gd`, `follow_camera.gd`, `player.gd`, `Player.tscn`, `w_reloj.gd`, `villager.gd`, `catalina_oso.tres`, widgets HUD, scripts de fauna, spawners) (`:3-21`).
- **Subrecursos internos:** `ProceduralSkyMaterial`, `Sky`, `Environment`, `StyleBoxFlat` (`:24-54`).
- **Jerarquía principal (nodos bajo `Main`):**
  - Entorno/iluminación: `WorldEnvironment` (`:59-60`), `DirectionalLight` (`:87-95`), `DirLightLuna` (`:97-101`).
  - Sistemas/mundo: `VegetationSpawner` (`:62-63`), `FaunaSpawner` (`:65-66`), `VoxelTerrain` (`:67`), `VoxelViewer` (`:69`), `DayNightCycle` (`:154-155`), `AguaAnimada` (`:157-159`, transform centrado en 2560,4.05,2560), `TerrenoHorizonte` (`:161-163`, centrado en 2560,0,2560).
  - Jugador/cámara: `Player` (`CharacterBody3D`, instanciado desde `Player.tscn` pero redefinido en línea, ver §2/§3) (`:72-75`), `Camera3D` con `follow_camera.gd` (`:77-79`).
  - UI embebida (`CanvasLayer UI`): `FPSLabel`, `ControlsLabel`, `RelojWidget`, `StatusBar`, `InteractPrompt`, `MinimapWidget` (`:103-152`).
  - NPCs/fauna colocados en escena: `CatalinaOso` (`:148-152`), `TortugaNPC`, `CangrejoNPC`, `JabaliNPC`, `JabaliAdultoNPC`, `GaviotaNPC` (`:166-188`).
- **Observaciones estructurales:** escena monolítica de mundo (terreno, clima/día-noche, spawners, jugador, cámara, HUD parcial y fauna/NPC) concentrada en un único `.tscn`; mezcla instanciación de escena (`Player.tscn`) con composición inline y UI duplicada respecto a `scenes/ui/hud.tscn`.

### 1.3 `scenes/main.tscn` (escena principal alternativa/simplificada)
- **Archivo:** `game/isla-ancestral/scenes/main.tscn` (86 líneas).
- **Cabecera:** `[gd_scene load_steps=6 format=3 uid="uid://c1234568aa0"]` (`:1`).
- **Raíz:** `Main` (`Node3D`) + `main.gd` (`:3`, `:28-29`).
- **Dependencias externas:** `camera_rig.gd`, `camera_spring.gd`, `Player.tscn` (`:4-6`).
- **Estructura:** `WorldEnvironment`, `VoxelTerrain`, instancia limpia de `Player` (`:33`), `CameraRig` → `CameraSpring` (+ `RayCast3D`) + `Camera3D` como hijo del rig, `DirectionalLight`, `UI` con labels FPS/controles (`:31-85`).
- **Comparación con `main_island`:** más modular en cámara (rig/spring separados) y usa instancia de jugador sin override de script; carece de ciclo día/noche, spawners, NPCs, agua/horizonte y HUD completo.

### 1.4 `scenes/main_simple.tscn` (variante de inicio ligera)
- **Archivo:** `game/isla-ancestral/scenes/main_simple.tscn` (64 líneas).
- **Raíz:** `Main` (`Node3D`) + `main_simple.gd`; usa `simple_camera.gd` y `Player.tscn` (`:3-5`, `:27-28`, `:32`, `:34-38`).
- **Estructura:** entorno, `VoxelTerrain`, jugador instanciado, `SimpleCamera` (Camera3D directa), luz direccional y UI mínima (FPS/controles) (`:30-63`).
- **Patrón:** similar a `main.tscn` pero con cámara simplificada (sin rig/spring).

### 1.5 Otras escenas de arranque/mundo/prueba detectadas
- `scenes/main_test.tscn`, `scenes/main_test2.tscn`, `scenes/simple_walk.tscn`, `scenes/test_terrain.tscn`, `scenes/minimal_test.tscn`, etc. (inventario completo vía glob: 40+ `.tscn` bajo `scenes/`, incluyendo `player/`, `npc/`, `ui/`, `museo/`, `terrenos/`, `tests/`, `debug/`).

### 1.6 Escenas de composición reutilizable relevantes
- **Jugador:** `scenes/player/Player.tscn` — raíz `CharacterBody3D` + `player.gd`; hijos: `ModeloVoxel` (instancia GLB), colisión cápsula, `TerrainDetector`, `TerrainFootprints`, `TerrainParticles`, `NucleoM11`, `AnimacionM48` con `AnimationPlayer` y librería (`Player.tscn:1-54`).
- **HUD modular:** `scenes/ui/hud.tscn` — `CanvasLayer HUDScreen` con widgets (status, reloj, estación, recursos, hotbar, interact, action prompt, minimapa, mapa completo) y scripts dedicados (`hud.tscn:1-154`).
- **Cámara reusable:** `scenes/CameraRig.tscn` — `Node3D CameraRig` → `CameraSpring` → `RayCast3D` y `Camera3D` (`CameraRig.tscn:1-18`).

---

## 2) ¿Hay nodos huérfanos o sin padre?

**Conclusión:** no se identificaron nodos huérfanos en el sentido de Godot (nodos definidos fuera de la jerarquía de la escena sin `parent` válido) en las escenas revisadas.

**Evidencia y matices:**
- Toda escena `.tscn` válida debe tener exactamente **un nodo raíz** (declarado sin atributo `parent`). Las escenas inspeccionadas (`main.tscn`, `main_island.tscn`, `main_simple.tscn`, `Player.tscn`, `hud.tscn`, `CameraRig.tscn`, `simple_walk.tscn`, `preview_particles.tscn`) presentan una raíz única y el resto de nodos con `parent="."` o `parent="Ruta/Hijo"` consistente.
- Un conteo heurístico automático por regex marcó como anómalas (`root_count=2`) varias escenas (`main.tscn`, `main_simple.tscn`, `main_test.tscn`, `main_test2.tscn`, `Player.tscn`), pero la inspección manual muestra que se debe al formato Godot 4 (`unique_id`, orden de atributos) y **no** a múltiples raíces reales ni a nodos huérfanos.
- **Casos a vigilar (no huérfanos, pero estructuralmente atípicos):**
  - `simple_walk.tscn`: el nodo raíz es `Game` (`CharacterBody3D`) que además contiene un hijo `Player` (`CharacterBody3D`) y componentes de mundo/luz/cámara (`simple_walk.tscn:56-127`). No es huérfano, pero duplica rol de cuerpo controlable/escena y puede confundir ownership de lógica.
  - `main_island.tscn`: `Player` se declara como nodo con `instance=ExtResource("3_player")` y a la vez `type="CharacterBody3D"` + `script=ExtResource("3_ff3n1")` (`main_island.tscn:72-75`). No es huérfano; es una **instancia sobrescrita inline** que puede generar ambigüedad frente a la definición canónica de `Player.tscn`.

---

## 3) ¿Hay dependencias entre escenas que puedan causar problemas de carga?

Sí, se observan varias dependencias/riesgos potenciales:

1. **Cadena crítica de arranque dependiente de autoloads masivos**  
   - `project.godot` define decenas de autoloads (núcleo, UI, mundo, audio, economía, etc.) antes/de forma paralela al arranque de `main_island.tscn` (`project.godot:[autoload]`).  
   - **Riesgo:** orden de inicialización, dependencias cíclicas o fallos en cualquier singleton pueden impedir la carga/ejecución de la escena principal.

2. **Instanciación + override del jugador en `main_island.tscn`**  
   - `Player` se instancia desde `res://scenes/player/Player.tscn` pero además se fuerza `type`, `script` y transform en la escena padre (`main_island.tscn:9,72-75`).  
   - **Riesgo:** divergencia con la escena de jugador canónica (`scenes/player/Player.tscn` define su propio script, hijos y configuración). Cambios futuros en `Player.tscn` pueden no reflejarse o chocar con overrides locales.

3. **Duplicación de UI entre escena de mundo y HUD modular**  
   - `main_island.tscn` incluye widgets UI propios (`RelojWidget`, `StatusBar`, `InteractPrompt`, `MinimapWidget`) con scripts directos (`main_island.tscn:10,13-15,120-152`), mientras existe `scenes/ui/hud.tscn` con un HUD completo y solapamiento funcional (`hud.tscn`).  
   - **Riesgo:** doble lógica/estado de UI, señales desconectadas o inconsistencias visuales al mantener dos implementaciones.

4. **Dependencia de subsistemas de voxel/terreno**  
   - Las escenas principales usan `VoxelTerrain`/`VoxelViewer` (`main.tscn:31`, `main_simple.tscn:30`, `main_island.tscn:67,69`).  
   - **Riesgo:** si el módulo/extensión Voxel Tools no está disponible o falla, la carga de estas escenas fallará en runtime/editor.

5. **Dependencia de recursos de datos y assets externos**  
   - `main_island.tscn` referencia `res://data/villagers/catalina_oso.tres` (`:12`, usado en `CatalinaOso` `:151-152`). `Player.tscn` referencia GLB y librería de animación (`res://assets/3d/media/45-Arte3D_jugador_voxel.glb`, `res://scripts/animacion/libraries/jugador_lib.tres`, `Player.tscn:4,7,23,51-53`).  
   - **Riesgo:** cualquier movimiento/renombrado de estos assets rompe la carga de escenas dependientes (la validación estática de existencia se detalla en §4).

6. **Posibles incoherencias de mundo/posicionamiento**  
   - En `main_island.tscn`, elementos de entorno se ubican en torno a `2560` (`AguaAnimada`, `TerrenoHorizonte` en `:158,162`) mientras NPCs/fauna aparecen en coordenadas ~232-285 (`:149,167,171,175,179,183`).  
   - **Riesgo funcional:** entidades pueden aparecer fuera del área jugable/terreno esperado al cargar la escena (no es error de parseo de `.tscn`, pero sí dependencia espacial frágil).

---

## 4) ¿Hay archivos `.tscn` con referencias a escenas/recursos que no existen?

**Resultado de verificación estática (referencias `res://` en todos los `.tscn` de `scenes/`):**  
- **No se encontraron referencias `res://` inexistentes en disco** dentro del alcance `game/isla-ancestral/scenes/**/*.tscn`.

**Detalle de la comprobación:**
- Se extrajeron todos los atributos `path="res://..."` de los `.tscn` bajo `scenes/` y se verificó la existencia de cada archivo en `game/isla-ancestral/`.
- Rutas muestreadas y existentes (ejemplos): `res://scenes/player/Player.tscn` (usada en `main.tscn:6,33`, `main_island.tscn:9,72`, `main_simple.tscn:5,32`, `main_test*.tscn`), `res://scripts/main_island.gd`, `res://scripts/main.gd`, `res://scripts/main_simple.gd`, `res://data/villagers/catalina_oso.tres`, `res://assets/3d/media/45-Arte3D_jugador_voxel.glb`, `res://scripts/animacion/libraries/jugador_lib.tres`, scripts de UI/cámara/fauna/spawners referenciados.
- **Limitación:** esta verificación cubre rutas `res://` declaradas en `.tscn`. No valida referencias cargadas dinámicamente por código GDScript (`load()`/`preload()`/`change_scene_to_file()` en scripts), UIDs huérfanos, ni recursos generados en runtime.

---

## 5) Sugerencias: 2 acciones de verificación

1. **Carga/runtime headless de la escena principal y revisión de errores**
   - **Acción:** ejecutar Godot en modo headless (o con ventana) cargando la escena principal configurada y capturar el log completo.
   - **Comando sugerido (desde `game/isla-ancestral/`):**
     - `godot --headless --path . --scene res://scenes/main_island.tscn` (o `--quit-after 60` si se desea cierre automático tras inicialización), según versión/flags disponibles.
   - **Qué validar:** errores de carga de recursos, fallos de autoloads, nodos/tipos no disponibles (p. ej. `VoxelTerrain`), scripts con errores de parseo, y warnings de dependencias. Complementar con `get_debug_output` si se usa el MCP de Godot.

2. **Validación automática de integridad de escenas (`.tscn`) en CI/local**
   - **Acción:** crear/ejecutar un script de verificación estática que, para cada `scenes/**/*.tscn`: (a) confirme referencias `res://` existentes, (b) verifique raíz única y nodos con `parent` resoluble, (c) detecte instancias con overrides conflictivos (ej. `instance=` + `type=`/`script=` redundante como en `main_island.tscn:72-75`), y (d) compare uso de HUD modular (`scenes/ui/hud.tscn`) vs. UI embebida.
   - **Criterio de éxito:** 0 referencias rotas, 0 nodos huérfanos, reporte de overrides/duplicaciones para decisión de refactor. Ejecutar en cada cambio de escenas o antes de merge.

---

## Conclusión final

- **Escena de inicio real:** `res://scenes/main_island.tscn` (configurada en `project.godot`). Es una escena de mundo rica pero monolítica, con múltiples subsistemas integrados (terreno voxel, ciclo día/noche, agua/horizonte, spawners, NPC/fauna, UI parcial y jugador).
- **Coherencia de referencias estáticas:** no se hallaron rutas `res://` rotas en los `.tscn` de `scenes/` según la verificación en disco.
- **Nodos huérfanos:** no se evidenciaron huérfanos reales; las anomalías detectadas por heurística se explican por formato Godot 4 y requieren validación manual/editor.
- **Riesgos de carga/mantenimiento:** dependencia fuerte de autoloads, uso de nodos de voxel, override inline del `Player` instanciado en `main_island.tscn`, y duplicación de UI frente a `scenes/ui/hud.tscn`. Estos puntos son los principales focos para pruebas de carga y refactor.
- **Próximo paso recomendado:** ejecutar la verificación runtime de la escena principal y establecer un chequeo automático de integridad de `.tscn` para prevenir regresiones de dependencias.
