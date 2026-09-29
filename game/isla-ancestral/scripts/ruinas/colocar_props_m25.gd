# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M25: Colocación de props .glb del módulo sobre el terreno REAL.
# Reglas de oro (AGENTS.md §"Posicionamiento OBLIGATORIO" + GUIA-GODOT 07 §10.15/§10.16):
#   - SIEMPRE sobre TerrainLocator.get_height(x, z) + 1. NUNCA z hardcodeado.
#   - Piezas montadas (E-80, ej. antorcha_pared M166): llevan z_min POSITIVO en el glb
#     (la pieza vive a la altura de su montaje, no del suelo). Para que su cara inferior
#     quede a la altura de montaje declarada, el origen del glb se corre -z_min.
#
# Fix V-3 (Log 1035 / BUG-053): antorcha_pared (z_min +0.295 ALTA / +0.340 MEDIA-BAJA)
# flotaba ~30 cm si se colocaba con el flujo estándar de props de suelo.
# Uso:
#   var placer := ColocarPropsM25.new()
#   placer.add_child(arbol)  # o usar el nodo como es en escena
#   placer.colocar_prop("res://assets/3d/media/25-Ruinas-Templos_antorcha_pared.glb", 12.0, -4.0, "montado_e80", 0.30)
#
class_name ColocarPropsM25
extends Node3D

## Altura de referencia del suelo SI no hay TerrainLocator (fallback documentado).
const Z_SUELO_FALLBACK := 1.0

## E-80: altura de montaje por defecto de la antorcha de pared sobre la referencia.
const ALTURA_MONTAJE_ANTORCHA := 0.30

var _colocados: Array[Node3D] = []

## Devuelve la referencia de suelo: TerrainLocator.get_height(x,z)+1 (regla de oro)
## o Z_SUELO_FALLBACK si el autoload no existe (escenas de preview/test).
func obtener_z_base(x: int, z: int) -> float:
	var locator := get_node_or_null("/root/TerrainLocator")
	if locator and locator.has_method("get_height"):
		var h: int = locator.get_height(x, z)
		if h >= 0:
			return float(h) + 1.0
	return Z_SUELO_FALLBACK

## z_min del glb en estado de reposo (mínimo z de los vértices de todos sus meshes),
## si la API de superficies de la versión de Godot lo permite. Si no (Godot 4.7
## eliminó get_mesh_array), devuelve 0.0 y el llamador debe pasar
## `z_min_referencia` (dato medido con scripts/auditar_flotacion_glb.py, Log 1035:
## antorcha_pared alta 0.295 · media/baja 0.340).
func medir_z_min(res: PackedScene) -> float:
	var inst := res.instantiate()
	var z_min := 0.0
	var encontrado := false
	for c in inst.get_children():
		var mesh := (c as MeshInstance3D).mesh as ArrayMesh if c is MeshInstance3D else null
		if mesh == null:
			continue
		for s in range(mesh.get_surface_count()):
			var arrays: Array = []
			if mesh.has_method("surface_get_arrays"):
				arrays = mesh.surface_get_arrays(s)
			elif mesh.has_method("get_mesh_array"):
				arrays = [mesh.get_mesh_array(s, Mesh.ARRAY_VERTEX)]
			for a in arrays:
				if a is PackedVector3Array:
					for v in a:
						z_min = minf(z_min, v.z)
					encontrado = true
	inst.free()  # nunca entró al árbol: liberar directamente
	if not encontrado:
		return 0.0
	return z_min

## Coloca un prop del módulo M25.
## modo: "suelo" (glb origin en la referencia; la librería assets/3d va centrada en
## origen, z_min negativo = embebido por diseño) o "montado_e80" (pieza montada: la
## cara inferior queda a `altura_montaje` sobre la referencia, compensando el z_min;
## si la medición runtime no está disponible, usa `z_min_referencia` — dato del
## audit scripts/auditar_flotacion_glb.py, Log 1035).
## Devuelve el nodo colocado (null si no se pudo cargar).
func colocar_prop(ruta_glb: String, x: float, z: float, modo: String = "suelo", altura_montaje: float = 0.0, z_min_referencia: float = 0.0) -> Node3D:
	var res: PackedScene = load(ruta_glb)
	if res == null:
		push_error("[M25] No se pudo cargar %s" % ruta_glb)
		return null
	var inst: Node3D = res.instantiate()
	var z_base := obtener_z_base(int(x), int(z))
	if modo == "montado_e80":
		var z_min := medir_z_min(res)
		if z_min <= 0.0 and z_min_referencia > 0.0:
			z_min = z_min_referencia
		inst.position = Vector3(x, z_base + altura_montaje - z_min, z)
		print("[M25] %s E-80: z_min=%.3f → cara inferior en %+.3f sobre la referencia (z_base %.2f)" % [ruta_glb.get_file(), z_min, altura_montaje, z_base])
	else:
		inst.position = Vector3(x, z_base, z)
		print("[M25] %s suelo: referencia %.2f (z_base)" % [ruta_glb.get_file(), z_base])
	add_child(inst)
	_colocados.append(inst)
	return inst

## Atajo documentado: antorcha de pared (V-3, BUG-053).
## z_min_referencia por variante (Log 1035): media/baja 0.340 · alta 0.295.
func colocar_antorcha_pared(ruta_glb: String, x: float, z: float, altura_montaje: float = ALTURA_MONTAJE_ANTORCHA, z_min_referencia: float = 0.34) -> Node3D:
	return colocar_prop(ruta_glb, x, z, "montado_e80", altura_montaje, z_min_referencia)
