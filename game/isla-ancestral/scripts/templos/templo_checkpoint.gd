# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-14
#
# M26 — Templo Subterráneo (iteración 2).
# TemploCheckpoint: los 5 checkpoints del templo (porte, vestíbulo, vientos,
# central, sello) con GUARDADO ATÓMICO.
#
# Patrón atómico: se escribe `<cp>.json.tmp`, se respalda el anterior en
# `<cp>.json.bak` y recién entonces se renombra el temporal al definitivo. Si el
# proceso muere en el medio, el checkpoint previo (o su .bak) sigue intacto: no
# hay estado a medio escribir.
#
# ⚠️ Dos trampas medidas en este host (Godot 4.7.2 headless, `--path` relativo):
#   1. `DirAccess.make_dir_recursive()` NO es estático: la variante estática es
#      `make_dir_recursive_absolute()`. Y `DirAccess.new()` no existe (la clase
#      es abstracta) — ver `scripts/backup/backup_manager.gd` (M107), que está
#      roto justamente por eso.
#   2. `DirAccess.open("user://...")` devuelve **null** en este entorno, aunque
#      `FileAccess.open()` y las variantes `*_absolute()` sí resuelven `user://`.
#      Por eso acá se usan SOLO las funciones estáticas: `rename_absolute()`,
#      `remove_absolute()`, `get_files_at()`, `dir_exists_absolute()`.
#   `globalize_path("user://")` devuelve una ruta RELATIVA (`./Godot/app_userdata/
#   isla-ancestral/`), así que nunca se debe globalizar a mano: se pasa `user://`
#   tal cual a las funciones estáticas.

class_name TemploCheckpoint
extends RefCounted

## Ids de los 5 checkpoints del templo (03-Diseno, "Checkpoints (patrón M66)").
const CP_IDS := ["porte", "vestibulo", "vientos", "central", "sello"]

var dir: String = "user://templo/checkpoints"
var ultimo_error: String = ""
## De dónde salió la última carga con respaldo: "principal", "respaldo" o "".
var origen_carga: String = ""


func _init(dir_base: String = "user://templo/checkpoints") -> void:
	dir = dir_base


func ruta_cp(id: String) -> String:
	return "%s/cp_%s.json" % [dir, id]


func ruta_tmp(id: String) -> String:
	return "%s.tmp" % ruta_cp(id)


func ruta_bak(id: String) -> String:
	return "%s.bak" % ruta_cp(id)


## Crea el directorio de checkpoints si falta. Devuelve false y setea
## `ultimo_error` si no se pudo (en vez de fallar en silencio).
func asegurar_dir() -> bool:
	if DirAccess.dir_exists_absolute(dir):
		return true
	var e := DirAccess.make_dir_recursive_absolute(dir)
	if e != OK:
		ultimo_error = "no se pudo crear '%s' (err %d)" % [dir, e]
		return false
	return true


## Guardado atómico: tmp -> (bak del anterior) -> rename final.
func guardar(id: String, datos: Dictionary) -> bool:
	ultimo_error = ""
	if id.is_empty():
		ultimo_error = "id de checkpoint vacío"
		return false
	if not asegurar_dir():
		return false
	var ruta := ruta_cp(id)
	var tmp := ruta_tmp(id)
	var bak := ruta_bak(id)
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		ultimo_error = "no se pudo escribir '%s' (err %d)" % [tmp, FileAccess.get_open_error()]
		return false
	f.store_string(JSON.stringify(datos, "  "))
	f.close()
	# Respaldo del checkpoint anterior antes de pisarlo.
	if FileAccess.file_exists(ruta):
		if FileAccess.file_exists(bak):
			DirAccess.remove_absolute(bak)
		var e_bak := DirAccess.rename_absolute(ruta, bak)
		if e_bak != OK:
			ultimo_error = "no se pudo respaldar '%s' (err %d)" % [ruta, e_bak]
			return false
	var e := DirAccess.rename_absolute(tmp, ruta)
	if e != OK:
		ultimo_error = "no se pudo renombrar '%s' -> '%s' (err %d)" % [tmp, ruta, e]
		return false
	return true


