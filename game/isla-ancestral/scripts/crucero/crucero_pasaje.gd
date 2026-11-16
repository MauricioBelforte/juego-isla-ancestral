class_name PasajeCrucero
extends Resource
## Pasaje del Crucero Real (M169).
## Es un Resource para poder guardarlo como parte del estado y no acoplarlo a la UI.

@export var route_id: StringName = &""
@export var stop_id_origen: StringName = &""
@export var stop_id_destino: StringName = &""
@export var clase: StringName = &""          ## "tercera" | "segunda" | "primera"
@export var camarote: StringName = &""       ## id de camarotes.json
@export var precio: int = 0
@export var cubierta: int = 2
@export var embarcado: bool = false
@export var fecha_compra: Dictionary = {}    ## {dia, mes, anio} (M29)

func esta_vacio() -> bool:
	return route_id == &"" or clase == &""

func descripcion() -> String:
	if esta_vacio():
		return "(sin pasaje)"
	return "%s a %s · %s" % [stop_id_origen, stop_id_destino, clase]

func clonar() -> PasajeCrucero:
	var p := PasajeCrucero.new()
	p.route_id = route_id
	p.stop_id_origen = stop_id_origen
	p.stop_id_destino = stop_id_destino
	p.clase = clase
	p.camarote = camarote
	p.precio = precio
	p.cubierta = cubierta
	p.embarcado = embarcado
	p.fecha_compra = fecha_compra.duplicate(true)
	return p