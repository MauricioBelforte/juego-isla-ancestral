# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: VALIDADOR UNIFICADO (sección W).
#
# Un solo punto de entrada (`validar_todo`) que reúne TODAS las invariantes del
# módulo, en vez de repartirlas por los tests:
#
#   grafo        TransportNetwork.validar()                 (dataset)
#   planes       TransportTripPlanner.verificar_plan()       (cozy, M61, RF20)
#   costes       directo > combinar · descuento M20          (M38/M20)
#   especiales   TransportSpecialTrips.validar()             (M74/M31)
#   narrativos   TransportNarrativeTrips.validar()           (M22/M23)
#   eventos      TransportRouteEvents.validar()              (M64, RF18)
#   m69          TransportM69Bridge.validar()                (M69)
#   localizacion TransportLocalizer.validar()                (M87)
#   ciclo        ciclo completo mapa → elegir → pagar → viajar → llegar
#
# Lo que NO se puede verificar sin M46/M54 (señalización vs mapa, capa de rutas)
# NO se declara como error: se informa en `pendientes`, para no fingir cobertura.
#
# Sin escena y sin autoloads: todo entra por parámetro.

class_name ValidateTransport
extends RefCounted

const BLOQUES: Array[String] = [
	"grafo", "planes", "costes", "especiales", "narrativos",
	"eventos", "m69", "localizacion", "ciclo",
]

## Bloques que dependen de módulos de escena (M46 carteles, M54 mapa) y que por
## tanto NO son verificables headless. Se informan, no se fingen.
const PENDIENTES_EXTERNOS: Array[String] = [
	"senalizacion_vs_mapa (M46)",
	"capa_de_rutas_en_el_mapa (M54)",
	"panel_de_transporte (M53)",
	"animaciones_y_pasajeros (M48/M64)",
]

var _checks: int = 0


## ── Bloques ──────────────────────────────────────────────────────────────

func validar_grafo(red: TransportNetwork) -> Array[String]:
	if red == null:
		return ["sin red de transporte"]
	return red.validar()


## Todos los planes posibles: uno por ruta del grafo. Comprueba las invariantes
## de RF14/RF15/RF20 sobre CADA ruta, no sobre una muestra.
func validar_planes(red: TransportNetwork) -> Array[String]:
	var errores: Array[String] = []
	if red == null:
		return ["sin red de transporte"]
	var cortos: int = 0
	var largos: int = 0
	for r in red.routes:
		var ruta: TransportRoute = r as TransportRoute
		if ruta == null:
			continue
		var destino: TransportStop = red.stop(ruta.to_id)
		if destino == null:
			errores.append("ruta %s sin destino" % ruta.id)
			continue
		var plan: Dictionary = TransportTripPlanner.planificar(ruta, destino)
		for e in TransportTripPlanner.verificar_plan(plan):
			errores.append("ruta %s: %s" % [ruta.id, e])
		_checks += 1
		if bool(plan.get("usa_vehiculo", false)):
			cortos += 1
		else:
			largos += 1
	# Ambas ramas del diseño deben existir (viaje corto y montaje con fade).
	if cortos == 0:
		errores.append("ninguna ruta se resuelve como viaje corto (M67)")
	if largos == 0:
		errores.append("ninguna ruta usa montaje con fade")
	return errores


## Costes. HARD: el descuento de M20 debe ser exactamente −20 % a nivel 5+.
##
## ⚠️ La propiedad "el directo es más caro que combinar" (03-Diseno §3.2) NO es
## universal en el dataset: se cumple en las rutas EXPRESAS (aurora→sur 80 vs 68,
## aurora→este 90 vs 78) pero NO en las locales del muelle (muelle→sur 60 vs 88),
## donde el directo ES la opción barata. Por eso se MIDE
## (`medir_directo_vs_combinar`) en vez de exigirse: exigirla fallaría en 6 rutas
## correctas por diseño. Corrige el `[x]` optimista de la iter. 1 (Log 910).
func validar_costes(red: TransportNetwork) -> Array[String]:
	var errores: Array[String] = []
	if red == null:
		return ["sin red de transporte"]
	for r in red.routes:
		var ruta: TransportRoute = r as TransportRoute
		if ruta == null:
			continue
		# Descuento M20 (universal).
		var esperado: int = int(round(float(ruta.base_cost) * 0.8))
		var con_desc: int = ruta.coste_con_descuento(5)
		if con_desc != esperado:
			errores.append("ruta %s: descuento M20 %d != esperado %d" % [ruta.id, con_desc, esperado])
		if ruta.coste_con_descuento(4) != ruta.base_cost:
			errores.append("ruta %s: descuenta con amistad < 5" % ruta.id)
		if ruta.base_cost <= 0:
			errores.append("ruta %s: coste no positivo" % ruta.id)
		_checks += 1
	return errores


