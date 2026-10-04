# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — BuildManager (autoload `Construccion`).
#
# Sesion de construccion: entrada/salida de modo, seleccion de pieza, validacion
# (delegada a ConstruccionValidator, unica autoridad), colocacion/demolicion,
# undo/redo por deltas y PERSISTENCIA por duck-typing.
#
# ── Contrato de persistencia (M60 iter. 3 / M59) ────────────────────────
# `scripts/datos/buildings_save_provider.gd` busca en el arbol (autoloads
# incluidos) una fuente que exponga:
#
#     obtener_estructuras() -> Array                 (obligatorio)
#     restaurar_estructuras(lista: Array) -> void     (para cargar)
#
# y la codifica con `EstructurasCodec` en la forma canonica
#     { id, tipo, pos[3] int, rot_y, planta, variante }
#
# Este manager expone AMBOS metodos -> **cierra BUG-057** (delegado a M17) en
# cuanto el nucleo exista. No hace falta registrar nada: el provider re-evalua
# la fuente en cada llamada.
#
# ── Nota de diseno ──────────────────────────────────────────────────────
# NO usa `class_name`: es un autoload y su nombre global (`Construccion`) ya
# esta reservado en project.godot. Ademas evita depender del cache de clases
# globales en headless.
#
# Las dependencias externas son INYECTABLES para poder testear en headless:
#   * mundo     -> `conectar_mundo(ConstruccionMundo)` (M08)
#   * inventario-> `conectar_inventario(obj)` (M14); por defecto `/root/Inventario`
#   * zonas     -> `zonas()` / `registrar_zona(aabb, permiso)`

extends Node

## Carpeta de recetas .tres (catalogo data-driven, RF12).
const DIR_PIEZAS: String = "res://data/construccion/piezas"

# ── Senales (la capa UI/M18/M64 escucha; aqui no hay logica de UI) ──────
signal obra_activa(activa: bool)
signal pieza_colocada(receta_id: StringName, celda: Vector3i)
signal pieza_demolida(receta_id: StringName, celda: Vector3i)
signal zona_rechazada(celda: Vector3i, motivo: String)
signal estructuras_restauradas(cantidad: int)
## M64: la navmesh debe recalcularse en las celdas que cambiaron (bloque K).
signal navmesh_delta(celdas: Array)

# ── Estado de sesion ────────────────────────────────────────────────────
var _en_modo: bool = false
var _modo: int = ConstruccionTipos.Modo.CONSTRUCCION
var _receta: PlacementRule = null
var _rotacion: int = 0        # pasos de 90 grados (0..3)
var _planta: int = 0

# ── Estado del mundo construido ─────────────────────────────────────────
## Ancla (clave de celda) -> estructura canonica del save.
var _estructuras: Dictionary = {}
## Celda ocupada (clave) -> ancla (clave). Indice O(1) de ocupacion.
var _ocupacion: Dictionary = {}

# ── Colaboradores ───────────────────────────────────────────────────────
var _zonas: ZoneRegistry = ZoneRegistry.new()
var _historial: BuildHistory = BuildHistory.new()
var _mundo: ConstruccionMundo = ConstruccionMundo.new()
var _catalogo: Dictionary = {}          # id (StringName) -> PlacementRule
var _catalogo_db: BuildCatalogDB = BuildCatalogDB.new()
var _preview: BuildPreview = BuildPreview.new()

var _f_puede_pagar: Callable = Callable()
var _f_descontar: Callable = Callable()
var _f_devolver: Callable = Callable()

# ── Ciclo de vida ───────────────────────────────────────────────────────

func _ready() -> void:
	var n: int = _cargar_catalogo()
	_resolver_inventario()
	print("[M17] Construccion listo (catalogo=%d, terreno=%s, inventario=%s)" % [
		n, str(_mundo.tiene_terreno()), str(_f_puede_pagar.is_valid())])

