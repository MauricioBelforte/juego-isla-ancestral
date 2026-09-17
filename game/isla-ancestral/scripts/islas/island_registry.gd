# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — IslandRegistry (autoload "IslandRegistry").
# Catálogo del archipiélago: carga las definiciones `.tres`, garantiza ids
# únicos, orden determinista, cache de anclas (M10) y validación de anclas.
#
# ⚠️ Sin class_name: es autoload (§9.17/§9.41 de la guía).
# El diseño lo llamaba `class_name IslandRegistry extends Node`; la convención
# del proyecto (autoload sin class_name) manda.

extends Node

signal archipielago_cargado(cantidad: int)
signal anclas_validadas(errores: Array)
signal isla_descubierta(id: StringName)

const ISLA_PRINCIPAL_ID := &"aurora"
const RUTA_DEFINICIONES := "res://data/islas/definiciones"
const RUTA_ARCHIPIELAGO := "res://data/islas/archipielago.tres"
## Mínimo de agua entre playas de dos islas (m) — 04-Codigo §7.
const MARGEN_MAR_ENTRE_ISLAS := 64
const SECCION_GUARDADO := "islas"

var _definiciones: Dictionary = {}        # id -> IslandDefinition
var _ids_ordenados: Array[StringName] = [] # orden determinista
var _cache_anclas: Dictionary = {}        # id -> Vector3i (invalidada por anclar())
var _errores_carga: Array[String] = []
var _duplicados: Array[String] = []
var _descubiertas: Dictionary = {}        # id -> true (M59)
var _visitadas: Dictionary = {}           # id -> true (M59)
var _cargado: bool = false
## Hooks de test: permiten apuntar la carga a una carpeta temporal sin tocar
## el dataset real (test de fallback de `.tres` faltante). Vacío = ruta const.
var _test_ruta_defs: String = ""
var _test_ruta_arch: String = ""


func _ruta_defs() -> String:
	return _test_ruta_defs if not _test_ruta_defs.is_empty() else RUTA_DEFINICIONES


func _ruta_arch() -> String:
	return _test_ruta_arch if not _test_ruta_arch.is_empty() else RUTA_ARCHIPIELAGO


func _ready() -> void:
	cargar_definiciones()
	_registrar_proveedor_guardado()


## ── Carga ─────────────────────────────────────────────────

## Carga (o recarga) todas las definiciones. Devuelve un informe:
## {ok, cargadas, esperadas, faltantes, extra, duplicados, errores}.
## NUNCA falla en bloque: una definición rota se descarta y se loguea ERROR;
## la isla principal se garantiza siempre (requisito de fallback).
func cargar_definiciones() -> Dictionary:
	_definiciones.clear()
	_ids_ordenados.clear()
	_cache_anclas.clear()
	_errores_carga.clear()
	_duplicados.clear()
	_cargado = false

	var encontradas: Array[String] = _escanear_definiciones()

	# Orden determinista por id (nunca por orden de lectura del directorio).
	encontradas.sort()
	for id in encontradas:
		var ruta: String = "%s/%s.tres" % [_ruta_defs(), id]
		var rec: Resource = ResourceLoader.load(ruta) if ResourceLoader.exists(ruta) else null
		if rec == null or not (rec is IslandDefinition):
			_errores_carga.append("definición ilegible: %s" % ruta)
			continue
		var def: IslandDefinition = rec as IslandDefinition
		var errores: Array[String] = def.validar()
		if not errores.is_empty():
			_errores_carga.append("%s: %s" % [id, errores[0]])
			continue
		var clave: String = String(def.id)
		if _definiciones.has(def.id):
			# Primera gana (requisito 127): se conserva la de id menor.
			_duplicados.append(clave)
			_errores_carga.append("id duplicado en .tres: %s (se conserva el primero)" % clave)
			continue
		# Reset del estado RUNTIME: Godot cachea el Resource, así que sin esto un
		# reload arrastraría el ancla vieja. Un reload debe dejar las islas SIN
		# anclar hasta que M10 vuelva a llamar anclar().
		def.ancla = Vector3i.ZERO
		def.semilla_isla = 0
		def.ancla_asignada = false
		_definiciones[def.id] = def
		_ids_ordenados.append(def.id)

	var informe: Dictionary = _comparar_con_indice()
	# Fallback: la isla principal SIEMPRE tiene que estar.
	if not _definiciones.has(ISLA_PRINCIPAL_ID):
		_errores_carga.append("FALTA la isla principal (%s): el archipiélago es inválido" % ISLA_PRINCIPAL_ID)
		informe["ok"] = false
	_cargado = true

	for e in _errores_carga:
		push_error("[Islands] %s" % e)
	for f in informe.get("faltantes", []):
		push_error("[Islands] .tres faltante: %s (definido en archipielago.tres)" % f)
	print("[Islands] Registry cargado: %d islas (principal: %s)%s" % [
		_definiciones.size(),
		"OK" if _definiciones.has(ISLA_PRINCIPAL_ID) else "AUSENTE",
		"" if _errores_carga.is_empty() else " · %d errores" % _errores_carga.size(),
	])
	archipielago_cargado.emit(_definiciones.size())
	return informe


