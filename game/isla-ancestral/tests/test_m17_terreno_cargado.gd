extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — suite de TERRENO CARGADO (L102 / D100).
#
# POR QUE EXISTE: el checklist pedia "la rejilla solo se calcula sobre terreno
# cargado (nunca sobre chunks vacios)". La nota de 04-Codigo.md decia: "el
# adaptador devuelve 'aire' sin terreno, pero FALTA la prueba con chunks reales
# en runtime". En ese momento NO habia ninguna comprobacion de chunk: el
# manager colocaba la pieza (y la registraba en M17) aunque el terreno no
# tuviera data block en esa zona -> la pieza existia en la logica pero no en el
# mundo (y el undo/rehash tampoco cuadraban).
#
# API NATIVA MEDIDA (Godot 4.7.2 + Voxel Tools, via ClassDB):
#   VoxelTerrain.voxel_to_data_block(voxel_pos: Vector3) -> Vector3i
#   VoxelTerrain.has_data_block(block_position: Vector3i) -> bool
# El terreno falso de esta suite reproduce EXACTAMENTE ese contrato.
#
# QUE MIDE (headless, manager real + terreno falso con chunks):
#   * `chunk_cargada()`: true en el chunk cargado, false en el vacio
#   * `superficie_voxel()` devuelve "aire" en un chunk NO cargado AUNQUE el
#     voxelTool diga "solido" (la rejilla no se calcula sobre datos rancios)
#   * `celdas_sin_chunk()` separa las celdas fuera de la rejilla
#   * el manager RECHAZA colocar/copiar/mover sobre un chunk sin cargar, con el
#     motivo TERRENO_NO_CARGADO (temporal: el chunk se carga solo)
#   * el rechazo NO deja la pieza a medias (no se registra ni se escribe)
#   * en modo LOGICO (sin terreno) no se bloquea nada (no se rompe el modo logico)
#   * el CONTEO de consultas al terreno esta acotado por la huella de la pieza
#     (la rejilla no se calcula sobre chunks)
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_terreno_cargado.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: la rejilla solo sobre terreno cargado (L102)"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const MUNDO := preload("res://scripts/construccion/construccion_mundo.gd")
const CHECKS_MINIMOS := 22

## Lado del data block (celdas por data block) — el valor real del terreno lo
## decide VoxelTerrain; aqui basta un tamano fijo y coherente.
const LADO_BLOQUE := 16

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


# ── Terreno falso: reproduce el contrato nativo medido ───────────────────

class VoxelToolFalso:
	extends RefCounted
	var channel: int = 0
	var mode: int = 0
	var value: int = 0
	var eraser_value: int = 0
	var bloques: Dictionary = {}       # celda -> id de bloque
	var escrituras: int = 0
	func get_voxel(celda: Vector3i) -> int:
		return int(bloques.get(celda, 0))
	func do_point(celda: Vector3i) -> void:
		escrituras += 1
		bloques[celda] = 99


class TerrainFalso:
	extends Node
	var tool: VoxelToolFalso = VoxelToolFalso.new()
	var data_blocks: Array[Vector3i] = []
	func get_voxel_tool():
		return tool
	func voxel_to_data_block(v: Vector3) -> Vector3i:
		return Vector3i(int(floor(v.x / LADO_BLOQUE)), int(floor(v.y / LADO_BLOQUE)), int(floor(v.z / LADO_BLOQUE)))
	func has_data_block(bloque: Vector3i) -> bool:
		return data_blocks.has(bloque)


class FakeInventario:
	extends RefCounted
	var items: Dictionary = {}
	func count_item(item_id: String, _include_house: bool = false) -> int:
		return int(items.get(item_id, 0))
	func remover_items(d: Dictionary) -> bool:
		for k in d.keys():
			if int(items.get(String(k), 0)) < int(d[k]):
				return false
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) - int(d[k])
		return true
	func agregar_items(d: Dictionary) -> bool:
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) + int(d[k])
		return true
	func has_free_space(_container: int = 0) -> bool:
		return true


## Mundo LOGICO con soporte (como el que usan las demas suites de M17): no
## tiene terreno, asi que no hay chunks -> el guard de L102 no debe bloquear.
class MundoLogico:
	extends ConstruccionMundo
	var suelo: int = 0
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= suelo else &"aire"


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _motivos(res: Dictionary) -> Array:
	return res.get("motivos", [])


