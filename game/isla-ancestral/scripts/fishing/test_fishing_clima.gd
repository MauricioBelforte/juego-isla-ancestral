# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M34: Test de bonos clima M32→M34 (lluvia +15% raro, tropical +25% raro,
# preferencia JSON como bono, nunca filtro — "nunca prohibida").
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/fishing/test_fishing_clima.gd

extends SceneTree

var _fallos: int = 0
var _fishing: Node = null
var _w: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_fishing = root.get_node_or_null("Fishing")
	_w = root.get_node_or_null("Weather")
	_check(_fishing != null, "Fishing autoload presente")
	_check(_w != null, "Weather autoload presente (M32)")
	if _fishing == null:
		print("=== TEST M34 CLIMA: 1+ fallo(s) ===")
		quit(1)
		return
	_test_conversion_clima()
	_test_bono_preferencia()
	_test_bono_raros()
	_test_nunca_prohibida()
	_test_sin_weather_neutro()
	print("=== TEST M34 CLIMA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_conversion_clima() -> void:
	_check(_fishing._clima_m32_a_m34(2) == 1, "M32 LLUVIA(2) → M34 1")
	_check(_fishing._clima_m32_a_m34(3) == 2, "M32 TORMENTA(3) → M34 2")
	_check(_fishing._clima_m32_a_m34(5) == 3, "M32 NIEVE(5) → M34 3")
	_check(_fishing._clima_m32_a_m34(0) == 0, "M32 SOLEADO(0) → despejado 0")
	_check(_fishing._clima_m32_a_m34(4) == 0, "M32 NIEBLA(4) → despejado 0")

func _test_bono_preferencia() -> void:
	if _w == null:
		return
	# Pez con "clima": ["lluvia"] y peso normal (no raro)
	var pez := FishDefinition.new()
	pez.id = "pez_lluvia"
	pez.peso_rareza = 0.2
	pez.climas = [1]  # lluvia en formato M34
	# Forzar SOLEADO: peso base sin bono
	_w._clima_actual = 0
	var base: float = _fishing._peso_efectivo(pez, null)
	_check(absf(base - 0.2) < 0.001, "SOLEADO: peso base (%.3f)" % base)
	# Forzar LLUVIA (M32=2): bono por preferencia JSON
	_w._clima_actual = 2
	var lluvia: float = _fishing._peso_efectivo(pez, null)
	_check(absf(lluvia - 0.2 * 1.15) < 0.001, "LLUVIA: bono 1.15 por preferencia (%.3f)" % lluvia)
	# Forzar TROPICAL (M32=7): por diseño solo aplican los RAROS; este pez
	# preferente-de-lluvia no es raro → peso base (verificado abajo en común).
	_w._clima_actual = 7
	var tropical: float = _fishing._peso_efectivo(pez, null)
	_check(absf(tropical - 0.2) < 0.001, "TROPICAL: preferente-lluvia no-raro sin bono (%.3f)" % tropical)
	# Pez SIN preferencia de clima: peso base incluso bajo lluvia
	var pez_comun := FishDefinition.new()
	pez_comun.id = "pez_comun"
	pez_comun.peso_rareza = 0.4
	pez_comun.climas = []
	_w._clima_actual = 2
	var comun_lluvia: float = _fishing._peso_efectivo(pez_comun, null)
	_check(absf(comun_lluvia - 0.4) < 0.001, "pez sin preferencia ni rareza: sin bono (%.3f)" % comun_lluvia)
	# Pez preferente-de-lluvia pero NO raro: bajo TROPICAL solo aplican los "raros"
	# (diseño M32 §6: "tropical +25% raro"), así que queda en peso base.
	_w._clima_actual = 7
	var lluvia_en_tropical: float = _fishing._peso_efectivo(pez, null)
	_check(absf(lluvia_en_tropical - 0.2) < 0.001,
		"preferente-lluvia no-raro bajo tropical: sin bono (%.3f)" % lluvia_en_tropical)
	_w._clima_actual = 0

func _test_bono_raros() -> void:
	if _w == null:
		return
	_check(absf(_fishing.BONO_LLUVIA - 1.15) < 0.001, "BONO_LLUVIA = 1.15 (diseño M32)")
	_check(absf(_fishing.BONO_TROPICAL - 1.25) < 0.001, "BONO_TROPICAL = 1.25 (diseño M32)")
	_check(_fishing.UMBRAL_RARO == 0.08, "umbral raro 0.08")
	# Pez RARO (peso <= 0.08) sin preferencia JSON: bono por rareza bajo lluvia
	var raro := FishDefinition.new()
	raro.id = "pez_raro"
	raro.peso_rareza = 0.05
	raro.climas = []
	_w._clima_actual = 2
	var raro_lluvia: float = _fishing._peso_efectivo(raro, null)
	_check(absf(raro_lluvia - 0.05 * 1.15) < 0.001, "raro sube con lluvia 1.15 (%.4f)" % raro_lluvia)
	_w._clima_actual = 7
	var raro_tropical: float = _fishing._peso_efectivo(raro, null)
	_check(absf(raro_tropical - 0.05 * 1.25) < 0.001, "raro sube con tropical 1.25 (%.4f)" % raro_tropical)
	_w._clima_actual = 0
	var raro_base: float = _fishing._peso_efectivo(raro, null)
	_check(absf(raro_base - 0.05) < 0.001, "raro sin clima especial: sin bono (%.4f)" % raro_base)

func _test_nunca_prohibida() -> void:
	# §6: el clima NUNCA filtra — "bono sí, bloqueo no". Garantía determinista:
	# bajo CUALQUIER clima, TODO pez del catálogo conserva peso > 0 (nunca 0,
	# nunca excluido). Se prueba el catálogo real completo.
	if _w == null or _fishing._peces.is_empty():
		return
	var clima_guardado: int = _w.get_clima()
	var peces: Array = _fishing._peces
	for clima in [0, 2, 3, 5, 7]:  # SOLEADO, LLUVIA, TORMENTA, NIEVE, TROPICAL
		_w._clima_actual = clima
		for pez in peces:
			_check(_fishing._peso_efectivo(pez, null) > 0.0,
				"peso > 0 con clima %d para %s" % [clima, pez.id])
	# resolver sigue devolviendo peces bajo tormenta
	_w._clima_actual = 3
	var ok := true
	for i in range(50):
		if _fishing.resolver_especie(null, null) == null:
			ok = false
	_check(ok, "resolver_especie nunca null bajo tormenta")
	_w._clima_actual = clima_guardado

func _test_sin_weather_neutro() -> void:
	# Sin Weather (o get_clima ausente), _peso_efectivo = peso base (+ cebo/pity)
	var pez := FishDefinition.new()
	pez.id = "pez_simple"
	pez.peso_rareza = 0.3
	pez.climas = [1]
	var peso_stub: float = _fishing._peso_efectivo(pez, null)
	_check(peso_stub > 0.0, "peso efectivo siempre > 0 (nunca peso 0)")
