# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M67: Vehículos — VehiclePreset (Resource data-driven, diseño §1/§3.1).
# Un preset describe tipo, física y capacidades. La fuente de verdad es
# data/vehiculos/vehicles.json; VehiclePreset es la representación runtime.
# SÍ lleva class_name: es Resource (convención del proyecto, como BoatRoute).
class_name VehiclePreset
extends Resource

@export var id: String = ""
## agua | aire | subagua | riel
@export var tipo: String = ""
@export var nombre: String = ""
## Velocidad máxima (m/s) — nunca rompe streaming (regla dura M10/M61)
@export var velocidad_max: float = 12.0
@export var velocidad_crucero: float = 6.0
## Rad/s de giro (0 = fijo, locomotora sobre riel)
@export var giro: float = 1.6
## Desaceleración al frenar (m/s²)
@export var frenado: float = 4.0
## Altitud máxima (m sobre el nivel del mar; 0 = no vuela)
@export var altitud_max: float = 0.0
## Profundidad máxima (m bajo el nivel del mar; 0 = no se sumerge)
@export var profundidad_max: float = 0.0
## Baúl del vehículo (M14) — solo contrato de tamaño aquí
@export var baul_slots: int = 12
@export var tiene_reversa: bool = true
## Módulo condicional (ej. locomotora espera M68); "" = siempre disponible
@export var condicional: String = ""
## Mejoras por nivel (03-Diseno §3.1): {"nivel_max": int,
## "por_nivel": {velocidad/giro/baul/altitud: float}, "topes": {...}}.
## Vacío = sin mejoras (locomotora las declara pero el techo las limita).
@export var mejoras: Dictionary = {}
## Nivel de mejora actual (0 = base; persistencia M59 en iter. siguiente)
@export var nivel: int = 0


## Datos → preset (desde vehicles.json)
static func desde_datos(datos: Dictionary) -> VehiclePreset:
	var p := VehiclePreset.new()
	p.id = String(datos.get("id", ""))
	p.tipo = String(datos.get("tipo", ""))
	p.nombre = String(datos.get("nombre", p.id))
	p.velocidad_max = float(datos.get("velocidad_max", 12.0))
	p.velocidad_crucero = float(datos.get("velocidad_crucero", 6.0))
	p.giro = float(datos.get("giro", 1.6))
	p.frenado = float(datos.get("frenado", 4.0))
	p.altitud_max = float(datos.get("altitud_max", 0.0))
	p.profundidad_max = float(datos.get("profundidad_max", 0.0))
	p.baul_slots = int(datos.get("baul_slots", 12))
	p.tiene_reversa = bool(datos.get("tiene_reversa", true))
	p.condicional = String(datos.get("condicional", ""))
	var m = datos.get("mejoras", {})
	p.mejoras = m if m is Dictionary else {}
	p.nivel = clampi(int(datos.get("nivel", 0)), 0, p.nivel_max())
	return p


# --- Mejoras por nivel (M67 tanda 4, 2026-10-22) ---
# Data-driven: los incrementos y topes salen de vehicles.json; los topes
# coinciden con la columna Mejoras de 03-Diseno §3.1 (dirigible altitud 90,
# submarino baul 16). Nivel 0 = valores base (comportamiento histórico).

func nivel_max() -> int:
	return maxi(0, int(mejoras.get("nivel_max", 0)))


func _por_nivel(clave: String) -> float:
	var pn = mejoras.get("por_nivel", {})
	return float(pn.get(clave, 0.0)) if pn is Dictionary else 0.0


func _tope(clave: String, base: float) -> float:
	var tops = mejoras.get("topes", {})
	if tops is Dictionary and tops.has(clave):
		return float(tops[clave])
	return base


## Velocidad máxima efectiva (base + incrementos por nivel, con techo)
func velocidad_max_efectiva() -> float:
	if nivel <= 0:
		return velocidad_max
	return minf(velocidad_max + _por_nivel("velocidad") * nivel, _tope("velocidad", velocidad_max))


## Giro efectivo (rad/s; 0 sigue siendo 0 = riel fijo)
func giro_efectivo() -> float:
	if nivel <= 0 or giro <= 0.0:
		return giro
	return minf(giro + _por_nivel("giro") * nivel, _tope("giro", giro))


## Slots de baúl efectivos (M14; techo del diseño §3.1)
func baul_slots_efectivo() -> int:
	if nivel <= 0:
		return baul_slots
	return int(minf(float(baul_slots + int(_por_nivel("baul")) * nivel), _tope("baul", float(baul_slots))))


## Altitud máxima efectiva (m; dirigible 60 -> 90 con el nivel máximo)
func altitud_max_efectiva() -> float:
	if nivel <= 0 or altitud_max <= 0.0:
		return altitud_max
	return minf(altitud_max + _por_nivel("altitud") * nivel, _tope("altitud", altitud_max))


## Sube un nivel si no está al máximo. Devuelve true si cambió.
func subir_nivel() -> bool:
	if nivel >= nivel_max():
		return false
	nivel += 1
	return true


## Baja un nivel si no está en la base. Devuelve true si cambió.
func bajar_nivel() -> bool:
	if nivel <= 0:
		return false
	nivel -= 1
	return true
