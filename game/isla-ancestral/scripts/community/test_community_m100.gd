# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M100: Community Management — Test headless
# Valida: CommunityManager (canales, calendario, eventos por canal/tipo,
# KPIs). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M100] Test de Community Management ===")
	_test_manager()
	_test_calendario()
	_test_kpis()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_manager() -> void:
	print("--- CommunityManager: config data-driven ---")
	var cm := root.get_node_or_null("CommunityManager")
	if cm == null:
		_check("CommunityManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("CommunityManager autoload presente", true)
	_check("5 canales", cm.canales().size() == 5, "size=%d" % cm.canales().size())
	_check("4 eventos calendario", cm.config.get("calendario", []).size() == 4, "size=%d" % cm.config.get("calendario", []).size())

func _test_calendario() -> void:
	print("--- Calendario: por canal y tipo ---")
	var cm := root.get_node_or_null("CommunityManager")
	var discord = cm.eventos_por_canal("discord")
	_check("1 evento en discord", discord.size() == 1, "size=%d" % discord.size())
	var devlog = cm.eventos_por_tipo("devlog")
	_check("1 devlog mensual", devlog.size() == 1, "size=%d" % devlog.size())
	var semanales = cm.eventos_por_tipo("anuncio")
	_check("1 anuncio semanal", semanales.size() == 1)

func _test_kpis() -> void:
	print("--- KPIs ---")
	var cm := root.get_node_or_null("CommunityManager")
	var kpis = cm.kpis()
	_check("4 KPIs", kpis.size() == 4, "size=%d" % kpis.size())
	_check("miembros en KPIs", "miembros" in kpis)

func _summary() -> void:
	print("=== Resumen M100: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M100 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M100 OK — todos los checks pasaron")
		quit(0)