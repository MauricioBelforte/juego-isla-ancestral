# IMPOSTORES DEL TERRENO: heightmap completo, anti-tildes y anti-caída

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-09
> **Validado en:** Isla Ancestral — isla 10× (5120×5120), GPU integrada AMD Radeon, max_height 40
> **Logs:** 758-799 · **Referencia cruzada:** 07-GUIA-GODOT §13.1-13.9

---

## El problema

En mundos voxel grandes (isla 10× = 5120×5120), los chunks voxel reales solo
cargan a ~1024m alrededor del jugador (subir el radio = tildes por streaming).
Más allá hay **agua infinita** y las montañas del centro **no se ven nunca**.

**El diagnóstico del usuario que lo resolvió todo**:
> "Un plano horizontal visto de canto desde lejos es una línea invisible por
> perspectiva — física pura. Por eso nunca se vio el disco verde plano."

**La solución**: impostor HEIGHTMAP de toda la isla con relieve vertical —
prismas escalonados que se ven de cualquier ángulo.

---

## Arquitectura completa (4 sistemas integrados)

```
Arranque del mundo 10×:
1. main_island instala UN generador (WorldGenerator island 10×) — único dueño
2. Spawn: posicionar en Y=altura_del_generador+3 (get_height O(1))
3. Física del player CONGELADA 10s (await timer — streaming inicial)
4. VoxelViewer enganchado al Player (streaming sigue al jugador)
5. Física liberada tras los 10s
6. Suelo fantasma activo SIEMPRE (get_height O(1)):
   - Tierra (h>=4): apoyar en la altura del terreno
   - Agua (h<4): apoyar en y=4.45 (superficie, nadando)
7. Impostor heightmap: 44 tiles, ocultos <400m del player
8. Disco base verde: y=4.3, opaco, SIEMPRE visible (fondo bajo el agua)
```

---

## PARTE 1 — El impostor heightmap (relieve vertical)

### El concepto

Un mesh que copia el terreno completo con **prismas escalonados**: cada celda
de la grilla es un prisma desde y=0 hasta la altura real del generador. Se ve
de CUALQUIER ángulo (superficie + paredes).

### El código (terreno_horizonte.gd — versión final)

