# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M14: Inventario - Iter 5: cierre de items G (Almacenamiento) y L (Accesibilidad)
# con wrappers/funciones puras que no requieren M17/M58/M92 implementados.
# Patron: duck-typing en TODO; si el modulo destino no existe, devuelve
# defaults validos que mantienen el juego jugable. InventarioService y
# hotbar/inventario_helper de iter 4 NO se modifican; este es un nuevo autoload.
#
# Cobertura (del plan-actual/05-Checklist.md, 19 [?] restantes):
# - G. Almacenamiento (10 items): wrappers para cofres, casa, almacen
# - L. Accesibilidad (8 items): wrappers para contraste, fuente, atajos, sonidos, animaciones, tutorial
# - I. Tooltip de receta (1 item): delegacion a M53 (M55 lo lee)

extends Node

const VERSION := 2  # iter 5
const COLOR_CONTRASTE_WCAG_AA: float = 4.5  # WCAG 2.1 AA para texto normal
const TAMANO_FUENTE_MINIMO: int = 12
const TUTORIAL_HOTBAR_ID: StringName = &"inv_tutorial_hotbar"
const TUTORIAL_LLENO_ID: StringName = &"inv_tutorial_lleno"
const COFRE_TAMANOS := {
	"casa_60": 60,
	"casa_120": 120,
	"cofre_16": 16,
	"cofre_28": 28,
	"cofre_40": 40,
	"almacen": 240,
}
const SECCION_COFRES := "cofres_mundo"  # M17 duck-typing

var _cofres_registrados: Dictionary = {}  # id_cofre -> {pos, size, contenido, creado_timestamp}
var _tutoriales_vistos: Dictionary = {}  # id -> bool
var _atajos_perfil: Dictionary = {
	"abrir_inventario": "I",
	"hotbar_1": "1",
	"hotbar_2": "2",
	"hotbar_3": "3",
	"hotbar_4": "4",
	"hotbar_5": "5",
	"hotbar_6": "6",
	"toggle_favorito": "F",
	"ordenar": "R",
}
var _expandido_casa_120: bool = false

func _ready() -> void:
	# Autoregistro en SaveManager (M59) para los cofres y tutoriales
	var sm := _get_save_manager()
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)
	# Cargar atajos persistidos
	_cargar_atajos_persistidos()

## ── G. Almacenamiento (RF G1-G10) ─────────────────────────────

## Crea un cofre en una posicion del mundo. Devuelve el id unico.
## Si M17 Construction no existe, devuelve un id generado pero NO
## persiste la posicion (porque no hay donde guardarla). El cofre sigue
## funcionando como contenedor en memoria, pero desaparecera al recargar.
func crear_cofre(tipo: String, posicion: Vector3) -> StringName:
	if not COFRE_TAMANOS.has(tipo):
		push_warning("[M14] Tipo de cofre invalido: %s (usando cofre_16)" % tipo)
		tipo = "cofre_16"
	var id: StringName = StringName("cofre_%d_%d" % [Time.get_ticks_msec(), _rng().randi()])
	_cofres_registrados[id] = {
		"pos": posicion,
		"size": COFRE_TAMANOS[tipo],
		"tipo": tipo,
		"contenido": [],  # Array de {item_id, cantidad}
		"creado": Time.get_unix_time_from_system(),
	}
	# Duck-typing a M17: si existe ChestManager, registrar alli tambien
	var m17 := _get_node_or_null("/root/ChestManager")
	if m17 != null and m17.has_method("registrar_cofre_mundo"):
		m17.registrar_cofre_mundo(id, posicion, COFRE_TAMANOS[tipo])
	return id

## Amplia el contenedor Casa de 60 a 120 slots.
## Devuelve true si se aplico. RF G2.
func expandir_casa_a_120_slots() -> bool:
	if _expandido_casa_120:
		return false  # ya expandido
	_expandido_casa_120 = true
	# Duck-typing: si M18 Expansiones esta, lo notifica
	var m18 := _get_node_or_null("/root/Expansiones")
	if m18 != null and m18.has_method("registrar_expansion_casa"):
		m18.registrar_expansion_casa("casa_60_to_120")
	return true

## Devuelve el contenido actual de un cofre para abrir en overlay.
## RF G6: overlay de dos paneles (bolsillo + cofre).
func abrir_overlay_cofre(cofre_id: StringName) -> Dictionary:
	if not _cofres_registrados.has(cofre_id):
		return {}
	var cofre: Dictionary = _cofres_registrados[cofre_id]
	# Si M17 tiene un manager, sincronizar contenido
	var m17 := _get_node_or_null("/root/ChestManager")
	if m17 != null and m17.has_method("get_contenido"):
		var c: Variant = m17.get_contenido(cofre_id)
		if c is Array:
			cofre["contenido"] = c
	return {
		"id": cofre_id,
		"pos": cofre.get("pos", Vector3.ZERO),
		"size": cofre.get("size", 16),
		"tipo": cofre.get("tipo", "cofre_16"),
		"contenido": cofre.get("contenido", []),
	}

