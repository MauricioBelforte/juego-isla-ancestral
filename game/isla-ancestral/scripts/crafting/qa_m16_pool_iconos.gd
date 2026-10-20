# -*- coding: utf-8 -*-
# QA M16 item 6: pool ligero de iconos de recetas (cache) — G-5.3-Flash-Agente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-I] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-I] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var svc = load("res://scripts/crafting/crafting_service.gd").new()
	svc.registra_en_save = false
	root.add_child(svc)
	await process_frame

	var ids: Array = svc._recetas.keys()
	_check(ids.size() > 0, "catálogo presente (%d recetas)" % ids.size(), "catálogo vacío")

	# Primera consulta: cachea todas (precarga).
	var icono0 = svc.icono_de_receta(String(ids[0]))
	await process_frame
	_check(svc._cache_iconos.size() >= ids.size(), "cache poblada al primer consumo (%d)" % svc._cache_iconos.size(), "cache incompleta")

	# Re-uso: segunda llamada devuelve LA MISMA instancia (hit, sin re-scan).
	var icono1 = svc.icono_de_receta(String(ids[0]))
	var misma: bool = (icono0 == icono1) or (icono0 == null and icono1 == null)
	_check(misma, "hit de cache: misma instancia repetida (icono o null consistente)", "instancias distintas")

	# Cache estable tras más consultas (sin crecimiento no acotado).
	var tamaño: int = svc._cache_iconos.size()
	for i in 10:
		svc.icono_de_receta(String(ids[i % ids.size()]))
	_check(svc._cache_iconos.size() == tamaño, "cache estable (sin crecimiento)", "creció a %d" % svc._cache_iconos.size())

	svc.queue_free()
	print("[QA-M16-I] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
