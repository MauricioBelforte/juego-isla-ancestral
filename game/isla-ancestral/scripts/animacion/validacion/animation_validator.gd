# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M48: Validador de animaciones — RF12 / 03-Diseno.md sec 2.3 y sec 3.1.
# Contrato: 04-Codigo.md sec 2.5 (validate_animation.gd) y sec 3 (firmas).
# Corre headless como --script (M118): NO es un plugin de import ni depende del editor.
#   Gate:  res://scripts/animacion/validacion/validate_animation_cli.gd
#   Suite: res://scripts/animacion/test_validacion_m48.gd
#
# Severidad por PREFIJO de codigo en la MISMA lista de salida (tres niveles, no uno):
#   E#  = error de contrato      -> rompe el gate (exit 1)
#   A#  = aviso justificable     -> se reporta, NO rompe el gate
#   NV# = no verificable headless-> se DECLARA; nunca se cuenta como aprobado
#
# Regla de honestidad: lo que no se puede medir desde un .tres (T-pose del FBX,
# fps de origen, compresion de import) sale como NV#, no se omite ni se asume OK.

class_name AnimationValidator
extends RefCounted

## FPS base del proyecto (03-Diseno sec 3.1): 30 salvo UI.
const FPS_BASE := 30.0
const FPS_UI := 60.0

## Tolerancia de grilla, en frames. Un key a 0.25 s con 30 fps son 7.5 frames -> fuera.
const TOLERANCIA_FRAMES := 0.01

## Tabla 3.1 (03-Diseno): fps, duracion maxima por categoria y blend default (ms).
const CATEGORIAS := {
	"locomocion": {"fps": 30.0, "max": 1.6, "blend_ms": 250},
	"accion": {"fps": 30.0, "max": 2.5, "blend_ms": 200},
	"fauna": {"fps": 30.0, "max": 3.0, "blend_ms": 300},
	"mecanica": {"fps": 30.0, "max": 4.0, "blend_ms": 0},
	"ui": {"fps": 60.0, "max": 0.6, "blend_ms": 0},
	"mundo": {"fps": 30.0, "max": INF, "blend_ms": 0},
}

## L181: clip = anim_<actor>_<accion>[_<variante>], prefijo anim_ obligatorio.
const PATRON_NOMBRE := "^anim_[a-z0-9]+_[a-z0-9]+(?:_[a-z0-9]+)*$"

## Presupuesto 3.2 y criterio 5 del kit (03-Diseno sec 6).
const MAX_ACTORES_PLENOS := 60
const MAX_BLEND_NODOS := 4

## Subset de huesos por familia (03-Diseno sec 5).
const HUESOS_POR_FAMILIA := {"humanoide": 40, "cuadrupedo": 28, "ave": 22, "pez": 14}

## Catalogo 3.3: accion -> categoria (para clasificar un clip por su nombre).
const ACCION_A_CATEGORIA := {
	"idle": "locomocion", "walk": "locomocion", "run": "locomocion",
	"caminar": "locomocion", "correr": "locomocion", "saltar": "locomocion",
	"nadar": "locomocion", "caer": "locomocion",
	"minar": "accion", "talar": "accion", "pescar": "accion", "cosechar": "accion",
	"regar": "accion", "extraer": "accion", "martillar": "accion", "swing": "accion",
	"comer": "fauna", "pastorear": "fauna", "huir": "fauna", "volar": "fauna",
	"dormir": "mecanica", "abrir": "mecanica", "cerrar": "mecanica", "subir": "mecanica",
	"transicion": "ui", "recompensa": "ui",
}

var _re: RegEx = null


func _init() -> void:
	_re = RegEx.new()
	_re.compile(PATRON_NOMBRE)


## Nombre canonico de un clip: resource_name si existe, si no la clave de la libreria.
static func nombre_de(anim: Animation, clave: String = "") -> String:
	if anim == null:
		return clave
	var n: String = anim.resource_name
	if n == "":
		n = clave
	return n


