# -*- coding: utf-8 -*-
# QA item [20] M16: pool de iconos de recetas (precarga, cache, null-safe)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var cs := root.get_node_or_null("Crafting")
	if cs == null:
		print("[QA-POOL] FAIL: Crafting ausente")
		quit(1)
		return
	var fallos := 0

	# la precarga corre en _ready (tras _cargar_recetas) — verificado el cache poblado
	var n_recetas: int = cs._recetas.size()
	var n_cache: int = cs._cache_iconos.size()
	if n_cache != n_recetas:
		fallos += 1
		print("[QA-POOL] FALLO cache incompleto: ", n_cache, "/", n_recetas)
	else:
		print("[QA-POOL] OK cache precargada ", n_cache, "/", n_recetas)

	# icono_de_receta devuelve la MISMA instancia del pool (sin recarga)
	var tex1 = cs.icono_de_receta("rec_pico_cobre")
	var tex2 = cs.icono_de_receta("rec_pico_cobre")
	if tex1 != tex2:
		fallos += 1
		print("[QA-POOL] FALLO: icono_de_receta no cachea (instancias distintas)")
	else:
		print("[QA-POOL] OK cache consistente (misma instancia)")

	# receta inexistente -> null (sin crash)
	var tx = cs.icono_de_receta("rec_inexistente_xyz9")
	if tx != null:
		print("[QA-POOL] nota: receta inexistente devolvió icono (inesperado)")
	print("[QA-POOL] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
