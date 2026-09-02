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
	return p
