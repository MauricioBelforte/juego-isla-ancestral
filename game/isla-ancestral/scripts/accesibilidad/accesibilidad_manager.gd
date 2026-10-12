# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M58 iter 2 (glm-5.3-flash): + RF8 subtítulos por defecto (con tamaño/fondo),
# + RF13 perfiles de control data-driven (single_hand, low_mobility),
# + RF18 pausa instantánea (pausar el juego sin menús intermedios).
# Base iter 1: RF1 daltonismo, RF19 presets, señales, persistencia M57/M59.
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/accesibilidad/test_accesibilidad_manager.gd

extends Node

signal profile_loaded(profile_name: String)
signal profile_changed(profile_name: String)
signal profile_reset
signal subtitulos_changed(activado: bool, tamano: String, fondo: bool)
signal control_changed(preset: String)
signal pausa_instantanea_activada
## RF9 (iter. 3): cambiaron los indicadores visuales de sonido.
signal sonido_visual_changed(activado: bool)
## E91: la dificultad cambió (p. ej. desde el menú de pausa en partida activa).
## `en_partida` permite a la UI mostrar el aviso claro que pide el ítem.
signal dificultad_cambiada(dificultad: String, en_partida: bool)

const RUTA_PERFIL: String = "user://accessibility_profile.json"

## Perfil activo (dict: nombre, daltonismo, dificultad, texto_grande, subtitulos...)
var _perfil: Dictionary = {}

## Perfiles predefinidos (data-driven)
const PERFILES := {
	"default": {
		"daltonismo": "",
		"dificultad": "estandar",
		"texto_grande": false,
		"subtitulos": true,
		"alto_contraste": false,
	},
	"protanopia": {"daltonismo": "protanopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"deuteranopia": {"daltonismo": "deuteranopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"tritanopia": {"daltonismo": "tritanopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"sereno": {"daltonismo": "", "dificultad": "sereno",
		"texto_grande": true, "subtitulos": true, "alto_contraste": false},
	# RF21: "Prevenir mareos" — reduce cámara/movimiento al 20 % del normal.
	"prevenir_mareos": {"daltonismo": "", "dificultad": "sereno",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false,
		"reducir_movimiento": true, "factor_movimiento": 0.2},
	"alto_contraste": {"daltonismo": "", "dificultad": "estandar",
		"texto_grande": true, "subtitulos": true, "alto_contraste": true},
}

## RF8: subtítulos por defecto — activados, tamaño mediano, fondo legible.
const SUBTITULOS_DEFECTO := {"subtitulos": true, "subtitulos_tamano": "mediano",
	"subtitulos_fondo": true}

## RF9 (iter. 3): los indicadores visuales de sonido arrancan apagados (opt-in),
## igual que el schema los valida como flag booleano.
const SONIDO_VISUAL_DEFECTO := {"sonido_visual": false}

## Edge case J2 (iter. 3): debounce de guardado para sliders.
## `set_campo_lento` aplica el valor en memoria y en señales de inmediato (el slider
## responde), pero agrupa la escritura a disco tras DEBOUNCE_GUARDADO_SEG sin
## cambios. Un arrastre rápido termina en UNA sola escritura, y el último valor
## nunca se pierde: `_salir`/`_notification` fuerza el flush pendiente.
const DEBOUNCE_GUARDADO_SEG := 0.5

var _tiempo_debounce: float = 0.0
var _perfil_sucio: bool = false


func set_campo_lento(clave: String, valor) -> void:
	if RANGOS.has(clave):
		valor = _coaccionar(clave, valor)
	_perfil[clave] = valor
	_perfil_sucio = true
	profile_changed.emit(String(_perfil.get("nombre", "custom")))
	_tiempo_debounce = DEBOUNCE_GUARDADO_SEG


## Debe llamarse desde _process: acumula delta y escribe pasado el debounce.
func tick_debounce(delta: float) -> void:
	if not _perfil_sucio:
		return
	_tiempo_debounce -= delta
	if _tiempo_debounce <= 0.0:
		_flush()


func _flush() -> void:
	if not _perfil_sucio:
		return
	guardar_perfil()
	_perfil_sucio = false


## Fuerza el guardado pendiente al salir (no se pierde el último valor).
func _exit_tree() -> void:
	_flush()
## Fuera de rango -> coaccionar al límite más cercano, nunca fallar.
const RANGOS := {
	"subtitulos_velocidad": {"min": 0.5, "max": 2.0, "tipo": "float"},
	"volumen_general": {"min": 0.0, "max": 1.0, "tipo": "float"},
	"volumen_musica": {"min": 0.0, "max": 1.0, "tipo": "float"},
	"volumen_efectos": {"min": 0.0, "max": 1.0, "tipo": "float"},
	"tiempo_mantener_ms": {"min": 100.0, "max": 5000.0, "tipo": "float"},
	# RF3: 80 % a 200 % en pasos de 10 % (ver escalas_ui/set_escala_ui).
	"escala_ui": {"min": 0.8, "max": 2.0, "tipo": "float"},
	# RF21: factor de reducción de movimiento (0.0 = apagado, 1.0 = sin cambio).
	"factor_movimiento": {"min": 0.0, "max": 1.0, "tipo": "float"},
}

## ── RF3: escala de interfaz en pasos de 10 % ─────────────────────────────
## Escalas válidas: 0.8, 0.9, 1.0 … 2.0 (13 valores).
const ESCALAS_UI: Array = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]