func nombre_valido(nombre: String) -> bool:
	if _re == null:
		return false
	return _re.search(nombre) != null


## Clasifica por la accion del nombre (anim_<actor>_<accion>...). "" si no se reconoce.
static func categoria_de(nombre: String) -> String:
	var partes: PackedStringArray = nombre.split("_")
	if partes.size() < 3:
		return ""
	var accion: String = partes[2]
	if ACCION_A_CATEGORIA.has(accion):
		return str(ACCION_A_CATEGORIA[accion])
	return ""


static func es_error(linea: String) -> bool:
	return linea.begins_with("E")


static func es_aviso(linea: String) -> bool:
	return linea.begins_with("A")


static func es_no_verificable(linea: String) -> bool:
	return linea.begins_with("NV")


## Valida UN clip. Devuelve la lista completa (E#, A#, NV#) — sin filtrar.
## categoria: clave de CATEGORIAS. familia: clave de HUESOS_POR_FAMILIA ("" = no se chequea).
## clave: nombre con el que el clip esta registrado en su AnimationLibrary.
func validar_clip(anim: Animation, categoria: String, familia: String = "", clave: String = "") -> Array[String]:
	var salida: Array[String] = []
	if anim == null:
		salida.append("E4 clip nulo (no se pudo cargar)")
		return salida

	var nombre: String = nombre_de(anim, clave)
	if not nombre_valido(nombre):
		salida.append("E1 nombre '%s' no cumple anim_<actor>_<accion>[_<variante>]" % nombre)
	if clave != "" and nombre != clave:
		salida.append("E5 clave '%s' != resource_name '%s'" % [clave, nombre])

	if not CATEGORIAS.has(categoria):
		salida.append("E2 categoria desconocida '%s' (validas: %s)" % [categoria, str(CATEGORIAS.keys())])
		return salida

	var cfg: Dictionary = CATEGORIAS[categoria]
	var fps: float = float(cfg["fps"])
	var tope: float = float(cfg["max"])

	# E3: un clip mas corto que UN frame no se puede muestrear.
	# MEDIDO: Animation.length NO puede valer 0 (el motor lo clampa a 0.001), asi que
	# "length <= 0" seria una rama INALCANZABLE (= check muerto). El criterio util es
	# el frame minimo de la categoria.
	if anim.length < 1.0 / fps:
		salida.append("E3 '%s' duracion %.4f s < 1 frame a %d fps" % [nombre, anim.length, int(fps)])
	elif anim.length > tope:
		salida.append("A1 '%s' dura %.3f s > tope %.3f s de '%s' (justificable: dividir o documentar)" % [nombre, anim.length, tope, categoria])

	var tracks: int = anim.get_track_count()
	if tracks == 0:
		salida.append("E4 '%s' sin tracks (clip vacio)" % nombre)
		return salida

	var huesos: Dictionary = {}
	var fuera_grilla: int = 0
	var redundantes: int = 0
	for t in range(tracks):
		var tipo: int = anim.track_get_type(t)
		if tipo == Animation.TYPE_POSITION_3D or tipo == Animation.TYPE_ROTATION_3D or tipo == Animation.TYPE_SCALE_3D:
			var ruta: String = str(anim.track_get_path(t))
			var partes: PackedStringArray = ruta.split(":")
			if partes.size() >= 2:
				huesos[partes[1]] = true
		var claves: int = anim.track_get_key_count(t)
		for k in range(claves):
			var t_key: float = anim.track_get_key_time(t, k)
			var frames: float = t_key * fps
			if absf(frames - roundf(frames)) > TOLERANCIA_FRAMES:
				fuera_grilla += 1
			if k > 0:
				var previo: Variant = anim.track_get_key_value(t, k - 1)
				var actual: Variant = anim.track_get_key_value(t, k)
				if previo == actual:
					redundantes += 1

	if fuera_grilla > 0:
		salida.append("A2 '%s' %d key(s) fuera de la grilla de %d fps" % [nombre, fuera_grilla, int(fps)])
	if redundantes > 0:
		salida.append("A4 '%s' %d keyframe(s) redundante(s) (mismo valor consecutivo)" % [nombre, redundantes])

	if huesos.is_empty():
		salida.append("NV1 '%s' sin tracks de hueso: T-pose y subset no verificables desde el .tres" % nombre)
	elif familia != "" and HUESOS_POR_FAMILIA.has(familia):
		var tope_huesos: int = int(HUESOS_POR_FAMILIA[familia])
		if huesos.size() > tope_huesos:
			salida.append("A3 '%s' %d huesos > subset %d de '%s'" % [nombre, huesos.size(), tope_huesos, familia])
	return salida


