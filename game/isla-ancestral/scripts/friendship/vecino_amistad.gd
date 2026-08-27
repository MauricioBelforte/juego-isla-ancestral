# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M20: Amistad — VecinoAmistad (estado de amistad individual de un vecino)
# Puntos acumulados, nivel, historial de hoy (límites diarios), memoria de
# regalos recibidos, cartas y eventos. Cozy: SIN decaimiento ni FOMO.
class_name VecinoAmistad
extends RefCounted

## Umbrales por nivel (03-Diseno §4): puntos acumulados para alcanzar cada nivel.
const UMBRALES := [0, 20, 40, 70, 100, 140, 190, 250, 320, 400, 500]

const LIMITE_DIARIO := {
	"regalo": 1,
	"charla": 1,
	"carta": 1,
}

var vecino_id: String = ""
var puntos: int = 0
var nivel: int = 1
var _regalos_recibidos: Array = []          # item_ids ya regalados (memoria)
var _limites_hoy: Dictionary = {}           # tipo -> cantidad usada hoy
var _dia_actual: int = 0
var _recompensas_pendientes: Array = []     # reward_ids por reclamar

func _init(p_vecino_id: String) -> void:
	vecino_id = p_vecino_id

## ── Consultas ─────────────────────────────────────────────
func get_nivel() -> int:
	return nivel

func get_puntos() -> int:
	return puntos

func get_progreso() -> Dictionary:
	var umbral_ini: int = int(UMBRALES[clampi(nivel - 1, 0, UMBRALES.size() - 1)])
	var umbral_sig: int = int(UMBRALES[clampi(nivel, 0, UMBRALES.size() - 1)])
	var en_nivel: int = puntos - umbral_ini
	var ancho: int = maxi(1, umbral_sig - umbral_ini)
	return {"nivel": nivel, "puntos": puntos, "en_nivel": en_nivel, "ancho": ancho, "progreso": float(en_nivel) / float(ancho)}

func get_limite_dia(tipo: String) -> Dictionary:
	var maximo := int(LIMITE_DIARIO.get(tipo, 0))
	var usado := int(_limites_hoy.get(tipo, 0))
	return {"maximo": maximo, "usado": usado, "restante": maxi(0, maximo - usado)}

func ha_regalado(item_id: String) -> bool:
	return item_id in _regalos_recibidos

func get_memoria() -> Array:
	return _regalos_recibidos.duplicate()

func get_recompensas_pendientes() -> Array:
	return _recompensas_pendientes.duplicate()

## ── Acciones ──────────────────────────────────────────────

## Intentar usar un límite diario. Devuelve false si ya se agotó.
func intentar_usar_limite(tipo: String, dia: int) -> bool:
	if dia != _dia_actual:
		_dia_actual = dia
		_limites_hoy.clear()
	var usado := int(_limites_hoy.get(tipo, 0))
	var maximo := int(LIMITE_DIARIO.get(tipo, 0))
	if usado >= maximo:
		return false
	_limites_hoy[tipo] = usado + 1
	return true

## Aplica puntos, resuelve subida de nivel (conserva excedente) y devuelve
## si subió de nivel. Emite via retorno; el servicio decide la señal.
func aplicar_puntos(delta: int, recompensas_nivel: Dictionary) -> bool:
	puntos += maxi(0, delta)
	var subio := false
	while nivel < UMBRALES.size() - 1 and puntos >= UMBRALES[nivel]:
		nivel += 1
		subio = true
		if recompensas_nivel.has(nivel):
			for r in recompensas_nivel[nivel]:
				if not (r in _recompensas_pendientes):
					_recompensas_pendientes.append(r)
	return subio

func registrar_regalo(item_id: String) -> void:
	if not (item_id in _regalos_recibidos):
		_regalos_recibidos.append(item_id)

func reclamar_recompensa(reward_id: String) -> bool:
	if reward_id in _recompensas_pendientes:
		_recompensas_pendientes.erase(reward_id)
		return true
	return false

## ── Persistencia (M59 ISaveProvider) ──────────────────────
func serializar() -> Dictionary:
	return {
		"vecino_id": vecino_id,
		"puntos": puntos,
		"nivel": nivel,
		"regalos": _regalos_recibidos.duplicate(),
		"limites_hoy": _limites_hoy.duplicate(),
		"dia": _dia_actual,
		"pendientes": _recompensas_pendientes.duplicate(),
	}

func deserializar(d: Dictionary) -> void:
	vecino_id = str(d.get("vecino_id", vecino_id))
	puntos = maxi(0, int(d.get("puntos", 0)))
	nivel = clampi(int(d.get("nivel", 1)), 1, UMBRALES.size() - 1)
	_regalos_recibidos.clear()
	for r in d.get("regalos", []):
		_regalos_recibidos.append(str(r))
	_limites_hoy.clear()
	for k in d.get("limites_hoy", {}):
		_limites_hoy[str(k)] = int(d["limites_hoy"][k])
	_dia_actual = int(d.get("dia", 0))
	_recompensas_pendientes.clear()
	for p in d.get("pendientes", []):
		_recompensas_pendientes.append(str(p))