## Ajusta `valor` a la escala válida más cercana (pasos de 10 %).
static func snap_escala_ui(valor: float) -> float:
	var f: float = clampf(float(valor), 0.8, 2.0)
	var mejor: float = ESCALAS_UI[0]
	for e in ESCALAS_UI:
		if absf(float(e) - f) < absf(mejor - f):
			mejor = float(e)
	return mejor

## RF3: setea la escala de la interfaz ajustada a un paso válido.
func set_escala_ui(valor: float) -> float:
	var v: float = snap_escala_ui(valor)
	set_campo("escala_ui", v)
	return v

## Coacciona un valor al rango declarado. Devuelve el valor sin tocar si la
## clave no tiene rango o si el valor no es numérico (lo valida el schema).
func _coaccionar(clave: String, valor):
	var r: Dictionary = RANGOS[clave]
	if typeof(valor) != TYPE_FLOAT and typeof(valor) != TYPE_INT:
		return valor
	var f := float(valor)
	var lo: float = float(r["min"])
	var hi: float = float(r["max"])
	if String(r.get("tipo")) == "int":
		return int(clampf(roundf(f), lo, hi))
	return clampf(f, lo, hi)

## Edge case J1: lista los campos acotados (para tests y para la UI de opciones).
func campos_con_rango() -> Array:
	return RANGOS.keys()

## RF13: presets de control data-driven (mapeo de acciones → teclas/botones).
const PERFILES_CONTROL := {
	"estandar": {
		"descripcion": "Controles por defecto",
		"acciones_mantenidas_auto": false,
		"tiempo_mantener_multiplicador": 1.0,
		"remap": {},
	},
	"single_hand": {
		"descripcion": "Una sola mano: acciones agrupadas en la mitad izquierda del teclado + ratón",
		"acciones_mantenidas_auto": true,
		"tiempo_mantener_multiplicador": 1.5,
		"remap": {
			"mover_izquierda": "A",
			"mover_derecha": "D",
			"mover_arriba": "W",
			"mover_abajo": "S",
			"interactuar": "RATON_IZQ",
			"usar_herramienta": "RATON_DER",
			"inventario": "Q",
			"pausa": "E",
			"mapa": "R",
		},
	},
	"low_mobility": {
		"descripcion": "Movilidad reducida: mantener automático, tiempos extendidos, sin doble toque",
		"acciones_mantenidas_auto": true,
		"tiempo_mantener_multiplicador": 2.0,
		"remap": {
			"interactuar": "ESPACIO",
			"usar_herramienta": "F",
			"pausa": "ESC",
		},
	},
}


func _process(delta: float) -> void:
	tick_debounce(delta)

func _ready() -> void:
	_cargar_perfil()
	# RF8: subtítulos por defecto si el perfil no trae la configuración
	for k in SUBTITULOS_DEFECTO:
		if not _perfil.has(k):
			_perfil[k] = SUBTITULOS_DEFECTO[k]
	# RF9 (iter. 3): indicadores visuales de sonido (opt-in) si no trae la clave
	for k in SONIDO_VISUAL_DEFECTO:
		if not _perfil.has(k):
			_perfil[k] = SONIDO_VISUAL_DEFECTO[k]


## Aplica un perfil predefinido por nombre.
func aplicar_perfil(nombre: String) -> bool:
	if not PERFILES.has(nombre):
		return false
	_perfil = PERFILES[nombre].duplicate()
	_perfil["nombre"] = nombre
	invalidar_cache()
	guardar_perfil()
	profile_changed.emit(nombre)
	return true


## Modifica un campo del perfil activo.
## Los campos con rango definido en RANGOS se coaccionan a valores válidos:
## un perfil corrupto o manipulado degrada al límite más cercano en vez de
## romperse (edge case J1: "perfil con valores fuera de rango -> coerce").
func set_campo(clave: String, valor) -> void:
	if RANGOS.has(clave):
		valor = _coaccionar(clave, valor)
	_perfil[clave] = valor
	invalidar_cache()
	guardar_perfil()
	profile_changed.emit(String(_perfil.get("nombre", "custom")))