## Valida una AnimationLibrary completa y agrega por severidad.
## categoria: forzada para todos los clips ("" = clasificar por nombre).
func validar_libreria(lib: AnimationLibrary, categoria: String = "", familia: String = "") -> Dictionary:
	var errores: Array[String] = []
	var avisos: Array[String] = []
	var no_verificable: Array[String] = []
	var clips: int = 0

	if lib == null:
		errores.append("E4 libreria nula")
	else:
		var claves: Array = lib.get_animation_list()
		for clave_v in claves:
			var clave: String = str(clave_v)
			var anim: Animation = lib.get_animation(clave)
			var cat: String = categoria
			if cat == "":
				cat = categoria_de(nombre_de(anim, clave))
			clips += 1
			var lineas: Array[String] = validar_clip(anim, cat, familia, clave)
			for l in lineas:
				if es_error(l):
					errores.append(l)
				elif es_aviso(l):
					avisos.append(l)
				else:
					no_verificable.append(l)

	# Declaracion de lo que este validador NO puede ver (honestidad, no omision).
	no_verificable.append("NV2 fps de ORIGEN (FBX) no verificable headless: se mide la grilla de keys, no el import")
	no_verificable.append("NV3 compresion de import y T-pose del FBX no verificables desde un .tres")

	return {
		"clips": clips,
		"errores": errores,
		"avisos": avisos,
		"no_verificable": no_verificable,
	}


## Valida el presupuesto de un actor (criterios 5 y 6 del kit, 03-Diseno sec 6).
## cfg: {"actores_plenos": int, "blend_nodos": int, "estados": Array, "clips": Array}
func validar_actor(cfg: Dictionary) -> Array[String]:
	var salida: Array[String] = []
	var plenos: int = int(cfg.get("actores_plenos", 0))
	var blend: int = int(cfg.get("blend_nodos", 0))
	if plenos > MAX_ACTORES_PLENOS:
		salida.append("E6 %d actores plenos > presupuesto %d" % [plenos, MAX_ACTORES_PLENOS])
	if blend > MAX_BLEND_NODOS:
		salida.append("E7 %d nodos de blend tree > presupuesto %d" % [blend, MAX_BLEND_NODOS])

	var estados_v: Variant = cfg.get("estados", [])
	var clips_v: Variant = cfg.get("clips", [])
	var estados: Array = estados_v if estados_v is Array else []
	var clips: Array = clips_v if clips_v is Array else []
	var faltantes: Array[String] = []
	for e in estados:
		if not clips.has(e):
			faltantes.append(str(e))
	if not faltantes.is_empty():
		salida.append("E8 %d estado(s) de FSM sin clip: %s" % [faltantes.size(), str(faltantes)])
	return salida


## Blend default de una categoria, en ms (tabla 3.1).
static func blend_de(categoria: String) -> int:
	if not CATEGORIAS.has(categoria):
		return 0
	var cfg: Dictionary = CATEGORIAS[categoria]
	return int(cfg["blend_ms"])
