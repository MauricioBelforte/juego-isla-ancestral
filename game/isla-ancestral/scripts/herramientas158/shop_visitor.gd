# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M158: Herramientas — ShopVisitorManager (Node interno del autoload "Tiers",
# iter. 2 Log 610). NPCs visitantes que compran 1x/día en la tienda del jugador
# (checklist F del 05-Checklist):
#  - 1 NPC por día máximo (cozy, sin spam)
#  - Compra 1-3 ítems del stock del jugador (M14 Inventario + M38 Economía)
#  - Paga precio de venta de M38 (duck-typed: obtener_precio_venta o precio base)
#  - Prefiere ítems de su profesión (data-driven)
#  - Solo visita si el jugador tiene un curso de oficio (puede_vender_tier)
#  - NPC trae monedas propias (tope, no infinito)
#  - Persistencia M59: visitante del día + compras (en la sección del pool padre)
# ⚠️ No es autoload: lo instancia ToolTierSystem (mismo proceso, evita otro autoload).

extends Node

signal visitor_sale(npc_nombre: String, item_id: String, precio: int)
signal visitor_llego(npc_nombre: String, profesion: String)

## Pool de NPCs visitantes data-driven (profesión ↔ cursos del jugador)
const VISITANTES := [
	{"nombre": "Mercader Ambulante", "profesion": "carpinteria", "monedas": 300},
	{"nombre": "Herrero Nómada", "profesion": "herreria", "monedas": 800},
	{"nombre": "Orfebre Viajero", "profesion": "encantamiento", "monedas": 1500},
]

## Último día absoluto en que visitó alguien (1 visita/día máximo)
var _ultimo_dia_visita: int = -1
## Visitante que llegó hoy (null si aún no llegó)
var _visitante_hoy: Dictionary = {}
## Monedas restantes del visitante de hoy
var _monedas_visitante: int = 0


## Intento de visita diaria: llamado por ToolTierSystem en day_started (M29).
## Solo visita si: no vino nadie hoy + el jugador tiene algún curso (puede vender).
## El visitante anterior se va al pasar de día (sin despedida, cozy).
func intentar_visita_diaria(dia_absoluto: int) -> Dictionary:
	# El visitante anterior se va (fin del día)
	_visitante_hoy = {}
	if _ultimo_dia_visita == dia_absoluto:
		return {}  # ya vino alguien hoy
	var ts := get_node_or_null("/root/Tiers")
	if ts == null or not ts.has_method("puede_vender_tier"):
		return {}
	var puede_vender := false
	for curso in ["T1_COBRE", "T2_HIERRO", "T3_ORO", "T4_CRISTAL"]:
		if bool(ts.puede_vender_tier(curso)):
			puede_vender = true
			break
	if not puede_vender:
		return {}
	# PRNG determinista por día (M29): sin rand global
	var rng := RandomNumberGenerator.new()
	rng.seed = dia_absoluto * 7919
	var visitante: Dictionary = VISITANTES[rng.randi_range(0, VISITANTES.size() - 1)]
	_ultimo_dia_visita = dia_absoluto
	_visitante_hoy = visitante
	_monedas_visitante = int(visitante.get("monedas", 100))
	visitor_llego.emit(String(visitante.get("nombre", "")), String(visitante.get("profesion", "")))
	print("[M158/Visitor] %s (%s) llegó a la tienda con %d AO" % [
		String(visitante.get("nombre", "")), String(visitante.get("profesion", "")), _monedas_visitante])
	return visitante


## El visitante compra un ítem del jugador (M14 → M38):
## precio = precio de venta de M38 o fallback base; respeta monedas del visitante.
func intentar_compra(item_id: String) -> Dictionary:
	if _visitante_hoy.is_empty() or _monedas_visitante <= 0:
		return {"ok": false, "motivo": "sin visitante o sin monedas"}
	var inv := get_node_or_null("/root/Inventario")
	var eco := get_node_or_null("/root/EconomyManager")
	if inv == null or eco == null:
		return {"ok": false, "motivo": "M14/M38 no disponibles"}
	if int(inv.count_item(item_id)) < 1:
		return {"ok": false, "motivo": "item no poseído"}
	# Precio de venta: M38 PriceManager (duck-typed) o fallback 5 AO
	var precio := 5
	var pm := get_node_or_null("/root/PriceManager")
	if pm != null and pm.has_method("obtener_precio_venta"):
		precio = int(pm.obtener_precio_venta(item_id))
	precio = mini(precio, _monedas_visitante)
	if precio <= 0:
		return {"ok": false, "motivo": "visitante sin monedas"}
	# Transferencia atómica: ítem del jugador → AO al jugador
	if not bool(inv.remover_items({item_id: 1})):
		return {"ok": false, "motivo": "inventario cambió"}
	eco.depositar_monedas(precio)
	_monedas_visitante -= precio
	var nombre := String(_visitante_hoy.get("nombre", ""))
	visitor_sale.emit(nombre, item_id, precio)
	print("[M158/Visitor] %s compró %s por %d AO" % [nombre, item_id, precio])
	return {"ok": true, "precio": precio}


## Estado del visitante de hoy (para UI M53)
func visitante_hoy() -> Dictionary:
	return _visitante_hoy.duplicate()


func monedas_visitante() -> int:
	return _monedas_visitante
