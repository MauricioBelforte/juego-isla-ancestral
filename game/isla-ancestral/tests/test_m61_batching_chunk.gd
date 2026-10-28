# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M61 / item L289 del 05-Checklist ("Usar meshes combinados por chunk (M07)").
#
# El item afirmaba que el terreno voxel combina la geometria POR CHUNK. Hasta hoy
# eso era una afirmacion sin medir: el bloque `batching` de
# `data/performance/budgets.json` decia "el terreno voxel ya es por chunks: M07"
# y ningun gate lo contrastaba contra el mesher real.
#
# Este suite mide el mecanismo en CPU pura (determinista, headless, sin GPU):
#   A. la norma declarada coincide con la tabla canonica del gate;
#   B. el chunk declarado es el `mesh_block_size` REAL del VoxelTerrain;
#   C. un chunk 16^3 LLENO (4096 voxeles) sale en UN solo ArrayMesh con 6144
#      verts (solo la cascara expuesta), contra 98304 verts si se emitiera un
#      cubo por voxel -> la combinacion por chunk es 16x;
#   D. la regla del padding: el mesher exige 1 voxel de margen; un voxel en el
#      borde devuelve null (trampa medida, ver doc 12 del modulo);
#   E. control negativo: un buffer vacio no produce ninguna superficie.
#
# Guardia de 3 capas (skill §2): marcadores `_fin("X")` por bloque + piso
# `CHECKS_MINIMOS` MEDIDO + `_resumen()` en un `call_deferred` SEPARADO, para
# que un SCRIPT ERROR que aborte `_correr()` no deje el SceneTree colgado.
#
# Ejecutar:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m61_batching_chunk.gd
#
# Exit code: 0 = verde medido | 1 = fallos.

extends SceneTree

const MODULO := "M61 batching por chunk"
const RUTA_BUDGETS := "res://data/performance/budgets.json"
const RUTA_PRODUCCION := "res://scripts/main_island.gd"
const VB := preload("res://scripts/performance/validate_budget.gd")

## Bloques esperados: si uno no cierra, `_resumen()` lo nombra.
const BLOQUES := ["A", "B", "C", "D", "E"]

## Piso MEDIDO en verde (no estimado): la corrida real publica 26 checks, asi que
## 24 deja 2 de margen y cualquier aborto parcial que pierda 3+ checks lo delata.
const CHECKS_MINIMOS := 24

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _cerrado := false


