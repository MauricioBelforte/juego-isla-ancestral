# validate_mp_contract.gd - verificador del contrato multijugador (M76)
# M76: decision v1 = single-player; contrato MP futuro (local primero).
# Verifica: (A) manifiesto mp_contract.json coherente, (B) nucleo sin refs MP,
# (C) coherencia cruzada del contrato. Estandar headless del repo (SceneTree).
extends SceneTree

const MODULO := "validate_mp_contract (M76)"
const RUTA_MANIFIESTO := "res://data/multijugador/mp_contract.json"
const BLOQUES := ["A", "B", "C"]
const CHECKS_MINIMOS := 36   # medido en verde (36/0) el 2026-10-16

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _terminado := false
var _frames := 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _check(ok: bool, nombre: String) -> void:
	_checks += 1
	if ok:
		print("[OK] %s" % nombre)
	else:
		_fallos += 1
		print("[FALLO] %s" % nombre)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > 600:
		_checks += 1; _fallos += 1; _terminado = true
		print("!! WATCHDOG: _run() no termino en 600 frames (posible SCRIPT ERROR)")
		print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
		quit(1)
	return false

# --- Bloque A: manifiesto ---
func _bloque_a() -> void:
	var texto := FileAccess.get_file_as_string(RUTA_MANIFIESTO)
	_check(texto != "", "manifiesto mp_contract.json existe y no esta vacio")
	var json: Variant = JSON.parse_string(texto)
	_check(json is Dictionary, "manifiesto parsea como Dictionary")
	if not (json is Dictionary):
		_fin("A"); return
	var d: Dictionary = json
	_check(d.get("mp_v1") == "single", "mp_v1 == single (decision v1)")
	_check(d.get("mp_future") == "local_first", "mp_future == local_first (puerta de entrada)")
	_check(d.get("players_local") == 2, "players_local == 2 (couch)")
	_check(d.get("players_online_max") == 4, "players_online_max == 4 (techo online)")
	_check(d.get("authority") == "host", "authority == host (local)")
	_check(d.get("persistence") == "individual", "persistence == individual (invitado = perfil local)")
	_check(d.get("chat") == "frases rapidas", "chat == frases rapidas (sin texto libre)")
	_check(d.get("servidores_v1") == false, "servidores_v1 == false ($0 en v1)")
	_check(d.get("coste_estimado_mensual") == 0, "coste_estimado_mensual == 0")
	var hit: String = str(d.get("online_hit", ""))
	_check("10000" in hit, "online_hit menciona el umbral >10k descargas")
	var eco: String = str(d.get("economia", ""))
	_check("historia" in eco, "economia protege items de historia (M22/M23)")
	var prog: Variant = d.get("progreso", {})
	_check(prog is Dictionary and prog.get("compartido") == "nunca", "progreso.compartido == nunca (RF19)")
	_check(prog is Dictionary and prog.get("invitado_logros_isla_ajena") == false, "invitado NO desbloquea logros en isla ajena (M72)")
	_check(prog is Dictionary and prog.get("invitado_avanza_historia_ajena") == false, "invitado NO avanza historia ajena (M22)")
	var seg: Variant = d.get("seguridad", {})
	_check(seg is Dictionary and seg.get("offline_first") == true, "seguridad.offline_first == true (M59)")
	_check(seg is Dictionary and seg.get("abre_puertos_v1") == false, "seguridad.abre_puertos_v1 == false (v1 sin red)")
	var mod: Variant = d.get("moderacion", {})
	_check(mod is Dictionary and mod.get("cero_moderacion_v1") == true, "moderacion.cero_moderacion_v1 == true")
	var emo: Variant = d.get("emotes", {})
	_check(emo is Dictionary and emo.get("requieren_red") == false, "emotes.requieren_red == false (locales, M44)")
	var ids: Variant = d.get("identidad", {})
	_check(ids is Dictionary and ids.get("sin_cuentas_v1") == true, "identidad.sin_cuentas_v1 == true (RF12)")
	var resp: Variant = d.get("persistencia_respaldo", {})
	_check(resp is Dictionary and resp.get("respaldo_mundo_host") == true, "persistencia_respaldo.respaldo_mundo_host == true (M59)")
	_fin("A")