```gdscript
extends Node3D

const PASO := 64.0                  # 4× menos geometría que 16m
const CENTRO_ISLA := Vector2(2560.0, 2560.0)
const RADIO_CUBIERTO := 2700.0      # toda la isla + margen
const FACTOR_ALTURA := 0.85         # 15% bajo el terreno real (anti z-fighting)
const MONT_EXAG := 4.0              # cimas ×4 (visibles de lejos)
const H_MIN := 4.0                  # debajo = agua, la cubre el plano de agua
const TAMANO_TILE := 640.0          # tiles de 640m con ocultamiento independiente
const TILE_OCULTAR_UMBRAL := 1024.0 # match con view_distance de chunks
const FILAS_POR_FRAME := 6          # muestreo incremental sin hitch

var _alturas_celda: Dictionary = {}  # Vector2i(x,z) -> altura
var _tiles: Array = []
var _island_gen = null
# ... estado incremental (ver archivo completo)

func _muestrear_fila(z: int) -> void:
	var x := int(CENTRO_ISLA.x - RADIO_CUBIERTO)
	var x_max := int(CENTRO_ISLA.x + RADIO_CUBIERTO)
	while x < x_max:
		_alturas_celda[Vector2i(x, z)] = float(_island_gen.get_height(x, z))
		x += int(PASO)

func _crear_tiles() -> void:
	var n := int(ceil(RADIO_CUBIERTO * 2.0 / TAMANO_TILE))
	var min_x := int(CENTRO_ISLA.x - RADIO_CUBIERTO)
	var min_z := int(CENTRO_ISLA.y - RADIO_CUBIERTO)
	for tx in range(n):
		for tz in range(n):
			var t_x0 := min_x + tx * int(TAMANO_TILE)
			var t_z0 := min_z + tz * int(TAMANO_TILE)
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var celdas := 0
			var z := t_z0
			while z < t_z1:
				var x := t_x0
				while x < t_x1:
					var clave := Vector2i(x, z)
					if _alturas_celda.has(clave):
						var h: float = _alturas_celda[clave]
						if h >= 4.0:
							# EXAGERACIÓN SOLO en montañas reales (h>20):
							# exagerar TODO el terreno crea montañas falsas
							# que tapan el disco verde y la arena
							var top := h * FACTOR_ALTURA
							if h > 20.0:
								top = h * FACTOR_ALTURA * MONT_EXAG
							var x0 := float(x)
							var x1 := float(x) + PASO
							var z0 := float(z)
							var z1 := float(z) + PASO
							var cc := _color_por_altura(top)
							# superficie superior
							_tri(st, Vector3(x0, top, z0), cc, Vector3(x0, top, z1), cc, Vector3(x1, top, z1), cc)
							_tri(st, Vector3(x0, top, z0), cc, Vector3(x1, top, z1), cc, Vector3(x1, top, z0), cc)
							# paredes SOLO en acantilados (vecino >= 2m más bajo)
							_pared_si_cliff(st, Vector2i(x - int(PASO), z), Vector3(x0, top, z0), Vector3(x0, top, z1), cc)
							_pared_si_cliff(st, Vector2i(x + int(PASO), z), Vector3(x1, top, z1), Vector3(x1, top, z0), cc)
							_pared_si_cliff(st, Vector2i(x, z - int(PASO)), Vector3(x1, top, z0), Vector3(x0, top, z0), cc)
							_pared_si_cliff(st, Vector2i(x, z + int(PASO)), Vector3(x0, top, z1), Vector3(x1, top, z1), cc)
							celdas += 1
					x += int(PASO)
				z += int(PASO)
			if celdas == 0:
				_tiles.append(null)
				continue
			var mi := MeshInstance3D.new()
			mi.mesh = st.commit()
			var mat := StandardMaterial3D.new()
			mat.vertex_color_use_as_albedo = true
			mat.roughness = 1.0
			mi.material_override = mat
			mi.position = Vector3.ZERO  # vértices ya mundiales
			add_child(mi)
			_tiles.append(mi)

## Pared SOLO si el vecino es >= 2m más bajo (acantilado real)
func _pared_si_cliff(st: SurfaceTool, vecino: Vector2i, esquina_a: Vector3, esquina_b: Vector3, cc: Color) -> void:
	if not _alturas_celda.has(vecino):
		return
	var h_vecino: float = _alturas_celda[vecino] * FACTOR_ALTURA
	var h_propio: float = maxf(esquina_a.y, esquina_b.y)
	if h_propio - h_vecino < 2.0:
		return  # no es acantilado: sin pared
	_tri(st, esquina_a, cc, esquina_b, cc, Vector3(esquina_b.x, h_vecino, esquina_b.z), cc)
	_tri(st, esquina_a, cc, Vector3(esquina_b.x, h_vecino, esquina_b.z), cc, Vector3(esquina_a.x, h_vecino, esquina_a.z), cc)
```

### Las reglas críticas del impostor

1. **Exageración SOLO en montañas reales** (h > 20 con max_height 40).
   Exagerar TODAS las celdas crea montañas gigantes falsas en todo el terreno
   que tapan el disco verde y la arena (bug del Log 803).
2. **Paredes SOLO en acantilados** (vecino ≥2m más bajo). Paredes en todas
   las celdas = overdraw masivo = tilda GPU integrada.
3. **FACTOR_ALTURA 0.85**: el impostor queda 15% bajo el terreno real.
   Cerca, los chunks reales lo cubren; lejos, el impostor es el horizonte.