## MEDICIÓN (no invariante): ¿el viaje directo cuesta más que combinar rutas?
## Devuelve {total, sin_alternativa, cumplen, violan}. `cumplen` = el directo es
## más caro que la mejor combinación (incentiva la exploración); `violan` = el
## directo es la opción barata (rutas locales: comportamiento correcto).
func medir_directo_vs_combinar(red: TransportNetwork) -> Dictionary:
	var cumplen: Array[String] = []
	var violan: Array[String] = []
	var sin_alt: Array[String] = []
	if red == null:
		return {"total": 0, "sin_alternativa": sin_alt, "cumplen": cumplen, "violan": violan}
	for r in red.routes:
		var ruta: TransportRoute = r as TransportRoute
		if ruta == null:
			continue
		var evitar := func(otra: TransportRoute) -> bool:
			return otra.id != ruta.id
		var alt: Dictionary = red.ruta_mas_barata(ruta.from_id, ruta.to_id, evitar)
		if not bool(alt.get("ok", false)):
			sin_alt.append(String(ruta.id))
			continue
		if ruta.base_cost > int(alt.get("coste", 0)):
			cumplen.append(String(ruta.id))
		else:
			violan.append(String(ruta.id))
	cumplen.sort()
	violan.sort()
	sin_alt.sort()
	return {"total": red.contar_rutas(), "sin_alternativa": sin_alt, "cumplen": cumplen, "violan": violan}


func validar_especiales(registro: Object, red: TransportNetwork) -> Array[String]:
	if registro == null:
		return ["registro de viajes especiales ausente"]
	if not registro.has_method("validar"):
		return ["el registro de viajes especiales no expone validar()"]
	var r: Variant = registro.call("validar", red)
	return _a_errores(r)


func validar_narrativos(registro: Object, red: TransportNetwork, historia: Object = null) -> Array[String]:
	if registro == null:
		return ["registro de viajes narrativos ausente"]
	if not registro.has_method("validar"):
		return ["el registro de viajes narrativos no expone validar()"]
	var r: Variant = registro.call("validar", red, historia)
	return _a_errores(r)


func validar_eventos(registro: Object, red: TransportNetwork, villager: Object = null) -> Array[String]:
	if registro == null:
		return ["registro de eventos de ruta ausente"]
	if not registro.has_method("validar"):
		return ["el registro de eventos de ruta no expone validar()"]
	var r: Variant = registro.call("validar", red, villager)
	return _a_errores(r)


func validar_m69(puente: Object, red: TransportNetwork, anclas: Array, precios_boleto: Dictionary = {}, desbloqueadas: Array = []) -> Array[String]:
	if puente == null:
		return ["puente M69 ausente"]
	if not puente.has_method("validar"):
		return ["el puente M69 no expone validar()"]
	var r: Variant = puente.call("validar", red, anclas, precios_boleto, desbloqueadas)
	return _a_errores(r)


