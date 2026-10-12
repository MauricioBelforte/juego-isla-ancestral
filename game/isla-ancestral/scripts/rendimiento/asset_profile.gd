extends Node

## Autoload de selecction de variantes de asset por perfil de rendimiento (M166 F1).
## Disenio: DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/03-Diseno.md §4.
##
## Responsabilidades:
##  - Resolver el perfil activo ("alta" | "media" | "baja") una vez al arrancar.
##  - Resolver la ruta res:// del GLB correcto para un modelo_id dado.
##  - Degradar a la variante mas alta disponible si el perfil activo no existe
##    para ese modelo (graceful fallback), con push_warning en Debug.
##
## Formato de archivo en disco (verificado en assets/3d/{perfil}/):
##   res://assets/3d/{perfil}/{modelo_id}.glb
## donde modelo_id es el stem del archivo (p.ej. "25-Ruinas-Templos_cofre_ancestral").
## (Nota: el diseno conceptual §2.2/§4.6 usa assets/props/...; el layout REAL del
##  repo es assets/3d/{perfil}/, por eso ruta() sigue el disco, no el boceto.)
##
## Nota de implementacion (Godot 4.7.2): OS.get_video_adapter_name() fue removido
## del API. Por eso la deteccion NO puede leer el nombre de GPU en produccion; el
## helper es_gpu_blacklist() existe y esta testeado, pero se aplica solo si el caller
## inyecta el nombre (p.ej. desde un override de configuracion). En produccion la
## cadena usa cpu/os/vram(fallback) y cae a "media".

const PERFILES_ORDEN := ["baja", "media", "alta"]
const GPU_BLACKLIST := [
	"Intel HD Graphics 4000",
	"Intel HD Graphics 5000",
	"Mali-T8",   # cubre Mali-T820/T830/T860/T880
]

## Perfil activo. Fallback conservador por defecto (nunca "alta").
var perfil: String = "media"

func _ready() -> void:
	recalcular()

## Recalcula el perfil activo.
## override: si no esta vacio y es valido, gana (equivalente a GameSettings.perfil_assets).
func recalcular(override: String = "") -> void:
	var p := ""
	if override != "":
		p = override
	else:
		# GameSettings es un autoload; se resuelve por ruta de nodo (no es global en compile-time).
		var gs = get_node_or_null("/root/GameSettings")
		if gs != null and "perfil_assets" in gs:
			var v = gs.perfil_assets
			if typeof(v) == TYPE_STRING and v != "" and v != "auto":
				p = v
	if p != "":
		perfil = validar_perfil(p)
	else:
		perfil = detectar_auto()

## Normaliza un perfil cualquiera al conjunto valido; desconocido -> "media".
func validar_perfil(p: String) -> String:
	if PERFILES_ORDEN.has(p):
		return p
	return "media"

## Deteccion automatica de hardware.
## Parametros inyectables para test (si estan vacios/negativos se leen de OS en prod):
##   cpu_name, os_name, gpu_name, vram_gb.
func detectar_auto(cpu_name: String = "", gpu_name: String = "", os_name: String = "", vram_gb: float = -1.0) -> String:
	if cpu_name == "":
		cpu_name = OS.get_processor_name()
	if os_name == "":
		os_name = OS.get_name()
	# gpu_name: no hay API de nombre de GPU en Godot 4.7.2; caller puede inyectarlo.
	if es_mobile(os_name):
		return "baja"
	if "Apple M" in cpu_name:
		return "media"
	if es_gpu_blacklist(gpu_name):
		return "baja"
	if vram_gb >= 0.0:
		var c := clasificar_vram(vram_gb)
		if c != "":
			return c
	return "media"

func es_mobile(os_name: String = "") -> bool:
	if os_name == "":
		os_name = OS.get_name()
	return os_name == "Android" or os_name == "iOS"

## True si el nombre de GPU esta en la lista negra. Helper puro (testeado).
func es_gpu_blacklist(gpu_name: String) -> bool:
	for b in GPU_BLACKLIST:
		if b in gpu_name:
			return true
	return false

## Clasifica por VRAM reportada. Devuelve "" si no se puede decidir.
func clasificar_vram(vram_gb: float) -> String:
	if vram_gb < 0.0:
		return ""
	if vram_gb < 2.0:
		return "baja"
	if vram_gb <= 4.0:
		return "media"
	return "alta"

## Godot 4 no expone VRAM directamente. Best-effort: devuelve -1 (desconocido)
## para que la cadena caiga al fallback conservador "media".
func detectar_vram_gb() -> float:
	return -1.0

## Resuelve la ruta res:// del GLB bajo el perfil activo a partir de una ruta
## base (M166 F1, capa B). Acepta tres formas de entrada:
##   - stem puro: "25-Ruinas-Templos_cofre_ancestral"
##   - ruta base con extension: "45-Arte3D_totem_isla.glb"
##   - ruta completa legacy: "res://assets/3d/alta/foo.glb"
## En cualquier caso extrae el stem y lo perfina.
## Si variantes_disponibles no esta vacio y no contiene el perfil activo,
## degrada al perfil mas alto disponible y avisa en Debug.
func ruta(ruta_base: String, variantes_disponibles: PackedStringArray = PackedStringArray()) -> String:
	var stem := _stem_de_ruta(ruta_base)
	var perfil_usado := perfil
	if not variantes_disponibles.is_empty() and not variantes_disponibles.has(perfil):
		perfil_usado = perfil_mas_alto_disponible(variantes_disponibles)
		if OS.is_debug_build():
			push_warning("AssetProfile: perfil '%s' no disponible para '%s'; degradado a '%s'." % [perfil, stem, perfil_usado])
	return "res://assets/3d/%s/%s.glb" % [perfil_usado, stem]

## Extrae el stem del archivo de una ruta (con o sin directorio, con o sin
## .glb). "res://assets/3d/alta/45-Arte3D_totem_isla.glb" -> "45-Arte3D_totem_isla";
## "45-Arte3D_totem_isla.glb" -> "45-Arte3D_totem_isla"; "foo" -> "foo".
func _stem_de_ruta(ruta_base: String) -> String:
	var s := ruta_base.strip_edges()
	var slash := s.rfind("/")
	if slash >= 0:
		s = s.substr(slash + 1)
	if s.ends_with(".glb"):
		s = s.substr(0, s.length() - 4)
	return s

## Perfil mas alto (alta > media > baja) presente en variantes; "media" si vacio.
func perfil_mas_alto_disponible(variantes: PackedStringArray) -> String:
	for i in range(PERFILES_ORDEN.size() - 1, -1, -1):
		if variantes.has(PERFILES_ORDEN[i]):
			return PERFILES_ORDEN[i]
	return "media"

## Carga la PackedScene del modelo bajo el perfil activo (o degradado).
func cargar(modelo_id: String, variantes_disponibles: PackedStringArray = PackedStringArray()) -> PackedScene:
	var r := ruta(modelo_id, variantes_disponibles)
	var scn := load(r) as PackedScene
	return scn

## Cambia el perfil en caliente (menu de opciones). Normaliza siempre.
func cambiar_perfil(p: String) -> void:
	perfil = validar_perfil(p)

## Hook extensible: un asset debe ir por MultiMeshInstance3D (ver diseno §5).
## Por defecto false; el caller (catalogo M159) decide segun el asset.
func debe_usar_multimesh(_modelo_id: String) -> bool:
	return false