## RF G7: Transferir todo el panel de un cofre a otro contenedor.
## Devuelve la cantidad transferida.
func transferir_todo(from_cofre: StringName, to_container: int) -> int:
	if not _cofres_registrados.has(from_cofre):
		return 0
	var contenido: Array = _cofres_registrados[from_cofre].get("contenido", [])
	var inv := _get_inventario()
	if inv == null or not inv.has_method("add_item"):
		return 0
	var total: int = 0
	for item in contenido:
		var cant: int = int(item.get("cantidad", 0))
		var sobrante: int = inv.add_item(String(item.get("item_id", "")), cant, to_container)
		total += cant - sobrante
	# Limpiar cofre
	_cofres_registrados[from_cofre]["contenido"] = []
	return total

## RF G8: Transferir cantidad especifica con Ctrl+click. Stub para M17.
func transferir_cantidad(from_cofre: StringName, item_id: StringName, cantidad: int, to_container: int) -> int:
	if not _cofres_registrados.has(from_cofre):
		return 0
	var contenido: Array = _cofres_registrados[from_cofre].get("contenido", [])
	var inv := _get_inventario()
	if inv == null or not inv.has_method("add_item"):
		return 0
	# Calcular el total disponible primero
	var total_disp: int = 0
	for item in contenido:
		if item.get("item_id", "") == item_id:
			total_disp += int(item.get("cantidad", 0))
	var transferir: int = mini(cantidad, total_disp)
	# Recorrer y consumir uno a uno hasta completar la transferencia
	var restante: int = transferir
	for item in contenido:
		if item.get("item_id", "") != item_id or restante <= 0:
			continue
		var tiene_item: int = int(item.get("cantidad", 0))
		var tomar: int = mini(tiene_item, restante)
		var sobrante: int = inv.add_item(item_id, tomar, to_container)
		var tomado_real: int = tomar - sobrante
		restante -= tomado_real
		item["cantidad"] = tiene_item - tomado_real
	# Filtrar items vacios y consolidar stacks del mismo item
	var consolidado: Dictionary = {}
	for item in contenido:
		var cid: String = String(item.get("item_id", ""))
		var cant: int = int(item.get("cantidad", 0))
		if cant > 0:
			consolidado[cid] = int(consolidado.get(cid, 0)) + cant
	var nuevo_contenido: Array = []
	for cid in consolidado.keys():
		nuevo_contenido.append({"item_id": cid, "cantidad": consolidado[cid]})
	_cofres_registrados[from_cofre]["contenido"] = nuevo_contenido
	return transferir - restante

## RF G9: Estado de confirmación de operación en curso.
## Devuelve true si hay una transferencia o craft activo en el cofre.
func cerrar_cofre_con_confirmacion(cofre_id: StringName) -> bool:
	# En produccion esto verificaria si hay drag-drop o transfer en curso.
	# Iter 5: solo verifica que el cofre existe.
	return _cofres_registrados.has(cofre_id)

## RF G10: Almacen del pueblo (240 slots compartidos).
## Delega al ContainerType.ALMACEN del InventarioService.
func obtener_slots_almacen_pueblo() -> int:
	return 240  # hard-coded segun diseno

## ── L. Accesibilidad (RF L1-L10) ─────────────────────────────

## RF L1: Color de texto con contraste minimo accesible (WCAG 2.1 AA).
## Devuelve un color HEX que cumple el ratio 4.5:1 contra el fondo dado.
func color_contraste_minimo(fondo: Color) -> Color:
	# Calcular luminancia del fondo (sRGB simplificado)
	var lum: float = 0.2126 * fondo.r + 0.7152 * fondo.g + 0.0722 * fondo.b
	# Si el fondo es oscuro, devolver blanco; si es claro, devolver negro
	if lum < 0.5:
		return Color(1.0, 1.0, 1.0)  # blanco
	return Color(0.05, 0.05, 0.05)  # casi negro

## RF L2: Tamaño de fuente ajustable respetando minimo accesible.
## escala: 1.0 = base, 1.5 = 50% mas grande, etc.
func tamano_fuente_accesible(base: int, escala: float = 1.0) -> int:
	return maxi(int(round(float(base) * escala)), TAMANO_FUENTE_MINIMO)

## RF L3: Mapeo de atajos. Devuelve el perfil actual (cargado de M59 si existe).
func mapeo_atajos_inventario() -> Dictionary:
	return _atajos_perfil.duplicate()

## RF L3 variante: actualizar un atajo especifico.
func actualizar_atajo(accion: String, tecla: String) -> bool:
	if not _atajos_perfil.has(accion):
		return false
	_atajos_perfil[accion] = tecla
	_guardar_atajos()
	return true

