# Modelo: deepseek-v4-flash-vision-exp (iter. 3) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 5)
# Plataforma: Kilo Code (iter. 3) · WorkBuddy (iter. 5)
# Fecha: 2026-09-02 (iter. 3) · 2026-09-13 (iter. 5)
#
# M52 iter 3: VfxFactory — parámetros y creación de GPUParticles3D desde el
# catálogo. `parametros(vfx)` es puro/testeable (headless safe); `crear()`
# instancia el nodo (solo en runtime de render, no en headless).
#
# M52 iter 5 (Log 882): `mesh` → `draw_pass_1` (bug REAL: `mesh` se eliminó en
# Godot 4.3 y el fallo abortaba en silencio → `crear()` devolvía null y no se
# instanciaba NINGÚN VFX con los tests en verde); + `nuevo_emisor()` (configura
# sin añadir al árbol, para el pool) y `redisparar()` (reuso determinista con
# `seed` fijada DESPUÉS de `restart()`, que la re-aleatoriza).

class_name VfxFactory
extends RefCounted

const RUTA_CATALOGO := "res://data/vfx/vfx_catalog.json"

## Devuelve el catálogo (Array de VFX) o [] si no existe.
static func cargar_catalogo() -> Array:
	if not FileAccess.file_exists(RUTA_CATALOGO):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("vfx")) == TYPE_ARRAY:
		return parsed.get("vfx")
	return []

## Parámetros normalizados de un VFX del catálogo (para configurar partículas).
static func parametros(vfx: Dictionary) -> Dictionary:
	return {
		"color": _color_desde_hex(str(vfx.get("color", "#FFFFFF"))),
		"cantidad": int(vfx.get("cantidad", 20)),
		"emision": float(vfx.get("emision", 0.5)),
		"tipo": str(vfx.get("tipo", "flotante")),
		"id": str(vfx.get("id", "")),
	}

static func crear(container: Node, vfx: Dictionary, position: Vector3 = Vector3.ZERO) -> Node:
	var gp := nuevo_emisor(vfx)
	gp.position = position
	container.add_child(gp)
	gp.emitting = true
	return gp

## Crea un emisor configurado SIN añadirlo al árbol (lo usa el pool, M52/T-027).
##
## ⚠️ Godot 4.3 eliminó `GPUParticles3D.mesh` → ahora es `draw_pass_1`.
## Asignar `mesh` aborta la función EN SILENCIO (el patrón de falso verde) y
## `crear()` devolvía null: el sistema de VFX no instanciaba NADA pese a que
## los 3 tests daban verde (solo probaban funciones puras). Ver Log 882.
static func nuevo_emisor(vfx: Dictionary) -> GPUParticles3D:
	var p := parametros(vfx)
	var gp := GPUParticles3D.new()
	gp.amount = int(p["cantidad"])
	gp.one_shot = true
	gp.explosiveness = 1.0
	gp.lifetime = maxf(0.2, float(p["emision"]))
	gp.draw_pass_1 = _quad()
	gp.process_material = _material(vfx)
	return gp

## Reconfigura y re-dispara un emisor ya creado (reuso del pool), fijando la
## semilla para que la emisión sea determinista (T-093).
##
## ⚠️ El orden importa: `restart()` **re-aleatoriza** `seed`. Poner la semilla
## ANTES de `restart()` la pierde (medido: 2694543342 → 2659173778). Hay que
## asignarla DESPUÉS de `restart()`.
static func redisparar(gp: GPUParticles3D, vfx: Dictionary, position: Vector3, semilla: int) -> void:
	var p := parametros(vfx)
	gp.amount = int(p["cantidad"])
	gp.lifetime = maxf(0.2, float(p["emision"]))
	gp.process_material = _material(vfx)
	gp.position = position
	gp.restart()
	gp.seed = semilla
	gp.emitting = true

static func _material(vfx: Dictionary) -> ParticleProcessMaterial:
	var p := parametros(vfx)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = float(p["emision"]) * 2.0
	mat.gravity = Vector3(0, -0.5, 0)
	mat.color = p["color"]
	return mat

static func _parametros_particula(vfx: Dictionary) -> Dictionary:
	var p := parametros(vfx)
	return {"cantidad": p["cantidad"], "material": _material(vfx)}

static func _quad() -> QuadMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.08, 0.08)
	return quad

static func _color_desde_hex(hex: String) -> Color:
	if hex.begins_with("#") and hex.length() == 7:
		var h := hex.substr(1)
		return Color(
			float(_hex_byte(h.substr(0, 2))) / 255.0,
			float(_hex_byte(h.substr(2, 2))) / 255.0,
			float(_hex_byte(h.substr(4, 2))) / 255.0)
	return Color.WHITE

static func _hex_byte(cad: String) -> int:
	var hex_digits := "0123456789abcdef"
	if cad.length() < 2:
		return 0
	var alto := hex_digits.find(cad.substr(0, 1).to_lower())
	var bajo := hex_digits.find(cad.substr(1, 1).to_lower())
	return (alto * 16 + bajo) if (alto >= 0 and bajo >= 0) else 0