4. **Vértices en coordenadas MUNDIALES, nodo en Vector3.ZERO** — nunca
   doble offset (el impostor aparecía "sobre el agua" en el lado equivocado).
5. **Ocultamiento con distancia al PUNTO MÁS CERCANO del AABB** (clamp) —
   el centro del AABB mide mal en tiles alargados.

---

## PARTE 2 — Anti-tildes: las 4 causas y sus soluciones

Ver detalle completo en 07-GUIA-GODOT §13.7. Resumen ejecutivo:

### TILDE 1 — Generación por VOXEL (el más importante)

`_generate_block` llamaba `get_block_at(x,y,z)` por CADA voxel (~20k por
chunk) y cada llamada recalculaba noises.

```gdscript
# ❌ MAL: noise por voxel
for z in range(size.z):
	for x in range(size.x):
		for y in range(size.y):
			var block_id: int = gen.get_block_at(world_x, world_y, world_z)  # ¡20k noises!

# ✅ BIEN: precalculo por COLUMNA
for z in range(size.z):
	for x in range(size.x):
		var col: Array = gen.get_column_data(world_x, world_z)  # 1 vez por columna
		var height: int = col[0]
		var biome: String = col[1]
		for y in range(size.y):
			var block_id: int = gen.get_block_at_column(world_x, world_y, world_z, height, biome)
			out_buffer.set_voxel(block_id, x, y, z, VoxelBuffer.CHANNEL_TYPE)
```

**~80× menos llamadas de noise**. Métodos en island_generator.gd:
- `get_column_data(x, z) -> Array` — retorna [height, biome].
- `get_block_at_column(x, y, z, height, biome) -> int` — misma lógica con
  datos precalculados.

### TILDE 2 — VoxelTool.get_voxel() fuerza generación sincrónica

`get_voxel()` sobre un chunk no materializado **bloquea el main thread**
forzando la generación sincrónica (warning `Waiting for all tasks...`).

```gdscript
# ❌ MAL: verificar el chunk con get_voxel (bloquea)
if vt.get_voxel(Vector3i(x, h, z)) != 0:  # fuerza generación sincrónica
	liberar_fisica()

# ✅ BIEN: timer fijo + suelo fantasma permanente
await get_tree().create_timer(10.0).timeout
_liberar_fisica_player(player)  # el suelo fantasma (get_height O(1)) lo sostiene
```

### TILDE 3 — TRANSPARENCY_ALPHA en meshes enormes

El sorting de transparencias masivo tilda la GPU integrada.

```gdscript
# ❌ MAL: disco de 6200×6200 con transparencia
mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

# ✅ BIEN: material opaco + fade binario por tile
mat.albedo_color = COLOR  # opaco
mi.visible = distancia > umbral  # ocultamiento por tile
```

### TILDE 4 — Streaming descubre demasiados chunks al volar

view_distance 1024 en un mundo 10× = demasiados chunks por segundo al volar.
Solución: view_distance 512 + impostor heightmap cubriendo el resto.

---

## PARTE 3 — Anti-caída al vacío (spawn + caminar + volar)

### Al spawn — verificación + física congelada

```gdscript
# main_island.gd — flujo del spawn
func _ajustar_spawn_superficie() -> void:
	if _spawn_ajustado:
		return  # guard: UNA sola vez (evita doble caída)
	var locator = get_node_or_null("/root/TerrainLocator")
	var mundo = get_node_or_null("/root/MundoRaiz")
	var spawn_x: float = mundo.SPAWN_JUGADOR.x if mundo != null else 256.0
	var spawn_z: float = mundo.SPAWN_JUGADOR.z if mundo != null else 256.0
	if locator:
		var altura_spawn: int = locator.get_height(spawn_x, spawn_z)
		var player = get_node_or_null("Player")
		if player and altura_spawn >= 0:
			_spawn_ajustado = true
			player.global_position = Vector3(spawn_x, altura_spawn + 3, spawn_z)
			_enganchar_voxel_viewer(player)  # streaming sigue al jugador
			player.set_physics_process(false)  # congelar durante el streaming
			await get_tree().create_timer(10.0).timeout
			_liberar_fisica_player(player)  # el suelo fantasma lo sostiene SIEMPRE
```