func existe(id: String) -> bool:
	return FileAccess.file_exists(ruta_cp(id))


func respaldo_existe(id: String) -> bool:
	return FileAccess.file_exists(ruta_bak(id))


func cargar(id: String) -> Dictionary:
	ultimo_error = ""
	var ruta := ruta_cp(id)
	if not FileAccess.file_exists(ruta):
		ultimo_error = "no existe el checkpoint '%s'" % id
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) != TYPE_DICTIONARY:
		ultimo_error = "checkpoint '%s' corrupto (JSON inválido)" % id
		return {}
	return parsed as Dictionary


## Carga con respaldo: si el checkpoint principal está corrupto o falta, intenta
## el `.bak`. Devuelve el diccionario y deja en `origen_carga` de dónde salió.
func cargar_con_respaldo(id: String) -> Dictionary:
	var d := cargar(id)
	if not d.is_empty():
		origen_carga = "principal"
		return d
	var bak := ruta_bak(id)
	if FileAccess.file_exists(bak):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(bak))
		if typeof(parsed) == TYPE_DICTIONARY:
			origen_carga = "respaldo"
			ultimo_error = ""
			return parsed as Dictionary
	origen_carga = ""
	return {}


func borrar(id: String) -> bool:
	ultimo_error = ""
	var ok := true
	for ruta in [ruta_cp(id), ruta_tmp(id), ruta_bak(id)]:
		if FileAccess.file_exists(ruta):
			if DirAccess.remove_absolute(ruta) != OK:
				ok = false
				ultimo_error = "no se pudo borrar '%s'" % ruta
	return ok


## Ids de checkpoint presentes en disco, ordenados según CP_IDS.
func listar() -> Array[String]:
	var presentes: Array[String] = []
	for id in CP_IDS:
		if existe(id):
			presentes.append(id)
	return presentes


## Archivos conocidos de checkpoints presentes en disco (ids de CP_IDS × sus
## tres sufijos). ⚠️ NO se usa `DirAccess.get_files_at()` ni `DirAccess.open()`:
## en este entorno headless con `--path` relativo ambos devuelven vacío/null
## para rutas `user://`, mientras que `FileAccess` y las variantes `*_absolute()`
## sí resuelven. Derivar la lista de los ids conocidos evita esa trampa.
func archivos() -> PackedStringArray:
	var res := PackedStringArray()
	for id in CP_IDS:
		for ruta in [ruta_cp(id), ruta_tmp(id), ruta_bak(id)]:
			if FileAccess.file_exists(ruta):
				res.append(ruta.get_file())
	return res


## Cuenta los `.bak` en disco. (Se expone explícitamente porque el bug M107 fue
## justamente una `cantidad_backups()` que devolvía 0 por la ruta mal creada.)
func cantidad_backups() -> int:
	var n := 0
	for id in CP_IDS:
		if respaldo_existe(id):
			n += 1
	return n


## Cuenta los `.tmp` huérfanos: un `.tmp` que sobrevive indica un guardado
## interrumpido (el temporal nunca se renombró).
func cantidad_tmp_huerfanos() -> int:
	var n := 0
	for id in CP_IDS:
		if FileAccess.file_exists(ruta_tmp(id)):
			n += 1
	return n


## Valida la integridad del directorio de checkpoints. Devuelve la lista de
## problemas (vacía = sano). Usado por la suite anti-softlock.
func validar_atomico() -> Array[String]:
	var errores: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir):
		errores.append("directorio de checkpoints inexistente: %s" % dir)
		return errores
	for id in listar():
		if not respaldo_existe(id):
			errores.append("checkpoint '%s' sin respaldo .bak" % id)
		if FileAccess.file_exists(ruta_tmp(id)):
			errores.append("checkpoint '%s' dejó un .tmp huérfano" % id)
	return errores
