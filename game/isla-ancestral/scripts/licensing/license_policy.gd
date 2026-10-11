class_name LicensePolicy
extends Resource
## M83 — LicensePolicy: política de licencias del proyecto.

enum CopyleftMode { ALLOW, ISOLATE, DENY }

@export var policy_name: String = ""
@export var allowed_licenses: Array[String] = []
@export var prohibited_licenses: Array[String] = []
@export var copyleft_mode: int = CopyleftMode.ALLOW
@export var require_attribution: bool = true
@export var require_source_offer: bool = false

func licencia_permitida(lic: String) -> bool:
	if prohibited_licenses.has(lic):
		return false
	if allowed_licenses.is_empty():
		return true
	return allowed_licenses.has(lic)

func copyleft_label() -> String:
	match copyleft_mode:
		CopyleftMode.ALLOW: return "ALLOW"
		CopyleftMode.ISOLATE: return "ISOLATE"
		_: return "DENY"