func _init() -> void:
	# Dos diferidas SEPARADAS: si `_correr()` aborta por un SCRIPT ERROR, la
	# cola diferida sigue y `_resumen()` corre igual (nombra el bloque y sale 1).
	call_deferred("_correr")
	call_deferred("_resumen")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" - " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" - " + detalle) if detalle != "" else ""])


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _leer(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(v) != TYPE_DICTIONARY:
		return {}
	return v as Dictionary


## Compara dos valores de la norma. JSON.parse_string devuelve TODO numero como
## float (skill trampa 16), asi que comparar por str() da "16.0" != "16".
func _mismo(a: Variant, b: Variant) -> bool:
	var na := (typeof(a) == TYPE_INT or typeof(a) == TYPE_FLOAT)
	var nb := (typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT)
	if na and nb:
		return is_equal_approx(float(a), float(b))
	return str(a) == str(b)


## Construye una libreria blocky con aire (0) + cubo (1), igual que main_island.
func _libreria() -> VoxelBlockyLibrary:
	var lib := VoxelBlockyLibrary.new()
	var aire := VoxelBlockyModelEmpty.new()
	aire.set_name("air")
	lib.add_model(aire)
	var cubo := VoxelBlockyModelCube.new()
	cubo.set_name("tierra")
	lib.add_model(cubo)
	lib.bake()
	return lib


## Buffer de (lado+2)^3 con el bloque de `lado` lleno en el interior [1..lado].
## El mesher blocky exige 1 voxel de padding por lado (regla medida, bloque D).
func _buffer_chunk_lleno(lado: int) -> VoxelBuffer:
	var n := lado + 2
	var b := VoxelBuffer.new()
	b.create(n, n, n)
	for x in range(1, lado + 1):
		for y in range(1, lado + 1):
			for z in range(1, lado + 1):
				b.set_voxel(1, x, y, z, VoxelBuffer.CHANNEL_TYPE)
	return b


## Devuelve [superficies, verts] del primer mesh; [-1, -1] si build_mesh da null.
func _medir(mesher: VoxelMesherBlocky, buf: VoxelBuffer) -> Array:
	var m = mesher.build_mesh(buf, [])
	if m == null:
		return [-1, -1]
	var sup: int = m.get_surface_count()
	if sup <= 0:
		return [0, 0]
	var arr: Array = m.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	return [sup, verts.size()]


func _correr() -> void:
	print("=== %s ===" % MODULO)

	var data := _leer(RUTA_BUDGETS)
	_check("budgets.json existe y parsea", not data.is_empty())
	var batching: Dictionary = data.get("batching", {})
	_check("bloque batching presente", not batching.is_empty())
	if batching.is_empty():
		_fin("A")
		_fin("B")
		_fin("C")
		_fin("D")
		_fin("E")
		return

	# ── A. la norma declarada == la tabla canonica del gate ──────────────────
	var canon: Dictionary = VB.TECNICAS_CANONICAS.get("batching", {})
	_check("el gate declara canon para batching", not canon.is_empty())
	for clave in ["meshes_combinados_por_chunk", "chunk_mesh_block_size", "verts_cascara_chunk"]:
		_check("canon declara batching.%s" % clave, canon.has(clave))
		_check("budgets declara batching.%s" % clave, batching.has(clave))
		if canon.has(clave) and batching.has(clave):
			_check("batching.%s coincide con el canon" % clave,
				_mismo(batching[clave], canon[clave]),
				"budgets=%s / canon=%s" % [str(batching[clave]), str(canon[clave])])
	_check("meshes_combinados_por_chunk == true",
		bool(batching.get("meshes_combinados_por_chunk", false)))
	_fin("A")

	# ── B. el chunk declarado es el del MOTOR (medido, no asumido) ───────────
	var lado := int(batching.get("chunk_mesh_block_size", 0))
	_check("chunk_mesh_block_size >= 2", lado >= 2, "declarado=%d" % lado)
	_check("VoxelTerrain existe (addon zylann.voxel cargado)",
		ClassDB.class_exists("VoxelTerrain"))
	var real := -1
	if ClassDB.class_exists("VoxelTerrain"):
		var t: Object = ClassDB.instantiate("VoxelTerrain")
		if t != null:
			real = int(t.get("mesh_block_size"))
			t.free()
	_check("chunk_mesh_block_size == VoxelTerrain.mesh_block_size medido",
		real == lado, "norma=%d / motor=%d" % [lado, real])
	_check("produccion usa VoxelMesherBlocky (main_island.gd)",
		FileAccess.file_exists(RUTA_PRODUCCION)
		and FileAccess.get_file_as_string(RUTA_PRODUCCION).contains("VoxelMesherBlocky.new()"))
	_fin("B")

	# ── C. un chunk LLENO sale en UN mesh: la combinacion por chunk ─────────
	if not ClassDB.class_exists("VoxelMesherBlocky") or lado < 2:
		_check("VoxelMesherBlocky disponible para medir", false)
		_fin("C")
		_fin("D")
		_fin("E")
		return
	var mesher := VoxelMesherBlocky.new()
	mesher.library = _libreria()
	_check("mesher.library asignada", mesher.library != null)

	var lleno := _buffer_chunk_lleno(lado)
	var r := _medir(mesher, lleno)
	var sup_lleno := int(r[0])
	var verts_lleno := int(r[1])
	var voxeles := lado * lado * lado
	var naive := voxeles * 24  # 6 caras * 4 verts por voxel, sin combinar
	print("  [med] chunk %d^3 = %d voxeles -> superficies=%d verts=%d (naive por voxel=%d)" % [
		lado, voxeles, sup_lleno, verts_lleno, naive])
	_check("el chunk lleno sale en UN solo mesh", sup_lleno == 1, "superficies=%d" % sup_lleno)
	_check("verts de la cascara == verts_cascara_chunk declarado",
		verts_lleno == int(batching.get("verts_cascara_chunk", -1)),
		"medido=%d / norma=%d" % [verts_lleno, int(batching.get("verts_cascara_chunk", -1))])
	_check("la cascara se combina: verts << emitir un cubo por voxel",
		verts_lleno > 0 and verts_lleno < naive,
		"verts=%d / naive por voxel=%d" % [verts_lleno, naive])
	var ratio := float(naive) / float(max(1, verts_lleno))
	_check("combinar por chunk ahorra >= 8x verts", ratio >= 8.0, "ratio=%.2fx" % ratio)
	_fin("C")

	# ── D. regla del padding (trampa medida) ────────────────────────────────
	var aislados := VoxelBuffer.new()
	aislados.create(lado + 2, lado + 2, lado + 2)
	var pos: Array = [[2, 2, 2], [6, 2, 2], [10, 2, 2], [14, 2, 2],
		[2, 10, 2], [6, 10, 2], [10, 10, 2], [14, 10, 2]]
	for p in pos:
		aislados.set_voxel(1, int(p[0]), int(p[1]), int(p[2]), VoxelBuffer.CHANNEL_TYPE)
	var r2 := _medir(mesher, aislados)
	_check("8 voxeles aislados interiores -> UN mesh", int(r2[0]) == 1, "superficies=%d" % int(r2[0]))
	_check("8 cubos aislados -> 192 verts (8 x 24)", int(r2[1]) == 192, "verts=%d" % int(r2[1]))

	# Voxel pegado al borde de un buffer SIN padding -> build_mesh devuelve null.
	var sin_padding := VoxelBuffer.new()
	sin_padding.create(lado, lado, lado)
	sin_padding.set_voxel(1, lado - 1, int(floor(lado * 0.5)), int(floor(lado * 0.5)), VoxelBuffer.CHANNEL_TYPE)
	var r3 := _medir(mesher, sin_padding)
	_check("voxel en el borde sin padding -> build_mesh null (exige 1 voxel de margen)",
		int(r3[0]) == -1, "superficies=%d" % int(r3[0]))
	_fin("D")

	# ── E. control negativo ─────────────────────────────────────────────────
	var vacio := VoxelBuffer.new()
	vacio.create(lado + 2, lado + 2, lado + 2)
	var r4 := _medir(mesher, vacio)
	# Un buffer sin nada que dibujar devuelve null (medido), no un mesh de 0
	# superficies. Lo que importa es que NO produzca geometria: el bloque C ya
	# exige que el caso con voxeles SI devuelva un mesh, asi que este control no
	# puede pasar con un mesher roto que siempre devuelva null.
	_check("control negativo: buffer vacio no produce geometria", int(r4[0]) <= 0,
		"superficies=%d" % int(r4[0]))
	_fin("E")


## Cierre por cola diferida: corre aunque `_correr()` haya abortado.
func _resumen() -> void:
	if _cerrado:
		return
	_cerrado = true
	for nombre in BLOQUES:
		if not _vistos.has(nombre):
			_check("el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % nombre, false)
	if _checks < CHECKS_MINIMOS:
		_check("solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS], false)
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO - salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK - el terreno combina la geometria por chunk (medido)" % MODULO)
		quit(0)
