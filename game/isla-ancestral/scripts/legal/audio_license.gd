# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M84: Música y Audio Legal — AudioLicense (Resource)
# Representa la licencia de un track de audio. Usado por AudioLegalManager
# y AudioLicenseValidator para rastrear estado legal de cada pieza musical.

class_name AudioLicense
extends Resource

## Tipos de audio
enum AudioType {
	COMPOSICION_ORIGINAL,   ## Compuesta para el juego
	LIBRERIA_STOCK,         ## Comprada/libre de bancos
	Generada_POR_IA,        ## Generada con herramientas de IA
	SAMPLE,                 ## Muestra de otra obra
	DISENO_SONORO,          ## Diseño de efectos
	ACTUACION_VOCAL         ## Voice acting
}

## Tipos de licencia
enum LicenseType {
	PROPIA,                 ## Derechos totales del estudio
	MIT,                    ## Licencia permisiva
	CC0,                    ## Dominio público
	CC_BY,                  ## Creative Commons atribución
	CC_BY_SA,               ## CC atribución-share alike
	CC_BY_NC,               ## CC no comercial (RECHAZADA)
	OTRO                    ## Otra (verificar)
}

## alcance de la licencia
enum LicenseScope {
	EXCLUSIVA,
	NO_EXCLUSIVA,
	SOLO_UNA_VEZ
}

## Datos del track
@export var track_id: String
@export var titulo: String
@export var autor: String
@export var audio_type: AudioType
@export var license_type: LicenseType
@export var license_scope: LicenseScope

## Datos de la licencia
@export var perpetua: bool = true
@export var uso_comercial: bool = true
@export var attribution_requerida: bool = false
@export var attribution_texto: String = ""
@export var regalías_requeridas: bool = false
@export var tasa_regalias: float = 0.0
@export var territorio: String = "mundial"
@export var duracion: String = "perpetua"
@export var documento_licencia_ruta: String = ""
@export var notas: String = ""

## Estado de la licencia
@export var verificada: bool = false
@export var fecha_verificacion: String = ""


func es_valida() -> bool:
	if track_id.is_empty():
		return false
	if license_type == LicenseType.CC_BY_NC:
		return false
	if not uso_comercial:
		return false
	if attribution_requerida and attribution_texto.is_empty():
		return false
	return true


func tiene_atribucion_requerida() -> bool:
	return attribution_requerida and not attribution_texto.is_empty()


func generar_texto_atribucion() -> String:
	if attribution_texto.is_empty():
		return "%s — %s" % [autor, titulo]
	return attribution_texto


func to_dict() -> Dictionary:
	return {
		"track_id": track_id,
		"titulo": titulo,
		"autor": autor,
		"audio_type": AudioType.keys()[audio_type],
		"license_type": LicenseType.keys()[license_type],
		"license_scope": LicenseScope.keys()[license_scope],
		"perpetua": perpetua,
		"uso_comercial": uso_comercial,
		"attribution_requerida": attribution_requerida,
		"attribution_texto": attribution_texto,
		"regalias_requeridas": regalías_requeridas,
		"tasa_regalias": tasa_regalias,
		"territorio": territorio,
		"duracion": duracion,
		"documento_licencia_ruta": documento_licencia_ruta,
		"notas": notas,
		"verificada": verificada,
		"fecha_verificacion": fecha_verificacion,
	}


static func from_dict(dict: Dictionary) -> AudioLicense:
	var lic := AudioLicense.new()
	lic.track_id = String(dict.get("track_id", ""))
	lic.titulo = String(dict.get("titulo", ""))
	lic.autor = String(dict.get("autor", ""))
	lic.audio_type = AudioType.get(String(dict.get("audio_type", "COMPOSICION_ORIGINAL")), AudioType.COMPOSICION_ORIGINAL)
	lic.license_type = LicenseType.get(String(dict.get("license_type", "PROPIA")), LicenseType.PROPIA)
	lic.license_scope = LicenseScope.get(String(dict.get("license_scope", "EXCLUSIVA")), LicenseScope.EXCLUSIVA)
	lic.perpetua = bool(dict.get("perpetua", true))
	lic.uso_comercial = bool(dict.get("uso_comercial", true))
	lic.attribution_requerida = bool(dict.get("attribution_requerida", false))
	lic.attribution_texto = String(dict.get("attribution_texto", ""))
	lic.regalías_requeridas = bool(dict.get("regalias_requeridas", false))
	lic.tasa_regalias = float(dict.get("tasa_regalias", 0.0))
	lic.territorio = String(dict.get("territorio", "mundial"))
	lic.duracion = String(dict.get("duracion", "perpetua"))
	lic.documento_licencia_ruta = String(dict.get("documento_licencia_ruta", ""))
	lic.notas = String(dict.get("notas", ""))
	lic.verificada = bool(dict.get("verificada", false))
	lic.fecha_verificacion = String(dict.get("fecha_verificacion", ""))
	return lic