## Nombres de archivo (sin extensión) en la carpeta de definiciones.
func _escanear_definiciones() -> Array[String]:
	var out: Array[String] = []
	var dir: DirAccess = _abrir_dir(_ruta_defs())
	if dir == null:
		_errores_carga.append("no existe la carpeta de definiciones: %s" % _ruta_defs())
		return out
	dir.list_dir_begin()
	var nombre: String = dir.get_next()
	while nombre != "":
		if not dir.current_is_dir() and nombre.ends_with(".tres") and not nombre.ends_with(".uid"):
			out.append(nombre.trim_suffix(".tres"))
		nombre = dir.get_next()
	dir.list_dir_end()
	return out


## Abre un directorio resolviendo el caso `user://`.
## En este entorno `DirAccess.open("user://…")` devuelve null y
## `ProjectSettings.globalize_path()` devuelve una ruta RELATIVA, así que hay
## que recomponer una ruta absoluta a partir de `res://`. Ver 04-Codigo §Notas.
func _abrir_dir(ruta: String) -> DirAccess:
	var dir: DirAccess = DirAccess.open(ruta)
	if dir != null:
		return dir
	var abs: String = ProjectSettings.globalize_path(ruta)
	if not abs.is_absolute_path():
		var base: String = ProjectSettings.globalize_path("res://")
		abs = base.path_join(abs.trim_prefix("./"))
	return DirAccess.open(abs)


func _comparar_con_indice() -> Dictionary:
	var base: Dictionary = {"ok": true, "cargadas": _definiciones.size(), "esperadas": 0,
		"faltantes": [], "extra": [], "duplicados": _duplicados.duplicate(), "errores": _errores_carga.duplicate()}
	if not ResourceLoader.exists(_ruta_arch()):
		return base
	var rec: Resource = ResourceLoader.load(_ruta_arch())
	if rec == null or not (rec is Archipielago):
		return base
	var arch: Archipielago = rec as Archipielago
	var cmp: Dictionary = arch.comparar(_ids_ordenados)
	base["esperadas"] = arch.contar_esperadas()
	base["faltantes"] = cmp.get("faltantes", [])
	base["extra"] = cmp.get("extra", [])
	base["ok"] = bool(cmp.get("ok", true)) and _errores_carga.is_empty() \
		and _definiciones.has(ISLA_PRINCIPAL_ID)
	return base


## ── Consultas ─────────────────────────────────────────────

## Definición por id. Id inexistente → null + WARN (requisito 33).
func get_isla(id: StringName) -> IslandDefinition:
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		push_warning("[Islands] isla desconocida: %s" % id)
	return def


func tiene_isla(id: StringName) -> bool:
	return _definiciones.has(id)


## Array ordenado determinista por id (requisito 34).
func todas_las_islas() -> Array[IslandDefinition]:
	var out: Array[IslandDefinition] = []
	for id in _ids_ordenados:
		out.append(_definiciones[id])
	return out


func isla_principal() -> IslandDefinition:
	return _definiciones.get(ISLA_PRINCIPAL_ID, null)


func ids() -> Array[StringName]:
	return _ids_ordenados.duplicate()


func contar() -> int:
	return _definiciones.size()


func errores_carga() -> Array[String]:
	return _errores_carga.duplicate()


func duplicados() -> Array[String]:
	return _duplicados.duplicate()


func esta_cargado() -> bool:
	return _cargado


## ── Anclas (M10) ──────────────────────────────────────────

