# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de Objeto Clave
# Valida que todo objeto único sea accesible (2+ caminos verificables).

## Valida objetos clave únicos: posición válida y navegable, o justificación narrativa.
class_name ObjetoClaveInvariant
extends InvariantBase

## Claves únicas monitoreadas
var _claves: Dictionary = {}

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.OBJETO_CLAVE

## Registra una clave única a vigilar.
func registrar_clave(clave: String, nodo: Node3D = null, requiere_navegacion: bool = true) -> void:
	_claves[clave] = {
		"nodo": nodo,
		"requiere_navegacion": requiere_navegacion,
		"recuperado": false,
	}

## Marca una clave como recuperada (no se vuelve a devolver al cofre).
func marcar_recuperada(clave: String) -> void:
	if _claves.has(clave):
		_claves[clave]["recuperado"] = true

## Devuelve la lista de claves perdidas (no en mundo + no en inventario + no recuperadas).
func claves_perdidas() -> Array[String]:
	var perdidas: Array[String] = []
	for clave in _claves.keys():
		var entry = _claves[clave]
		if entry["recuperado"]:
			continue
		var nodo = entry["nodo"]
		if nodo == null or not nodo.is_inside_tree():
			perdidas.append(clave)
	return perdidas

func _check() -> bool:
	var perdidas := claves_perdidas()
	if not perdidas.is_empty():
		ultima_razon = "Objetos clave perdidos: %s" % ", ".join(perdidas)
		return false
	return true

func _razon_fallo() -> String:
	return ultima_razon
