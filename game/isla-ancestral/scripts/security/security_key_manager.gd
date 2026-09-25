# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityKeyManager (helper reutilizable, V0 + headless).
# Implementa el servicio "KeyManager" del diseño (03-Diseno.md §3).
#
# ⚠️ HALLAZGO P-36: los 5 ítems de KeyManager en 05-Checklist.md estaban marcados `[x]`
# **sin ninguna implementación** (grep de `load_keys_from_environment|validate_keys|key_manager`
# sobre todo `scripts/` → 0 resultados). Era un falso verde HEREDADO (también en HEAD). Este
# archivo lo convierte en un `[x]` verdadero.
#
# Lógica pura (RefCounted, sin class_name → preload). El entorno se INYECTA (Dictionary) para
# poder testear sin tocar el proceso; si no se inyecta, lee `OS.get_environment`.

extends RefCounted

## Claves que el diseño §3 exige presentes.
const CLAVES_REQUERIDAS: Array = [
	"API_KEY", "STEAM_API_KEY", "ANALYTICS_KEY", "CRASH_REPORTING_KEY", "TAMPER_SECRET_KEY",
]

var keys: Dictionary = {}


## Carga las claves requeridas desde `entorno` (o del proceso si está vacío).
## Devuelve cuántas quedaron VACÍAS (0 = todas presentes).
## Si se inyecta un `entorno` NO vacío, NO cae a `OS.get_environment` (determinismo en tests).
func cargar_desde_entorno(entorno: Dictionary = {}) -> int:
	var usar_entorno: bool = not entorno.is_empty()
	var vacias: int = 0
	for nombre in CLAVES_REQUERIDAS:
		var valor: String = ""
		if usar_entorno:
			valor = str(entorno.get(nombre, ""))
		else:
			valor = OS.get_environment(nombre)
		keys[nombre] = valor
		if valor.is_empty():
			vacias += 1
	return vacias


## Valor de una clave ("" si no existe). Equivale a `get_key`.
func obtener(nombre: String) -> String:
	return str(keys.get(nombre, ""))


## ¿Están TODAS las claves cargadas y no vacías? Equivale a `validate_keys`.
func validar() -> bool:
	if keys.is_empty():
		return false
	for nombre in keys.keys():
		if str(keys[nombre]).is_empty():
			return false
	return true


## Nombres de las claves vacías (auditable; no expone valores).
func faltantes() -> Array:
	var out: Array = []
	for nombre in keys.keys():
		if str(keys[nombre]).is_empty():
			out.append(nombre)
	return out
