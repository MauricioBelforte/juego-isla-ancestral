class_name LicenseProfile
extends Resource
## M83 — LicenseProfile: perfil de licencia por dependencia.

@export var dependency_name: String = ""
@export var version: String = ""
@export var license_type: String = ""
@export var license_text: String = ""
@export var license_url: String = ""
@export var commercial_use: bool = true
@export var modifications_required: bool = false
@export var attribution_required: bool = false
@export var source_offer_required: bool = false
@export var notes: String = ""

func es_valido() -> bool:
	return dependency_name != "" and license_type != ""

func resumen() -> String:
	return "%s %s [%s] (comercial=%s, atrib=%s, src=%s)" % [
		dependency_name, version, license_type,
		commercial_use, attribution_required, source_offer_required
	]
