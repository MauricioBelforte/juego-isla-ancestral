# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M121: Soporte Post-Lanzamiento — HotfixManager
# Proceso de hotfixes para bugs criticos (crash, savegame corrupto,
# performance severa, exploit). SLA 24-48 h. Diseno: 04-Codigo.md sec.7.
#
# Divergencia declarada: RefCounted instanciado por SupportManager en vez de
# autoload propio (no tocar project.godot). El proceso se modela como una
# maquina de fases trazable; el deployment real en Steam es manual/externo.

class_name HotfixManager
extends RefCounted

const HORAS_SLA_MIN := 24
const HORAS_SLA_MAX := 48
const FASES := ["identificado", "reproducido", "corregido", "testeado", "desplegado", "comunicado"]

signal hotfix_desplegado(hotfix_version: String)

var hotfixes: Dictionary = {}
var _por_version: Dictionary = {}
var _contador: int = 0

func trigger_hotfix(bug_id: String, version: String = "") -> String:
	_contador += 1
	var hf_id := "HF%04d" % _contador
	hotfixes[hf_id] = {
		"hotfix_id": hf_id,
		"bug_id": bug_id,
		"version": version,
		"fase": "identificado",
		"fases": ["identificado"],
		"desplegado": false,
		"sla_horas": HORAS_SLA_MAX,
	}
	if version != "":
		_por_version[version] = hf_id
	return hf_id

func avanzar_fase(hotfix_id: String, fase: String) -> bool:
	if not hotfixes.has(hotfix_id) or not FASES.has(fase):
		return false
	var h: Dictionary = hotfixes[hotfix_id]
	h["fase"] = fase
	var fs: Array = h.get("fases", [])
	if not fs.has(fase):
		fs.append(fase)
	h["fases"] = fs
	return true

func get_hotfix(hotfix_id: String) -> Dictionary:
	if hotfixes.has(hotfix_id):
		var h: Dictionary = hotfixes[hotfix_id]
		return h.duplicate(true)
	return {}

func deploy_hotfix(hotfix_version: String) -> bool:
	if not _por_version.has(hotfix_version):
		return false
	var hf_id := String(_por_version[hotfix_version])
	if not hotfixes.has(hf_id):
		return false
	var h: Dictionary = hotfixes[hf_id]
	h["fase"] = "desplegado"
	h["desplegado"] = true
	var fs: Array = h.get("fases", [])
	if not fs.has("desplegado"):
		fs.append("desplegado")
	h["fases"] = fs
	hotfix_desplegado.emit(hotfix_version)
	return true

func communicate_hotfix(hotfix_version: String, bug_description: String) -> String:
	var anuncio := "[HOTFIX %s] Se corrigio: %s. Actualiza el juego para aplicar el fix." % [hotfix_version, bug_description]
	if _por_version.has(hotfix_version):
		var hf_id := String(_por_version[hotfix_version])
		if hotfixes.has(hf_id):
			var h: Dictionary = hotfixes[hf_id]
			h["anuncio"] = anuncio
			var fs: Array = h.get("fases", [])
			if not fs.has("comunicado"):
				fs.append("comunicado")
			h["fases"] = fs
	return anuncio

func total() -> int:
	return hotfixes.size()

func desplegados() -> Array:
	var out: Array = []
	for id in hotfixes:
		var h: Dictionary = hotfixes[id]
		if bool(h.get("desplegado", false)):
			out.append(id)
	return out