func _sembrar(inv: FakeInventario, r: PlacementRule) -> void:
	for k in (r.costo as Dictionary).keys():
		inv.items[String(k)] = 999
	for k in ["madera", "piedra", "stone", "planks", "fibra", "tierra", "arena", "ore"]:
		inv.items[k] = 999


## Terreno con dos zonas: el chunk (0,0,0) CARGADO y el chunk (8,0,0) VACIO.
func _terreno(inv) -> Array:
	var terreno := TerrainFalso.new()
	terreno.name = "TerrainFalso"
	root.add_child(terreno)
	terreno.data_blocks.append(Vector3i(0, 0, 0))
	# El chunk (8,0,0) NO esta en data_blocks: es la zona "sin terreno cargado".
	# Ademas el voxelTool dice "solido" en la zona vacia: si M17 no consultara
	# el chunk, la trataria como buildable (este es el caso que hay que cazar).
	for x in range(8 * LADO_BLOQUE, 9 * LADO_BLOQUE):
		for z in range(0, 4):
			terreno.tool.bloques[Vector3i(x, 0, z)] = 12
	return [terreno, MUNDO.new()]


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var recetas_pared: Array = cat.por_familia(&"pared")
	var receta_base: PlacementRule = recetas_pared[0] if not recetas_pared.is_empty() else null
	_check("A0: el catalogo real de M17 tiene recetas de la familia 'pared'", receta_base != null)

	# ── A. El contrato de chunk en el adaptador ─────────────────────────
	var par: Array = _terreno(null)
	var terreno: TerrainFalso = par[0]
	var mundo: ConstruccionMundo = par[1]
	mundo.conectar_terrain(terreno)

	var celda_cargada := Vector3i(2, 1, 2)
	var celda_vacia := Vector3i(8 * LADO_BLOQUE + 2, 1, 2)
	_check("A1: chunk_cargada = true en la celda del chunk cargado",
		mundo.chunk_cargada(celda_cargada))
	_check("A2: chunk_cargada = false en la celda del chunk VACIO",
		not mundo.chunk_cargada(celda_vacia))
	_check("A3: celdas_sin_chunk marca SOLO las celdas del chunk vacio",
		(mundo.celdas_sin_chunk([celda_cargada, celda_vacia]) as Array).size() == 1
			and (mundo.celdas_sin_chunk([celda_cargada, celda_vacia]) as Array)[0] == celda_vacia)
	_check("A4: superficie_voxel = 'aire' en el chunk NO cargado (aunque el voxel diga solido)",
		mundo.superficie_voxel(celda_vacia) == &"aire",
		String(mundo.superficie_voxel(celda_vacia)))

	# ── B. El manager RECHAZA construir sobre un chunk sin cargar ───────
	var inv := FakeInventario.new()
	_sembrar(inv, receta_base)
	var mgr = MGR.new()
	mgr.name = "BuildManagerTerrenoCargado"
	root.add_child(mgr)
	mgr.conectar_mundo(mundo)
	mgr.conectar_zonas(ZONE_REG.new())
	mgr.set_limite_mundo(AABB())
	mgr.conectar_inventario(inv)
	await process_frame
	mgr.registrar_receta(receta_base)
	mgr.seleccionar_pieza(receta_base)

	var res_fuera: Dictionary = mgr.confirmar_colocacion(celda_vacia)
	_check("B1: colocar sobre un chunk SIN cargar -> motivo TERRENO_NO_CARGADO",
		(_motivos(res_fuera) as Array).has(TIPO.Motivo.TERRENO_NO_CARGADO), str(_motivos(res_fuera)))
	_check("B2: TERRENO_NO_CARGADO es TEMPORAL (el chunk se carga solo)",
		TIPO.es_temporal(TIPO.Motivo.TERRENO_NO_CARGADO))
	_check("B3: el texto del motivo es legible para el HUD",
		TIPO.texto(TIPO.Motivo.TERRENO_NO_CARGADO).contains("cargado"),
		TIPO.texto(TIPO.Motivo.TERRENO_NO_CARGADO))
	_check("B4: NO se registro la pieza (no queda a medias)",
		(mgr.pieza_en_celda(celda_vacia) as Dictionary).is_empty())
	_check("B5: NO se escribio ningun voxel en el chunk vacio",
		terreno.tool.escrituras == 0, "escrituras=%d" % terreno.tool.escrituras)
	_check("B6: no se cobro el costo (el rechazo es antes del descuento)",
		int(inv.items.get("piedra", 0)) == 999, "items=%s" % str(inv.items))

	# ── C. En el chunk CARGADO se construye normal ─────────────────────
	terreno.tool.bloques[Vector3i(celda_cargada.x, 0, celda_cargada.z)] = 12
	var res_dentro: Dictionary = mgr.confirmar_colocacion(celda_cargada)
	_check("C1: colocar en el chunk CARGADO -> ok",
		bool(res_dentro.get("ok", false)), str(_motivos(res_dentro)))
	_check("C2: la pieza quedo registrada",
		not (mgr.pieza_en_celda(celda_cargada) as Dictionary).is_empty())
	_check("C3: se escribieron los voxeles de la pieza",
		terreno.tool.escrituras > 0, "escrituras=%d" % terreno.tool.escrituras)

	# ── D. La rejilla NO se calcula sobre chunks (acotado) ────────────
	mundo.reiniciar_contadores()
	var consultas_antes: int = mundo.consultas
	var res_preview: Dictionary = mgr.preview(celda_cargada)
	var consultas_preview: int = mundo.consultas - consultas_antes
	var celdas_pieza: int = int((res_preview.get("celdas", []) as Array).size())
	_check("D1: el preview devuelve las celdas de la pieza",
		celdas_pieza > 0, "celdas=%d" % celdas_pieza)
	_check("D2: la rejilla no se calcula sobre chunks (consultas acotadas por la huella de la pieza)",
		consultas_preview <= maxi(4, celdas_pieza * 4),
		"consultas=%d celdas=%d" % [consultas_preview, celdas_pieza])

	# ── E. Modo LOGICO (sin terreno): no se bloquea nada ───────────────
	var mundo_logico := MundoLogico.new()
	var mgr_logico = MGR.new()
	mgr_logico.name = "BuildManagerLogico"
	root.add_child(mgr_logico)
	mgr_logico.conectar_mundo(mundo_logico)
	mgr_logico.conectar_zonas(ZONE_REG.new())
	mgr_logico.set_limite_mundo(AABB())
	mgr_logico.conectar_inventario(inv)
	await process_frame
	mgr_logico.registrar_receta(receta_base)
	mgr_logico.seleccionar_pieza(receta_base)
	var res_logico: Dictionary = mgr_logico.confirmar_colocacion(Vector3i(50, 1, 50))
	_check("E1: en modo LOGICO (sin terreno) se coloca igual que siempre",
		bool(res_logico.get("ok", false)), str(_motivos(res_logico)))
	_check("E2: en modo LOGICO chunk_cargada = true (no bloquea nada)",
		mundo_logico.chunk_cargada(Vector3i(50, 1, 50)))
	_check("E3: en modo LOGICO celdas_sin_chunk devuelve la lista vacia",
		(mundo_logico.celdas_sin_chunk([Vector3i(50, 1, 50)]) as Array).is_empty())

	# ── F. Copiar y mover: mismo guard (no se tocan chunks sin cargar) ──
	var res_copia: Dictionary = mgr.copiar_pieza(celda_cargada, celda_vacia)
	_check("F1: copiar a un chunk SIN cargar -> motivo TERRENO_NO_CARGADO",
		(_motivos(res_copia) as Array).has(TIPO.Motivo.TERRENO_NO_CARGADO), str(_motivos(res_copia)))
	_check("F2: la copia NO se registro (no queda a medias)",
		(mgr.pieza_en_celda(celda_vacia) as Dictionary).is_empty())
	var res_mover: Dictionary = mgr.mover_pieza(celda_cargada, celda_vacia)
	_check("F3: mover a un chunk SIN cargar -> motivo TERRENO_NO_CARGADO",
		(_motivos(res_mover) as Array).has(TIPO.Motivo.TERRENO_NO_CARGADO), str(_motivos(res_mover)))
	_check("F4: al no poder mover, la pieza ORIGEN sigue en su sitio",
		not (mgr.pieza_en_celda(celda_cargada) as Dictionary).is_empty())

	# ── G. Anti-falso-verde: el minimo de checks ───────────────────────
	_check("G1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