## ── K183: cache de consultas mientras el perfil no cambia ────────────────
## El perfil se lee muchas veces por frame (UI, HUD, aplicadores). Si no está
## sucio, las consultas se responden desde el cache en vez de tocar el
## diccionario. `set_campo`/`aplicar_perfil`/`reset_perfil` invalidan el cache.
var _cache_consultas: Dictionary = {}
var _cache_lecturas: int = 0
var _cache_aciertos: int = 0

## true si hay cambios sin guardar (el cache está invalidado).
func is_dirty() -> bool:
	return _perfil_sucio

## Invalida el cache de consultas (llamar tras modificar el perfil).
## También reinicia las métricas: es un arranque limpio.
func invalidar_cache() -> void:
	_cache_consultas.clear()
	_cache_lecturas = 0
	_cache_aciertos = 0

## Métricas del cache (para tests y para el profiler).
func cache_stats() -> Dictionary:
	return {"lecturas": _cache_lecturas, "aciertos": _cache_aciertos}


func get_campo(clave: String, fallback=null):
	# K183: con el perfil limpio se responde desde el cache.
	if not is_dirty():
		_cache_lecturas += 1
		if _cache_consultas.has(clave):
			_cache_aciertos += 1
			return _cache_consultas[clave]
		var v = _perfil.get(clave, fallback)
		_cache_consultas[clave] = v
		return v
	return _perfil.get(clave, fallback)


func get_perfil() -> Dictionary:
	return _perfil.duplicate()


## E91: cambia la dificultad y avisa. `en_partida` distingue el cambio hecho
## con la partida activa (el menú de pausa), que es el caso que necesita aviso
## claro para no sorprender al jugador.
func set_dificultad(valor: String, en_partida: bool = false) -> bool:
	var v: String = String(valor)
	if v == "":
		return false
	set_campo("dificultad", v)
	dificultad_cambiada.emit(v, en_partida)
	return true

## Dificultad activa del perfil.
func get_dificultad() -> String:
	return String(get_campo("dificultad", "estandar"))


## Resetea al perfil default.
func reset_perfil() -> void:
	_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false}
	guardar_perfil()
	profile_reset.emit()


func guardar_perfil() -> void:
	var f := FileAccess.open(RUTA_PERFIL, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_perfil, "\t"))


func _cargar_perfil() -> void:
	if not FileAccess.file_exists(RUTA_PERFIL):
		_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
			"texto_grande": false, "subtitulos": true, "alto_contraste": false}
		for k in SUBTITULOS_DEFECTO:
			_perfil[k] = SUBTITULOS_DEFECTO[k]
		for k in SONIDO_VISUAL_DEFECTO:
			_perfil[k] = SONIDO_VISUAL_DEFECTO[k]
		return
	var texto := FileAccess.get_file_as_string(RUTA_PERFIL)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) == TYPE_DICTIONARY:
		_perfil = parseado
		for k in SUBTITULOS_DEFECTO:
			if not _perfil.has(k):
				_perfil[k] = SUBTITULOS_DEFECTO[k]
		profile_loaded.emit(String(_perfil.get("nombre", "custom")))
	else:
		_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
			"texto_grande": false, "subtitulos": true, "alto_contraste": false}
		for k in SUBTITULOS_DEFECTO:
			_perfil[k] = SUBTITULOS_DEFECTO[k]

# ═══════════ Iter. 2 (glm-5.3-flash): RF8 + RF13 + RF18 ═══════════

## RF8: activa/desactiva subtítulos con tamaño y fondo.
func set_subtitulos(activado: bool, tamano: String = "mediano", fondo: bool = true) -> void:
	_perfil["subtitulos"] = activado
	_perfil["subtitulos_tamano"] = tamano
	_perfil["subtitulos_fondo"] = fondo
	guardar_perfil()
	subtitulos_changed.emit(activado, tamano, fondo)
	profile_changed.emit(String(_perfil.get("nombre", "custom")))

## RF8: configura el tamaño de los subtítulos (pequeno/mediano/grande).
func set_subtitulos_tamano(tamano: String) -> bool:
	if not ["pequeno", "mediano", "grande"].has(tamano):
		return false
	_perfil["subtitulos_tamano"] = tamano
	guardar_perfil()
	subtitulos_changed.emit(bool(_perfil.get("subtitulos", true)), tamano, bool(_perfil.get("subtitulos_fondo", true)))
	return true

## RF8: estado actual de subtítulos para la capa de diálogo (M53/M150).
func get_subtitulos() -> Dictionary:
	return {"activado": bool(_perfil.get("subtitulos", true)),
		"tamano": String(_perfil.get("subtitulos_tamano", "mediano")),
		"fondo": bool(_perfil.get("subtitulos_fondo", true))}

