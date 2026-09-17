# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M124: Contenido Generado por Usuarios — UgcLimits
# Límites de almacenamiento (RF13) data-driven desde el bloque `limites` de
# ugc_catalog.json. Dos niveles de validación independientes:
#   - por ítem  (peso y formato)                                      -> validar_item()
#   - por cuota (ítems activos, fotos/día, blueprints/día, bytes/día) -> validar_cuota()
# Siempre devuelve Dictionary {ok, motivo, mensaje}: el motivo es una constante
# (para el test) y el mensaje es texto listo para mostrar al jugador
# (checklist M124 §14, ítems 143-144).
#
# ⚠️ Sin autoload: en `--script` los autoloads no resuelven como identificador
# global. Todo estático o por instancia.

class_name UgcLimits
extends RefCounted

# --- Motivos: nunca strings sueltos, el test los compara por constante ---
const MOTIVO_OK := "ok"
const MOTIVO_TIPO_DESCONOCIDO := "tipo_desconocido"
const MOTIVO_PESO_EXCEDIDO := "peso_excedido"
const MOTIVO_FORMATO_NO_SOPORTADO := "formato_no_soportado"
const MOTIVO_BYTES_INVALIDOS := "bytes_invalidos"
const MOTIVO_CUOTA_ITEMS := "cuota_items"
const MOTIVO_CUOTA_DIARIA := "cuota_diaria"
const MOTIVO_CUOTA_BYTES := "cuota_bytes"

# Tipos con peso propio; el resto de tipos de contenido no se sube como archivo.
const TIPOS_CON_PESO := ["foto", "blueprint", "construccion"]

# --- Defaults (si el catálogo no trae el bloque `limites`) ---
const DEF_ITEMS_ACTIVOS := 200
const DEF_FOTOS_DIA := 50
const DEF_BLUEPRINTS_DIA := 20
const DEF_BYTES_DIA := 10485760
const DEF_PESO_FOTO := 3145728
const DEF_PESO_BLUEPRINT := 262144
const DEF_PESO_CONSTRUCCION := 524288
const DEF_LADO_MAX_PX := 2048
const DEF_SLA_HORAS := 72

var _lim: Dictionary = {}

func _init(limites: Dictionary = {}) -> void:
	_lim = limites.duplicate(true)

static func desde_catalogo(config: Dictionary) -> UgcLimits:
	return UgcLimits.new(config.get("limites", {}))

func limites() -> Dictionary:
	return _lim.duplicate(true)

# --- Lectura tolerante: JSON.parse_string devuelve float para los enteros ---
static func _entero(d: Dictionary, clave: String, por_defecto: int) -> int:
	var v: Variant = d.get(clave, por_defecto)
	if typeof(v) == TYPE_FLOAT:
		return int(v)
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_STRING:
		var s := str(v)
		if s.is_valid_int():
			return s.to_int()
	return por_defecto

func get_int(clave: String, por_defecto: int) -> int:
	return _entero(_lim, clave, por_defecto)

func items_activos_max() -> int:
	return get_int("items_activos_por_usuario", DEF_ITEMS_ACTIVOS)

func fotos_por_dia_max() -> int:
	return get_int("fotos_por_dia", DEF_FOTOS_DIA)

func blueprints_por_dia_max() -> int:
	return get_int("blueprints_por_dia", DEF_BLUEPRINTS_DIA)

func bytes_por_dia_max() -> int:
	return get_int("bytes_subida_por_dia", DEF_BYTES_DIA)

func lado_max_foto_px() -> int:
	return get_int("lado_max_foto_px", DEF_LADO_MAX_PX)

func peso_max(tipo: String) -> int:
	var por_defecto := DEF_PESO_BLUEPRINT
	if tipo == "foto":
		por_defecto = DEF_PESO_FOTO
	elif tipo == "construccion":
		por_defecto = DEF_PESO_CONSTRUCCION
	var tabla: Variant = _lim.get("peso_max_bytes", {})
	if typeof(tabla) != TYPE_DICTIONARY:
		return por_defecto
	return _entero(tabla as Dictionary, tipo, por_defecto)

func formatos_foto() -> Array:
	var f: Variant = _lim.get("formatos_foto", ["jpg", "webp"])
	if typeof(f) == TYPE_ARRAY:
		return (f as Array).duplicate()
	return ["jpg", "webp"]

func formato_soportado(tipo: String, formato: String) -> bool:
	if tipo != "foto":
		return true  # los blueprints son JSON: el formato de imagen no aplica
	var f := formato.strip_edges().to_lower()
	if f.begins_with("."):
		f = f.substr(1)
	return formatos_foto().has(f)

func sla_reporte_horas(categoria: String) -> int:
	var t: Variant = _lim.get("sla_reporte_horas", {})
	if typeof(t) == TYPE_DICTIONARY:
		return _entero(t as Dictionary, categoria, DEF_SLA_HORAS)
	return DEF_SLA_HORAS

# --- Resultado normalizado ---
static func _res(ok: bool, motivo: String, mensaje: String) -> Dictionary:
	return {"ok": ok, "motivo": motivo, "mensaje": mensaje}

static func _ok() -> Dictionary:
	return _res(true, MOTIVO_OK, "")