## `locales` se recibe como Array SIN tipar a propósito: cuando viene de un
## Dictionary (`contexto.get("locales")`) es un Array genérico y Godot rechaza
## pasarlo a un parámetro `Array[String]` ("does not have the same element type").
func validar_localizacion(localizador: Object, locales: Array = ["es", "en"], red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Array[String]:
	if localizador == null:
		return ["localizador ausente"]
	if not localizador.has_method("validar"):
		return ["el localizador no expone validar()"]
	var locales_tipados: Array[String] = []
	for l in locales:
		locales_tipados.append(str(l))
	var r: Variant = localizador.call("validar", locales_tipados, red, especiales, narrativos, eventos)
	return _a_errores(r)


## ── Ciclo completo (mapa → elegir → pagar → viajar → llegar) ─────────────

## Simula el ciclo entero contra el TransportManager REAL. Devuelve
## {ok, pasos, errores, plan}. No necesita escena ni jugador: usa los hooks de
## test del manager (contexto y cartera simulados) si `opciones` los trae.
func simular_ciclo(manager: Object, red: TransportNetwork, stop_id: String, route_id: String, opciones: Dictionary = {}) -> Dictionary:
	var pasos: Array[String] = []
	var errores: Array[String] = []
	var plan: Dictionary = {}
	if manager == null or red == null:
		return {"ok": false, "pasos": pasos, "errores": ["sin manager o sin red"], "plan": plan}

	# 1) Abrir el panel: listar rutas de la parada.
	if manager.has_method("forzar_contexto") and opciones.has("contexto"):
		var ctx: Array = opciones.get("contexto", []) as Array
		if ctx.size() >= 4:
			manager.call("forzar_contexto", int(ctx[0]), int(ctx[1]), str(ctx[2]), int(ctx[3]))
	if manager.has_method("forzar_cartera") and opciones.has("cartera"):
		manager.call("forzar_cartera", int(opciones["cartera"]))
	var rutas: Variant = manager.call("list_routes", StringName(stop_id))
	var lista: Array = rutas if rutas is Array else []
	var encontrada: Dictionary = {}
	for r in lista:
		var rd: Dictionary = r as Dictionary
		if not rd.is_empty() and str(rd.get("route_id", "")) == route_id:
			encontrada = rd
			break
	if encontrada.is_empty():
		errores.append("la ruta %s no aparece en la parada %s" % [route_id, stop_id])
		return {"ok": false, "pasos": pasos, "errores": errores, "plan": plan}
	pasos.append("panel: %s ofrecida a %s" % [route_id, str(encontrada.get("precio", "?"))])
	if not bool(encontrada.get("disponible", false)):
		errores.append("la ruta %s no está disponible: %s" % [route_id, str(encontrada.get("motivo_bloqueo", ""))])
		return {"ok": false, "pasos": pasos, "errores": errores, "plan": plan}

	# 2) Pagar el boleto.
	var compra_d: Dictionary = _dic(manager.call("buy_ticket", StringName(route_id), StringName(stop_id)))
	if not bool(compra_d.get("ok", false)):
		errores.append("no se pudo comprar el boleto: %s" % str(compra_d.get("motivo", "?")))
		return {"ok": false, "pasos": pasos, "errores": errores, "plan": plan}
	pasos.append("boleto pagado: %d AO" % int(compra_d.get("precio", 0)))

	# 3) Planificar la transición (cozy, cargar destino antes de mover).
	var ruta: TransportRoute = red.ruta(StringName(route_id))
	var destino: TransportStop = red.stop(ruta.to_id) if ruta != null else null
	plan = TransportTripPlanner.planificar(ruta, destino)
	for e in TransportTripPlanner.verificar_plan(plan):
		errores.append("plan: " + e)
	if bool(plan.get("ok", false)):
		pasos.append(TransportTripPlanner.resumen(plan))
	# 4) Llegar.
	var llegada_d: Dictionary = _dic(manager.call("notificar_llegada"))
	if not bool(llegada_d.get("ok", false)):
		errores.append("no se pudo cerrar el viaje: %s" % str(llegada_d.get("motivo", "?")))
	else:
		pasos.append("llegada registrada en %s" % str(llegada_d.get("to", "")))

	if manager.has_method("forzar_cartera"):
		manager.call("forzar_cartera", -1)
	if manager.has_method("forzar_contexto"):
		manager.call("forzar_contexto", -1, -1, "", -1)
	return {"ok": errores.is_empty(), "pasos": pasos, "errores": errores, "plan": plan}


## ── Todo ─────────────────────────────────────────────────────────────────

## Ejecuta todos los bloques. Devuelve:
##   {ok, errores, checks, bloques: {nombre: n_errores}, pendientes: Array}
func validar_todo(red: TransportNetwork, contexto: Dictionary = {}) -> Dictionary:
	_checks = 0
	var errores: Array[String] = []

	var bloques: Dictionary = {
		"grafo": validar_grafo(red),
		"planes": validar_planes(red),
		"costes": validar_costes(red),
		"especiales": validar_especiales(contexto.get("especiales"), red),
		"narrativos": validar_narrativos(contexto.get("narrativos"), red, contexto.get("historia")),
		"eventos": validar_eventos(contexto.get("eventos"), red, contexto.get("villager")),
		"m69": validar_m69(contexto.get("m69"), red, contexto.get("anclas", []), contexto.get("precios", {}), contexto.get("desbloqueadas", [])),
		"localizacion": validar_localizacion(contexto.get("localizador"), contexto.get("locales", ["es", "en"]), red,
			contexto.get("especiales"), contexto.get("narrativos"), contexto.get("eventos")),
		"ciclo": [],
	}
	# Ciclo completo: 3 destinos representativos (barco corto, tren, dirigible).
	var manager: Variant = contexto.get("manager")
	if manager != null:
		var pruebas: Array = contexto.get("ciclos", [
			["puerto_aurora", "r_aurora_sur"],
			["puerto_aurora", "r_aurora_estacion"],
			["puerto_aurora", "r_aurora_plataforma"],
		])
		var errores_ciclo: Array[String] = []
		for p in pruebas:
			var par: Array = p
			var res: Dictionary = simular_ciclo(manager, red, str(par[0]), str(par[1]), contexto)
			for e in res.get("errores", []):
				errores_ciclo.append("ciclo %s: %s" % [str(par[1]), str(e)])
			_checks += 1
		bloques["ciclo"] = errores_ciclo
	else:
		bloques["ciclo"] = ["sin manager: ciclo no simulado"]

	var resumen_bloques: Dictionary = {}
	for nombre in bloques.keys():
		var lista: Array = bloques[nombre]
		resumen_bloques[nombre] = lista.size()
		for e2 in lista:
			errores.append("[%s] %s" % [str(nombre), str(e2)])

	var medicion: Dictionary = medir_directo_vs_combinar(red)
	return {
		"ok": errores.is_empty(),
		"errores": errores,
		"checks": _checks,
		"bloques": resumen_bloques,
		"pendientes": PENDIENTES_EXTERNOS.duplicate(),
		"mediciones": {"directo_vs_combinar": medicion},
	}


func informe(resultado: Dictionary) -> String:
	var lineas: Array[String] = []
	lineas.append("VALIDATE-TRANSPORT %s (%d checks)" % ["OK" if bool(resultado.get("ok", false)) else "FALLO", int(resultado.get("checks", 0))])
	var bloques: Dictionary = resultado.get("bloques", {})
	for nombre in BLOQUES:
		if bloques.has(nombre):
			lineas.append("  %-13s %d errores" % [nombre, int(bloques[nombre])])
	for e in resultado.get("errores", []):
		lineas.append("  ! " + str(e))
	var mediciones: Dictionary = resultado.get("mediciones", {})
	if mediciones.has("directo_vs_combinar"):
		var m: Dictionary = mediciones["directo_vs_combinar"]
		lineas.append("  ~ medido: directo>combinar — %d cumplen, %d violan (locales), %d sin alternativa" % [
			(m.get("cumplen", []) as Array).size(),
			(m.get("violan", []) as Array).size(),
			(m.get("sin_alternativa", []) as Array).size(),
		])
	for p in resultado.get("pendientes", []):
		lineas.append("  ~ pendiente (fuera de headless): " + str(p))
	return "\n".join(lineas)


static func _a_errores(valor: Variant) -> Array[String]:
	var out: Array[String] = []
	if valor is Array:
		for x in valor:
			out.append(str(x))
	return out


## Convierte un Variant a Dictionary sin romper (los `call()` devuelven Variant).
static func _dic(valor: Variant) -> Dictionary:
	if valor is Dictionary:
		return valor
	return {}