## Carga las recetas .tres de `DIR_PIEZAS` via `BuildCatalogDB` (recursivo, por
## familia). Devuelve cuantas registro. Tolerante: si la carpeta no existe o un
## archivo no es una PlacementRule, se omite (el conteo real lo afirma la suite).
func _cargar_catalogo() -> int:
	var n: int = _catalogo_db.cargar(DIR_PIEZAS)
	if n == 0:
		push_warning("[M17] catalogo vacio en %s" % DIR_PIEZAS)
	for id in _catalogo_db.ids():
		_catalogo[id] = _catalogo_db.receta(id)
	return n

## El catalogo data-driven (12 familias). Es la fuente; `_catalogo` es su espejo.
func catalogo_db() -> BuildCatalogDB:
	return _catalogo_db

## Registra (o reemplaza) una receta en el catalogo Y en su espejo.
func _espejo(r: PlacementRule) -> void:
	_catalogo[r.id] = r

## Resuelve el inventario real (M14) por duck-typing. Tolerante si no esta.
func _resolver_inventario() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return
	conectar_inventario(inv)

# ── Inyeccion (tests) ───────────────────────────────────────────────────

## Conecta un adaptador de mundo (M08). Acepta null.
func conectar_mundo(m: ConstruccionMundo) -> void:
	_mundo = m if m != null else ConstruccionMundo.new()

func mundo() -> ConstruccionMundo:
	return _mundo

## Conecta un inventario (M14) por duck-typing. Espera:
##   count_item(item_id) -> int ; remover_items(Dictionary) -> bool ;
##   agregar_items(Dictionary) -> bool
func conectar_inventario(inv) -> void:
	if inv == null:
		_f_puede_pagar = Callable()
		_f_descontar = Callable()
		_f_devolver = Callable()
		return
	_f_puede_pagar = func(costo: Dictionary) -> bool:
		for k in costo.keys():
			if int(inv.count_item(String(k))) < int(costo[k]):
				return false
		return true
	_f_descontar = func(costo: Dictionary) -> bool:
		if costo.is_empty():
			return true
		return bool(inv.remover_items(costo))
	_f_devolver = func(d: Dictionary) -> bool:
		if d.is_empty():
			return true
		return bool(inv.agregar_items(d))

## Conecta un registro de zonas (o uno vacio si es null).
func conectar_zonas(z: ZoneRegistry) -> void:
	_zonas = z if z != null else ZoneRegistry.new()

func zonas() -> ZoneRegistry:
	return _zonas

## Registra una zona (delega en el ZoneRegistry).
func registrar_zona(aabb: AABB, permiso: int) -> void:
	_zonas.registrar_zona(aabb, permiso)

## Conecta un historial (tests: uno con limite pequeno).
func conectar_historial(h: BuildHistory) -> void:
	_historial = h if h != null else BuildHistory.new()

func historial() -> BuildHistory:
	return _historial

# ── Catalogo ────────────────────────────────────────────────────────────

## Registra (o reemplaza) una receta en el catalogo.
func registrar_receta(r: PlacementRule) -> bool:
	if r == null or not r.es_valida():
		return false
	_catalogo[r.id] = r
	_catalogo_db.registrar(r)
	return true

## Registra varias recetas. Devuelve cuantas se aceptaron.
func registrar_recetas(lista: Array) -> int:
	var n: int = 0
	for r in lista:
		if registrar_receta(r):
			n += 1
	return n

func receta(id: StringName) -> PlacementRule:
	return _catalogo.get(id, null)

func catalogo() -> Dictionary:
	return _catalogo.duplicate()

# ── Preview / fantasma (iter. 2) ────────────────────────────────────────

## Evalua la pieza seleccionada en `celda` para el fantasma. Devuelve el
## resultado de `BuildPreview` (ok/valido/motivos/color/celdas/costo).
## El preview NUNCA cobra ni escribe en el mundo (bloque I).
func preview(celda: Vector3i) -> Dictionary:
	return _preview.evaluar(self, celda)

## Evalua una receta arbitraria (QA).
func preview_receta(r: PlacementRule, celda: Vector3i, rotacion: int) -> Dictionary:
	return _preview.evaluar_receta(self, r, celda, rotacion)

## El evaluador de fantasma en uso (para inspeccionar la cache en tests).
func preview_actual() -> BuildPreview:
	return _preview

