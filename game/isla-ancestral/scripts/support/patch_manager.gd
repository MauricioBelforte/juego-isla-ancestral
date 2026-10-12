# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M121: Soporte Post-Lanzamiento — PatchManager
# Proceso de parches para bugs NO criticos (cosmeticos, menores, QoL).
# Cadencia mensual/trimestral. Diseno: 04-Codigo.md sec.8.
#
# Divergencia declarada: RefCounted instanciado por SupportManager en vez de
# autoload propio (no tocar project.godot). El deployment real en Steam es
# manual/externo; aca se modela el ciclo y el changelog.

class_name PatchManager
extends RefCounted

const DIAS_CADENCIA_MIN := 30
const DIAS_CADENCIA_MAX := 90
const FASES := ["acumulando", "corrigiendo", "testeando", "desplegado", "documentado"]

signal parche_desplegado(patch_version: String)

var parches: Dictionary = {}
var _contador: int = 0

func create_patch(patch_version: String, bug_ids: Array = []) -> Dictionary:
	_contador += 1
	parches[patch_version] = {
		"patch_version": patch_version,
		"bug_ids": bug_ids.duplicate(),
		"fase": "acumulando",
		"desplegado": false,
		"cadencia_dias": DIAS_CADENCIA_MIN,
		"creado_ts": Time.get_unix_time_from_system(),
	}
	return parches[patch_version].duplicate(true)

func acumular_bug(patch_version: String, bug_id: String) -> bool:
	if not parches.has(patch_version):
		return false
	var p: Dictionary = parches[patch_version]
	var ids: Array = p.get("bug_ids", [])
	if ids.has(bug_id):
		return false
	ids.append(bug_id)
	p["bug_ids"] = ids
	return true

func avanzar_fase(patch_version: String, fase: String) -> bool:
	if not parches.has(patch_version) or not FASES.has(fase):
		return false
	var p: Dictionary = parches[patch_version]
	p["fase"] = fase
	return true

func get_patch(patch_version: String) -> Dictionary:
	if parches.has(patch_version):
		var p: Dictionary = parches[patch_version]
		return p.duplicate(true)
	return {}

func deploy_patch(patch_version: String) -> bool:
	if not parches.has(patch_version):
		return false
	var p: Dictionary = parches[patch_version]
	p["fase"] = "desplegado"
	p["desplegado"] = true
	parche_desplegado.emit(patch_version)
	return true

func update_changelog(patch_version: String, bug_ids: Array = []) -> String:
	if not parches.has(patch_version):
		return ""
	var p: Dictionary = parches[patch_version]
	var ids: Array = p.get("bug_ids", [])
	if ids.is_empty() and not bug_ids.is_empty():
		ids = bug_ids.duplicate()
	var lineas: Array = ["Changelog %s:" % patch_version]
	for b in ids:
		lineas.append("  - %s" % str(b))
	var changelog := "\n".join(lineas)
	p["changelog"] = changelog
	p["fase"] = "documentado"
	return changelog

func total() -> int:
	return parches.size()