## Puebla el ancla y la semilla de una isla (lo llama M10). Invalida la cache.
func anclar(id: StringName, ancla: Vector3i, semilla_isla: int) -> bool:
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		push_error("[Islands] anclar(): isla desconocida %s" % id)
		return false
	def.ancla = ancla
	def.semilla_isla = semilla_isla
	def.ancla_asignada = true
	_cache_anclas.erase(id)
	return true


## Ancla en voxels con cache (requisito 36). Sin ancla asignada → Vector3i.ZERO
## y WARN: el llamador puede consultar `tiene_ancla()` para distinguirlo.
func posicion_ancla(id: StringName) -> Vector3i:
	if _cache_anclas.has(id):
		return _cache_anclas[id]
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		push_warning("[Islands] posicion_ancla(): isla desconocida %s" % id)
		return Vector3i.ZERO
	if not def.ancla_asignada:
		push_warning("[Islands] isla %s sin ancla en M10" % id)
		return Vector3i.ZERO
	_cache_anclas[id] = def.ancla
	return def.ancla


func tiene_ancla(id: StringName) -> bool:
	var def: IslandDefinition = _definiciones.get(id, null)
	return def != null and def.ancla_asignada


## Semilla determinista de isla derivada de la semilla de partida (M10).
## Misma semilla de partida → misma semilla por isla, siempre.
static func semilla_de_isla(semilla_partida: int, id: StringName) -> int:
	var h: int = hash(String(id))
	return int(abs(h ^ (semilla_partida * 2654435761)) % 2147483647)


## Coordenadas (bounds XZ en voxels) para M63 (requisito 38).
func coordenadas_por_isla(id: StringName) -> Rect2i:
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		return Rect2i()
	return def.bounds_locales()


## Vecinas de `id` dentro del radio de streaming. `corte_anillo` (-1 = todos)
## limita a los anillos <= corte. Sin allocs grandes: un barrido por anillo.
func vecinas(id: StringName, corte_anillo: int = -1) -> Array[IslandDefinition]:
	var out: Array[IslandDefinition] = []
	var base: IslandDefinition = _definiciones.get(id, null)
	if base == null:
		return out
	var radio_busqueda: int = IslandRing.radio_vecindad(base.anillo)
	if radio_busqueda <= 0:
		# NUCLEO: sus "vecinas" son todos los CERCANO (no tiene radio propio).
		for otra in todas_las_islas():
			if otra.id == id:
				continue
			if corte_anillo >= 0 and otra.anillo > corte_anillo:
				continue
			out.append(otra)
		return out
	for otra in todas_las_islas():
		if otra.id == id:
			continue
		if corte_anillo >= 0 and otra.anillo > corte_anillo:
			continue
		if not base.ancla_asignada or not otra.ancla_asignada:
			# Sin anclas todavía: se consideran vecinas por anillo (pre-M10).
			if absi(otra.anillo - base.anillo) <= 1:
				out.append(otra)
			continue
		if base.distancia_a(otra) <= float(radio_busqueda):
			out.append(otra)
	return out


## ── Validación de anclas (requisito 39) ───────────────────

## Errores de anclas del archipiélago (vacío = OK). Requiere que M10 haya
## anclado las islas; si no, devuelve el aviso correspondiente.
func validar_anclas() -> Array[String]:
	var errores: Array[String] = []
	var sin_ancla: Array[String] = []
	for def in todas_las_islas():
		if not def.ancla_asignada:
			sin_ancla.append(String(def.id))
	if not sin_ancla.is_empty():
		errores.append("islas sin ancla en M10: %s" % ", ".join(sin_ancla))
		anclas_validadas.emit(errores)
		return errores

	# Aurora en el centro del archipiélago (requisito 50).
	var principal: IslandDefinition = isla_principal()
	if principal != null:
		var d: float = sqrt(float(principal.ancla.x * principal.ancla.x + principal.ancla.z * principal.ancla.z))
		if d > 1.0:
			errores.append("la isla principal (%s) no está en el centro del archipiélago (d=%.0f)" % [principal.id, d])

	# Solapamiento: distancia mínima = radio_a + radio_b + MARGEN_MAR (requisito 48).
	var lista: Array[IslandDefinition] = todas_las_islas()
	for i in range(lista.size()):
		for j in range(i + 1, lista.size()):
			var a: IslandDefinition = lista[i]
			var b: IslandDefinition = lista[j]
			var minimo: float = float(a.radio + b.radio + MARGEN_MAR_ENTRE_ISLAS)
			var dist: float = a.distancia_a(b)
			if dist < minimo:
				errores.append("solapamiento %s/%s (d=%.0f < min=%.0f)" % [a.id, b.id, dist, minimo])

	# Anillo coherente con la distancia al centro (requisito 23 + 50).
	if principal != null:
		for def in lista:
			if def.id == principal.id:
				continue
			var d: float = def.distancia_a(principal)
			var maximo: float = float(IslandRing.distancia_max_anillo(def.anillo))
			if maximo > 0.0 and d > maximo:
				errores.append("isla %s (anillo %s) demasiado lejos del centro: d=%.0f > %d"
					% [def.id, def.anillo_nombre(), d, int(maximo)])

	anclas_validadas.emit(errores)
	return errores


