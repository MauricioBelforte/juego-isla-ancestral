# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M60 iter. 3 — RF3: provider de la sección "buildings" del save (M17/M18).
#
# Implementa el contrato ISaveProvider (M59) para construcciones y casas.
# La FUENTE de estado es PLUGGABLE por duck-typing: cualquier autoload o nodo
# que exponga
#
#     obtener_estructuras() -> Array          (obligatorio para aportar datos)
#     restaurar_estructuras(lista: Array) -> void   (opcional, para cargar)
#
# Si no hay fuente —M17 (Construcción) todavía no está implementado— el
# provider devuelve la sección con el default del schema y el restore es
# no-op. Así el guardado funciona desde hoy y M17 se enchufa sin tocar M60.
#
# Ventaja del diseño: hay UN solo provider por sección. M17 no necesita
# registrarse ni conocer M59: le basta exponer los dos métodos.
#
# Sin aliasing: get_save_data() construye un Dictionary nuevo en cada llamada
# (pasa el auditor scripts/saving/auditar_aliasing.gd).

class_name BuildingsSaveProvider
extends RefCounted

## Método que debe exponer la fuente para aportar su estado.
const METODO_LEER: String = "obtener_estructuras"
## Método opcional para restaurar el estado al cargar.
const METODO_RESTAURAR: String = "restaurar_estructuras"

func get_section_name() -> String:
	return EstructurasCodec.SECCION

## Busca la fuente en el árbol (autoloads incluidos) por duck-typing.
## Se re-evalúa en cada llamada a propósito: M17 puede registrarse después
## del boot y el provider lo encuentra sin reconexión.
func fuente() -> Object:
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return null
	for hijo in arbol.root.get_children():
		if hijo != null and is_instance_valid(hijo) and hijo.has_method(METODO_LEER):
			return hijo
	return null

## true si hay una fuente de construcciones activa (diagnóstico).
func tiene_fuente() -> bool:
	return fuente() != null

func get_save_data() -> Dictionary:
	var f := fuente()
	if f == null:
		return {"structures": []}
	var crudo: Variant = f.call(METODO_LEER)
	return EstructurasCodec.a_seccion(crudo)

func restore_save_data(data: Dictionary) -> void:
	var lista := EstructurasCodec.desde_seccion(data)
	var f := fuente()
	if f == null:
		return
	if not f.has_method(METODO_RESTAURAR):
		push_warning("[M60] La fuente de construcciones no expone %s(); no se restauran %d estructuras"
			% [METODO_RESTAURAR, lista.size()])
		return
	f.call(METODO_RESTAURAR, lista)
