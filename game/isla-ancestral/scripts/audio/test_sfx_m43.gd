# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M43: Efectos de Sonido — Test headless
# Valida: SFXManager (pool 24 voces con límite duro, prioridades,
# reproducción por superficie con variaciones, familia tonal §4).
# Exit code != 0 si falla.
#
# Lote B1 (2026-10-03, mimo-v2.6-flash-free): + _test_tonos() contra
# data/audio/sfx_tones.json (03-Diseno §4). Los checks originales se
# conservan sin tocar.
#
# Lote B2 (2026-10-03, mimo-v2.6-flash-free): + _test_catalogo() contra
# Lote B3 (2026-10-03, mimo-v2.6-flash-free): + _test_categorias() (§2 +
# Lote B4 (2026-10-03, mimo-v2.6-flash-free): + _test_api() (§2: pos,
# localizado, configurar_volumen, pausa). `reproducir()` cambió de firma
# (el 2º argumento es ahora `pos`), así que sus 7 llamadas llevan `null`.
# Lote B5 (2026-10-03, mimo-v2.6-flash-free): + _test_ducking() (F92/F95).
# límites §5: ≤6 por tipo, UI máx 2, pool preallocado, PRNG cacheado).
# data/audio/sfx_catalog.json (03-Diseno §3, 12 filas) y superficies a 9.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M43] Test de Efectos de Sonido ===")
	_test_surfaces()
	_test_pool()
	_test_prioridad()
	_test_categorias()
	_test_api()
	_test_ducking()
	_test_tonos()
	_test_catalogo()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Expectativas de variaciones por superficie (03-Diseno §3).
## agua/metal/cristal no figuran en §3 pero ya existían: se fijan en 4.
var _espd := {"hierba": 5, "madera": 4, "piedra": 5, "tierra": 4,
	"nieve": 4, "arena": 4, "agua": 4, "metal": 4, "cristal": 4}

