# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M92: Tutorial — TutorialManager (autoload "Tutorial").
# Orquestador del tutorial integrado no intrusivo (RF1-RF19):
#   - Registro de capítulos con pasos (PISTA/SECUENCIA/CONSEJO)
#   - Triggers de señal para disparar lecciones
#   - Revalidación: si la meta ya se cumplió, se marca sin pasos redundantes
#   - Estado ACTIVO/ESPERANDO/PISTA/SKIPPED/DORMIDO
#   - Persistencia liviana (enum de capítulos completados + consejos vistos)
# No posee UI final: expone señales; M53/M58 dibujan la presentación.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

enum Estado { ACTIVO, ESPERANDO, PISTA, CONSECUENCIA, SKIPPED, DORMIDO }

signal capitulo_iniciado(capitulo_id: String)
signal capitulo_completado(capitulo_id: String)
signal paso_mostrado(capitulo_id: String, paso: Dictionary)
signal estado_cambiado(estado: int)

const SECCION_SAVE := "tutorial"

var estado: int = Estado.ESPERANDO
var capitulos: Dictionary = {}   # capitulo_id -> {pasos: Array, meta: String, rejugable: bool}
var completados: Array = []
var consejos_vistos: Array = []
var activo_actual: String = ""

var _trigger_registros: Array = []  # [{senal: String, capitulo: String}]

func _ready() -> void:
	_registrar_capitulos_base()
	_registrar_proveedor_guardado()

## ── Capítulos base (contenido de ejemplo) ────────────────

func _registrar_capitulos_base() -> void:
	registrar_capitulo("prologo", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.PROLOGO_BIENVENIDA", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.PROLOGO_MOVERSE", "meta": "mover", "icono_tecla": "mover_norte"},
	], "mover", true)
	registrar_capitulo("interactuar", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.INTERACTUAR", "meta": "interactuar", "icono_tecla": "interactuar"},
	], "interactuar", false)
	registrar_capitulo("herramienta", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.HERRAMIENTA", "icono_tecla": "colocar"},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.HERRAMIENTA_USO", "meta": "usar_herramienta", "icono_tecla": "colocar"},
	], "usar_herramienta", false)
	registrar_capitulo("vecino", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.VECINO", "meta": "charlar", "icono_tecla": "interactuar"},
	], "charlar", true)

func registrar_capitulo(capitulo_id: String, pasos: Array, meta: String, rejugable: bool) -> void:
	if capitulos.has(capitulo_id):
		return
	capitulos[capitulo_id] = {"pasos": pasos, "meta": meta, "rejugable": rejugable}

## ── Triggers ─────────────────────────────────────────────

## Registra que una señal del sistema dispara un capítulo.
func registrar_trigger(senal: String, capitulo_id: String) -> void:
	if capitulos.has(capitulo_id):
		_trigger_registros.append({"senal": senal, "capitulo": capitulo_id})

## Llamado por sistemas del juego (M11/M13/M70/M33/M34/M35/M16).
## Revalida: si la meta ya se cumplió, marca completo sin pasos.
func notificar_senal(senal: String) -> void:
	for trig in _trigger_registros:
		if trig.senal == senal:
			desplegar_capitulo(trig.capitulo)

## ── Despliegue de capítulos ──────────────────────────────

func desplegar_capitulo(capitulo_id: String) -> void:
	if estado == Estado.SKIPPED:
		return
	if not capitulos.has(capitulo_id):
		return
	var capitulo: Dictionary = capitulos[capitulo_id]
	if capitulo_id in completados and not bool(capitulo.get("rejugable", false)):
		return
	# Revalidación: meta ya cumplida por jugador que sabe
	if _meta_cumplida(capitulo.get("meta", "")):
		_completar(capitulo_id)
		return
	activo_actual = capitulo_id
	estado = Estado.ACTIVO
	estado_cambiado.emit(estado)
	capitulo_iniciado.emit(capitulo_id)
	for paso in capitulo.pasos:
		paso_mostrado.emit(capitulo_id, paso)

func _meta_cumplida(meta: String) -> bool:
	if meta == "":
		return false
	return meta in completados

## Marca una meta como cumplida (la llama el sistema enseñado o el watchdog).
func cumplir_meta(meta: String) -> void:
	if meta == "" or meta in completados:
		return
	completados.append(meta)
	if activo_actual != "" and capitulos.has(activo_actual):
		var capitulo: Dictionary = capitulos[activo_actual]
		if capitulo.get("meta", "") == meta:
			_completar(activo_actual)

func _completar(capitulo_id: String) -> void:
	if capitulo_id in completados:
		return
	completados.append(capitulo_id)
	estado = Estado.CONSECUENCIA
	estado_cambiado.emit(estado)
	capitulo_completado.emit(capitulo_id)
	activo_actual = ""
	estado = Estado.ESPERANDO
	estado_cambiado.emit(estado)

## ── Controles ────────────────────────────────────────────

func skip_todo() -> void:
	estado = Estado.SKIPPED
	estado_cambiado.emit(estado)

func reanudar() -> void:
	if estado == Estado.SKIPPED:
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)

func set_dormido(valor: bool) -> void:
	if valor and estado != Estado.SKIPPED:
		estado = Estado.DORMIDO
		estado_cambiado.emit(estado)
	elif not valor and estado == Estado.DORMIDO:
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)

func esta_activo() -> bool:
	return estado == Estado.ACTIVO

func capitulos_completados() -> Array:
	return completados.duplicate()

func capitulo_estado(capitulo_id: String) -> bool:
	return capitulo_id in completados

## ── Consejos (tips opcionales) ───────────────────────────

func marcar_consejo_visto(consejo_id: String) -> void:
	if consejo_id not in consejos_vistos:
		consejos_vistos.append(consejo_id)

func consejo_visto(consejo_id: String) -> bool:
	return consejo_id in consejos_vistos

## ── Persistencia (M59) ───────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {
		"completados": completados.duplicate(),
		"consejos_vistos": consejos_vistos.duplicate(),
		"skip": estado == Estado.SKIPPED,
	}

func restore_save_data(data: Dictionary) -> void:
	completados.clear()
	for c in data.get("completados", []):
		completados.append(str(c))
	consejos_vistos.clear()
	for c in data.get("consejos_vistos", []):
		consejos_vistos.append(str(c))
	if bool(data.get("skip", false)):
		estado = Estado.SKIPPED