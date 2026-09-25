# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityAuditLogger (helper reutilizable, V0 + headless).
# Implementa el servicio "AuditLogger" del diseño (03-Diseno.md §9), que quedó `[ ]`:
#   audit_logs (var)   -> registros (Array, público)
#   log_access         -> registrar
#   print_audit_log    -> formatear   (devuelve la línea; el test la asevera, no se imprime a ciegas)
#   save_audit_logs    -> guardar     (crea el directorio destino si falta)
# Lógica pura (RefCounted, sin class_name → preload). Complementa el audit log del autoload
# (`registrar_acceso`/`volcar_audit_log`, JSON Lines con retención); este helper es la variante
# en memoria + volcado JSON completo del diseño §9.
#
# ⚠️ No expone PII: `registrar` guarda el `usuario` tal cual lo reciba el llamador; el saneamiento
# de PII es responsabilidad del llamador (M106 `no_logs_sensibles`).

extends RefCounted

var registros: Array = []


## Registra un acceso importante. Devuelve la entrada creada.
## `resultado` true = SUCCESS, false = FAILURE. `ts` <= 0 usa la hora del sistema.
func registrar(usuario: String, accion: String, resultado: bool, ts: float = -1.0) -> Dictionary:
	var marca: float = ts if ts > 0.0 else Time.get_unix_time_from_system()
	var entrada := {
		"timestamp": marca,
		"usuario": usuario,
		"accion": accion,
		"resultado": resultado,
	}
	registros.append(entrada)
	return entrada


## Línea legible de una entrada (equivalente a `print_audit_log`, sin imprimir).
func formatear(entrada: Dictionary) -> String:
	var estado: String = "SUCCESS" if bool(entrada.get("resultado", false)) else "FAILURE"
	return "AUDIT: [%s] User: %s, Action: %s, Result: %s" % [
		str(entrada.get("timestamp", 0.0)),
		str(entrada.get("usuario", "")),
		str(entrada.get("accion", "")),
		estado,
	]


## Vuelca todos los registros a un JSON en `ruta` (crea el directorio si falta).
## Devuelve true si escribió; false si no pudo abrir el archivo.
func guardar(ruta: String = "user://logs/audit.json") -> bool:
	var dir: String = ruta.get_base_dir()
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(registros))
	f.close()
	return true


func cantidad() -> int:
	return registros.size()


func limpiar() -> void:
	registros.clear()