## Recetas filtradas por modo (construccion vs decoracion). RF2.
func piezas_de_modo(modo: int) -> Array:
	var out: Array = []
	for r in _catalogo.values():
		if (r as PlacementRule).es_mueble == (modo == ConstruccionTipos.Modo.DECORACION):
			out.append(r)
	return out

# ── Sesion ──────────────────────────────────────────────────────────────

func entrar_modo(modo: int = ConstruccionTipos.Modo.CONSTRUCCION) -> void:
	_modo = modo
	_en_modo = true
	obra_activa.emit(true)

func salir_modo() -> void:
	_en_modo = false
	_receta = null
	obra_activa.emit(false)

func esta_en_modo() -> bool:
	return _en_modo

func modo_actual() -> int:
	return _modo

func seleccionar_pieza(r: PlacementRule) -> bool:
	if r == null or not r.es_valida():
		return false
	_receta = r
	return true

func receta_actual() -> PlacementRule:
	return _receta

func rotar_paso() -> int:
	_rotacion = posmod(_rotacion + 1, 4)
	return _rotacion

func set_rotacion(paso: int) -> void:
	_rotacion = posmod(paso, 4)

func rotacion_actual() -> int:
	return _rotacion

func set_planta(p: int) -> void:
	_planta = maxi(0, p)

func planta_actual() -> int:
	return _planta

# ── Validacion ──────────────────────────────────────────────────────────

## Contexto para el validador, armado desde el estado real.
func _contexto() -> Dictionary:
	return ConstruccionValidator.contexto(
		Callable(self, "_ctx_ocupada"),
		Callable(self, "_ctx_superficie"),
		Callable(self, "_ctx_npc"),
		_f_puede_pagar,
		Callable(self, "_ctx_permiso"),
		Callable(self, "_ctx_piezas_en_zona"))

## Valida la receta seleccionada en `celda` con la rotacion actual.
func validar(celda: Vector3i) -> Dictionary:
	if _receta == null:
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.RECETA_INVALIDA], ["no hay pieza seleccionada"], [])
	var res: Dictionary = ConstruccionValidator.validar(_receta, celda, _rotacion, _contexto())
	var detalle: Array = res.get("detalle", [])
	if not _f_puede_pagar.is_valid():
		detalle.append("inventario: no conectado -> recursos NO verificados")
	res["detalle"] = detalle
	return res

## Valida una receta arbitraria (util para QA y para el fantasma).
func validar_receta(r: PlacementRule, celda: Vector3i, rotacion: int) -> Dictionary:
	return ConstruccionValidator.validar(r, celda, rotacion, _contexto())

func _ctx_ocupada(celda: Vector3i) -> bool:
	return _ocupacion.has(ConstruccionTipos.clave(celda))

func _ctx_superficie(celda: Vector3i) -> StringName:
	var k: String = ConstruccionTipos.clave(celda)
	if _ocupacion.has(k):
		var r: PlacementRule = _receta_de_ancla(String(_ocupacion[k]))
		if r != null:
			return r.superficie_ofrecida
		return &"piso"
	return _mundo.superficie_voxel(celda)

func _ctx_npc(celda: Vector3i) -> bool:
	return _mundo.hay_npc_en(celda)

func _ctx_permiso(celda: Vector3i) -> int:
	return _zonas.zona_de(celda)

func _ctx_piezas_en_zona(r: PlacementRule, celda: Vector3i) -> int:
	var zid: int = _zonas.id_zona_de(celda)
	var n: int = 0
	for ancla in _estructuras.keys():
		var e: Dictionary = _estructuras[ancla]
		if StringName(String(e.get("tipo", ""))) != r.id:
			continue
		var c: Vector3i = _celda_de_ancla(String(ancla))
		if _zonas.id_zona_de(c) == zid:
			n += 1
	return n

# ── Acciones ────────────────────────────────────────────────────────────

