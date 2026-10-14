class_name NpcProfile
extends Resource

##
# M139 Pre-Alpha (seccion 4) — plantilla de NPC: rutina, horarios y personalidad.
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha).
# Cierra el item "Disenar la plantilla npc_profile.gd (rutina, horarios, personalidad)".
#
# QUE ES: el Resource que define a un NPC del elenco de Aurora/Coral. Lo cargan los generadores
# de rutas (M64) y la capa de dialogo (M21). No tiene logica: es data + validacion.
#
# @see RutinaIA (companero: la maquina de estados que CONSUME este perfil)
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md (seccion 2.3, elenco)

## Personalidades canonicas del slice (afectan ritmo de dialogo y tolerancia).
enum Personalidad { VECINAL, ARTESANO, COMERCIANTE, EXPLORADOR, VIGIA, BANCARIO, VIDRIERO }

## Nombre mostrable (i18n key, ej: "NPC.FINNEAS").
@export var nombre_clave: String = ""
## Pronombres canonicos (M147): "el", "ella", "elle".
@export var pronombres: String = "elle"
## Rol corto para la UI (i18n key).
@export var rol_clave: String = ""
@export var personalidad: int = Personalidad.VECINAL
## Isla/zona donde vive (ej: "aurora", "coral").
@export var zona: String = "aurora"

## Waypoints de la rutina: Array de Vector3 (posiciones en el mundo).
@export var ruta: Array[Vector3] = []
## Franjas horarias de la rutina: Array de Dictionary {desde:int, hasta:int, waypoint:int}.
# Horas en formato 0-23. Sin solapamiento catastrofico: ver tabla de rangos en 03-Diseno.md 2.3.1.
@export var horarios: Array[Dictionary] = []
## Velocidad base de caminata (m/s).
@export var velocidad: float = 1.6
## Tolerancia a desvios de ruta en metros (M66 anti-stuck).
@export var tolerancia_desvio: float = 0.75
## true si el NPC tiene puesto fijo (bucle) en lugar de ruta.
@export var bucle_fijo: bool = false
## Gancho de gameplay (i18n key del dialogo/trigger que lo identifica).
@export var gancho_clave: String = ""

## Valida el perfil; devuelve una lista de strings vacios si todo OK.
func validar() -> Array:
	var errores: Array = []
	if nombre_clave.is_empty():
		errores.append("nombre_clave vacio")
	if ruta.is_empty() and not bucle_fijo:
		errores.append("sin ruta y no es bucle_fijo")
	if horarios.is_empty() and not bucle_fijo:
		errores.append("sin horarios y no es bucle_fijo")
	return errores