func _test_surfaces() -> void:
	print("--- Superficies: 9 (§3 pasos + agua/metal/cristal) ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("SFXManager autoload presente", true)
	_check("9 superficies", sfx.surfaces.size() == 9, "size=%d" % sfx.surfaces.size())
	for sup in sfx.surfaces:
		var variaciones: Array = sfx.surfaces[sup].get("variaciones", [])
		var esp: int = int(_espd.get(sup, -1))
		_check("superficie %s: %d variaciones (§3)" % [sup, esp],
			esp > 0 and variaciones.size() == esp,
			"esperado=%d size=%d" % [esp, variaciones.size()])
	var variacion = sfx.reproducir_superficie("madera", 5)
	_check("madera devuelve variación", variacion.begins_with("golpe_madera"), "v=%s" % variacion)
	var vacio = sfx.reproducir_superficie("no_existe", 5)
	_check("superficie inexistente -> ''", vacio == "")

func _test_pool() -> void:
	print("--- Pool: 24 voces con límite duro ---")
	var sfx := root.get_node_or_null("SFXManager")
# Llenar el pool hasta 24 (1 ya existe del test de superficies, caben 23 más)
	var ok_llenar = true
	for i in range(23):
		if not sfx.reproducir("sfx_%d" % i, null, 1):
			ok_llenar = false
			break
	_check("pool lleno a 24 (1 existente + 23 nuevas)", ok_llenar and sfx.voces_activas() == 24, "voces=%d" % sfx.voces_activas())
	# Pool lleno: nueva voz de mayor prioridad reemplaza la menor (prioridad 1)
	var ok_alta = sfx.reproducir("sfx_importante", null, 10)
	_check("prioridad alta reemplaza en pool lleno", ok_alta and sfx.voces_activas() == 24, "ok=%s voces=%d" % [ok_alta, sfx.voces_activas()])
	# Pool lleno: nueva voz de menor prioridad se descarta
	var ok_baja = sfx.reproducir("sfx_trivial", null, 0)
	_check("prioridad baja descartada (límite duro)", ok_baja == false and sfx.voces_activas() == 24, "ok=%s voces=%d" % [ok_baja, sfx.voces_activas()])

func _test_prioridad() -> void:
	print("--- Prioridades básicas ---")
	var sfx := root.get_node_or_null("SFXManager")
	# Reset: limpiar voces viejas es complejo en test; verificamos API básica
	_check("reproducir prioridad media", sfx.reproducir("test_medio", null, 5) == true)
	_check("reproducir prioridad alta", sfx.reproducir("test_alto", null, 9) == true)

## Categorías de 03-Diseno §2 y límites de §5 (pool preallocado, ≤6 por
## tipo, UI máx 2, PRNG cacheado). Corre con el pool ya lleno por _test_pool.
func _test_categorias() -> void:
	print("--- Categorías §2 + límites §5 ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (categorías)", false)
		return
	var cats: Dictionary = sfx.CATEGORIAS
	_check("4 categorías de §2", cats.size() == 4, "n=%d" % cats.size())
	_check("niveles §2 (ui=1, mundo=2, bloque=3, paso=4)",
		int(cats["ui"]["nivel_s2"]) == 1 and int(cats["mundo"]["nivel_s2"]) == 2
		and int(cats["bloque"]["nivel_s2"]) == 3 and int(cats["paso"]["nivel_s2"]) == 4)
	_check("prioridad interna invertida (el mayor gana el corte)",
		int(cats["ui"]["prioridad"]) > int(cats["mundo"]["prioridad"])
		and int(cats["mundo"]["prioridad"]) > int(cats["bloque"]["prioridad"])
		and int(cats["bloque"]["prioridad"]) > int(cats["paso"]["prioridad"]))
	_check("UI nunca se corta", bool(cats["ui"]["nunca_corta"]))
	_check("pasos se cortan primero", bool(cats["paso"]["se_corta_primero"]))
	_check("UI máx 2 simultáneos (§2)", int(cats["ui"]["max_simultaneos"]) == 2)

	# Deducción de categoría por prioridad
	_check("prioridad 10 -> ui", sfx.categoria_de(10) == "ui")
	_check("prioridad 5 -> mundo", sfx.categoria_de(5) == "mundo")
	_check("prioridad 3 -> bloque", sfx.categoria_de(3) == "bloque")
	_check("prioridad 1 -> paso", sfx.categoria_de(1) == "paso")
	_check("categoría explícita se respeta", sfx.categoria_de(1, "ui") == "ui")

	# §2: con 2 UI ya activas (_test_pool + _test_prioridad), la 3ª se corta
	var ui_ok: bool = sfx.reproducir("ui_extra", null, 10)
	_check("UI: 3ª simultánea descartada (máx 2)", ui_ok == false, "ok=%s" % ui_ok)

	# §5: ≤ 6 del mismo tipo -> la 7ª se corta (las 6 primeras entran)
	var siete_ok := true
	for i in range(7):
		var r: bool = sfx.reproducir("mismo_tipo", null, 5)
		if r != (i < 6):
			siete_ok = false
	_check("≤ 6 del mismo tipo (la 7ª se corta)", siete_ok, "rango roto")
	_check("pool sigue en el tope de 24", sfx.voces_activas() == 24,
		"voces=%d" % sfx.voces_activas())

	# §5: pool preallocado y PRNG cacheado
	_check("pool preallocado a 24 slots", sfx._voces.size() == 24, "n=%d" % sfx._voces.size())
	_check("PRNG cacheado (sin allocs por evento)", sfx._rng is RandomNumberGenerator)
	_check("randi del RNG dentro de rango", sfx._rng.randi_range(0, 3) in [0, 1, 2, 3])

## API pública de 04-Codigo §2. Corre con el pool VACÍO: los límites de §5
## (ui máx 2) descartaban legítimamente a `api_ui` si heredaba el estado de
## los tests anteriores, y así el resultado no depende del orden de ejecución.
func _voz_de(sfx: Node, tipo: String) -> Variant:
	for i in range(24):
		var v: Variant = sfx._voces[i]
		if v != null and String(v["tipo"]) == tipo:
			return v
	return null

func _test_api() -> void:
	print("--- API pública §2 ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (API)", false)
		return
	# Estado inicial determinista: pool vacío y sin pausa heredada.
	for i in range(24):
		sfx._voces[i] = null
	if sfx._pausado:
		sfx.reanudar()
	_check("pool vaciado antes de la API", sfx.voces_activas() == 0,
		"activas=%d" % sfx.voces_activas())

	# reproducir(efecto, pos)
	_check("reproducir(efecto, pos) -> true", sfx.reproducir("api_pos", Vector3(1, 2, 3), 4))
	var vz: Variant = _voz_de(sfx, "api_pos")
	_check("pos Vector3 registrada en la voz", vz != null and vz["pos"] is Vector3,
		"vz=%s" % str(vz))
	_check("pos null = 2D/UI", sfx.reproducir("api_ui", null, 9))
	var vz2: Variant = _voz_de(sfx, "api_ui")
	_check("voz 2D registrada sin pos", vz2 != null and vz2["pos"] == null)

	# reproducir_localizado(tipo, material, pos)
	var loc: String = sfx.reproducir_localizado("paso", "madera", Vector3(0, 1, 0))
	_check("localizado paso/madera -> golpe_madera_N", loc.begins_with("golpe_madera"),
		"v=%s" % loc)
	var rom: String = sfx.reproducir_localizado("romper", "piedra", Vector3(2, 1, 0))
	_check("localizado romper/piedra -> romper_piedra_N", rom.begins_with("romper_piedra"),
		"v=%s" % rom)
	var col: String = sfx.reproducir_localizado("colocar", "madera", Vector3(3, 1, 0))
	_check("localizado colocar -> colocar_N", col.begins_with("colocar_"), "v=%s" % col)
	var mal: String = sfx.reproducir_localizado("paso", "no_existe", Vector3.ZERO)
	_check("localizado material desconocido -> ''", mal == "")

	# configurar_volumen(bus, dB) -> delega en AudioConfig (M91)
	var ac: Node = Engine.get_main_loop().root.get_node_or_null("AudioConfig")
	_check("AudioConfig (M91) disponible", ac != null)
	_check("bus inexistente -> false", sfx.configurar_volumen("NoExiste", -6.0) == false)
	var prev: float = float(ac.get_volumen("SFX")) if ac != null else 1.0
	_check("configurar_volumen(SFX, -6 dB) -> true", sfx.configurar_volumen("SFX", -6.0))
	_check("SFX a -6 dB ≈ 0.501 lineal",
		abs(float(ac.get_volumen("SFX")) - 0.5012) < 0.002, "v=%s" % str(ac.get_volumen("SFX")))
	# restaurar el volumen previo (lineal -> dB)
	if prev > 0.0:
		sfx.configurar_volumen("SFX", 20.0 * log(prev) / log(10.0))

	# pausar()/reanudar() sin residuos (F99)
	sfx.pausar()
	var voces_antes: int = sfx.voces_activas()
	_check("reproducir en pausa -> false", sfx.reproducir("en_pausa", null, 5) == false)
	_check("la pausa no añade voces", sfx.voces_activas() == voces_antes,
		"antes=%d ahora=%d" % [voces_antes, sfx.voces_activas()])
	# envenenar una voz con un timestamp de hace 60 s (vencida)
	for i in range(24):
		var vv: Variant = sfx._voces[i]
		if vv != null:
			sfx._voces[i]["tiempo_ms"] = Time.get_ticks_msec() - 60000
			break
	sfx.reanudar()
	var voces_rean: int = sfx.voces_activas()
	_check("reanudar purga solo la voz vencida (sin residuos)",
		voces_rean == voces_antes - 1,
		"esperaba %d y hay %d" % [voces_antes - 1, voces_rean])
	_check("reanudar devuelve a reproducir", sfx.reproducir("post_pausa", null, 5))
	var vz3: Variant = _voz_de(sfx, "post_pausa")
	_check("la voz nueva tras reanudar es fresca",
		vz3 != null and Time.get_ticks_msec() - int(vz3["tiempo_ms"]) <= 5000,
		"vz3=%s" % str(vz3))
	# limpiar el flag por si otro test lo hereda
	if sfx._pausado:
		sfx.reanudar()

	# L115: el pool lleno con pasos de prioridad 1 jamás corta a la UI.
	for i in range(24):
		sfx._voces[i] = null
	for i in range(24):
		sfx.reproducir("relleno_%d" % i, null, 1)
	_check("pool 24 exactos con pasos", sfx.voces_activas() == 24,
		"voces=%d" % sfx.voces_activas())
	var ui_final: bool = sfx.reproducir("ui_final", null, 10)
	_check("pool lleno: la UI entra cortando a un paso (nunca se corta)", ui_final)

## F92/F95: ducking de diálogo suscrito a M21 (sin modificar sus archivos).
func _test_ducking() -> void:
	print("--- Ducking de diálogo (F92/F95) ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (ducking)", false)
		return
	var dm: Node = root.get_node_or_null("DialogueManager")
	_check("DialogueManager (M21) disponible", dm != null)
	if dm != null:
		_check("suscripto a dialogue_started",
			dm.dialogue_started.is_connected(sfx._on_dialogue_started))
		_check("suscripto a dialogue_ended",
			dm.dialogue_ended.is_connected(sfx._on_dialogue_ended))
	var idx := AudioServer.get_bus_index("SFX")
	_check("bus SFX existe (M91)", idx >= 0)
	if idx < 0:
		return
	var base := AudioServer.get_bus_volume_db(idx)

	# activar / idempotencia / desactivar
	sfx.ducking_dialogo(true)
	var ducked := AudioServer.get_bus_volume_db(idx)
	_check("ducking baja 6 dB", abs(ducked - (base - 6.0)) < 0.02,
		"base=%s ducked=%s" % [str(base), str(ducked)])
	sfx.ducking_dialogo(true)
	_check("ducking idempotente (no acumula)", abs(AudioServer.get_bus_volume_db(idx) - ducked) < 0.001,
		"db=%s" % str(AudioServer.get_bus_volume_db(idx)))
	sfx.ducking_dialogo(false)
	var restaurado := AudioServer.get_bus_volume_db(idx)
	_check("al soltar el diálogo vuelve la base", abs(restaurado - base) < 0.02,
		"base=%s restaurado=%s" % [str(base), str(restaurado)])
	sfx.ducking_dialogo(false)
	_check("desactivar dos veces no cambia nada", abs(AudioServer.get_bus_volume_db(idx) - base) < 0.001)

	# F95: SFX queda por debajo del diálogo al activarse
	sfx.ducking_dialogo(true)
	_check("SFX por debajo del diálogo (jerarquía)", AudioServer.get_bus_volume_db(idx) < base - 5.9)
	sfx.ducking_dialogo(false)

	# el flag de estado queda limpio para el resto de la suite
	_check("sin ducking al terminar", bool(sfx._ducking) == false)

## Familia tonal (03-Diseno §4): 7 SFX de UI/eventos verificables por datos.
## NOTA: JSON.parse_string convierte todos los números a float, así que las
## comparaciones de semitonos se normalizan a int (error Godot 4 documentado).
func _a_ints(a: Array) -> Array:
	var r: Array = []
	for v in a:
		r.append(int(v))
	return r

func _test_tonos() -> void:
	print("--- Familia tonal: 7 SFX (03-Diseno §4) ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (tonos)", false)
		return
	_check("sfx_tones.json cargado con 7 entradas", sfx.tones.size() == 7, "size=%d" % sfx.tones.size())
	_check("API tono() responde", not sfx.tono("confirmacion").is_empty())
	_check("tono inexistente -> {}", sfx.tono("no_existe").is_empty())
	_check("tonos_disponibles() == 7", sfx.tonos_disponibles().size() == 7, "n=%d" % sfx.tonos_disponibles().size())

	# Confirmación: 2 notas ascendentes con 5ª justa (7 semitonos)
	var conf: Dictionary = sfx.tono("confirmacion")
	var conf_n: Array = conf.get("notas_semitonos", [])
	_check("confirmacion: 2 notas", conf_n.size() == 2, "n=%d" % conf_n.size())
	_check("confirmacion: 5ª justa ascendente",
		conf_n.size() == 2 and int(conf_n[1]) - int(conf_n[0]) == 7
		and String(conf.get("orden", "")) == "ascendente")
	_check("confirmacion: tono calido", String(conf.get("tono", "")) == "calido")

	# Logro: arpegio de tríada mayor (3 notas: 3ª mayor + 5ª justa)
	var logro: Dictionary = sfx.tono("logro")
	var logro_n: Array = logro.get("notas_semitonos", [])
	_check("logro: tríada mayor 0-4-7", _a_ints(logro_n) == [0, 4, 7], "v=%s" % str(logro_n))
	_check("logro: 3 notas ascendentes", String(logro.get("orden", "")) == "ascendente")
	_check("logro: tono brillante", String(logro.get("tono", "")) == "brillante")

	# Error: tríada menor descendente, 0.4 s, nunca buzz
	var err: Dictionary = sfx.tono("error")
	var err_n: Array = err.get("notas_semitonos", [])
	_check("error: tríada menor descendente 7-4-0", _a_ints(err_n) == [7, 4, 0], "v=%s" % str(err_n))
	_check("error: duracion 0.4 s", is_equal_approx(float(err.get("duracion_s", 0.0)), 0.4),
		"d=%s" % str(err.get("duracion_s")))
	_check("error: tono suave", String(err.get("tono", "")) == "suave")

	# Recoger: nota aguda corta, positiva
	var rec: Dictionary = sfx.tono("recoger")
	var rec_n: Array = rec.get("notas_semitonos", [])
	_check("recoger: nota aguda (+1 octava)", rec_n.size() == 1 and int(rec_n[0]) >= 12, "v=%s" % str(rec_n))
	_check("recoger: corta (<=0.25 s)", float(rec.get("duracion_s", 9.0)) <= 0.25,
		"d=%s" % str(rec.get("duracion_s")))

	# Compra vs venta: audiblemente distintas
	var cmp: Dictionary = sfx.tono("compra")
	var vta: Dictionary = sfx.tono("venta")
	var cmp_n: Array = cmp.get("notas_semitonos", [])
	var vta_n: Array = vta.get("notas_semitonos", [])
	_check("compra: 2 monedas", int(cmp.get("monedas", 0)) == 2, "m=%s" % str(cmp.get("monedas")))
	_check("compra != venta", _a_ints(cmp_n) != _a_ints(vta_n), "compra=%s venta=%s" % [str(cmp_n), str(vta_n)])
	_check("venta: tríada menor 0-3-7", _a_ints(vta_n) == [0, 3, 7], "v=%s" % str(vta_n))
	_check("venta: tono medio distinto de compra",
		String(vta.get("tono", "")) != String(cmp.get("tono", "")))

	# Crafting éxito: arpegio corto de 4ª-5ª
	var cra: Dictionary = sfx.tono("crafting_exito")
	var cra_n: Array = cra.get("notas_semitonos", [])
	_check("crafting_exito: arpegio 4ª-5ª (0-5-7)", _a_ints(cra_n) == [0, 5, 7], "v=%s" % str(cra_n))

## Catálogo de efectos (03-Diseno §3): 12 filas (6 paso + 5 romper + 1 colocar).
## Verifica valores exactos de §3 y la coherencia catálogo ↔ sfx_surfaces.json.
func _test_catalogo() -> void:
	print("--- Catálogo: 12 filas de §3 ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (catálogo)", false)
		return
	_check("sfx_catalog.json cargado", not sfx.catalogo().is_empty())
	_check("claves paso/romper/colocar",
		sfx.catalogo().has("paso") and sfx.catalogo().has("romper") and sfx.catalogo().has("colocar"))

	var paso: Dictionary = sfx.catalogo().get("paso", {})
	var romper: Dictionary = sfx.catalogo().get("romper", {})
	_check("paso: 6 materiales (§3)", paso.size() == 6, "n=%d" % paso.size())
	_check("romper: 5 materiales (§3)", romper.size() == 5, "n=%d" % romper.size())
	_check("colocar: 4 variaciones (§3)",
		int(sfx.catalogo().get("colocar", {}).get("variaciones", 0)) == 4)
	_check("total 12 filas de §3", paso.size() + romper.size() + 1 == 12,
		"n=%d" % (paso.size() + romper.size() + 1))

	# Valores exactos de §3 (paso 6 + romper 5 = 11 comprobaciones)
	var s3 := {"paso": {"hierba": 5, "madera": 4, "piedra": 5, "tierra": 4, "nieve": 4, "arena": 4},
		"romper": {"piedra": 5, "madera": 5, "tierra": 4, "cristal": 4, "metal": 4}}
	for efecto in s3:
		for mat in s3[efecto]:
			var esp: int = int(s3[efecto][mat])
			var real: int = sfx.catalogo_variaciones(efecto, mat)
			_check("%s/%s = %d (§3)" % [efecto, mat, esp], real == esp, "real=%d" % real)

	# Coherencia catálogo ↔ sfx_surfaces (paso usa las mismas superficies)
	var coh := true
	var detalle_coh := ""
	for mat in paso:
		if not sfx.surfaces.has(mat):
			coh = false
			detalle_coh = "falta superficie %s" % mat
			break
		var va: Array = sfx.surfaces[mat].get("variaciones", [])
		if va.size() != int(paso[mat]):
			coh = false
			detalle_coh = "%s: surfaces=%d catalogo=%d" % [mat, va.size(), int(paso[mat])]
			break
	_check("catálogo paso ↔ sfx_surfaces coherentes", coh, detalle_coh)

	_check("catalogo_variaciones(colocar) == 4", sfx.catalogo_variaciones("colocar") == 4)
	_check("efecto inexistente -> -1", sfx.catalogo_variaciones("volar") == -1)
	_check("material inexistente -> -1", sfx.catalogo_variaciones("paso", "vidrio") == -1)

func _summary() -> void:
	print("=== Resumen M43: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M43 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M43 OK — todos los checks pasaron")
		quit(0)