# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M66 iter. 3: MisionInvariant FUNCIONAL (glm-5.3-flash).
# Mejoras sobre el núcleo ox-alpha (era un stub con _check() -> true):
#  - _check() detecta objetivos activos SIN fallback declarado → condición
#    imposible (diseño §2.4: informa a M66 vía señal).
#  - registrar_recompensa_entregada()/recompensa_ya_entregada(): recompensa
#    equivalente del fallback NO duplicada (checklist ítem "recompensa no
#    duplicada si el fallback se completó").
#  - al activarse un fallback, registra aviso en el diario (M55) — checklist
#    ítem "aviso en diario de misión al activar fallback".
class_name MisionInvariant
extends InvariantBase

## Registro de fallbacks declarados: objetivo_id -> alternativo_id
var _fallbacks: Dictionary = {}

## Misiones/objetivos en curso que deben validar: mision_id -> objetivo_id
var _objetivos_activos: Dictionary = {}

## Recompensas equivalentes ya entregadas (anti-duplicación §4.2)
var _recompensas_entregadas: Dictionary = {}


func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.MISION

func registrar_fallback(objetivo_id: String, alternativo_id: String) -> void:
	_fallbacks[objetivo_id] = alternativo_id

func registrar_objetivo(mision_id: String, objetivo_id: String) -> void:
	_objetivos_activos[mision_id] = objetivo_id

func tiene_fallback(objetivo_id: String) -> bool:
	return _fallbacks.has(objetivo_id)

## §2.4: true = todos los objetivos activos tienen ruta alternativa.
## Un objetivo activo SIN fallback = condición imposible → _check falla
## y el detector central informa (señal estado_invalido_detectado).
func _check() -> bool:
	for mision_id in _objetivos_activos:
		var objetivo: String = String(_objetivos_activos[mision_id])
		if objetivo == "":
			continue
		if not _fallbacks.has(objetivo):
			return false
	return true

func _razon_fallo() -> String:
	for mision_id in _objetivos_activos:
		var objetivo: String = String(_objetivos_activos[mision_id])
		if objetivo != "" and not _fallbacks.has(objetivo):
			return "Objetivo '%s' de '%s' sin ruta alternativa (condición imposible)" % [objetivo, mision_id]
	return "Misión con objetivo imposible"


## Fallback activado → registrar aviso en el diario (M55) + marcar recompensa
func activar_fallback(objetivo_id: String, mision_id: String) -> void:
	var alternativo: String = String(_fallbacks.get(objetivo_id, ""))
	if alternativo == "":
		return
	# MisionInvariant es RefCounted (no Node): accede al árbol vía Engine
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return
	var diary := arbol.root.get_node_or_null("/root/Diary")
	if diary != null and diary.has_method("registrar"):
		# Entrada en la categoría descubrimientos (aviso al jugador, cozy)
		diary.registrar("descubrimiento_fallback_" + mision_id, "descubrimientos")
	print("[M66] Fallback activado para '%s' de '%s' → '%s'" % [objetivo_id, mision_id, alternativo])


## Recompensa equivalente del fallback: registro anti-duplicado (§4.2 M37)
func registrar_recompensa_entregada(objetivo_id: String) -> void:
	_recompensas_entregadas[objetivo_id] = true


func recompensa_ya_entregada(objetivo_id: String) -> bool:
	return _recompensas_entregadas.has(objetivo_id)