# --- Bloque B: nucleo limpio (regla M15) ---
func _listar_gd(ruta: String, salida: Array) -> void:
	var dir := DirAccess.open(ruta)
	if dir == null:
		return
	for sub in dir.get_directories():
		_listar_gd(ruta.path_join(sub), salida)
	for f in dir.get_files():
		if f.ends_with(".gd"):
			salida.append(ruta.path_join(f))

func _bloque_b() -> void:
	# Los verificadores validate_* nombran en su propio codigo los patrones que
	# prohiben (como el colector de sintaxis en los gates de lint): se excluyen
	# de la medicion del nucleo v1 y se declara cuantos se saltaron.
	var todos: Array = []
	_listar_gd("res://scripts", todos)
	var archivos: Array = []
	var excluidos := 0
	for ruta in todos:
		var nom: String = ruta.get_file()
		if nom.begins_with("validate_"):
			excluidos += 1
		else:
			archivos.append(ruta)
	_check(archivos.size() > 500, "recorrida leyo %d .gd bajo res://scripts (guarda de ceguera)" % archivos.size())
	_check(excluidos >= 1, "verificadores validate_* excluidos y contados: %d (exclusion declarada)" % excluidos)
	var mp_archivos: Array = []
	var mp_refs: Array = []
	var red_refs: Array = []
	var re_mp := RegEx.new()
	re_mp.compile(r"\bmp_(?:local|online)\b")
	var re_red := RegEx.new()
	re_red.compile(r"ENetMultiplayerPeer|multiplayer_peer|MultiplayerAPI|create_multiplayer")
	for ruta in archivos:
		var nombre: String = ruta.get_file()
		if nombre.begins_with("mp_") and nombre.ends_with(".gd"):
			mp_archivos.append(ruta)
		var contenido: String = FileAccess.get_file_as_string(ruta)
		if contenido.is_empty():
			continue
		if re_mp.search(contenido) != null:
			mp_refs.append(ruta)
		if re_red.search(contenido) != null:
			red_refs.append(ruta)
	_check(mp_archivos.is_empty(), "cero archivos mp_*.gd en scripts (sin runtime MP)")
	_check(mp_refs.is_empty(), "cero refs mp_local/mp_online en scripts (word boundary: dump_locales NO matchea)")
	_check(red_refs.is_empty(), "cero refs de red (ENet/multiplayer_peer/MultiplayerAPI) en scripts v1, excluyendo validate_*")
	_fin("B")

# --- Bloque C: coherencia cruzada del contrato ---
func _bloque_c() -> void:
	var json: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MANIFIESTO))
	if not (json is Dictionary):
		_fin("C"); return
	var d: Dictionary = json
	var perm: Variant = d.get("permisos", {})
	_check(perm is Dictionary and perm.get("casa_del_host_protegida") == true, "permisos.casa_del_host_protegida (RF10)")
	_check(perm is Dictionary and perm.get("catalogo_muebles_compartido") == "solo lectura", "permisos.catalogo_muebles_compartido == solo lectura (RF17)")
	var inv: Variant = d.get("invitaciones", {})
	_check(inv is Dictionary and str(inv.get("online_futuro", "")).find("expiracion") >= 0, "invitaciones.online_futuro = codigo con expiracion (RF11)")
	_check(inv is Dictionary and "M77" in str(inv.get("lista_amigos", "")), "invitaciones.lista_amigos delegada a M77 (limite)")
	var ids: Variant = d.get("identidad", {})
	_check(ids is Dictionary and ids.get("nombre_jugador_editable") == true, "identidad.nombre_jugador_editable (RF13)")
	var mod: Variant = d.get("moderacion", {})
	_check(mod is Dictionary and mod.get("baneo_visitas_host") == true, "moderacion.baneo_visitas_host (RF23)")
	_check(mod is Dictionary and "texto libre" in str(mod.get("reporte_jugadores", "")), "moderacion.reporte_jugadores condicionado a texto libre futuro")
	_check(str(d.get("mp_v1")) == "single" and str(d.get("authority")) == "host", "coherencia: single v1 + autoridad host (local)")
	_check(d.get("servidores_v1") == false and d.get("coste_estimado_mensual") == 0, "coherencia: sin servidores y coste 0 en v1 (RF24)")
	_fin("C")

func _run() -> void:
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_terminado = true

func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FALLO] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] solo %d checks ejecutados (piso %d)" % [_checks, CHECKS_MINIMOS])
		_fallos += 1
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)
