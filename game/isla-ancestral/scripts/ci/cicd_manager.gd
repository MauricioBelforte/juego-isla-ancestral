# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M118 iter. 2 — Escaneo de assets con presupuesto M166 (E-33/E-40: tris reales
# con loop_triangles, no polygons), validador de JSON data-driven, y gates
# automáticos. Ejecutar: blender --background --python escanear_assets.py <media_dir>
# O desde Godot: Godot --headless --script res://scripts/ci/escanear_assets.py
#
# Este script es un Node del autoload (no se ejecuta solo) — el escaneo real
# es un script standalone que corre fuera del engine.

extends Node

const RUTA_GATES := "res://data/ci/ci_gates.json"

var config: Dictionary = {}
var resultados: Dictionary = {}   # requisito -> bool (resultados de la corrida)
var fallos_consecutivos: int = 0  # M118 iter. 3: fallback manual tras 3 fallos

func _ready() -> void:
	_cargar_config()
	_registrar_servicio()
	print("[M118] CiCdManager listo (%d gates)" % config.get("gates", {}).size())

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_GATES):
		push_warning("[M118] ci_gates.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_GATES))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("cicd"):
		sr.register("cicd", self)

## Registra el resultado de un requisito (ej: "tests_ok" -> true).
func registrar_resultado(requisito: String, ok: bool) -> void:
	resultados[requisito] = ok

## Verifica un gate: devuelve {ok, faltantes: Array, presentes: Array}.
func verificar_gate(gate_id: String) -> Dictionary:
	var gate: Dictionary = config.get("gates", {}).get(gate_id, {})
	if gate.is_empty():
		return {"ok": false, "faltantes": ["gate_inexistente_%s" % gate_id], "presentes": []}
	var requisitos: Array = gate.get("requisitos", [])
	var presentes: Array = []
	var faltantes: Array = []
	for req in requisitos:
		if resultados.get(req, false):
			presentes.append(req)
		else:
			faltantes.append(req)
	return {"ok": faltantes.is_empty(), "faltantes": faltantes, "presentes": presentes}

## Checklist de integración: devuelve el checklist configurado.
func checklist_integracion() -> Array:
	return config.get("checklist_integracion", [])

## Reporte legible de un gate para CI/QA.
func reporte_gate(gate_id: String) -> String:
	var r := verificar_gate(gate_id)
	var gate: Dictionary = config.get("gates", {}).get(gate_id, {})
	if r["ok"]:
		return "[M118] Gate '%s': OK — %d requisitos cumplidos" % [gate_id, (r["presentes"] as Array).size()]
	var lineas: Array = ["[M118] Gate '%s': FALLA — faltan: %s" % [gate_id, str(r["faltantes"])]]
	return "\n".join(lineas)

# ═══════════ Iter. 2 (glm-5.3-flash): validador de data + gates de optimización ═══════════

## RF del gate "data_valid": escanea los subdirectorios conocidos de data/
## y verifica que los .json parseen sin error. Sin recursión (res:// safe).
func validar_data_json() -> Dictionary:
	var total := 0
	var errores := 0
	var detalles: Array[String] = []
	var subdirs := ["balance", "ci", "clima", "eventos", "mineria", "vegetacion"]
	for sub in subdirs:
		var ruta: String = "res://data/" + sub
		var dir := DirAccess.open(ruta)
		if dir == null:
			continue
		for archivo in dir.get_files():
			var fname: String = String(archivo)
			if fname.ends_with(".json"):
				total += 1
				var texto: String = FileAccess.get_file_as_string(ruta + "/" + fname)
				var parsed: Variant = JSON.parse_string(texto)
				if parsed == null:
					errores += 1
					detalles.append("JSON inválido: %s/%s" % [ruta, fname])
	return {"total": total, "errores": errores, "detalles": detalles,
		"ok": errores == 0}

## Gate "data_valid": ejecuta validar_data_json() y registra el resultado.
func gate_data_valid() -> bool:
	var r := validar_data_json()
	var ok := bool(r.get("ok", false))
	registrar_resultado("data_json_valido", ok)
	if not ok:
		for det in r.get("detalles", []):
			push_error("[M118] " + str(det))
	print("[M118] data_valid: %d archivos, %d errores" % [int(r.get("total", 0)), int(r.get("errores", 0))])
	return ok

## Gate "m166_budget": verifica que los assets .glb en media/ no excedan el
## presupuesto de triángulos (necesita Blender — este método solo valida que
## los archivos existan y no estén vacíos; el conteo de tris lo hace Blender).
func gate_assets_existen() -> bool:
	var rutas := ["res://assets/3d/media/"]
	var total := 0
	var vacios := 0
	for ruta in rutas:
		var dir := DirAccess.open(ruta)
		if dir == null:
			continue
		for archivo in dir.get_files():
			var fname: String = String(archivo)
			if fname.ends_with(".glb"):
				total += 1
				var f := FileAccess.open(ruta + "/" + fname, FileAccess.READ)
				if f == null or f.get_length() < 100:
					vacios += 1
					push_warning("[M118] GLB sospechoso (vacío): %s" % fname)
				elif f:
					f.close()
	registrar_resultado("assets_glb_presentes", vacios == 0 and total > 0)
	print("[M118] assets_glb: %d archivos, %d vacíos" % [total, vacios])
	return vacios == 0

## Ejecuta TODOS los gates automáticos y retorna el resumen.
func ejecutar_gates_automaticos() -> Dictionary:
	var res := {}
	res["data_valid"] = gate_data_valid()
	res["assets_existen"] = gate_assets_existen()
	var ok := true
	for k in res:
		if not res[k]:
			ok = false
	print("[M118] Gates automáticos: %s" % ("TODOS OK" if ok else "HAY FALLOS"))
	return res

# ═══════════ Iter. 3 (glm-5.3-flash): artefactos — semver, SHA256, firma ═══════════

const CARPETA_ARTEFACTOS := "user://artefactos"
const REGEX_SEMVER := "^v(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$"

## RF5/P5: valida un tag de release semántico vX.Y.Z.
## Retorna {ok, version, major, minor, patch, motivo} — motivo vacío si ok.
func validar_tag_semver(tag: String) -> Dictionary:
	var re := RegEx.new()
	if re.compile(REGEX_SEMVER) != OK:
		return {"ok": false, "version": "", "motivo": "regex_semver_invalida"}
	var m := re.search(tag.strip_edges())
	if m == null:
		return {"ok": false, "version": "", "motivo": "formato_invalido (esperado vX.Y.Z)"}
	var res := {"ok": true, "version": tag.strip_edges(),
		"major": int(m.get_string(1)), "minor": int(m.get_string(2)),
		"patch": int(m.get_string(3)), "motivo": ""}
	registrar_resultado("tag_semver_valido", true)
	return res

## RF7: gate de calidad — exige lint, tests y análisis estático registrados.
func gate_calidad_codigo() -> bool:
	var requeridos := ["lint_ok", "tests_ok", "analisis_estatico_ok"]
	var faltan: Array = []
	for req in requeridos:
		if not resultados.get(req, false):
			faltan.append(req)
	var ok := faltan.is_empty()
	registrar_resultado("calidad_verificada", ok)
	print("[M118] gate_calidad: %s" % ("OK" if ok else "faltan " + str(faltan)))
	return ok

## Fallback manual (RF de iter. 1): tras 3 fallos consecutivos del pipeline,
## marca el estado para despliegue manual y retorna true si se activó.
func registrar_fallo_pipeline() -> bool:
	fallos_consecutivos += 1
	if fallos_consecutivos >= 3:
		registrar_resultado("fallback_manual_activo", true)
		push_warning("[M118] 3 fallos consecutivos: activado fallback manual")
		return true
	return false

## Resetea el contador de fallos consecutivos (llamar tras un pipeline OK).
func registrar_exito_pipeline() -> void:
	fallos_consecutivos = 0
	registrar_resultado("fallback_manual_activo", false)

## Genera un artefacto comprimido (ZIP) desde una lista de archivos fuente.
## Retorna {ok, ruta, sha256} — el ZIP incluye SHA256SUMS.txt interno.
func generar_artefacto(nombre: String, archivos: Array, etiqueta_version: String) -> Dictionary:
	var dir := DirAccess.open(CARPETA_ARTEFACTOS)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(CARPETA_ARTEFACTOS)
		dir = DirAccess.open(CARPETA_ARTEFACTOS)
	if dir == null:
		return {"ok": false, "ruta": "", "sha256": "", "motivo": "no_se_pudo_crear_directorio"}
	var ruta_zip := "%s/%s-%s.zip" % [CARPETA_ARTEFACTOS, nombre, etiqueta_version]
	var writer := ZIPPacker.new()
	if writer.open(ruta_zip) != OK:
		return {"ok": false, "ruta": ruta_zip, "sha256": "", "motivo": "no_se_pudo_abrir_zip"}
	var resumen_sha := PackedStringArray()
	for ruta_archivo in archivos:
		if not FileAccess.file_exists(ruta_archivo):
			writer.close()
			return {"ok": false, "ruta": ruta_zip, "sha256": "", "motivo": "archivo_faltante: " + str(ruta_archivo)}
		var datos := FileAccess.get_file_as_bytes(ruta_archivo)
		# 4.7.2: start_file cierra el archivo anterior; no existe finish_file().
		writer.start_file(String(ruta_archivo).get_file())
		writer.write_file(datos)
		resumen_sha.append("%s  %s" % [_sha256_bytes(datos), String(ruta_archivo).get_file()])
	writer.start_file("SHA256SUMS.txt")
	writer.write_file("\n".join(resumen_sha).to_utf8_buffer())
	writer.close()
	var sha_zip := _sha256_archivo(ruta_zip)
	var size_bytes := 0
	var fz := FileAccess.open(ruta_zip, FileAccess.READ)
	if fz:
		size_bytes = int(fz.get_length())
		fz.close()
	print("[M118] Artefacto generado: %s (sha256=%s, %d bytes)" % [ruta_zip, sha_zip, size_bytes])
	return {"ok": true, "ruta": ruta_zip, "sha256": sha_zip, "size_bytes": size_bytes, "motivo": ""}

## Firma digital (RF iter. 1: firma de binarios — HMAC-SHA256 como sustituto
## portable de GPG en runtime; el pipeline de CI usa GPG real en el runner).
## Genera claves una sola vez y firma el contenido dado.
func firmar_artefacto(contenido_sha256: String) -> Dictionary:
	var clave := _cargar_o_generar_clave()
	var firma := HMACContext.new()
	if firma.start(HashingContext.HASH_SHA256, clave) != OK:
		return {"ok": false, "firma": "", "motivo": "hmac_start_fallo"}
	firma.update(contenido_sha256.to_utf8_buffer())
	var hex := firma.finish().hex_encode()
	registrar_resultado("artefacto_firmado", true)
	print("[M118] Artefacto firmado (HMAC-SHA256): %s..." % hex.substr(0, 16))
	return {"ok": true, "firma": hex, "algoritmo": "HMAC-SHA256", "motivo": ""}

## Verifica la firma de un artefacto contra su SHA256.
func verificar_firma(contenido_sha256: String, firma_hex: String) -> bool:
	var clave := _cargar_o_generar_clave()
	var firma := HMACContext.new()
	firma.start(HashingContext.HASH_SHA256, clave)
	firma.update(contenido_sha256.to_utf8_buffer())
	return firma.finish().hex_encode() == firma_hex

## Retención J: elimina artefactos más viejos que dias_maximo (default 30).
## Los ZIP se mantienen según la fecha de modificación del archivo.
func limpiar_artefactos(dias_maximo: int = 30) -> Dictionary:
	var dir := DirAccess.open(CARPETA_ARTEFACTOS)
	if dir == null:
		return {"eliminados": 0, "ok": true}
	var eliminados := 0
	var ahora := Time.get_unix_time_from_system()
	for archivo in dir.get_files():
		var ruta := CARPETA_ARTEFACTOS + "/" + String(archivo)
		var edad_seg := ahora - FileAccess.get_modified_time(ruta)
		if edad_seg > dias_maximo * 86400.0:
			dir.remove(String(archivo))
			eliminados += 1
	print("[M118] Limpieza de artefactos: %d eliminados (>%d días)" % [eliminados, dias_maximo])
	return {"eliminados": eliminados, "ok": true}

## SHA256 de un archivo completo.
func _sha256_archivo(ruta: String) -> String:
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return ""
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	while f.get_position() < f.get_length():
		ctx.update(f.get_buffer(65536))
	var h := ctx.finish().hex_encode()
	f.close()
	return h

func _sha256_bytes(datos: PackedByteArray) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(datos)
	return ctx.finish().hex_encode()

## Clave HMAC persistente en user:// (se genera una vez).
func _cargar_o_generar_clave() -> PackedByteArray:
	var ruta := CARPETA_ARTEFACTOS + "/clave_firma.key"
	if FileAccess.file_exists(ruta):
		var hex := FileAccess.get_file_as_string(ruta).strip_edges()
		return PackedByteArray(hex.hex_decode())
	DirAccess.make_dir_recursive_absolute(CARPETA_ARTEFACTOS)
	var clave := PackedByteArray()
	for i in 32:
		clave.append(randi() % 256)
	FileAccess.open(ruta, FileAccess.WRITE).store_string(clave.hex_encode())
	return clave
