# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: Test headless de los nuevos sistemas: HouseData, HouseUpgradeData,
# HouseStorage, HouseDecor, HouseUpgrade, House, HouseInterior, HouseVisit.
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 15

func _initialize() -> void:
	print("=== TEST M18 Sistemas nuevos (atria-dawn-s2) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Bloque 1: HouseData ──
	var hd_script: Script = load("res://scripts/houses/house_data.gd")
	_check("HouseData.gd carga", hd_script != null)
	if hd_script != null:
		var hd: Resource = hd_script.new()
		hd.huella_voxel = Vector2i(6, 4)
		_check("HouseData huella_valida", hd.huella_valida())
		_check("HouseData superficie_celdas", hd.superficie_celdas() == 24)
		_check("HouseData costo_total", hd.costo_total() == 30)
		hd.huella_voxel = Vector2i(0, 4)
		_check("HouseData huella invalida = false", not hd.huella_valida())

	# ── Bloque 2: HouseUpgradeData ──
	var hud_script: Script = load("res://scripts/houses/house_upgrade_data.gd")
	_check("HouseUpgradeData.gd carga", hud_script != null)
	if hud_script != null:
		var hud: Resource = hud_script.new()
		hud.etapa = 3
		hud.costo = {"wood": 50, "stone": 25}
		hud.requisito_mision = "mision_cocina"
		hud.habitaciones = ["cocina"]
		_check("HouseUpgradeData requiere_mision", hud.requiere_mision())
		_check("HouseUpgradeData no requiere_amistad", not hud.requiere_amistad())
		_check("HouseUpgradeData costo_total", hud.costo_total() == 75)
		_check("HouseUpgradeData anade_habitaciones", hud.anade_habitaciones())
		hud.requisito_mision = ""
		_check("HouseUpgradeData sin mision", not hud.requiere_mision())

	# ── Bloque 3: HouseStorage ──
	var hs_script: Script = load("res://scripts/houses/house_storage.gd")
	_check("HouseStorage.gd carga", hs_script != null)
	if hs_script != null:
		var hs: Node = hs_script.new()
		root.add_child(hs)
		hs.registrar_contenedor("cofre_1", 4)
		_check("registrar_contenedor", hs.abrir("cofre_1").size() == 3)
		# Sin Inventario en headless: transferir_desde_inventario debe devolver 0 sin crash
		var t1: int = hs.transferir_desde_inventario("cofre_1", "wood", 5)
		_check("transferencia sin inventario = 0", t1 == 0)
		_check("esta_lleno cofre nuevo = false", not hs.esta_lleno("cofre_1"))
		_check("cantidad_items vacio = 0", hs.cantidad_items("cofre_1") == 0)
		var abrir: Dictionary = hs.abrir("cofre_1")
		_check("capacidad cofre = 4", int(abrir.get("capacidad", 0)) == 4)
		# Recolectar/restaurar estado
		hs.registrar_contenedor("cofre_2", 2)
		var est: Dictionary = hs.recolectar_estado()
		var hs2: Node = hs_script.new()
		root.add_child(hs2)
		hs2.restaurar_estado(est)
		_check("restaurar estado: 2 contenedores", hs2.recolectar_estado().size() == 2)
		hs.queue_free()
		hs2.queue_free()

	# ── Bloque 4: HouseDecor ──
	var hdec_script: Script = load("res://scripts/houses/house_decor.gd")
	_check("HouseDecor.gd carga", hdec_script != null)
	if hdec_script != null:
		var hdec: Node = hdec_script.new()
		root.add_child(hdec)
		_check("decor inactivo al iniciar", not hdec.esta_activado())
		hdec.activar()
		_check("decor activado", hdec.esta_activado())
		var celda: Vector3i = hdec.mundo_a_celda(Vector3(1.0, 0.0, 0.5))
		_check("mundo_a_celda (1,0,0.5) = (4,0,2)", celda == Vector3i(4, 0, 2))
		var mundo: Vector3 = hdec.celda_a_mundo(Vector3i(4, 0, 2))
		_check("celda_a_mundo ida/vuelta", is_equal_approx(mundo.x, 1.0))
		# Validar celda con mueble ficticio (Dictionary)
		var mueble: Dictionary = {"ancho": 1.0, "profundo": 1.0, "requiere_pared": false}
		var v: Dictionary = hdec.validar_celda(Vector3i(1, 0, 1), mueble)
		_check("validar_celda ok", bool(v.get("ok", false)))
		var v2: Dictionary = hdec.validar_celda(Vector3i(1, 0, 1), mueble)
		# Ocupar y volver a validar en la misma celda
		_check("colocar mueble", hdec.colocar(Vector3i(1, 0, 1), "silla_madera", 0))
		var v3: Dictionary = hdec.validar_celda(Vector3i(1, 0, 1), mueble)
		_check("celda ocupada = false", not bool(v3.get("ok", true)))
		_check("cantidad_muebles = 1", hdec.cantidad_muebles() == 1)
		hdec.rotar(Vector3i(1, 0, 1), 1)
		_check("rotar mueble", int(hdec.obtener_mueble(Vector3i(1, 0, 1)).get("rotacion", -1)) == 1)
		hdec.levantar(Vector3i(1, 0, 1))
		_check("levantar: celda libre", hdec.cantidad_muebles() == 0)
		# Estado
		hdec.colocar(Vector3i(2, 0, 2), "mesa_madera", 2)
		var est_dec: Dictionary = hdec.recolectar_estado()
		var hdec2: Node = hdec_script.new()
		root.add_child(hdec2)
		hdec2.restaurar_estado(est_dec)
		_check("restaurar decor: 1 mueble", hdec2.cantidad_muebles() == 1)
		_check("restaurar decor: rotacion 2", int(hdec2.obtener_mueble(Vector3i(2, 0, 2)).get("rotacion", -1)) == 2)
		hdec.queue_free()
		hdec2.queue_free()

	# ── Bloque 5: HouseUpgrade ──
	var hu_script: Script = load("res://scripts/houses/house_upgrade.gd")
	_check("HouseUpgrade.gd carga", hu_script != null)
	if hu_script != null:
		var hu: Node = hu_script.new()
		root.add_child(hu)
		_check("etapa inicial 1", hu.etapa_actual() == 1)
		_check("proxima etapa 2", hu.proxima_etapa() == 2)
		var datos2: Dictionary = {"costo": {"wood": 30}, "dias_obra": 3}
		_check("requisitos etapa 2 sin inv", bool(hu.verificar_requisitos(2, null, datos2).get("ok", false)))
		_check("iniciar_obra etapa 2", hu.iniciar_obra(2, datos2))
		_check("en_obra = true", hu.en_obra())
		_check("progreso 0%", hu.progreso_obra() == 0)
		hu.tick_diario()
		hu.tick_diario()
		_check("progreso 66%", hu.progreso_obra() == 66)
		hu.tick_diario()
		_check("obra completada etapa 2", hu.etapa_actual() == 2)
		_check("en_obra = false post-completar", not hu.en_obra())
		# Sin obra repetida
		_check("re-iniciar sin verificacion = false", not hu.iniciar_obra(2, datos2))
		var datos3: Dictionary = {"costo": {"wood": 50}}
		_check("verificar etapa 3 ok", bool(hu.verificar_requisitos(3, null, datos3).get("ok", false)))
		hu.aplicar_etapa(5)
		_check("aplicar_etapa 5", hu.etapa_actual() == 5)
		_check("proxima etapa en max = 0", hu.proxima_etapa() == 0)
		var est_hu: Dictionary = hu.recolectar_estado()
		var hu2: Node = hu_script.new()
		root.add_child(hu2)
		hu2.restaurar_estado(est_hu)
		_check("restaurar upgrade: etapa 5", hu2.etapa_actual() == 5)
		hu.queue_free()
		hu2.queue_free()

	# ── Bloque 6: House ──
	var h_script: Script = load("res://scripts/houses/house.gd")
	_check("House.gd carga", h_script != null)
	if h_script != null:
		var h: Node = h_script.new()
		root.add_child(h)
		h.house_id = "casa_a"
		h.etapa = 3
		_check("etapa_actual 3", h.etapa_actual() == 3)
		_check("cartel no bloquea mapa", not h.cartel_bloquea_mapa())
		var ent: Vector3 = h.obtener_entrada()
		_check("entrada tiene offset Z", ent.z != 0.0)
		_check("abrir_interior", h.abrir_interior())
		_check("interior_activo", h.interior_activo())
		_check("puerta ocupada (doble entrada)", not h.abrir_interior())
		h.cerrar_interior()
		_check("cerrar_interior", not h.interior_activo())
		# Casa en obra: no se puede entrar
		h.en_obra = true
		_check("en obra: no entrar", not h.abrir_interior())
		h.en_obra = false
		var est_h: Dictionary = h.recolectar_estado()
		var h2: Node = h_script.new()
		root.add_child(h2)
		h2.restaurar_estado(est_h)
		_check("restaurar house: id", h2.house_id == "casa_a")
		_check("restaurar house: etapa 3", h2.etapa_actual() == 3)
		h.queue_free()
		h2.queue_free()

	# ── Bloque 7: HouseInterior ──
	var hi_script: Script = load("res://scripts/houses/house_interior.gd")
	_check("HouseInterior.gd carga", hi_script != null)
	if hi_script != null:
		var hi: Node3D = hi_script.new()
		root.add_child(hi)
		_check("etapa 1: solo living", hi.obtener_habitaciones().size() == 1)
		hi.entrar(3)
		_check("etapa 3: 3 habitaciones", hi.obtener_habitaciones().size() == 3)
		_check("cocina desbloqueada", hi.habitacion_desbloqueada("cocina"))
		_check("sotano NO desbloqueado (etapa 3)", not hi.habitacion_desbloqueada("sotano"))
		hi.agregar_habitaciones(["jardin"])
		_check("agregar_habitaciones jardin", hi.habitacion_desbloqueada("jardin"))
		hi.desbloquear_etapa(5)
		_check("etapa 5: 6 habitaciones", hi.obtener_habitaciones().size() == 6)
		_check("sotano desbloqueado (etapa 5)", hi.habitacion_desbloqueada("sotano"))
		var est_hi: Dictionary = hi.recolectar_estado()
		var hi2: Node3D = hi_script.new()
		root.add_child(hi2)
		hi2.restaurar_estado(est_hi)
		_check("restaurar interior: 6 habitaciones", hi2.obtener_habitaciones().size() == 6)
		hi.queue_free()
		hi2.queue_free()

	# ── Bloque 8: HouseVisit ──
	var hv_script: Script = load("res://scripts/houses/house_visit.gd")
	_check("HouseVisit.gd carga", hv_script != null)
	if hv_script != null:
		var hv: Node = hv_script.new()
		root.add_child(hv)
		hv.definir_preferencia("bruno_sapo", "ancestral")
		hv.programar_visita("bruno_sapo", "manana")
		_check("visitas_programadas manana", hv.visitas_programadas("manana").size() == 1)
		# Visita sin manager → fallo controlado
		var r0: Dictionary = hv.iniciar_visita("bruno_sapo", "casa_a", null)
		_check("sin manager = false", not bool(r0.get("ok", true)))
		# Mock de manager (Node con obtener_vecino/registrar_entrada_vecino)
		var mock = _MockManager.new()
		root.add_child(mock)
		var r1: Dictionary = hv.iniciar_visita("bruno_sapo", "casa_a", mock)
		_check("visita vecino dueño ok", bool(r1.get("ok", false)))
		_check("visita repetida = false", not bool(hv.iniciar_visita("bruno_sapo", "casa_a", mock).get("ok", true)))
		hv.terminar_visita("bruno_sapo", "casa_a", mock)
		_check("terminar_visita libera slot", bool(hv.iniciar_visita("bruno_sapo", "casa_a", mock).get("ok", false)))
		_check("vecino ajeno rechazado", not bool(hv.iniciar_visita("catalina_oso", "casa_a", mock).get("ok", true)))
		var reac: Dictionary = hv.reaccion_decoracion("bruno_sapo", "ancestral")
		_check("reacciona ancestral (match)", bool(reac.get("reacciona", false)) and String(reac.get("comentario", "")).contains("ancestral"))
		var reac2: Dictionary = hv.reaccion_decoracion("bruno_sapo", "oceánico")
		_check("reacciona no-match menciona preferencia", String(reac2.get("comentario", "")).contains("ancestral"))
		var uso: Dictionary = hv.vecino_usa_mueble({"categoria": "funcional", "nombre": "silla_madera"})
		_check("usa silla (sentarse)", uso_ok(uso, "sentarse"))
		_check("puntos_amistad_por_valor(250) = 25", hv.puntos_amistad_por_valor(250) == 25)
		_check("puntos_amistad_por_valor(9999) cap 50", hv.puntos_amistad_por_valor(9999) == 50)
		var est_hv: Dictionary = hv.recolectar_estado()
		var hv2: Node = hv_script.new()
		root.add_child(hv2)
		hv2.restaurar_estado(est_hv)
		_check("restaurar visit: agenda", hv2.visitas_programadas("manana").size() == 1)
		hv.queue_free()
		hv2.queue_free()
		mock.queue_free()

	# ── Red de seguridad ──
	create_timer(0.5).timeout.connect(func(): _fin())

func uso_ok(d: Dictionary, accion: String) -> bool:
	return bool(d.get("usa", false)) and String(d.get("accion", "")) == accion

class _MockManager extends Node:
	var _vecino_de := {"casa_a": "bruno_sapo"}
	var _entradas: Array = []
	var _salidas: Array = []
	func obtener_vecino(house_id: String) -> String:
		return String(_vecino_de.get(house_id, ""))
	func registrar_entrada_vecino(house_id: String, vecino_id: String) -> bool:
		_entradas.append(vecino_id)
		return true
	func registrar_salida_vecino(house_id: String, vecino_id: String) -> bool:
		_salidas.append(vecino_id)
		return true

func _fin() -> void:
	_summary()
	quit(1 if _fallos > 0 else 0)

func _summary() -> void:
	print("=== Resumen M18-s2: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
