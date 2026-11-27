# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M85: Modelos 3D Legal — ModelLicense (Resource)
# Representa la licencia de UN asset/modelo 3D. Un asset puede tener VARIAS
# licencias (ej: mesh CC-BY del artista + textura propia del estudio): por eso
# ModelLegalManager guarda Array[ModelLicense] por asset_id.
# Espejo de scripts/legal/audio_license.gd (M84, mimo-v2.5).
# Sin class_name en managers, pero el Resource SÍ lleva class_name (igual que
# AudioLicense) para que los validadores lo tipen.

class_name ModelLicense
extends Resource

## Tipos de licencia (mismos valores que AudioLicense.LicenseType, M84)
enum LicenseType {
	PROPIA,       ## Derechos totales del estudio
	MIT,          ## Licencia permisiva
	CC0,          ## Dominio público
	CC_BY,        ## Creative Commons atribución
	CC_BY_SA,     ## CC atribución-share alike
	CC_BY_NC,     ## CC no comercial (RECHAZADA para uso comercial)
	OTRO          ## Otra (verificar)
}

## Origen del asset (data/legal/modelos_3d.json: campo "origen")
enum Origen {
	PROPIO,       ## Modelado interno del proyecto
	COMPRADO,     ## Comprado en marketplace (con licencia)
	STOCK,        ## Librería de stock
	IA            ## Generado/retopologado con IA (M86: declarar herramienta)
}

## Datos del asset
@export var asset_id: String = ""
@export var nombre: String = ""
@export var artista: String = ""

## Origen y licencia
@export var origen: Origen = Origen.PROPIO
@export var license_type: LicenseType = LicenseType.PROPIA
@export var uso_comercial: bool = true

## Alcance de la licencia
@export var perpetua: bool = true
@export var duracion: String = "perpetua"
@export var territorio: String = "mundial"
@export var documento_licencia_ruta: String = ""

## Atribución (CC-BY la exige)
@export var attribution_requerida: bool = false
@export var attribution_texto: String = ""

## Notas de auditoría
@export var notas: String = ""
@export var verificada: bool = false
@export var fecha_verificacion: String = ""


func es_valida() -> bool:
	if asset_id.is_empty():
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


func es_perpetua() -> bool:
	return perpetua and duracion.to_lower() == "perpetua"


## Texto de atribución para créditos: usa el texto declarado si existe;
## si no, deriva "artista — nombre".
func generar_texto_atribucion() -> String:
	if attribution_texto.is_empty():
		return "%s — %s" % [artista, nombre]
	return attribution_texto


func to_dict() -> Dictionary:
	return {
		"asset_id": asset_id,
		"nombre": nombre,
		"artista": artista,
		"origen": Origen.keys()[origen],
		"license_type": LicenseType.keys()[license_type],
		"uso_comercial": uso_comercial,
		"perpetua": perpetua,
		"duracion": duracion,
		"territorio": territorio,
		"documento_licencia_ruta": documento_licencia_ruta,
		"attribution_requerida": attribution_requerida,
		"attribution_texto": attribution_texto,
		"notas": notas,
		"verificada": verificada,
		"fecha_verificacion": fecha_verificacion,
	}


static func from_dict(dict: Dictionary) -> ModelLicense:
	var lic := ModelLicense.new()
	lic.asset_id = String(dict.get("asset_id", ""))
	lic.nombre = String(dict.get("nombre", ""))
	lic.artista = String(dict.get("artista", ""))
	lic.origen = Origen.get(String(dict.get("origen", "PROPIO")), Origen.PROPIO)
	lic.license_type = LicenseType.get(String(dict.get("license_type", "PROPIA")), LicenseType.PROPIA)
	lic.uso_comercial = bool(dict.get("uso_comercial", true))
	lic.perpetua = bool(dict.get("perpetua", true))
	lic.duracion = String(dict.get("duracion", "perpetua"))
	lic.territorio = String(dict.get("territorio", "mundial"))
	lic.documento_licencia_ruta = String(dict.get("documento_licencia_ruta", ""))
	lic.attribution_requerida = bool(dict.get("attribution_requerida", false))
	lic.attribution_texto = String(dict.get("attribution_texto", ""))
	lic.notas = String(dict.get("notas", ""))
	lic.verificada = bool(dict.get("verificada", false))
	lic.fecha_verificacion = String(dict.get("fecha_verificacion", ""))
	return lic
