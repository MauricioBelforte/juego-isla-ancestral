# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M106: Seguridad — SecurityManager (autoload)
# Políticas de seguridad data-driven (security_policies.json): validación
# de saves con checksum, bloqueo de escritura en res://, rechazo de inputs
# fuera de rango, no-logs sensibles. Adaptación Godot 4.7/GDScript.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_POLICIES := "res://data/security/security_policies.json"

var config: Dictionary = {}
var _alertas: Array = []
var _ultimo_ts_bot: int = 0
var _intervalos_bot: int = 0
var _audit_buffer: Array = []
var _tasa_marcas: Dictionary = {}

func _ready() -> void:
	_cargar_policies()
	_registrar_servicio()
	print("[M106] SecurityManager listo (%d políticas)" % config.get("politicas", {}).size())

func _cargar_policies() -> void:
	if not FileAccess.file_exists(RUTA_POLICIES):
		push_warning("[M106] security_policies.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_POLICIES))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("security"):
		sr.register("security", self)

## ¿Está habilitada una política?
func politica(nombre: String) -> bool:
	return bool(config.get("politicas", {}).get(nombre, {}).get("habilitada", false))

## Valida un valor contra una restricción numérica (máx).
func validar_max(campo: String, valor: int) -> bool:
	var max_valor: int = int(config.get("restricciones", {}).get(campo, 0))
	if max_valor <= 0:
		return true  # sin restricción configurada
	return valor <= max_valor

## Valida integridad de un save (checksum CRC32 patrón M60).
func validar_save(ruta: String) -> bool:
	if not politica("validar_saves"):
		return true
	if not FileAccess.file_exists(ruta):
		return false
	var contenido := FileAccess.get_file_as_string(ruta)
	var newline := contenido.find("\n")
	if newline <= 0:
		return false
	var checksum := contenido.substr(0, newline)
	var payload := contenido.substr(newline + 1)
	return checksum == Validador.crc32_hex(payload)

## Valida la economía de un jugador contra las restricciones del catálogo (RF11).
## Detecta economía adulterada: plata/items/nivel fuera de rango o valores negativos.
## player_data: {"plata": int, "objetos_inventario": int, "nivel": int} (claves opcionales).
## Devuelve true si la economía es legítima; false si se detecta adulteración (registra alerta).
func validar_economia(player_data: Dictionary) -> bool:
	if not politica("rechazar_input_invalido"):
		return true  # política de validación deshabilitada
	var legitimo: bool = true
	# plata
	if player_data.has("plata"):
		var plata: int = int(player_data["plata"])
		if plata < 0:
			legitimo = false
			registrar_alerta("Economía adulterada: plata negativa (%d)" % plata)
		elif not validar_max("max_plata", plata):
			legitimo = false
			registrar_alerta("Economía adulterada: plata %d excede max_plata" % plata)
	# objetos de inventario
	if player_data.has("objetos_inventario"):
		var objetos: int = int(player_data["objetos_inventario"])
		if objetos < 0:
			legitimo = false
			registrar_alerta("Economía adulterada: objetos negativos (%d)" % objetos)
		elif not validar_max("max_objetos_inventario", objetos):
			legitimo = false
			registrar_alerta("Economía adulterada: %d objetos exceden max_objetos_inventario" % objetos)
	# nivel
	if player_data.has("nivel"):
		var nivel: int = int(player_data["nivel"])
		if nivel < 0:
			legitimo = false
			registrar_alerta("Economía adulterada: nivel negativo (%d)" % nivel)
		elif not validar_max("max_nivel", nivel):
			legitimo = false
			registrar_alerta("Economía adulterada: nivel %d excede max_nivel" % nivel)
	return legitimo

## Registra el timestamp de una acción del jugador y detecta patrones de bot (RF12).
## Marca intervalos sub-mínimos (input más rápido que lo humanamente posible = autoclicker/macro).
## Si la racha de intervalos marcados supera `max_rafaga_bot` → alerta de bot (una por racha).
## Devuelve el contador de intervalos marcados en la racha actual (0 = timing humano normal).
func registrar_accion_bot(timestamp_ms: int) -> int:
	if not politica("rechazar_input_invalido"):
		return 0
	var min_intervalo: int = int(config.get("restricciones", {}).get("min_intervalo_accion_ms", 80))
	var max_rafaga: int = int(config.get("restricciones", {}).get("max_rafaga_bot", 10))
	if _ultimo_ts_bot > 0:
		var intervalo: int = timestamp_ms - _ultimo_ts_bot
		if intervalo < min_intervalo:
			_intervalos_bot += 1
			if _intervalos_bot == max_rafaga:
				registrar_alerta("Patrón de bot: ráfaga de %d acciones a intervalos < %dms" % [max_rafaga, min_intervalo])
		else:
			_intervalos_bot = 0  # pausa humana: reset de la racha
	_ultimo_ts_bot = timestamp_ms
	return _intervalos_bot

## Registra un acceso importante en el audit log local (RF13).
## nivel: "info" | "critico". Buffer acotado (max_audit_buffer); auto-vuelca a user:// al llenarse.
## Devuelve la cantidad de entradas actualmente en el buffer.
func registrar_acceso(accion: String, detalle: String = "", nivel: String = "info") -> int:
	var entrada := {
		"ts": Time.get_datetime_string_from_system(false, true),
		"nivel": nivel,
		"accion": accion,
		"detalle": detalle,
	}
	_audit_buffer.append(entrada)
	if nivel == "critico":
		registrar_alerta("Acceso crítico: %s %s" % [accion, detalle])
	var max_buffer: int = int(config.get("restricciones", {}).get("max_audit_buffer", 50))
	if _audit_buffer.size() >= max_buffer:
		volcar_audit_log()
	return _audit_buffer.size()

## Vuelca el buffer de auditoría a disco (user://security_audit.log, JSON Lines) con retención
## de las últimas `audit_retener_lineas` líneas. Devuelve true si el volcado fue exitoso.
func volcar_audit_log() -> bool:
	if _audit_buffer.is_empty():
		return true
	var ruta := "user://security_audit.log"
	var retener: int = int(config.get("restricciones", {}).get("audit_retener_lineas", 500))
	# leer líneas previas para retención
	var previas: Array = []
	if FileAccess.file_exists(ruta):
		previas = FileAccess.get_file_as_string(ruta).split("\n", false)
	# agregar nuevas
	for entrada in _audit_buffer:
		previas.append(JSON.stringify(entrada))
	# retener solo las últimas
	if previas.size() > retener:
		previas = previas.slice(previas.size() - retener)
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_warning("[M106] No se pudo escribir %s" % ruta)
		return false
	for linea in previas:
		f.store_line(linea)
	f.close()
	_audit_buffer.clear()
	return true

func cantidad_audit() -> int:
	return _audit_buffer.size()

## Verifica y consume una unidad de tasa para una clave ("ip:1.2.3.4", "usuario:x", "endpoint:/api/crash")
## en el instante `ahora_s` (segundos). Ventana deslizante de `limite_tasa_ventana_s` segundos.
## El límite sale del catálogo `limites_tasa` (por_ip / por_usuario / endpoints[<ruta>]).
## Devuelve true si la solicitud está PERMITIDA (consume); false si excede el límite (registra alerta).
## Offline/local: en memoria. La aplicación real sobre red es de M77.
func verificar_limite_tasa(clave: String, ahora_s: int) -> bool:
	var limite: int = _limite_tasa_de(clave)
	if limite <= 0:
		return true  # sin límite configurado para esta clave
	var ventana: int = int(config.get("restricciones", {}).get("limite_tasa_ventana_s", 60))
	var corte: int = ahora_s - ventana
	var marcas: Array = _tasa_marcas.get(clave, [])
	# descartar marcas fuera de la ventana
	var vigentes: Array = []
	for m in marcas:
		if int(m) > corte:
			vigentes.append(m)
	if vigentes.size() >= limite:
		_tasa_marcas[clave] = vigentes
		registrar_alerta("Límite de tasa excedido: %s (%d/%d en %ds)" % [clave, vigentes.size(), limite, ventana])
		return false
	vigentes.append(ahora_s)
	_tasa_marcas[clave] = vigentes
	return true

## Límite configurado para una clave de tasa ("tipo:valor"). 0 = sin límite.
func _limite_tasa_de(clave: String) -> int:
	var lt: Dictionary = config.get("limites_tasa", {})
	var partes := clave.split(":", true, 1)
	if partes.is_empty():
		return 0
	var tipo: String = partes[0]
	match tipo:
		"ip":
			return int(lt.get("por_ip", 0))
		"usuario":
			return int(lt.get("por_usuario", 0))
		"endpoint":
			var ruta: String = partes[1] if partes.size() > 1 else ""
			return int(lt.get("endpoints", {}).get(ruta, 0))
	return 0

## Segundos hasta que la clave vuelva a tener capacidad (0 = ya hay capacidad).
## Usado por el middleware de rate limiting para reportar `reintentar_en_s`.
func tasa_reintento_s(clave: String, ahora_s: int) -> int:
	var limite: int = _limite_tasa_de(clave)
	if limite <= 0:
		return 0
	var ventana: int = int(config.get("restricciones", {}).get("limite_tasa_ventana_s", 60))
	var corte: int = ahora_s - ventana
	var marcas: Array = _tasa_marcas.get(clave, [])
	var vigentes: Array = []
	for m in marcas:
		if int(m) > corte:
			vigentes.append(m)
	if vigentes.size() < limite:
		return 0
	var mas_vieja: int = int(vigentes[0])
	for m in vigentes:
		mas_vieja = mini(mas_vieja, int(m))
	return maxi(0, (mas_vieja + ventana) - ahora_s)

## Registra una alerta de seguridad (no sensible).
func registrar_alerta(mensaje: String) -> void:
	_alertas.append(mensaje)
	push_warning("[M106] Alerta: %s" % mensaje)

func alertas() -> Array:
	return _alertas.duplicate()

func cantidad_alertas() -> int:
	return _alertas.size()