## Confirma la colocacion de la receta seleccionada en `celda`.
## Orden (03-Diseno §2): validar -> descontar (M14) -> escribir (M08) ->
## registrar delta (undo) -> emitir senal.
func confirmar_colocacion(celda: Vector3i) -> Dictionary:
	var res: Dictionary = validar(celda)
	if not bool(res.get("ok", false)):
		zona_rechazada.emit(celda, String(res.get("texto", "invalido")))
		return res
	var r: PlacementRule = _receta
	var celdas: Array[Vector3i] = r.celdas(celda, _rotacion)

	# Descuento real (solo al confirmar). El preview nunca cobra.
	if _f_descontar.is_valid() and not bool(_f_descontar.call(r.costo)):
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES],
			["descuento fallo al confirmar (carrera con otra operacion)"], celdas)

	# Escritura en el mundo (M08). Sin terreno -> 0 y se reporta.
	var escritos: int = _mundo.escribir_voxel(celdas, r.bloque)

	_alta_estructura(celda, r, _rotacion)
	_historial.registrar({
		"tipo": BuildHistory.TIPO_COLOCAR,
		"receta_id": r.id,
		"celda": celda,
		"rotacion": _rotacion,
		"celdas": celdas.duplicate(),
		"costo": r.costo.duplicate(),
		"bloque": r.bloque,
	})
	pieza_colocada.emit(r.id, celda)
	navmesh_delta.emit(celdas.duplicate())
	_preview.limpiar()

	return {
		"ok": true,
		"motivos": [],
		"detalle": ["colocada %s en %s (%d celdas, %d voxeles)" % [
			r.id, str(celda), celdas.size(), escritos]],
		"celdas": celdas,
		"texto": "",
		"voxeles_escritos": escritos,
		"mundo_conectado": _mundo.tiene_terreno(),
		"descontado": _f_descontar.is_valid(),
	}

## Demuele la pieza que ocupa `celda` y devuelve parte de su costo.
func demolir_pieza(celda: Vector3i) -> Dictionary:
	var ancla: String = String(_ocupacion.get(ConstruccionTipos.clave(celda), ""))
	if ancla == "":
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.NO_HAY_PIEZA], ["nada que demoler en %s" % str(celda)], [])
	var e: Dictionary = _estructuras[ancla]
	var r: PlacementRule = _receta_de_ancla(ancla)
	if r != null and not r.deconstruible:
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.NO_DECONSTRUIBLE],
			["%s no es deconstruible" % String(e.get("tipo", ""))], [])

	var celdas: Array = _celdas_de_estructura(e, r)
	var borrados: int = _mundo.borrar_voxel(celdas)
	var devuelto: Dictionary = r.devolucion_por_item() if r != null else {}
	if _f_devolver.is_valid() and not devuelto.is_empty():
		_f_devolver.call(devuelto)

	var c_ancla: Vector3i = ConstruccionTipos.celda_de_clave(ancla)
	_baja_estructura(ancla)
	_historial.registrar({
		"tipo": BuildHistory.TIPO_DEMOLER,
		"receta_id": StringName(String(e.get("tipo", ""))),
		"celda": c_ancla,
		"rotacion": _rotacion_de_estructura(e),
		"celdas": celdas.duplicate(),
		"costo": (r.costo.duplicate() if r != null else {}),
		"devuelto": devuelto.duplicate(),
		"bloque": (r.bloque if r != null else 0),
		"estructura": e.duplicate(true),
	})
	pieza_demolida.emit(StringName(String(e.get("tipo", ""))), c_ancla)
	navmesh_delta.emit(celdas.duplicate())
	_preview.limpiar()

	return {
		"ok": true,
		"motivos": [],
		"detalle": ["demolida %s en %s (devuelto %s)" % [String(e.get("tipo", "")), str(c_ancla), str(devuelto)]],
		"celdas": celdas,
		"texto": "",
		"voxeles_borrados": borrados,
		"devuelto": devuelto,
	}

## Deshace la ultima accion. Devuelve {ok, detalle}.
func undo() -> Dictionary:
	var d: Dictionary = _historial.undo_ultimo()
	if d.is_empty():
		return {"ok": false, "detalle": ["nada que deshacer"], "motivos": [], "texto": ""}
	return _invertir(d, true)

## Rehace la ultima accion deshecha. Devuelve {ok, detalle}.
func redo() -> Dictionary:
	var d: Dictionary = _historial.redo_siguiente()
	if d.is_empty():
		return {"ok": false, "detalle": ["nada que rehacer"], "motivos": [], "texto": ""}
	return _invertir(d, false)

