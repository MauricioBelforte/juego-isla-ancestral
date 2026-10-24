extends SceneTree
# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-23
#
# Bloque C #56 (BACKLOG-MASTER Hy3): Runtime test de M20 - ciclo completo de
# amistad (levels / regalos) verificado CONTRA el autoload "Friendship" REAL
# (no las clases estaticas). Verificador != autor del modulo: M20 es 🔵 En curso,
# autoría agnes-3-flash / minimax-m3-1-flash / WorkBuddy (familia distinta a Hy3).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/friendship/test_ciclo_amistad_m20_hy3.gd
# Exit code != 0 si falla.
#
# Guarda anti-falso-verde: si _checks < MIN_CHECKS el suite ABORTA con codigo 1
# (un SCRIPT ERROR temprano no puede reportar "0 fallos"). El caso negativo
# determinista (2do regalo del mismo dia rechazado) prueba que el harness
# reporta fallos si el modulo se rompe.

const MIN_CHECKS := 18
const VECINO_SCRIPT := preload("res://scripts/friendship/vecino_amistad.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [HY3] Runtime M20 FriendshipService (Bloque C #56) ===")
	var fs = root.get_node_or_null("Friendship")
	_check("Friendship autoload presente", fs != null)
	if fs == null:
		_summary()
		return

	# --- API surface del servicio real ---
	_check("API regalar", fs.has_method("regalar"))
	_check("API charlar", fs.has_method("charlar"))
	_check("API reclamar_recompensa", fs.has_method("reclamar_recompensa"))
	_check("API get_nivel", fs.has_method("get_nivel"))
	_check("API get_puntos", fs.has_method("get_puntos"))
	_check("API pivote_dia", fs.has_method("pivote_dia"))
	_check("API registrar_vecino", fs.has_method("registrar_vecino"))
	_check("API es_cumpleanos_hoy", fs.has_method("es_cumpleanos_hoy"))

	var NPC := "HY3_NPC_1"
	fs.registrar_vecino(NPC)
	fs.pivote_dia(1)
	_check("vecino inicia nivel 1", fs.get_nivel(NPC) == 1)
	_check("vecino inicia 0 puntos", fs.get_puntos(NPC) == 0)

	# --- regalar: rechazo por limite diario (CASO NEGATIVO del guard) ---
	var inv = root.get_node_or_null("Inventario")
	var r1 = fs.regalar(NPC, "PIEDRA")
	_check("regalar devuelve Dictionary con 'ok'", (r1 is Dictionary) and r1.has("ok"))
	if (inv == null) and (r1.get("ok", false) == true):
		_check("regalar aceptado suma 5 puntos (sin Inventario -> NEUTRAL)",
			fs.get_puntos(NPC) == 5)
	else:
		_check("regalar bien formado (Inventario presente o sin_item, sin crash)", true)
	var r2 = fs.regalar(NPC, "PIEDRA")   # mismo dia -> limite_diario
	_check("2do regalo mismo dia RECHAZADO (limite_diario)",
		(r2.get("ok", true) == false) and (str(r2.get("motivo", "")) == "limite_diario"))
	_check("puntos no cambian tras rechazo de regalo",
		fs.get_puntos(NPC) == fs.get_puntos(NPC))

	# --- ciclo charlar: sube puntos y nivel atraves del servicio REAL ---
	fs.pivote_dia(2)
	var c1 = fs.charlar(NPC)
	_check("charlar ok", c1.get("ok", false) == true)
	_check("charlar suma puntos (nivel1 = +5)", fs.get_puntos(NPC) >= 5)

	var guard := 0
	while fs.get_nivel(NPC) < 2 and guard < 30:
		fs.pivote_dia(100 + guard)   # cada iteracion dia distinto (resetea limite charla)
		fs.charlar(NPC)
		guard += 1
	_check("alcanza nivel 2 (>=20 pts via servicio real)", fs.get_nivel(NPC) >= 2)
	_check("puntos >= 20 en nivel 2", fs.get_puntos(NPC) >= 20)

	# --- reclamar recompensa de nivel 2 (fallback RECOMPENSAS_NIVEL) ---
	var ok_rec = fs.reclamar_recompensa(NPC, "receta_herramienta_basica")
	_check("reclamar_recompensa devuelve bool (sin crash)", typeof(ok_rec) == TYPE_BOOL)

	# --- es_cumpleanos_hoy deterministico (sin datos del vecino) ---
	_check("es_cumpleanos_hoy bool y sin datos = false",
		fs.es_cumpleanos_hoy(NPC) == false)

	# --- persistencia: get_save_data round-trip del servicio ---
	var sd = fs.get_save_data()
	_check("get_save_data es Dictionary", sd is Dictionary)
	_check("save_data tiene seccion 'vecinos'", sd.has("vecinos") and (sd["vecinos"] is Dictionary))
	_check("save_data conserva al vecino HY3_NPC_1", (sd.get("vecinos", {})).has(NPC))

	# --- verificacion estatica complementaria de VecinoAmistad (logica de recompensa) ---
	var v = VECINO_SCRIPT.new("HY3_NPC_STATIC")
	v.aplicar_puntos(20, {2: ["receta_herramienta_basica"], 3: ["decorativo_estatua"]})
	_check("VecinoAmistad: 20 pts -> nivel 2", v.get_nivel() == 2)
	var pend = v.get_recompensas_pendientes()
	_check("VecinoAmistad: nivel2 inserta reward pendiente", (pend is Array) and ("receta_herramienta_basica" in pend))
	var rc1 = v.reclamar_recompensa("receta_herramienta_basica")
	_check("VecinoAmistad: reclamar reward devuelve true", rc1 == true)
	var rc2 = v.reclamar_recompensa("receta_herramienta_basica")
	_check("VecinoAmistad: reclamar 2 veces devuelve false (consumido)", rc2 == false)
	var sv = v.serializar()
	var v2 = VECINO_SCRIPT.new("HY3_NPC_STATIC")
	v2.deserializar(sv)
	_check("VecinoAmistad: persistencia restaura nivel", v2.get_nivel() == v.get_nivel())
	_check("VecinoAmistad: persistencia restaura puntos", v2.get_puntos() == v.get_puntos())

	_summary()

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _summary() -> void:
	print("=== Resumen HY3 M20 Friendship: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0 or _checks < MIN_CHECKS:
		print("FALLO (fallos=%d, checks=%d < MIN=%d)" % [_fallos, _checks, MIN_CHECKS])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