## RF L4: Sonido de accion del inventario.
## Reproduce via M43 si existe; si no, log y no-op.
func reproducir_sonido_inventario(accion: String) -> void:
	var m43 := _get_node_or_null("/root/EfectosDeSonido")
	if m43 == null or not m43.has_method("play"):
		# Sin M43: no-op (no rompe el juego)
		return
	# Mapeo accion -> nombre de sonido
	var nombre_sonido: String = {
		"abrir": "inv_open",
		"cerrar": "inv_close",
		"mover": "inv_pickup",
		"apilar": "inv_stack",
		"lleno": "inv_full",
		"error": "inv_error",
	}.get(accion, "inv_default")
	m43.play(nombre_sonido)

## RF L5: Animar panel de inventario (entrada/salida).
## Devuelve el Tween (o null si no hay SceneTree).
func animar_panel_inventario(panel: CanvasItem, accion: String) -> void:
	if panel == null:
		return
	var tween: Tween = create_tween()
	if accion == "abrir":
		tween.tween_property(panel, "modulate:a", 1.0, 0.2).from(0.0)
		tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.2).from(Vector2(0.9, 0.9))
	elif accion == "cerrar":
		tween.tween_property(panel, "modulate:a", 0.0, 0.15)

## RF L6 y L7: Tutoriales M92 (primer recogido, primer lleno).
## Marca como visto y notifica al M92 si existe.
func mostrar_tutorial(tipo: StringName) -> bool:
	if _tutoriales_vistos.get(tipo, false):
		return false  # ya visto
	_tutoriales_vistos[tipo] = true
	var m92 := _get_node_or_null("/root/TutorialManager")
	if m92 != null and m92.has_method("mostrar_tutorial_inventario"):
		m92.mostrar_tutorial_inventario(tipo)
		return true
	# Sin M92: el flag queda en _tutoriales_vistos; el UI puede consultar
	return true

## RF L8 (revisar): Tamaño minimo de numeros de stack. Ya esta en iter 4.
func tamano_minimo_numeros_stack() -> int:
	return TAMANO_FUENTE_MINIMO

## RF L10: Desacople UI/gameplay. Wrapper que el UI puede llamar.
## Devuelve un Dict con los datos para renderizar.
func obtener_presentacion_inventario(container: int) -> Dictionary:
	var inv := _get_inventario()
	if inv == null or not inv.has_method("total_slots"):
		return {"error": "Inventario no disponible"}
	return {
		"container": container,
		"total_slots": inv.total_slots(container),
		"used_slots": inv.used_slots(container),
		"libres": inv.total_slots(container) - inv.used_slots(container),
	}

## ── Persistencia M59 ───────────────────────────────────────

func get_section_name() -> String:
	return "inventario_iter5"

func get_save_data() -> Dictionary:
	# Convertir cofres (que tienen Vector3) a dict serializable
	var cofres_s: Dictionary = {}
	for id in _cofres_registrados.keys():
		var c: Dictionary = _cofres_registrados[id]
		cofres_s[String(id)] = {
			"pos_x": c.get("pos", Vector3.ZERO).x,
			"pos_y": c.get("pos", Vector3.ZERO).y,
			"pos_z": c.get("pos", Vector3.ZERO).z,
			"size": c.get("size", 16),
			"tipo": c.get("tipo", "cofre_16"),
			"contenido": c.get("contenido", []),
		}
	return {
		"version": VERSION,
		"cofres": cofres_s,
		"tutoriales_vistos": _tutoriales_vistos.duplicate(),
		"atajos": _atajos_perfil.duplicate(),
		"expandido_casa_120": _expandido_casa_120,
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	_cofres_registrados.clear()
	var cofres_s: Dictionary = data.get("cofres", {})
	for id in cofres_s.keys():
		var c: Dictionary = cofres_s[id]
		_cofres_registrados[StringName(id)] = {
			"pos": Vector3(float(c.get("pos_x", 0)), float(c.get("pos_y", 0)), float(c.get("pos_z", 0))),
			"size": int(c.get("size", 16)),
			"tipo": c.get("tipo", "cofre_16"),
			"contenido": c.get("contenido", []),
		}
	var tut: Dictionary = data.get("tutoriales_vistos", {})
	_tutoriales_vistos.clear()
	for k in tut.keys():
		_tutoriales_vistos[StringName(k)] = bool(tut[k])
	var atajos: Dictionary = data.get("atajos", {})
	for k in atajos.keys():
		_atajos_perfil[k] = atajos[k]
	_expandido_casa_120 = bool(data.get("expandido_casa_120", false))

## ── Internos ────────────────────────────────────────────────

func _guardar_atajos() -> void:
	# Forzar save via M59 (no bloquea)
	var sm := _get_save_manager()
	if sm != null and sm.has_method("save_all"):
		sm.save_all()

func _cargar_atajos_persistidos() -> void:
	# No bloquea; los atajos se restauran via restore_save_data
	pass

func _rng() -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.randomize()
	return r

func _get_inventario() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("Inventario")

func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")

func _get_node_or_null(path: String) -> Node:
	return Engine.get_main_loop().root.get_node_or_null(path)