func anclas_validas() -> bool:
	return validar_anclas().is_empty()


## ── Descubrimiento / visita (M54 + M59) ───────────────────

func esta_descubierta(id: StringName) -> bool:
	return _descubiertas.has(id) or id == ISLA_PRINCIPAL_ID


func esta_visitada(id: StringName) -> bool:
	return _visitadas.has(id)


## Marca descubierta; devuelve true sólo la PRIMERA vez (para el toast de M54).
func descubrir(id: StringName) -> bool:
	if not tiene_isla(id) or esta_descubierta(id):
		return false
	_descubiertas[id] = true
	isla_descubierta.emit(id)
	return true


## Marca visitada (y descubierta, porque visitar implica descubrir).
func visitar(id: StringName) -> bool:
	if not tiene_isla(id):
		return false
	var nueva: bool = not _visitadas.has(id)
	_visitadas[id] = true
	_descubiertas[id] = true
	return nueva


## ¿El mapa puede mostrar esta isla? (requisito 119/132: secretas ocultas).
func visible_en_mapa(id: StringName) -> bool:
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		return false
	if def.es_secreta and not esta_descubierta(id):
		return false
	return true


func islas_descubiertas() -> Array[String]:
	var out: Array[String] = []
	for k in _descubiertas.keys():
		out.append(String(k))
	out.sort()
	return out


func islas_visitadas() -> Array[String]:
	var out: Array[String] = []
	for k in _visitadas.keys():
		out.append(String(k))
	out.sort()
	return out


## ¿Está desbloqueada? (M22): sin flag → siempre; con flag → WorldState.
func esta_desbloqueada(id: StringName) -> bool:
	var def: IslandDefinition = _definiciones.get(id, null)
	if def == null:
		return false
	if def.id == ISLA_PRINCIPAL_ID:
		return true
	if def.desbloqueo_flag == &"":
		return true
	var ws := get_node_or_null("/root/WorldState")
	if ws != null and ws.has_method("has_flag"):
		return bool(ws.has_flag(String(def.desbloqueo_flag)))
	return false


## ── Persistencia (M59) ────────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return SECCION_GUARDADO


func get_save_data() -> Dictionary:
	# Copias explícitas: nunca referencias vivas (BUG-014).
	return {
		"descubiertas": islas_descubiertas(),
		"visitadas": islas_visitadas(),
	}


func restore_save_data(datos: Dictionary) -> void:
	_descubiertas.clear()
	_visitadas.clear()
	for d in datos.get("descubiertas", []):
		var sid: StringName = StringName(String(d))
		if tiene_isla(sid):
			_descubiertas[sid] = true
	for v in datos.get("visitadas", []):
		var vid: StringName = StringName(String(v))
		if tiene_isla(vid):
			_visitadas[vid] = true


## ── Hooks de test ─────────────────────────────────────────

func _test_limpiar() -> void:
	_descubiertas.clear()
	_visitadas.clear()


## Apunta la carga a rutas alternativas (test de fallback). Vacío = default.
func _test_rutas(defs: String, arch: String) -> void:
	_test_ruta_defs = defs
	_test_ruta_arch = arch


func _test_definir(def: IslandDefinition) -> bool:
	if def == null or not def.es_valida():
		return false
	if _definiciones.has(def.id):
		return false
	_definiciones[def.id] = def
	_ids_ordenados.append(def.id)
	_ids_ordenados.sort()
	return true