## Mueve una pieza: desocupa el origen, valida el destino y la reubica SIN
## re-cobrar recursos (02-Analisis §1.8).
func mover_pieza(origen: Vector3i, destino: Vector3i) -> Dictionary:
	var ancla: String = String(_ocupacion.get(ConstruccionTipos.clave(origen), ""))
	if ancla == "":
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.NO_HAY_PIEZA], ["nada que mover en %s" % str(origen)], [])
	var e: Dictionary = _estructuras[ancla]
	var r: PlacementRule = _receta_de_ancla(ancla)
	if r == null:
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.RECETA_INVALIDA], ["la pieza no esta en el catalogo"], [])
	var paso: int = _rotacion_de_estructura(e)
	var c_ancla: Vector3i = ConstruccionTipos.celda_de_clave(ancla)

	# 1) desocupar el origen para que la validacion del destino no se autobloquee
	var celdas_viejas: Array = _celdas_de_estructura(e, r)
	_baja_estructura(ancla)
	# 2) validar el destino
	var res: Dictionary = validar_receta(r, destino, paso)
	if not bool(res.get("ok", false)):
		# rollback: volver a ocupar el origen
		_alta_estructura(c_ancla, r, paso, e)
		zona_rechazada.emit(destino, String(res.get("texto", "invalido")))
		return res
	# 3) reubicar
	var celdas_nuevas: Array[Vector3i] = r.celdas(destino, paso)
	_mundo.borrar_voxel(celdas_viejas)
	_mundo.escribir_voxel(celdas_nuevas, r.bloque)
	_alta_estructura(destino, r, paso, e, "", true)
	_historial.registrar({
		"tipo": BuildHistory.TIPO_MOVER,
		"receta_id": r.id,
		"celda": destino,
		"celda_origen": c_ancla,
		"rotacion": paso,
		"celdas": celdas_nuevas.duplicate(),
		"celdas_origen": celdas_viejas.duplicate(),
		"costo": {},
		"bloque": r.bloque,
	})
	return {
		"ok": true, "motivos": [], "texto": "",
		"detalle": ["movida %s de %s a %s" % [r.id, str(c_ancla), str(destino)]],
		"celdas": celdas_nuevas,
	}

## Pieza (estructura canonica) que ocupa una celda, o {} si esta libre.
func pieza_en_celda(celda: Vector3i) -> Dictionary:
	var ancla: String = String(_ocupacion.get(ConstruccionTipos.clave(celda), ""))
	if ancla == "":
		return {}
	return (_estructuras.get(ancla, {}) as Dictionary).duplicate(true)

func estructuras() -> Array:
	return obtener_estructuras()

func cantidad_estructuras() -> int:
	return _estructuras.size()

# ── Persistencia (contrato M60/M59 por duck-typing) ─────────────────────

## Lista canonica de estructuras para el save. Array NUEVO en cada llamada
## (sin aliasing: el provider lo exige y `auditar_aliasing.gd` lo verifica).
func obtener_estructuras() -> Array:
	var out: Array = []
	for ancla in _estructuras.keys():
		out.append((_estructuras[ancla] as Dictionary).duplicate(true))
	return out

## Restaura las estructuras desde el save. IDEMPOTENTE: limpia el estado actual
## antes de reconstruir (03-Diseno §6, M58).
func restaurar_estructuras(lista: Array) -> void:
	limpiar_estructuras()
	if typeof(lista) != TYPE_ARRAY:
		estructuras_restauradas.emit(0)
		return
	var n: int = 0
	for raw in (lista as Array):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var e: Dictionary = raw
		var pos: Variant = e.get("pos", null)
		if typeof(pos) != TYPE_ARRAY or (pos as Array).size() < 3:
			continue
		var celda := Vector3i(int((pos as Array)[0]), int((pos as Array)[1]), int((pos as Array)[2]))
		var tipo := String(e.get("tipo", ""))
		var paso: int = int(round(float(int(e.get("rot_y", 0))) / 90.0))
		var r: PlacementRule = _catalogo.get(StringName(tipo), null)
		var canon := {
			"id": String(e.get("id", "E_" + ConstruccionTipos.clave(celda))),
			"tipo": tipo,
			"pos": [celda.x, celda.y, celda.z],
			"rot_y": posmod(paso, 4) * 90,
			"planta": maxi(0, int(e.get("planta", 0))),
			"variante": String(e.get("variante", "")),
		}
		_alta_estructura(celda, r, posmod(paso, 4), canon, tipo)
		n += 1
	estructuras_restauradas.emit(n)

