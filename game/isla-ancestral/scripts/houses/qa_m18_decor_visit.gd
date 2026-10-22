# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M18: QA de HouseDecor sin allocs + PRNG de partido de HouseVisit (2-BIS).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/houses/qa_m18_decor_visit.gd
# Items del 05-Checklist cubiertos:
#   - "PRNG de partida M29 para preferencias y variaciones de visita" [S]
#   - "Grid de decoración sin allocs en el bucle de validación por frame" [M]

extends SceneTree

const CHECKS_MINIMOS := 12
var _checks: int = 0
var _fallos: int = 0

func _summary() -> void:
	print("=== Resumen QA decor/visit M18: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _load(clase: String) -> Script:
	return load("res://scripts/houses/" + clase)

func _run() -> void:
	_test_decor_sin_allocs()
	_test_prng_preferencias()

## Hot path de validación: 60 llamadas con out reutilizado deben dejar
## _allocs_validacion en delta 0 tras calentar (solo la 1a crea el buffer).
func _test_decor_sin_allocs() -> void:
	var dec_script: Script = _load("house_decor.gd")
	_check(dec_script != null, "house_decor.gd carga")
	if dec_script == null:
		return
	var hdec: Node = dec_script.new()
	root.add_child(hdec)
	hdec.activar()
	var mueble := {"nombre": "mesa_test", "ancho": 1.0, "profundo": 0.5}
	var celda := Vector3i(5, 0, 5)
	var out: Dictionary = {}
	# celdas del hot path: Murray con el array del caller ya creado
	var ref_celdas: Array = []
	out["celdas"] = ref_celdas
	# calentamiento (1a llamada crea buffers; delta arranca tras esta)
	hdec.validar_celda_en(celda, mueble, out)
	var antes: int = int(hdec._allocs_validacion)
	var ok := false
	for i in range(60):
		ok = hdec.validar_celda_en(celda, mueble, out)
	var delta: int = int(hdec._allocs_validacion) - antes
	_check(ok, "hot path: validacion valida en el camino caliente")
	_check(delta == 0, "hot path: 60 validaciones con 0 allocs (delta=%d)" % delta)
	_check(bool(out.get("ok", false)) == true, "out queda relleno con ok=true")
	_check(out["celdas"] is Array and (out["celdas"] as Array).size() == 2,
		"out trae superficie 1x0.5 = 2 celdas (%d)" % (out["celdas"] as Array).size())
	# Casos de rechazo mantienen el contrato sin tocar celdas
	var rechazo: bool = hdec.validar_celda_en(Vector3i(0, 0, 0), mueble, out)
	_check(not rechazo and String(out.get("razon", "")) == "requiere pared y no está en el borde",
		"hot path: mueble sin pared fuera del perimetro rechaza con razon")
	var wrapper: Dictionary = hdec.validar_celda(celda, mueble)
	_check(bool(wrapper.get("ok", false)) == true, "wrapper legacy mantiene el contrato completo")
	var d2: int = int(hdec._allocs_validacion) - (antes + delta)
	_check(d2 == 1, "wrapper legacy cuesta exactamente 1 (dict+array) y queda contado")
	hdec.desactivar()
	hdec.queue_free()

## PRNG determinista por partida (M29): misma sesion -> mismos gustos,
## no pisa preferencias ya definidas, y la variante de frase es estable.
func _test_prng_preferencias() -> void:
	var hv_script: Script = _load("house_visit.gd")
	_check(hv_script != null, "house_visit.gd carga")
	if hv_script == null:
		return
	var hv1: Node = hv_script.new()
	var hv2: Node = hv_script.new()
	root.add_child(hv1)
	root.add_child(hv2)
	var vecinos := ["bruno_sapo", "luna_zorra", "mateo_mapache", "aria_ciervo", "catalina_oso"]
	var n1: int = hv1.autocompletar_preferencias(vecinos)
	var n2: int = hv2.autocompletar_preferencias(vecinos)
	_check(n1 == vecinos.size() and n2 == n1, "PRNG: asigna preferencia a todos (%d)" % n1)
	var pref1: Dictionary = hv1._preferencias
	var pref2: Dictionary = hv2._preferencias
	_igual = true
	for v_ in vecinos:
		if String(pref1.get(v_, "X")) != String(pref2.get(v_, "Y")):
			_igual = false
	_check(_igual, "PRNG: misma partida produce los mismos gustos (determinismo)")
	var en_catalogo := true
	for v_ in vecinos:
		if not hv1.ESTILOS_DECOR.has(String(pref1.get(v_, ""))):
			en_catalogo = false
	_check(en_catalogo, "PRNG: preferencias dentro del catalogo de estilos")
	# No pisa lo definido a mano
	var hv3: Node = hv_script.new()
	root.add_child(hv3)
	hv3.definir_preferencia("bruno_sapo", "floral")
	hv3.autocompletar_preferencias(vecinos)
	_check(String(hv3._preferencias.get("bruno_sapo", "")) == "floral",
		"PRNG: definicion manual manda (no se pisa)")
	# Comentario mismatch: determinista por (vecino, dia), con variantes > 1
	var r1: Dictionary = hv1.reaccion_decoracion("bruno_sapo", "estilo_ajeno")
	var r2: Dictionary = hv1.reaccion_decoracion("bruno_sapo", "estilo_ajeno")
	_check(String(r1.get("comentario", "?")) == String(r2.get("comentario", "?")),
		"PRNG: misma partida+dia -> mismo comentario (sin RNG oculto)")
	var variantes := {}
	for d in range(6):
		variantes[hv1._variante_frase("bruno_sapo", d)] = true
	_check(variantes.size() >= 2, "PRNG: las variantes de frase varian con el dia (%d distintas en 6 dias)" % variantes.size())
	hv1.queue_free()
	hv2.queue_free()
	hv3.queue_free()

var _igual: bool = true