# ═══════════ Iter. 3 (stepfun-step-5-preview): RF9 + RF11 ═══════════

## RF9: estados de sonido no visualizable -> indicador visual.
## Catálogo data-driven: cada entrada define el texto localizable y el rizo/anillo
## que debe mostrarse. Cubre insectos, agua, cofres y cantos de NPC (RF9 del checklist).
const INDICADORES_SONIDO := {
	"insectos": {"clave_texto": "M58_IND_INSECTOS", "forma": "anillo"},
	"agua": {"clave_texto": "M58_IND_AGUA", "forma": "anillo"},
	"cofre": {"clave_texto": "M58_IND_COFRE", "forma": "rizos"},
	"canto_npc": {"clave_texto": "M58_IND_CANTO_NPC", "forma": "anillo"},
	"alerta_vida": {"clave_texto": "M58_ALERT_VIDA", "forma": "cartel"},
	"alerta_tormenta": {"clave_texto": "M58_ALERT_TORMENTA", "forma": "cartel"},
	"alerta_hambre": {"clave_texto": "M58_ALERT_HAMBRE", "forma": "cartel"},
}

## Anti-spam visual (L54): un indicador por tipo no se reemite dentro de esta
## ventana (segundos). Evita repintado continuo en sesiones largas.
const VENTANA_ANTISPAM_SEG := 2.0

var _ultimo_indicador: Dictionary = {}

## RF9: activa/desactiva los indicadores visuales de sonido.
func set_sonido_visual(activado: bool) -> void:
	_perfil["sonido_visual"] = activado
	if not activado:
		_ultimo_indicador.clear()
	guardar_perfil()
	sonido_visual_changed.emit(activado)
	profile_changed.emit(String(_perfil.get("nombre", "custom")))

## RF9: estado actual del indicador de sonido para la capa de HUD (M53).
func get_sonido_visual() -> bool:
	return bool(_perfil.get("sonido_visual", false))

## RF9: devuelve el descriptor del indicador, o {} si no aplica.
## Aplica anti-spam por tipo: dentro de VENTANA_ANTISPAM_SEG devuelve {}.
## No emite UI propia: solo describe qué debe mostrar la capa de presentación.
func pedir_indicador(tipo: String, forzar: bool = false) -> Dictionary:
	if not get_sonido_visual():
		return {}
	if not INDICADORES_SONIDO.has(tipo):
		push_warning("[M58] Indicador desconocido: %s" % tipo)
		return {}
	var ahora := Time.get_unix_time_from_system()
	if not forzar and _ultimo_indicador.has(tipo) and \
			ahora - float(_ultimo_indicador[tipo]) < VENTANA_ANTISPAM_SEG:
		return {}
	_ultimo_indicador[tipo] = ahora
	var d: Dictionary = INDICADORES_SONIDO[tipo].duplicate()
	d["tipo"] = tipo
	d["activado"] = true
	return d

## RF9: catálogo completo (para tests y para la capa de HUD).
func indicadores_disponibles() -> Array:
	return INDICADORES_SONIDO.keys()

## RF13: aplica un preset de control data-driven.
func aplicar_perfil_control(preset: String) -> bool:
	if not PERFILES_CONTROL.has(preset):
		return false
	_perfil["control_preset"] = preset
	guardar_perfil()
	control_changed.emit(preset)
	profile_changed.emit(String(_perfil.get("nombre", "custom")))
	return true

## RF13: mapeo de acciones del preset activo ({accion: tecla}).
func get_remap_control() -> Dictionary:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return conf.get("remap", {})

## RF13: ¿las acciones de mantener se ejecutan automáticas? (low_mobility).
func mantener_automatico() -> bool:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return bool(conf.get("acciones_mantenidas_auto", false))

## RF13: multiplicador de tiempos de mantener (1.0 estándar, 1.5/2.0 extendidos).
func tiempo_mantener_multiplicador() -> float:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return float(conf.get("tiempo_mantener_multiplicador", 1.0))

## RF18: pausa instantánea — congela el árbol de escena sin menús intermedios.
## Emite pausa_instantanea_activada para que la capa de UI (M53) muestre su overlay.
func pausar_instantaneo() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	if tree.paused:
		return true  # idempotente
	tree.paused = true
	pausa_instantanea_activada.emit()
	print("[M58] RF18: pausa instantánea activada")
	return true

## RF18: reanuda el juego tras la pausa instantánea.
func reanudar() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	tree.paused = false
	return true

## RF18: ¿el juego está en pausa instantánea?
func esta_pausado() -> bool:
	var tree := get_tree()
	return tree != null and tree.paused