static func _lista(a: Array) -> String:
	var partes := PackedStringArray()
	for x in a:
		partes.append(str(x))
	return ", ".join(partes)

static func _humano(bytes: int) -> String:
	if bytes >= 1048576:
		return "%.1f MB" % (float(bytes) / 1048576.0)
	if bytes >= 1024:
		return "%.0f KB" % (float(bytes) / 1024.0)
	return "%d B" % bytes

# --- Validación por ítem ---
func validar_item(tipo: String, bytes: int, formato: String = "") -> Dictionary:
	if not TIPOS_CON_PESO.has(tipo):
		return _res(false, MOTIVO_TIPO_DESCONOCIDO,
			"Tipo de contenido no reconocido: '%s' (válidos: %s)." % [tipo, _lista(TIPOS_CON_PESO)])
	if bytes <= 0:
		return _res(false, MOTIVO_BYTES_INVALIDOS, "El ítem no tiene contenido (0 bytes).")
	var tope := peso_max(tipo)
	if bytes > tope:
		# Si el redondeo humano deja ambos valores iguales (3.0 MB vs 3.0 MB),
		# el mensaje es inútil: en ese caso mostramos los bytes crudos.
		var h_bytes := _humano(bytes)
		var h_tope := _humano(tope)
		if h_bytes == h_tope:
			h_bytes = "%d B" % bytes
			h_tope = "%d B" % tope
		return _res(false, MOTIVO_PESO_EXCEDIDO,
			"%s demasiado grande: %s de %s permitidos." % [tipo.capitalize(), h_bytes, h_tope])
	if not formato_soportado(tipo, formato):
		return _res(false, MOTIVO_FORMATO_NO_SOPORTADO,
			"Formato '%s' no soportado para fotos (válidos: %s)." % [formato, _lista(formatos_foto())])
	return _ok()

# --- Validación por cuota ---
# `uso` = {"items_activos": int, "fotos_hoy": int, "blueprints_hoy": int, "bytes_hoy": int}
func validar_cuota(uso: Dictionary, tipo: String, bytes: int) -> Dictionary:
	if not TIPOS_CON_PESO.has(tipo):
		return _res(false, MOTIVO_TIPO_DESCONOCIDO,
			"Tipo de contenido no reconocido: '%s'." % tipo)
	if bytes <= 0:
		return _res(false, MOTIVO_BYTES_INVALIDOS, "El ítem no tiene contenido (0 bytes).")
	if _entero(uso, "items_activos", 0) + 1 > items_activos_max():
		return _res(false, MOTIVO_CUOTA_ITEMS,
			"Alcanzaste el máximo de %d ítems activos: eliminá alguno para publicar otro." % items_activos_max())
	if tipo == "foto":
		if _entero(uso, "fotos_hoy", 0) + 1 > fotos_por_dia_max():
			return _res(false, MOTIVO_CUOTA_DIARIA,
				"Límite diario de fotos alcanzado (%d). Probá mañana." % fotos_por_dia_max())
	else:
		if _entero(uso, "blueprints_hoy", 0) + 1 > blueprints_por_dia_max():
			return _res(false, MOTIVO_CUOTA_DIARIA,
				"Límite diario de diseños y construcciones alcanzado (%d). Probá mañana." % blueprints_por_dia_max())
	var hoy := _entero(uso, "bytes_hoy", 0)
	if hoy + bytes > bytes_por_dia_max():
		return _res(false, MOTIVO_CUOTA_BYTES,
			"Te queda menos de %s de subida hoy (límite %s)." % [
				_humano(bytes_por_dia_max() - hoy), _humano(bytes_por_dia_max())])
	return _ok()

# --- Validación completa (ítem + cuota) ---
func validar_subida(uso: Dictionary, tipo: String, bytes: int, formato: String = "") -> Dictionary:
	var r := validar_item(tipo, bytes, formato)
	if not r["ok"]:
		return r
	return validar_cuota(uso, tipo, bytes)

# --- Contabilidad: valida y, si pasa, descuenta la cuota ---
func consumir(uso: Dictionary, tipo: String, bytes: int, formato: String = "") -> Dictionary:
	var r := validar_subida(uso, tipo, bytes, formato)
	if not r["ok"]:
		return r
	uso["items_activos"] = _entero(uso, "items_activos", 0) + 1
	uso["bytes_hoy"] = _entero(uso, "bytes_hoy", 0) + bytes
	if tipo == "foto":
		uso["fotos_hoy"] = _entero(uso, "fotos_hoy", 0) + 1
	else:
		uso["blueprints_hoy"] = _entero(uso, "blueprints_hoy", 0) + 1
	return r

func uso_vacio() -> Dictionary:
	return {"items_activos": 0, "fotos_hoy": 0, "blueprints_hoy": 0, "bytes_hoy": 0}

func descripcion() -> String:
	return ("[M124] UgcLimits: %d ítems activos · %d fotos/día · %d blueprints/día · %s/día · "
		+ "pesos foto %s / blueprint %s / construcción %s · lado máx %d px") % [
			items_activos_max(), fotos_por_dia_max(), blueprints_por_dia_max(),
			_humano(bytes_por_dia_max()), _humano(peso_max("foto")),
			_humano(peso_max("blueprint")), _humano(peso_max("construccion")),
			lado_max_foto_px()]
