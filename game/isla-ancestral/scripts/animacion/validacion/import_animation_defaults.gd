# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M48: Plantilla de import de animaciones — L32 / 03-Diseno.md sec 6.
# Contrato: "aplica por DROP de FBX — fps 30, loop on/off por sufijo del clip
# (_loop), compresion activada como el resto del proyecto, remapeo de huesos por
# familia (tabla sec 5) y emision de las senales L199".
#
# ALCANCE MEDIDO Y DECLARADO (no se inventa lo que no hay):
#   - Se implementa la PARTE normalizable sobre un `Animation` ya cargado:
#     fps/step por categoria, loop por sufijo `_loop`, remapeo de prefijos de
#     vendor en las rutas de hueso, y validacion del subset por familia.
#   - NO se implementa el hook de import del editor (EditorImportPlugin): no corre
#     con --script, y este proyecto exige validacion headless (M118). El gate real
#     es validate_animation_cli.gd.
#   - La COMPRESION de import es un ajuste de importacion de Godot
#     (importer_defaults): se declara el valor esperado y se reporta como NV, no se
#     escribe en project.godot (archivo NO TOCAR, regla dura del proyecto).
#   - El remapeo es de PREFIJOS de vendor (mixamorig:, Armature|...). El mapping
#     hueso-por-hueso por familia necesita la tabla de sec 5 con datos por hueso,
#     que hoy no existe en disco: se declara NV, no se finge.
#
# Suite: res://scripts/animacion/test_validacion_m48.gd

class_name ImportAnimationDefaults
extends RefCounted

## fps por categoria (03-Diseno sec 3.1).
const FPS_BASE := 30.0
const FPS_UI := 60.0

## Sufijo que marca un clip ciclico (03-Diseno sec 6, L32).
const SUFIJO_LOOP := "_loop"

## Subset de huesos por familia (03-Diseno sec 5).
const HUESOS_POR_FAMILIA := {"humanoide": 40, "cuadrupedo": 28, "ave": 22, "pez": 14}

## Prefijos de vendor que se quitan al remapear (medidos en exports de Mixamo/Blender).
const PREFIJOS_VENDOR := ["mixamorig:", "mixamorig_", "Armature|", "Armature_", "Armature:"]

## Modo de compresion esperado para clips importados (declarado, no aplicable headless).
const COMPRESION_ESPERADA := "lossy_quantization"


## fps que corresponde a una categoria.
static func fps_de(categoria: String) -> float:
	if categoria == "ui":
		return FPS_UI
	return FPS_BASE


## Loop por SUFIJO: el contrato es explicito, no se adivina por el nombre de la accion.
static func debe_loopear(nombre: String) -> bool:
	return nombre.ends_with(SUFIJO_LOOP)


## Quita el sufijo de control del nombre para dejar el id del clip.
static func id_sin_sufijo(nombre: String) -> String:
	if nombre.ends_with(SUFIJO_LOOP):
		return nombre.substr(0, nombre.length() - SUFIJO_LOOP.length())
	return nombre


## Normaliza un nombre de hueso quitando el prefijo de vendor.
static func normalizar_hueso(hueso: String) -> String:
	var h: String = hueso
	for p in PREFIJOS_VENDOR:
		var pref: String = str(p)
		if h.begins_with(pref):
			h = h.substr(pref.length())
			break
	return h


## Remapea la ruta de un track de hueso: normaliza SOLO el hueso, conserva el nodo y la propiedad.
## "mixamorig:Skeleton3D:mixamorig_Hips:position" no es la forma real: la ruta es
## "<nodo>:<hueso>" o "<nodo>:<hueso>:<propiedad>"; se normaliza el indice 1.
static func remapear_ruta(ruta: NodePath) -> NodePath:
	var texto: String = str(ruta)
	var partes: PackedStringArray = texto.split(":")
	if partes.size() < 2:
		return ruta
	partes[1] = normalizar_hueso(partes[1])
	return NodePath(":".join(partes))


## Aplica los defaults de import a UN clip ya cargado.
## Devuelve {"step": float, "loop": bool, "cambios": Array[String]}.
## NO toca `length` (eso es contenido del clip, no default de import).
func aplicar(anim: Animation, categoria: String, nombre: String = "") -> Dictionary:
	var cambios: Array[String] = []
	if anim == null:
		return {"step": 0.0, "loop": false, "cambios": cambios}

	var n: String = nombre
	if n == "":
		n = anim.resource_name

	var fps: float = fps_de(categoria)
	var step: float = 1.0 / fps
	if not is_equal_approx(anim.step, step):
		cambios.append("step %s -> %s (%.1f fps)" % [str(anim.step), str(step), fps])
		anim.step = step

	var loop: bool = debe_loopear(n)
	var modo: int = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	if anim.loop_mode != modo:
		cambios.append("loop_mode %d -> %d" % [anim.loop_mode, modo])
		anim.loop_mode = modo

	var remapeadas: int = 0
	for t in range(anim.get_track_count()):
		var tipo: int = anim.track_get_type(t)
		if tipo != Animation.TYPE_POSITION_3D and tipo != Animation.TYPE_ROTATION_3D and tipo != Animation.TYPE_SCALE_3D:
			continue
		var original: NodePath = anim.track_get_path(t)
		var nueva: NodePath = remapear_ruta(original)
		if nueva != original:
			anim.track_set_path(t, nueva)
			remapeadas += 1
	if remapeadas > 0:
		cambios.append("%d ruta(s) de hueso remapeadas a prefijo neutro" % remapeadas)

	return {"step": step, "loop": loop, "cambios": cambios}


## Valida el subset de huesos de una familia. Devuelve errores E#/avisos A#.
static func validar_subset(familia: String, huesos: int) -> Array[String]:
	var salida: Array[String] = []
	if not HUESOS_POR_FAMILIA.has(familia):
		salida.append("E9 familia desconocida '%s' (validas: %s)" % [familia, str(HUESOS_POR_FAMILIA.keys())])
		return salida
	var tope: int = int(HUESOS_POR_FAMILIA[familia])
	if huesos > tope:
		salida.append("A3 %d huesos > subset %d de '%s'" % [huesos, tope, familia])
	return salida


## Lo que esta plantilla NO puede aplicar ni verificar sin tocar archivos protegidos.
static func no_verificable() -> Array[String]:
	var out: Array[String] = []
	out.append("NV4 compresion de import ('%s'): vive en importer_defaults de project.godot, archivo NO TOCAR" % COMPRESION_ESPERADA)
	out.append("NV5 mapping hueso-por-hueso por familia: la tabla de 03-Diseno sec 5 no tiene datos por hueso en disco")
	out.append("NV6 hook de import del editor: no corre con --script; el gate real es validate_animation_cli.gd")
	return out