## Vacia el estado construido (no toca el mundo voxel: eso es del cargador).
func limpiar_estructuras() -> void:
	_estructuras.clear()
	_ocupacion.clear()
	_historial.limpiar()

# ── Internos de estado ──────────────────────────────────────────────────

func _receta_de_ancla(ancla: String) -> PlacementRule:
	var e: Dictionary = _estructuras.get(ancla, {})
	if e.is_empty():
		return null
	return _catalogo.get(StringName(String(e.get("tipo", ""))), null)

func _rotacion_de_estructura(e: Dictionary) -> int:
	return posmod(int(round(float(int(e.get("rot_y", 0))) / 90.0)), 4)

func _celda_de_ancla(ancla: String) -> Vector3i:
	return ConstruccionTipos.celda_de_clave(ancla)

## Celdas ocupadas por una estructura. Si la receta no esta en el catalogo,
## solo se conoce el ancla (se degrada a 1x1 en vez de fallar).
func _celdas_de_estructura(e: Dictionary, r: PlacementRule) -> Array:
	var pos: Variant = e.get("pos", [0, 0, 0])
	var celda := Vector3i(int((pos as Array)[0]), int((pos as Array)[1]), int((pos as Array)[2]))
	if r != null:
		return r.celdas(celda, _rotacion_de_estructura(e))
	return [celda]

## Da de alta una estructura y marca su ocupacion. `e` permite conservar
## `id`/`tipo`/`planta`/`variante` de una estructura existente (restauracion /
## mover), pero **la posicion SIEMPRE se recalcula desde `celda`**: reutilizar
## el `pos` viejo marcaba la ocupacion en las celdas equivocadas (bug medido en
## la suite: mover dejaba la pieza ocupando el origen).
func _alta_estructura(celda: Vector3i, r: PlacementRule, rotacion: int,
		e: Dictionary = {}, tipo_forzado: String = "", regenerar_id: bool = false) -> void:
	var tipo: String = tipo_forzado
	if tipo == "":
		tipo = String(e.get("tipo", "")) if not e.is_empty() else (String(r.id) if r != null else "")
	var id_final: String = "" if regenerar_id else (String(e.get("id", "")) if not e.is_empty() else "")
	if id_final == "":
		id_final = "E_" + ConstruccionTipos.clave(celda)
	var planta: int = int(e.get("planta", _planta)) if not e.is_empty() else _planta
	var variante: String = String(e.get("variante", "")) if not e.is_empty() else (r.variante if r != null else "")
	var canon: Dictionary = {
		"id": id_final,
		"tipo": tipo,
		"pos": [celda.x, celda.y, celda.z],
		"rot_y": posmod(rotacion, 4) * 90,
		"planta": maxi(0, planta),
		"variante": variante,
	}
	var ancla: String = ConstruccionTipos.clave(celda)
	_estructuras[ancla] = canon
	for c in _celdas_de_estructura(canon, r):
		_ocupacion[ConstruccionTipos.clave(c)] = ancla

## Da de baja una estructura y libera su ocupacion.
func _baja_estructura(ancla: String) -> void:
	if not _estructuras.has(ancla):
		return
	var e: Dictionary = _estructuras[ancla]
	var r: PlacementRule = _receta_de_ancla(ancla)
	for c in _celdas_de_estructura(e, r):
		_ocupacion.erase(ConstruccionTipos.clave(c))
	_estructuras.erase(ancla)