### Al caminar/volar — suelo fantasma (player.gd)

```gdscript
# En _physics_process, después del movimiento del box mover:
if not _on_ground and velocity.y < -5.0:
	var gen = _generador_isla()
	if gen != null:
		var h_piso := float(gen.get_height(int(global_position.x), int(global_position.z)))
		if h_piso < 4.0:
			# AGUA: sostener en la superficie (nadando) — nunca al fondo
			if global_position.y < 4.45:
				global_position.y = 4.45
				velocity.y = 0.0
				_on_ground = true
		elif global_position.y < h_piso - 1.0:
			# TIERRA: apoyar en la altura del terreno
			global_position.y = h_piso
			velocity.y = 0.0
			_on_ground = true
```

**La regla de oro**: `get_height()` del generador es O(1) (sin I/O, sin
streaming) — es la "verdad" del terreno. El suelo fantasma la usa SIEMPRE que
el jugador caiga más rápido de lo que el streaming carga.

---

## PARTE 4 — El bot de paseo (verificación automatizada)

El bot teleporta por tramos de 200m, monitorea caídas/atascados/bajo-agua y
captura screenshots. Al terminar reporta:

```
PASEO TERMINADO: 17/17 waypoints, 17 capturas, 13 rescates
PASEO CON OBSERVACIONES: 13 (todas "TIMEOUT waypoint" del bot)
```

**Activación**: switch bot/humano en el código (`ACTIVADO_POR_DEFECTO`) o
flag `-- paseo`.

**Limitación conocida**: la tecla W simulada no camina porque el movimiento
del player es relativo a la CÁMARA que el bot no rota — es limitación del bot
de prueba, NO del juego (el juego funciona normal con WASD).

---

## Checklist de validación de un mundo voxel grande

- [ ] El jugador spawnea sobre el terreno (no en el aire, no bajo el agua)
- [ ] Caminar 60s seguidos sin un solo freeze
- [ ] Volar 60s seguidos sin un solo freeze
- [ ] Mirar el horizonte desde lejos: la isla completa visible (impostor)
- [ ] Acercarse a los bordes del impostor: transición impostor→chunks sin pop
- [ ] Caminar sobre lagunas sin chunks: nadar en la superficie (no ir al fondo)
- [ ] El relieve del impostor coincide con las montañas reales al acercarse
- [ ] FPS estables (~60) en todo el recorrido

---

## Los errores que evitar con esta guía

| Error | Consecuencia | Prevención |
|---|---|---|
| Dos generadores compitiendo | Bug indeterminista (B-076) | Un solo dueño de terrain.generator |
| Noise por voxel | Tildes al caminar (~100ms/chunk) | Precalculo por columna (Log 800) |
| get_voxel en chunks no cargados | Freeze del main thread | Suelo fantasma O(1) |
| Exagerar TODO el terreno | Montañas falsas tapando todo | Exagerar solo h>20 (Log 803) |
| Paredes en todas las celdas | Overdraw = tilda GPU integrada | Paredes solo en acantilados |
| TRANSPARENCY_ALPHA en mesh de km | Freeze de GPU integrada | Material opaco + fade binario |
| Plano horizontal de canto | Línea de subpíxeles (invisible) | Impostor heightmap con relieve |
| Timer fijo para streaming | Caída al vacío intermitente | Voxel-verificación o suelo fantasma |
| Thread con el generador | Race condition, datos corruptos | Construcción incremental por frames |
| Doble offset del impostor | Impostor en el lado equivocado | Vértices mundiales + nodo en ZERO |
| VegetationSpawner autoload + escena | Doble población silenciosa (Log 802) | Un solo dueño por instancia |