## Aplica la inversa de un delta. `es_undo` = true si venimos de undo().
func _invertir(d: Dictionary, es_undo: bool) -> Dictionary:
	var tipo: String = String(d.get("tipo", ""))
	var celda: Vector3i = d.get("celda", Vector3i.ZERO)
	# undo/redo cambian el mundo -> la cache del fantasma deja de valer y la
	# navmesh (M64) debe recalcular las celdas afectadas.
	_preview.limpiar()
	navmesh_delta.emit((d.get("celdas", []) as Array).duplicate())
	match tipo:
		BuildHistory.TIPO_COLOCAR:
			# deshacer colocar = demoler sin devolucion; rehacer = recolocar
			if es_undo:
				var ancla: String = ConstruccionTipos.clave(celda)
				var r: PlacementRule = _receta_de_ancla(ancla)
				var celdas: Array = d.get("celdas", [])
				_mundo.borrar_voxel(celdas)
				_baja_estructura(ancla)
				if _f_devolver.is_valid():
					_f_devolver.call(d.get("costo", {}))
				return {"ok": true, "motivos": [], "texto": "", "detalle": ["undo: colocacion revertida en %s" % str(celda)]}
			else:
				var r2: PlacementRule = _catalogo.get(StringName(String(d.get("receta_id", ""))), null)
				var celdas2: Array[Vector3i] = (d.get("celdas", []) as Array)
				_mundo.escribir_voxel(celdas2, int(d.get("bloque", 0)))
				if r2 != null:
					_alta_estructura(celda, r2, int(d.get("rotacion", 0)))
					if _f_descontar.is_valid():
						_f_descontar.call(r2.costo)
				return {"ok": true, "motivos": [], "texto": "", "detalle": ["redo: colocacion reaplicada en %s" % str(celda)]}
		BuildHistory.TIPO_DEMOLER:
			# deshacer demoler = recolocar; rehacer = volver a demoler
			var e: Dictionary = d.get("estructura", {})
			if es_undo:
				var r3: PlacementRule = _catalogo.get(StringName(String(d.get("receta_id", ""))), null)
				_alta_estructura(celda, r3, int(d.get("rotacion", 0)), e)
				_mundo.escribir_voxel(d.get("celdas", []), int(d.get("bloque", 0)))
				if _f_descontar.is_valid():
					_f_descontar.call(d.get("devuelto", {}))
				return {"ok": true, "motivos": [], "texto": "", "detalle": ["undo: demolicion revertida en %s" % str(celda)]}
			else:
				_baja_estructura(ConstruccionTipos.clave(celda))
				_mundo.borrar_voxel(d.get("celdas", []))
				if _f_devolver.is_valid():
					_f_devolver.call(d.get("devuelto", {}))
				return {"ok": true, "motivos": [], "texto": "", "detalle": ["redo: demolicion reaplicada en %s" % str(celda)]}
		BuildHistory.TIPO_MOVER:
			var destino: Vector3i = d.get("celda", Vector3i.ZERO)
			var origen: Vector3i = d.get("celda_origen", Vector3i.ZERO)
			# El delta guarda `celda` = destino (donde quedo la pieza) y
			# `celda_origen` = de donde salio. Undo: destino -> origen.
			var desde: Vector3i = destino if es_undo else origen
			var hasta: Vector3i = origen if es_undo else destino
			var ancla2: String = ConstruccionTipos.clave(desde)
			if not _estructuras.has(ancla2):
				return {"ok": false, "motivos": [], "texto": "", "detalle": ["no se pudo invertir mover: %s" % str(desde)]}
			var e2: Dictionary = _estructuras[ancla2]
			var r4: PlacementRule = _receta_de_ancla(ancla2)
			_baja_estructura(ancla2)
			_mundo.escribir_voxel(r4.celdas(hasta, int(d.get("rotacion", 0))) if r4 != null else [hasta], int(d.get("bloque", 0)))
			_alta_estructura(hasta, r4, int(d.get("rotacion", 0)), e2, "", true)
			return {"ok": true, "motivos": [], "texto": "", "detalle": ["%s: movimiento invertido %s -> %s" % [
				("undo" if es_undo else "redo"), str(desde), str(hasta)]],}
	return {"ok": false, "motivos": [], "texto": "", "detalle": ["delta desconocido: %s" % tipo]}
